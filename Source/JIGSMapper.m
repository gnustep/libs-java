/* JIGSMapper.m - Mapping tables from/to java
   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: July 2000
   
   This file is part of the GNUstep Java Interface Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
   */ 

#include "JIGSMapper.h"
#include "java.lang.Object.h"
#include "GSJNI.h"
#include "JIGSProxy.h"
#include "NSJavaVirtualMachine.h"

/***
 *** Table mapping real objc objects to their java proxies 
 ***/
static NSMapTable* _JIGSProxiedObjcMap = NULL; 
static objc_mutex_t _JIGSProxiedObjcMapLock = NULL;

static inline jobject _JIGSMapperGetProxyFromProxiedObjc (id objc)
{
  jobject java;
  
  objc_mutex_lock (_JIGSProxiedObjcMapLock);
  java = NSMapGet (_JIGSProxiedObjcMap, objc);
  objc_mutex_unlock (_JIGSProxiedObjcMapLock);
  return java;
}

inline void _JIGSMapperAddJavaProxy (JNIEnv *env, id objc, jobject java)
{
  jobject weak_java;
  
  weak_java = (*env)->NewWeakGlobalRef (env, java);
  if (weak_java == NULL)
    {
      return;
    }  

  objc_mutex_lock (_JIGSProxiedObjcMapLock);
  NSMapInsert (_JIGSProxiedObjcMap, objc, weak_java);
  objc_mutex_unlock (_JIGSProxiedObjcMapLock);
}

inline void _JIGSMapperRemoveJavaProxy (JNIEnv *env, id objc)
{
  jobject weak_java;

  objc_mutex_lock (_JIGSProxiedObjcMapLock);

  weak_java = NSMapGet (_JIGSProxiedObjcMap, objc);
  (*env)->DeleteWeakGlobalRef (env, weak_java);

  NSMapRemove (_JIGSProxiedObjcMap, objc);

  objc_mutex_unlock (_JIGSProxiedObjcMapLock);
}

/***
 *** Table mapping real java objects to their objc proxies 
 ***/
static NSMapTable* _JIGSProxiedJavaMap = NULL; 
static objc_mutex_t _JIGSProxiedJavaMapLock = NULL;

/* To compare two java references, we need to use JNI's
   IsSameObject. */
BOOL _JIGSProxyJavaIsEqual (NSMapTable *table, const void *a, const void *b)
{
  JNIEnv *env = JIGSJNIEnv ();

  return (*env)->IsSameObject (env, (jobject)a, (jobject)b);
}

/* Hashcodes to speed up comparison */
unsigned int _JIGSProxyJavaHash (NSMapTable *table, const void *a)
{
  static jmethodID jid = NULL; // Cached
  JNIEnv *env = JIGSJNIEnv ();
  jint javaHashCode;

  if (jid == NULL)
    {
      jclass java_lang_Object = NULL;

      if((*env)->PushLocalFrame (env, 1) < 0)
	{
	  return 0;
	}

      java_lang_Object = (*env)->FindClass (env, "java/lang/Object");
      if (java_lang_Object == NULL)
	{
	  (*env)->PopLocalFrame (env, NULL);
	  return 0;
	}

      jid = (*env)->GetMethodID (env, java_lang_Object, "hashCode", "()I");
      if (jid == NULL)
	{
	  (*env)->PopLocalFrame (env, NULL);
	  return 0;
	}
    }
  
  // Get object's hashCode
  javaHashCode = (*env)->CallIntMethod (env, (jobject)a, jid);

  // We encode the jint hashcode into an 'unsigned int' hashcode.
  // While doing this, we mix it up because java hashcodes
  // are not good in the implementation I tried.
  // If you change this, be careful to check for performance.
  // Bad hash codes can make lookup in the table slow by an order 
  // of magnitude or more.
  {
    int i;
    unsigned int hash = 0;
    union divide 
      {
	jint number;
	jboolean parts[4]; // NB: jboolean is defined as unsigned 8bit
      };
    
    for (i = 0; i < 4; i++)
      {
	hash = (hash << 5) + hash + ((union divide)javaHashCode).parts[i];
      }
    return hash;
  }
}

