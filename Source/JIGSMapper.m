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
#include <objc/Object.h>

/***
 *** Table mapping real objc objects to their java proxies 
 ***/
static NSMapTable* _JIGSProxiedObjcMap = NULL; 
static objc_mutex_t _JIGSProxiedObjcMapLock = NULL;

static inline jobject _JIGSMapperGetProxyFromProxiedObjc (JNIEnv *env, id objc)
{
  jobject java;
  
  objc_mutex_lock (_JIGSProxiedObjcMapLock);
  java = NSMapGet (_JIGSProxiedObjcMap, objc);
  if (java != NULL)
    {
      /*
       * The map only contains weak references, so we must create a
       * local reference for the object before unlocking the map to
       * prevent the jobject being garbage collected by another thread
       * before we have finished using it.
       *
       * Creating a new local reference to null returns NULL.
       * If this happens, the java object has been garbage collected
       * but the entry has not been removed from the map.
       * We don't care about that because the other thread will get
       * round to removing the entry when we unlock the table.
       */
      java = (*env)->NewLocalRef (env, java);
    }
  objc_mutex_unlock (_JIGSProxiedObjcMapLock);
  return java;
}

void _JIGSMapperAddJavaProxy (JNIEnv *env, id objc, jobject java)
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

/* Warning - the following might be called by finalize without an
   autoreleasepool in place and without the ObjC runtime knowing about
   the current thread ... you can't execute any ObjC code in here.  */
void _JIGSMapperRemoveJavaProxy (JNIEnv *env, id objc)
{
  jobject weak_java;

  objc_mutex_lock (_JIGSProxiedObjcMapLock);

  weak_java = NSMapGet (_JIGSProxiedObjcMap, objc);
  NSMapRemove (_JIGSProxiedObjcMap, objc);

  objc_mutex_unlock (_JIGSProxiedObjcMapLock);

  (*env)->DeleteWeakGlobalRef (env, weak_java); 
}

/***
 *** Table mapping real java objects to their objc proxies 
 ***/
static NSMapTable* _JIGSProxiedJavaMap = NULL; 
static objc_mutex_t _JIGSProxiedJavaMapLock = NULL;

/* To compare two java references, we need to use JNI's IsSameObject.  */
BOOL _JIGSProxyJavaIsEqual (NSMapTable *table, const void *a, const void *b)
{
  JNIEnv *env = JIGSJNIEnv ();
  return (*env)->IsSameObject (env, (jobject)a, (jobject)b);
}

/* Unfortunately, to get a working hash of a jobject to compare it
 * with other jobjects, the only way is to perform a JNI
 * cross-language call to the Java -hashCode method of the object a
 * ... which is unbeliveliably slow ...
 *
 * So we are in the paradoxical situation that computing the hash
 * takes much more time than comparing the keys directly ... 
 *
 * As a result, we have to disable hashing, and always compare all
 * keys directly.
 *
 * A solution would be for JNI to provide a hash function for
 * jobjects.  */

