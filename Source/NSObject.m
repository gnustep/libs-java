/* gnu/gnustep/base/NSObject.java native code
   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: June 2000
   
   This file is part of JIGS, the GNUstep Java Interface Library.

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

#include <jni.h>
#include <Foundation/Foundation.h>
#include "gnu/gnustep/base/NSObject.h"
#include "JIGS.h"

/* Warning - this method will not put the object into the mapping
   tables.  This will be done by the wrapper for the initXXX method.
   This is because the initXXX methods could return a different
   object, and we want to insert in the table that returned object. */
JNIEXPORT jlong JNICALL 
Java_gnu_gnustep_base_NSObject_NSObject_1alloc (JNIEnv *env, jobject this)
{
  Class objectClass;
  id objc;
  jlong java;

  JIGS_ENTER;

  objectClass = _JIGSAllocClassForThis (env, this);
  objc = [objectClass alloc];
  java = JIGS_ID_TO_JLONG (objc);

  JIGS_EXIT_WITH_VALUE (java);
}

JNIEXPORT jlong JNICALL 
Java_gnu_gnustep_base_NSObject_NSObject_1new (JNIEnv *env, jobject this)
{
  Class objectClass;
  id objc;
  jlong java;

  JIGS_ENTER;

  objectClass = _JIGSAllocClassForThis (env, this);
  objc = [objectClass new];
  _JIGSMapperAddJavaProxy (env, objc, this);
  java = JIGS_ID_TO_JLONG (objc);

  JIGS_EXIT_WITH_VALUE (java);
}

JNIEXPORT jboolean JNICALL 
Java_gnu_gnustep_base_NSObject_equals (JNIEnv *env, jobject this, 
				       jobject other)
{ 
  id we, they;
  jboolean return_value;

  JIGS_ENTER;

  we = JIGSIdFromThis (env, this);
  they =  JIGSIdFromJobject (env, other);
  return_value = (jboolean)[we isEqual: they];

  JIGS_EXIT_WITH_VALUE (return_value);  
}

/*
 * The following is special, so we take advantage of a little trick by
 * directly passing the IDpointer as argument and sparing the lookup.  */
JNIEXPORT void JNICALL 
Java_gnu_gnustep_base_NSObject_finalize_1native (JNIEnv *env, jobject this, 
						 jlong IDpointer)
{
  id objc;
  JIGS_ENTER;

  objc = JIGS_JLONG_TO_ID (IDpointer);

  _JIGSMapperRemoveJavaProxy (env, objc);

  RELEASE (objc);

  JIGS_EXIT;
}


JNIEXPORT jint JNICALL 
Java_gnu_gnustep_base_NSObject_hashCode (JNIEnv *env, jobject this)
{   
  id we;
  jint return_value;
  
  JIGS_ENTER;

  we = JIGSIdFromThis (env, this);
  return_value = (jint)[we hash];
  
  JIGS_EXIT_WITH_VALUE (return_value);
}


JNIEXPORT jobject JNICALL 
Java_gnu_gnustep_base_NSObject_clone (JNIEnv *env, jobject this)
{
  id thisObject;
  id newObject;
  jobject newProxyObject;
  
  JIGS_ENTER;

  thisObject = JIGSIdFromThis (env, this);
  newObject = AUTORELEASE ([thisObject copy]);
  newProxyObject = JIGSCreateNewJavaProxy (env, newObject);
  
  JIGS_EXIT_WITH_VALUE (newProxyObject);
}

JNIEXPORT jobject JNICALL 
Java_gnu_gnustep_base_NSObject_mutableClone (JNIEnv *env, jobject this)
{
  id thisObject;
  id newObject;
  jobject newProxyObject;
  
  JIGS_ENTER;

  thisObject = JIGSIdFromThis (env, this);
  newObject = AUTORELEASE ([thisObject mutableCopy]);
  newProxyObject = JIGSCreateNewJavaProxy (env, newObject);
  
  JIGS_EXIT_WITH_VALUE (newProxyObject);
}

JNIEXPORT jstring JNICALL 
Java_gnu_gnustep_base_NSObject_toString (JNIEnv *env, jobject this)
{
  id thisObject;
  NSString *description;
  jstring result;
  
  JIGS_ENTER;
  
  thisObject = JIGSIdFromThis (env, this);
  description = [thisObject description];
  result = JIGSJobjectFromId (env, description);
  
  JIGS_EXIT_WITH_VALUE (result);
}

JNIEXPORT void JNICALL 
Java_gnu_gnustep_base_NSObject_takeValueForKey
(JNIEnv *env, jobject this, jobject value, jstring key)
{
  id thisObject;
  id objc_value;
  NSString *objc_key;

  JIGS_ENTER;
  
  thisObject = JIGSIdFromThis (env, this);
  objc_value = JIGSIdFromJobject (env, value);
  objc_key = GSJNI_NSStringFromJString (env, key);

  [thisObject takeValue: objc_value  forKey: objc_key];
    
  JIGS_EXIT;  
}

JNIEXPORT jobject JNICALL 
Java_gnu_gnustep_base_NSObject_valueForKey
(JNIEnv *env, jobject this, jstring key)
{
  id thisObject;  
  NSString *objc_key;
  id objc_value;
  jobject result;

  JIGS_ENTER;
  
  thisObject = JIGSIdFromThis (env, this);
  objc_key = GSJNI_NSStringFromJString (env, key);
  
  objc_value = [thisObject valueForKey: objc_key];
    
  result = JIGSJobjectFromId (env, objc_value);
  
  JIGS_EXIT_WITH_VALUE (result);
}

JNIEXPORT void JNICALL 
Java_gnu_gnustep_base_NSObject_retainObject 
(JNIEnv *env, jclass this, jobject object)
{
  id objc;
  
  JIGS_ENTER;
 
  objc = JIGSIdFromJobject (env, object);
  RETAIN (objc);

  JIGS_EXIT;  
}


JNIEXPORT void JNICALL 
Java_gnu_gnustep_base_NSObject_releaseObject 
(JNIEnv *env, jclass this, jobject object)
{
  id objc;
  
  JIGS_ENTER;
  
  objc = JIGSIdFromJobject (env, object);
  RELEASE (objc);
    
  JIGS_EXIT;  
}





