/* GSJNINumber.h - Conversion between ObjC and Java number objects
   Copyright (C) 2001 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: May 2001
   
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

#ifndef __GSJNINumber_h_GNUSTEP_JAVA_INCLUDE
#define __GSJNINumber_h_GNUSTEP_JAVA_INCLUDE


#include <jni.h>
#include <Foundation/Foundation.h>

/* Convert a java.lang.Number object of an unknown class to a
 * NSNumber.  This first checks the standard classes, and tries to use
 * the appropriate code for better precision in conversion.  If the
 * number is not of a standard class, it gets the value of the number
 * as a double, and creates a NSNumber for a double.  Return nil upong
 * exception thrown.  object should not be NULL.  Return an
 * autoreleased number. 
 */
NSNumber *GSJNI_NSNumberFromJNumber (JNIEnv *env, jobject object);

/* Convert a java.lang.Boolean object to a NSNumber.  This is safe
 * because if you convert the NSNumber back, you will get a
 * java.lang.Boolean.  Return nil upong exception thrown.  object
 * should not be NULL.  Return an autoreleased number.  */
NSNumber *GSJNI_NSNumberFromJBoolean (JNIEnv *env, jobject object);

/* Convert the NSNumber object to an appropriate java.lang.Number
 * object - as an exception, if the NSNumber is actually holding a
 * BOOL, we morph it better into a java.lang.Boolean. We never return
 * a java.lang.Character even when it would be the more appropriate
 * conversion type, because java.lang.Character is not a number.
 * Return NULL upon exception thrown.  object should not be nil.
 * Return a local reference.  */
jobject GSJNI_JNumberFromNSNumber (JNIEnv *env, NSNumber *object);

#endif /*__GSJNINumber_h_GNUSTEP_JAVA_INCLUDE*/
