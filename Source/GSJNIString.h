/* GSJNIString.h - Conversion to/from JNI Strings
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

#ifndef __GSJNIString_h_GNUSTEP_JAVA_INCLUDE
#define __GSJNIString_h_GNUSTEP_JAVA_INCLUDE


#include <jni.h>
#include <Foundation/Foundation.h>

/* Convert the jstring string to a NSString.
 * Works only with ASCII strings, but it is slightly faster 
 * than the full UNICODE conversion.  Use it only for method names, 
 * class names, etc.
 * Return nil upon exception thrown.  string should not be NULL.
 * Return an autoreleased string.
 */
inline NSString *GSJNI_NSStringFromASCIIJString (JNIEnv *env, jstring string);

/* Convert the NSString string to a jstring.
 * Works only with ASCII strings, but it is slightly faster 
 * than the full UNICODE conversion.  Use it only for method names, 
 * class names, etc.
 * Return NULL upon exception thrown.  string should not be nil.
 * Return a local reference.
 */
inline jstring GSJNI_JStringFromASCIINSString (JNIEnv *env, NSString *string);

/* Convert the jstring string to a NSString. 
 * Performs full UNICODE conversion.
 * Return nil upon exception thrown.  string should not be NULL.
 * Return an autoreleased string.
 */
inline NSString *GSJNI_NSStringFromJString (JNIEnv *env, jstring string);

/* Convert the NSString string to a jstring. 
 * Performs full UNICODE conversion.
 * Return NULL upon exception thrown.  string should not be nil.
 * Return a local reference.
 */
inline jstring GSJNI_JStringFromNSString (JNIEnv *env, NSString *string);

#endif /*__GSJNIString_h_GNUSTEP_JAVA_INCLUDE*/
