/* SimpleGUI.m -  A library for simple GUI programming; java wrapper
   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: June 2000
   
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

#include <Foundation/Foundation.h>
#include <jni.h>
#include <java/JIGS.h>
#include "../../Library/SimpleGUI.h"

/* REQUIRED: This function should be implemented in all library wrapper, 
   calling JIGSRegisterJavaProxyClass for each java class */
JNIEXPORT jint JNICALL
JNI_OnLoad (JavaVM *jvm, void *reserved)
{
  JIGS_ONLOAD_ENTER;
  JIGSRegisterJavaProxyClass (JIGSJNIEnv (), @"SimpleGUI", @"SimpleGUI");
  JIGS_ONLOAD_EXIT;
}

/*
 * REQUIRED: All functions must begin with JIGS_ENTER straight after variables 
 * and before *any* objective-C code is executed; they must exit with 
 * JIGS_EXIT if they return void, or JIGS_EXIT_WITH_VALUE (value) 
 * if they return `value'.  `value' must be a variable whose value is computed 
 * inside the JIGS_ENTER/JIGS_EXIT tags; using a function or a macro as 
 * argument of JIGS_EXIT_WITH_VALUE is not safe since any exception generated 
 * inside the function would not be caught.
 *
 * To get the object which is receiving the method call, do as in: 
 * we = JIGSIdFromThis (env, this);
 * Or, if you are wrapping a class method, 
 * objcClass = JIGSClassFromThisClass (env, class);
 * Then use JIGSIdFromJobject to convert any object argument 
 * to a GNUstep object; call the method; convert the return value 
 * (if it is an object) to a Java object using JIGSJobjectFromId;
 * return the result.
 *
 * Some shortcuts are: 

 * convert string arguments using JIGSNSStringFromJstring.
 * This is slightly faster but you must be sure the arg is a string.
 
 * create proxies directly when cloning objects.  Please refer 
 * to JIGSMapper.h for more info.
 */

JNIEXPORT jlong JNICALL 
Java_SimpleGUI_initWithTitle (JNIEnv *env, jobject this, jstring title)
{
  SimpleGUI *we;
  id objc_new;
  jlong java;
  JIGS_ENTER;

  we = JIGSIdFromThis (env, this);
  objc_new = [we initWithTitle: JIGSNSStringFromJstring (env, title)];
  _JIGSMapperAddJavaProxy (env, objc_new, this);
  java = JIGS_ID_TO_JLONG (objc_new);  
  JIGS_EXIT_WITH_VALUE (java);
}

JNIEXPORT void JNICALL 
Java_SimpleGUI_addButtonWithTitle (JNIEnv *env, jobject this, 
				   jstring title, jint tag)
{
  SimpleGUI *we;
  JIGS_ENTER;

  we = JIGSIdFromThis (env, this);
  [we addButtonWithTitle: JIGSNSStringFromJstring (env, title)  tag: tag];

  JIGS_EXIT;
}


JNIEXPORT jobject JNICALL 
Java_SimpleGUI_delegate  (JNIEnv *env, jobject this)
{
  SimpleGUI *we;
  jobject output;
  JIGS_ENTER;

  we = JIGSIdFromThis (env, this);
  output = JIGSJobjectFromId (env, [we delegate]);
  
  JIGS_EXIT_WITH_VALUE (output);
}


JNIEXPORT void JNICALL 
Java_SimpleGUI_setDelegate (JNIEnv *env, jobject this, jobject delegate)
{
  SimpleGUI *we;
  JIGS_ENTER;

  we = JIGSIdFromThis (env, this);
  [we setDelegate: JIGSIdFromJobject (env, delegate)];

  JIGS_EXIT;
}


JNIEXPORT void JNICALL 
Java_SimpleGUI_start (JNIEnv *env, jobject this)
{
  SimpleGUI *we;
  JIGS_ENTER;

  we = JIGSIdFromThis (env, this);
  
  [we start];

  JIGS_EXIT;
}



