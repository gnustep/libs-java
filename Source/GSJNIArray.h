/* GSJNIArray.h - Conversion to/from JNI Arrays
   Copyright (C) 2001 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: February 2001
   
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

#ifndef __GSJNIArray_h_GNUSTEP_JAVA_INCLUDE
#define __GSJNIArray_h_GNUSTEP_JAVA_INCLUDE


#include <jni.h>
#include <Foundation/Foundation.h>

/* Convert a Java array of bytes into an NSData object. 
 * Return nil upon exception thrown.
 * Return an autorelease object.  array should not be NULL.
 */
NSData *GSJNI_NSDataFromJbyteArray (JNIEnv *env, jbyteArray array);

/* Create a Java array of bytes from an NSData object.
 * Return NULL upon exception thrown.
 * Return a local reference.  data should not be nil.
 */
jbyteArray GSJNI_jbyteArrayFromNSData (JNIEnv *env, NSData *data);

/*
 * You should call this function with a NSData object argument
 * (NSMutableData is Ok) in `data', which you have allocated but not
 * yet initialized.  The method will initialize the NSData object
 * passed as argument to contain the bytes in array; and return the
 * result of the init method.  array should not be NULL.  */
NSData *GSJNI_initNSDataFromJbyteArray (JNIEnv *env, NSData *data,
					       jbyteArray array);

#endif /*__GSJNIArray_h_GNUSTEP_JAVA_INCLUDE*/