unsigned int _JIGSProxyJavaHash (NSMapTable *table, const void *a)
{
  return 1;
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

void _JIGSMapperAddObjcProxy (JNIEnv *env, jobject java, id objc)
{
  objc_mutex_lock (_JIGSProxiedJavaMapLock);
  NSMapInsert (_JIGSProxiedJavaMap, java, objc);
  objc_mutex_unlock (_JIGSProxiedJavaMapLock);
}

void _JIGSMapperRemoveObjcProxy (JNIEnv* env, jobject java)
{
  objc_mutex_lock (_JIGSProxiedJavaMapLock);
  NSMapRemove (_JIGSProxiedJavaMap, java);
  objc_mutex_unlock (_JIGSProxiedJavaMapLock);
}

/***
 *** Table mapping GNUstep classes to the corresponding java proxy classes 
 ***/

/* A node holding an ObjC class <--> Java class mapping.  For example,
   it maps a jclass reference to gnu/gnustep/base/NSObject to a pointer
   to the NSObject class, and viceversa.  
*/
typedef struct _JIGSClassNode_
{

  /* Pointer to next entry on the list.  NULL indicates end of list.  */
  struct _JIGSClassNode_ *next;

  jclass javaClass; /* The Java class.  */
  Class objcClass;  /* The ObjC class.  */
  /* store the class name as well ? */
  
} *_JIGSClassMap;


/* The table itself.  */
static _JIGSClassMap _JIGSProxiedObjCClassMap = NULL;

/* A lock protecting the class from multiple concurrent writings.  We
   can read thread-safe without locks as we assume pointer
   assignment/comparison to be an atomic operation.  We also perform
   the minimal possible number of JNI calls when looking up stuff in
   the table.  */
static objc_mutex_t _JIGSProxiedObjCClassMapWriteLock = NULL;

/* We only insert in the table, never remove.  */
static inline void _JIGSClassMapInsert (jclass java, Class objc)
{
  _JIGSClassMap new = objc_malloc (sizeof (struct _JIGSClassNode_));

  new->javaClass = java;
  new->objcClass = objc;
  new->next = NULL;
  
  objc_mutex_lock (_JIGSProxiedObjCClassMapWriteLock);

  if (_JIGSProxiedObjCClassMap == NULL)
    {
      _JIGSProxiedObjCClassMap = new;
    }
  else
    {
      /* Add new classes at the end so the more fundamental remain at
	 the beginning.  */
      _JIGSClassMap iter = _JIGSProxiedObjCClassMap;
      while (iter->next != NULL)
	{
	  iter = iter->next;
	}
      iter->next = new;
    }

  objc_mutex_unlock (_JIGSProxiedObjCClassMapWriteLock);
}


/* Return Nil if it can't find the class.  */
static Class _JIGSClassMapGetObjCClassFromJavaClass (JNIEnv *env, 
						         jclass java)

{
  _JIGSClassMap iter = _JIGSProxiedObjCClassMap;
  while (iter != NULL)
    {
      if ((*env)->IsSameObject (env, java, iter->javaClass))
	{
	  return iter->objcClass;
	}
      iter = iter->next;
    }
  return Nil;
}

/* Return NULL if it can't find the class.  */
static jclass _JIGSClassMapGetJavaClassFromObjCClass (Class objc)
{
  _JIGSClassMap iter = _JIGSProxiedObjCClassMap;
  while (iter != NULL)
    {
      if (objc == iter->objcClass)
	{
	  return iter->javaClass;
	}
      iter = iter->next;
    }
  return NULL;
}


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

  _JIGSClassMapInsert (javaClass, objcClass);

  RELEASE (pool);
}

/* Please call the following only in the top-most local reference frame. 
   Otherwise, DeleteLocalRef will do nothing and for very deep class trees 
   you could get an out-of-memory error because of excessive local refs 
   creation.  

   Also, beware that this function call wants a local reference as 
   argument, and it destroys it during processing ! 
*/
static inline Class _JIGSFirstJavaProxySuperClass (JNIEnv *env,
                                                      jclass inClass)
{
  Class outClass;

  /* Keep an eye on leakages of local references */
  if ((*env)->EnsureLocalCapacity (env, 2) < 0)
    {
      /* Exception thrown */
      return Nil;
    }

  while (1)
    {
      outClass = _JIGSClassMapGetObjCClassFromJavaClass (env, inClass);

      if (outClass != NULL)
	{
	  break;
	}
      else
	{
	  jclass superClass = (*env)->GetSuperclass (env, inClass);

	  if (superClass == NULL)
	    {
	      // Root Class - no exception thrown
	      NSLog (@"Could not find a real objective-C class");
	      outClass = Nil;
	      break;
	    }

	  (*env)->DeleteLocalRef (env, inClass);
	  inClass = superClass;
	}
    }

  (*env)->DeleteLocalRef (env, inClass);

  return outClass;
}

Class JIGSClassFromThisClass (JNIEnv *env, jclass class)
{

  /* The new local ref we create is destroyed by the function call itself */
  return _JIGSFirstJavaProxySuperClass (env, 
					(*env)->NewLocalRef (env, class));
}

Class _JIGSAllocClassForThis (JNIEnv *env, jobject this)
{
  Class class;
  jclass objectClass;

  if ((*env)->EnsureLocalCapacity (env, 1) < 0)
    {
      /* Exception thrown */
      return Nil;
    }
  /* The following local ref is destroyed by _JIGSFirstJavaProxySuperclass */
  objectClass  = (*env)->GetObjectClass (env, this);

  class = _JIGSFirstJavaProxySuperClass (env, objectClass);

  return class;
}

NSString *_JIGSLongJavaClassNameForObjcClassName (JNIEnv *env, 
						  NSString *className)
{
  jclass result = NULL;
  Class objcClass = NSClassFromString (className);

  result = _JIGSClassMapGetJavaClassFromObjCClass (objcClass);

  if (result == NULL)
    {
      return nil;
    }

  return GSJNI_NSStringFromJClass (env, result);
}

