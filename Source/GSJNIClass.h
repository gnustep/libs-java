/* GSJNIClass.h - Utilities for class names etc
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

#ifndef __GSJNIClass_h_GNUSTEP_JAVA_INCLUDE
#define __GSJNIClass_h_GNUSTEP_JAVA_INCLUDE

#include <jni.h>
#include <Foundation/Foundation.h>
#include "GSJNICache.h"
#include "GSJNIDebug.h"
#include "GSJNIString.h"

/* 
 * Converts '.' in a Java class name to/from '/' (as used in the JNI) 
 */ 

/* Eg, converts java.lang.String to java/lang/String */
NSString *GSJNI_ConvertJavaClassNameToJNI (NSString *name);

/* Eg, converts java/lang/String to java.lang.String */
NSString *GSJNI_ConvertJavaClassNameFromJNI (NSString *name);


/*
 * Get a NSString describing the class of object, ready to be used.
 *
 * Eg, returns java.lang.String for a string object.
 * Return @"Null" upon NULL object.
 * Return nil upon exception thrown.
 */ 
NSString *GSJNI_NSStringFromClassOfObject (JNIEnv *env, jobject object);

/*
 * Eg, converts gnu.gnustep.base.NSObject to NSObject.
 * Use this only for Objc classes.
 *
 */
inline NSString *GSJNI_ShortClassNameFromLongClassName (NSString *className);


/*
 * Get the name of a Java class in the form of an NSString.
 */
NSString *GSJNI_NSStringFromJClass (JNIEnv *env, jclass class);

/*
 * Get the name of the superclass from the name of the class
 * Eg, return @"java.lang.Object" for className = @"java.lang.String"
 * Use this only for Java classes.
 */
NSString *GSJNI_SuperclassNameFromClassName (JNIEnv *env, NSString *className);

#endif /*__GSJNIClass_h_GNUSTEP_JAVA_INCLUDE*/