static NSMapTableKeyCallBacks JIGSJavaReferenceMapKeyCallBacks;

static inline id _JIGSMapperGetProxyFromProxiedJava (jobject java)
{
  id objc;
  
  objc_mutex_lock (_JIGSProxiedJavaMapLock);
  objc = NSMapGet (_JIGSProxiedJavaMap, java);
  objc_mutex_unlock (_JIGSProxiedJavaMapLock);
  return objc;
}

inline void _JIGSMapperAddObjcProxy (JNIEnv *env, jobject java, id objc)
{
  objc_mutex_lock (_JIGSProxiedJavaMapLock);
  NSMapInsert (_JIGSProxiedJavaMap, java, objc);
  objc_mutex_unlock (_JIGSProxiedJavaMapLock);
}

inline void _JIGSMapperRemoveObjcProxy (JNIEnv* env, jobject java)
{
  objc_mutex_lock (_JIGSProxiedJavaMapLock);
  NSMapRemove (_JIGSProxiedJavaMap, java);
  objc_mutex_unlock (_JIGSProxiedJavaMapLock);
}

/***
 *** Table mapping GNUstep classes to the corresponding java proxy classes 
 ***/

/* 
 * It maps a Class to a jclass reference, as in a pointer to the
 * NSObject class mapped to a jclass reference to gnu/gnustep/base/NSObject 
 */
static NSMapTable* _JIGSProxiedObjcClassMap = NULL;
static objc_mutex_t _JIGSProxiedObjcClassMapLock = NULL;

/* We only insert in the table, never remove */
void JIGSRegisterJavaProxyClass (JNIEnv *env, NSString *fullJavaClassName, 
				 NSString *objcClassName)
{
  jclass javaClass;
  Class objcClass;
  NSAutoreleasePool *pool = [NSAutoreleasePool new]; 

  fullJavaClassName = GSJNI_ConvertJavaClassNameToJNI (fullJavaClassName);
  javaClass = GSJNI_NewClassCache (env, [fullJavaClassName cString]);
  if (javaClass == NULL)
    {
      NSLog (@"Could not find java proxy class %@ for class %@", 
	     fullJavaClassName, objcClassName);
      RELEASE (pool);
      return;
    }
  objcClass = NSClassFromString (objcClassName);
  if (objcClass == Nil)
    {
      NSLog (@"Could not find objc class %@ proxied by java class %@", 
	     objcClassName, fullJavaClassName);
      RELEASE (pool);
      return;
    }

  objc_mutex_lock (_JIGSProxiedObjcClassMapLock);
  NSMapInsert (_JIGSProxiedObjcClassMap, objcClass, javaClass);
  objc_mutex_unlock (_JIGSProxiedObjcClassMapLock);
  RELEASE (pool);
}

inline static Class _JIGSFirstJavaProxySuperClass (JNIEnv *env, NSString *className)
{
  NSString *shortClassName;
  Class class;

  objc_mutex_lock (_JIGSProxiedObjcClassMapLock); 

  while (1)
    {
      shortClassName = GSJNI_ShortClassNameFromLongClassName (className);
      class = NSClassFromString (shortClassName);

      if (class == Nil)
	{
	  className = GSJNI_SuperclassNameFromClassName (env, className);
	  if (className == nil)
	    {
	      class = Nil;
	      NSLog (@"Could not find a real objective-C class for class %@", 
		     className);
	      break;
	    }
	}
      else
	{
	  if (NSMapGet (_JIGSProxiedObjcClassMap, class) != NULL)
	    {
	      break;
	    }
	  className = NSStringFromClass (class_get_super_class (class));
	}
    }

  objc_mutex_unlock (_JIGSProxiedObjcClassMapLock);
  return class;
}