// Cache used in the lookup functions
static jclass gnu_gnustep_base_NSObject = NULL;
static jfieldID fidRealObject = NULL;
static jclass java_lang_String = NULL;
static jclass java_lang_Number = NULL;
static Class java_lang_Object = Nil;
static Class nsstring = Nil;
static Class nsnumber = Nil;
static Class nsarray = Nil;

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

  _JIGSProxiedObjCClassMapWriteLock = objc_mutex_allocate ();

  JIGSFinalizeInit ();
  
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

#define NEW_CLASS_CACHE(VAR,CLASS_NAME) \
VAR = GSJNI_NewClassCache (env, #CLASS_NAME);           \
if (VAR == NULL)                                        \
  {                                                     \
    NSLog (@"Could not get reference to " @#CLASS_NAME);\
    return;                                            \
  }

  NEW_CLASS_CACHE (java_lang_String, java/lang/String);
  NEW_CLASS_CACHE (java_lang_Number, java/lang/Number);
  
  nsstring = NSClassFromString (@"NSString");
  nsnumber = NSClassFromString (@"NSNumber");
  nsarray = NSClassFromString (@"NSArray");
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
  
  while (1)
    {
      result = _JIGSClassMapGetJavaClassFromObjCClass (objcClass);
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

  RETAIN (object);

  _JIGSMapperAddJavaProxy (env, object, newProxy);

  return newProxy;
}

// NB: This method could return a global (for objects which are in map
// tables) or a local (eg for strings) reference; it indicates which sort
// if reference is being returned in the isLocal flags, so that your code
// is able to know whether it can safely call DeleteLocalRef() on the
// returned value.
jobject JIGSJobjectFromIdIsLocal (JNIEnv *env, id object, BOOL *isLocal)
{
  // Return object
  jobject ret;

  // nil
  if (object == nil)
    {
      if (isLocal) *isLocal = NO;
      return NULL;
    }

  // java.lang.Object
  if ([object isKindOfClass: java_lang_Object])
    {
      if (isLocal) *isLocal = NO;
      return ((_java_lang_Object *)object)->realObject;
    }
  
  // NSString 
  if ([object isKindOfClass: nsstring])
    {
      if (isLocal) *isLocal = YES;
      return GSJNI_JStringFromNSString (env, object);
    }

  // NSNumber
  if ([object isKindOfClass: nsnumber])
    {
      if (isLocal) *isLocal = YES;
      return GSJNI_JNumberFromNSNumber (env, object);
    }
  
  // NSException perhaps ?
  
  // Something else - check if it already proxied
  ret = _JIGSMapperGetProxyFromProxiedObjc (env, object);
  if (ret == NULL)
    {
      ret = JIGSCreateNewJavaProxy (env, object);
    }

  if (isLocal) *isLocal = NO;	// Proxies are globals references
  return ret;
}

// NB: This method could return a global (for objects which are in map
// tables) or a local (eg for strings) reference; in any case, you are
// not responsible for freeing the reference so you should not worry.
jobject JIGSJobjectFromId (JNIEnv *env, id object)
{
  return JIGSJobjectFromIdIsLocal (env, object, (BOOL*)0);
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
      ret = JIGS_JLONG_TO_ID((*env)->GetLongField (env, object, 
						    fidRealObject));
      /* The 'object' is a java proxy to an ObjC object, and it's possible
       * that it could be garbage collected by another thread almost
       * immediately after this function returns.
       * If that happens, the finalization of the proxy will release the
       * ObjC instance ... which might be in use by the ObjC code we return
       * it to.  If the ObjC code has not yet retained the ObjC instance,
       * that instance may be deallocated and the ObjC code could crash.
       * To prevent that happening, we retain and autorelease the instance
       * so that we guarantee enough time for the ObjC code to retain it.
       */
      return AUTORELEASE(RETAIN(ret));
    }  

  // FIXME - how slow is going to be the following class examination session
  
  // java.lang.String
  if ((*env)->IsInstanceOf (env, object, java_lang_String) == YES)
    {
      // Returns an autoreleased NSString
      return GSJNI_NSStringFromJString (env, object);
    }

  if ((*env)->IsInstanceOf (env, object, java_lang_Number) == YES)
    {
      // Returns an autoreleased NSNumber
      return GSJNI_NSNumberFromJNumber (env, object);
    }
  
  // Something else - check if it is already proxied
  ret = _JIGSMapperGetProxyFromProxiedJava (object);
  if (ret != nil)
    {
      // Returns a retained and autoreleased object from the map (see above).
      return AUTORELEASE(RETAIN(ret));
    }

  // Otherwise, create a proxy ... returns the autoreleased proxy.
  return JIGSCreateNewObjcProxy (env, object);
}

jstring JIGSJstringFromNSString (JNIEnv *env, NSString *string)
{
  if (string == nil)
    {
      return NULL;
    }
  else
    {
      return GSJNI_JStringFromNSString (env, string);
    }
}

NSString *JIGSNSStringFromJstring (JNIEnv *env, jstring string)
{
  if (string == NULL)
    {
      return nil;
    }
  else
    {
      return GSJNI_NSStringFromJString (env, string);
    }
}

jbyteArray JIGSJbyteArrayFromNSData (JNIEnv *env, NSData *data)
{
  if (data == nil)
    {
      return NULL;
    }
  else
    {
      return GSJNI_jbyteArrayFromNSData (env, data);
    }
}

NSData *JIGSNSDataFromJbyteArray (JNIEnv *env, jbyteArray bytes)
{
  if (bytes == NULL)
    {
      return nil;
    }
  else
    {
      return GSJNI_NSDataFromJbyteArray (env, bytes);
    }
}

NSData *JIGSInitNSDataFromJbyteArray (JNIEnv *env, NSData *data, 
				      jbyteArray bytes)
{
  if (bytes == NULL)
    {
      return nil;
    }
  else
    {
      return GSJNI_initNSDataFromJbyteArray (env, data, bytes);
    }
}

/* These functions managing jobjectArray can't be in GSJNI because they 
   need to map objects */
jobjectArray JIGSJobjectArrayFromNSArray (JNIEnv *env, NSArray *array)
{
  if (array == nil)
    {
      return NULL;
    }
  else
    {
      unsigned i, length;
      id *gnustepObjects;
      jobjectArray javaArray;
      static jclass Object_class = NULL;
      
      if (Object_class == NULL)
	{
	  Object_class = GSJNI_NewClassCache (env, "java/lang/Object");
	  if (Object_class == NULL)
	    {
	      return NULL;
	    }
	}

      length = [array count];
      gnustepObjects = malloc (sizeof (id) * length);
      if (gnustepObjects == NULL)
	{
	  return NULL;
	}
      [array getObjects: gnustepObjects];

      if ((*env)->EnsureLocalCapacity (env, 2) < 0)
	{
	  /* Exception thrown */
	  free (gnustepObjects);
	  return NULL;
	}

      javaArray = (*env)->NewObjectArray (env, length, Object_class, NULL);
      if (javaArray == NULL)
	{
	  /* OutOfMemory exception thrown */
	  free (gnustepObjects);
	  return NULL;
	}
      
      for (i = 0; i < length; i++)
	{
	  jobject object;
	  BOOL isLocal;

	  object = JIGSJobjectFromIdIsLocal (env, gnustepObjects[i], &isLocal);
	  (*env)->SetObjectArrayElement (env, javaArray, i, object);
	  if (isLocal == YES)
	    {
	      (*env)->DeleteLocalRef (env, object);
	    }
	}

      free (gnustepObjects);
      
      return javaArray;
    }
}

NSArray *JIGSInitNSArrayFromJobjectArray (JNIEnv *env, NSArray *array, 
					  jobjectArray objects)
{
  if (array == NULL)
    {
      return nil;
    }
  else
    {
      NSArray *returnArray;
      unsigned i, length;
      id *gnustepObjects;

      length = (*env)->GetArrayLength (env, objects);
      
      gnustepObjects = malloc (sizeof (id) * length);
      if (gnustepObjects == NULL)
	{
	  return nil;
	}

      if ((*env)->EnsureLocalCapacity (env, 1) < 0)
	{
	  /* Exception thrown */
	  free (gnustepObjects);
	  return NULL;
	}

      /* Get the objects and convert them to GNUstep objects */
      for (i = 0; i < length; i++)
	{
	  jobject object;
	  
	  object = (*env)->GetObjectArrayElement (env, objects, i);
	  gnustepObjects[i] = JIGSIdFromJobject (env, object);
	  (*env)->DeleteLocalRef (env, object);
	}

      returnArray = [array initWithObjects: gnustepObjects  count: length];
      free (gnustepObjects);

      return returnArray;
    }  
}

NSArray *JIGSNSArrayFromJobjectArray (JNIEnv *env, jobjectArray objects)
{
  return AUTORELEASE (JIGSInitNSArrayFromJobjectArray (env, [nsarray alloc],
						       objects));
}

id JIGSIdFromThis (JNIEnv *env, jobject this)
{
  return JIGS_JLONG_TO_ID((*env)->GetLongField (env, this, fidRealObject));
}
