/* GSJNIDebug.h - Debugging utilities
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

#ifndef __GSJNIDebug_h_GNUSTEP_JAVA_INCLUDE
#define __GSJNIDebug_h_GNUSTEP_JAVA_INCLUDE

#include <jni.h>
#include <Foundation/Foundation.h>
#include "GSJNIString.h"
#include "GSJNICache.h"

/*
 * Useful functions to put in your code when something is going wrong 
 * and you want to check what a variable really is.
 *
 * These functions are designed for debugging - they are chatty and
 * slow.
 * 
 */

/* Return an autoreleased NSString description of the jobject object.
 * Return nil upon exception thrown. object can be NULL.
 */
NSString *GSJNI_DescriptionOfJObject (JNIEnv *env, jobject object);

/* Return an autoreleased NSString description of the jclass class.
 * Return nil upon exception thrown.  class can be NULL.
 */
NSString *GSJNI_DescriptionOfJClass (JNIEnv *env, jclass class);

#endif /*__GSJNIDebug_h_GNUSTEP_JAVA_INCLUDE*/