Class JIGSClassFromThisClass (JNIEnv *env, jclass class)
{
  NSString *className;

  className = GSJNI_NSStringFromJClass (env, class);
  return _JIGSFirstJavaProxySuperClass (env, className);
}

Class _JIGSAllocClassForThis (JNIEnv *env, jobject this)
{
  NSString *className;
  Class class;

  className = GSJNI_NSStringFromClassOfObject (env, this); 
  class = _JIGSFirstJavaProxySuperClass (env, className);
  return class;
}

// Cache used in the lookup functions
static jclass gnu_gnustep_base_NSObject = NULL;
static jfieldID fidRealObject = NULL;
static jclass java_lang_String = NULL;
static Class java_lang_Object = Nil;
static Class nsstring = Nil;

/***
 *** Functions
 ***/

void _JIGSMapperInitialize (JNIEnv *env)
{
  if (gnu_gnustep_base_NSObject != NULL)
    return;

  // Create the maps 
  _JIGSProxiedObjcMap = NSCreateMapTable (NSNonOwnedPointerMapKeyCallBacks, 
					  NSNonOwnedPointerMapValueCallBacks, 
					  20);
  _JIGSProxiedObjcMapLock = objc_mutex_allocate ();
  
  
  JIGSJavaReferenceMapKeyCallBacks = NSNonOwnedPointerMapKeyCallBacks;
  JIGSJavaReferenceMapKeyCallBacks.isEqual = _JIGSProxyJavaIsEqual;
  JIGSJavaReferenceMapKeyCallBacks.hash = _JIGSProxyJavaHash;
  
  _JIGSProxiedJavaMap = NSCreateMapTable (JIGSJavaReferenceMapKeyCallBacks, 
					  NSNonOwnedPointerMapValueCallBacks, 
					  20);
  _JIGSProxiedJavaMapLock = objc_mutex_allocate ();
  
  _JIGSProxiedObjcClassMap 
    = NSCreateMapTable (NSNonOwnedPointerMapKeyCallBacks, 
			NSNonOwnedPointerMapValueCallBacks, 
			20);
  _JIGSProxiedObjcClassMapLock = objc_mutex_allocate ();
  
  gnu_gnustep_base_NSObject = GSJNI_NewClassCache 
    (env, "gnu/gnustep/base/NSObject");
  
  if (gnu_gnustep_base_NSObject == NULL)
    {
      NSLog (@"Could not get a reference to gnu/gnustep/base/NSObject");
      // Exception thrown
      return;
    }

  JIGSRegisterJavaProxyClass (env, @"gnu.gnustep.base.NSObject", @"NSObject");
  
  fidRealObject = (*env)->GetFieldID (env, gnu_gnustep_base_NSObject, 
				      "realObject", "J");
  if (fidRealObject == 0) 
    {
      NSLog (@"Could not get fid of realObject");
      // Exception thrown	  
      return;
    }
  
  java_lang_Object = NSClassFromString (@"java.lang.Object");
  java_lang_String = GSJNI_NewClassCache (env, "java/lang/String");
  if (java_lang_String == NULL)
    {
      NSLog (@"Could not get reference to java/lang/String");
      // Exception thrown
      return; 
    }
  nsstring = NSClassFromString (@"NSString");
}

/*
 * Gets the best proxy class for objcClass. 
 * This is the java proxy class for that class, if it exists; 
 * or the java proxy class of the superclass, if it exists; 
 * or the java proxy class of the supersuperclas, if it exists; 
 * etc.
 * 
 * Return NULL if the class could not be found.
 * 
 */
static inline jclass _JIGSMapperGetBestJavaProxyClass (Class objcClass)
{
  jclass result = NULL;
  
  objc_mutex_lock (_JIGSProxiedObjcClassMapLock); 
  while (1)
    {
      result = NSMapGet (_JIGSProxiedObjcClassMap, objcClass);
      if (result != NULL) 
	{
	  break;
	}

      objcClass = class_get_super_class (objcClass);
      if (objcClass == Nil)
	{
	  result = NULL;
	  break;
	}  
    }
  objc_mutex_unlock (_JIGSProxiedObjcClassMapLock);
  return result;
}

