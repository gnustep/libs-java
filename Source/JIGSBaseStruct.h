/* JIGSBaseStruct.h - Morphing NSPoint, NSSize, NSRect, NSRange
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

#ifndef __JIGSBaseStruct_h_GNUSTEP_JAVA_INCLUDE
#define __JIGSBaseStruct_h_GNUSTEP_JAVA_INCLUDE

#include <jni.h>
#include <Foundation/Foundation.h>
#include "GSJNI.h"

void _JIGSBaseStructInitialize (JNIEnv *env);

/* 
 * Morph one of the base library struct to its corresponding 
 * java class, and viceversa.
 *
 */

NSPoint JIGSNSPointConvertToStruct (JNIEnv *env, jobject point);
jobject JIGSNSPointConvertToJobject (JNIEnv *env, NSPoint point);

NSSize JIGSNSSizeConvertToStruct (JNIEnv *env, jobject point);
jobject JIGSNSSizeConvertToJobject (JNIEnv *env, NSSize point);

NSRect JIGSNSRectConvertToStruct (JNIEnv *env, jobject point);
jobject JIGSNSRectConvertToJobject (JNIEnv *env, NSRect point);

NSRange JIGSNSRangeConvertToStruct (JNIEnv *env, jobject point);
jobject JIGSNSRangeConvertToJobject (JNIEnv *env, NSRange point);

#endif /*__JIGSBaseStruct_h_GNUSTEP_JAVA_INCLUDE*/