id JIGSCreateNewObjcProxy (JNIEnv *env, jobject java)
{
  NSString *className;
  id objc;
  Class proxyClass;
  jobject java_global_ref;

  className = GSJNI_NSStringFromClassOfObject (env, java);

  // A. Create the class for the objc proxy if needed
  JIGSRegisterJavaClass (env, className);
  
  // B. Create the objc proxy of that class
  proxyClass = NSClassFromString (className);
  if (className == nil)
    {
      // FIXME - what to do here ?
      NSLog (@"Could not create proxy class");
      return nil;
    }
  objc = AUTORELEASE ([proxyClass alloc]);

  // C. Set the pointer of the proxy to the real java object
  java_global_ref = (*env)->NewGlobalRef (env, java);
  if (java_global_ref == NULL)
    {
      // Exception Thrown
      return nil;
    }

  ((_java_lang_Object *)objc)->realObject = java_global_ref;

  // D. Insert the (real object, proxy object) in the table
  _JIGSMapperAddObjcProxy (env, java_global_ref, objc);

  // E. Return it
  return objc;
}

jobject JIGSCreateNewJavaProxy (JNIEnv *env, id object)
{
  Class objectClass;
  jclass javaClass;
  jobject newProxy;

  objectClass = [object class];
  javaClass = _JIGSMapperGetBestJavaProxyClass (objectClass);
  
  if (javaClass == NULL)
    {
      // This should never happen. 
      [NSException raise: @"JIGSMapperException"
		   format: @"Could not find a suitable proxy for class %@", 
		   objectClass];
    }

  newProxy = (*env)->AllocObject (env, javaClass);
  
  if (newProxy == NULL)
    {
      // Oh oh - something big went wrong - do something
      return NULL;
    }
  
  (*env)->SetLongField (env, newProxy, fidRealObject, 
			JIGS_ID_TO_JLONG (object));

  _JIGSMapperAddJavaProxy (env, object, newProxy);

  return newProxy;
}

// NB: This method could return a global (for objects which are in map
// tables) or a local (eg for strings) reference; in any case, you are
// not responsible for freeing the reference so you should not worry.
jobject JIGSJobjectFromId (JNIEnv *env, id object)
{
  // Return object
  jobject ret;

  // nil
  if (object == nil)
    return NULL;
  
  // java.lang.Object
  if ([object isKindOf: java_lang_Object])
    {
      return ((_java_lang_Object *)object)->realObject;
    }
  
  // NSString 
  if ([object isKindOf: nsstring])
    {
      return GSJNI_JStringFromNSString (env, object);
    }

  // NSException perhaps ?
  
  // Something else - check if it already proxied
  ret = _JIGSMapperGetProxyFromProxiedObjc (object);
  if (ret != NULL)
    {
      return ret;
    }

  return JIGSCreateNewJavaProxy (env, object);
}

id JIGSIdFromJobject (JNIEnv *env, jobject object)
{
  // Return object
  id ret;

  // NULL
  if (object == NULL)
    {
      return nil;
    }
  
  // gnu.gnustep.NSObject
  if ((*env)->IsInstanceOf (env, object, gnu_gnustep_base_NSObject) == YES)
    {
      return JIGS_JLONG_TO_ID((*env)->GetLongField (env, object, 
						    fidRealObject));
    }  
  
  // java.lang.String
  if ((*env)->IsInstanceOf (env, object, java_lang_String) == YES)
    {
      return GSJNI_NSStringFromJString (env, object);
    }

  // Something else - check if it is already proxied
  ret = _JIGSMapperGetProxyFromProxiedJava (object);
  if (ret != nil)
    {
      return ret;
    }

  // Otherwise, create a proxy
  return JIGSCreateNewObjcProxy (env, object);
}

inline id JIGSIdFromThis (JNIEnv *env, jobject this)
{
  return JIGS_JLONG_TO_ID((*env)->GetLongField (env, this, fidRealObject));
}

