/* JIGSClass - class related utilities for JIGS
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

#ifndef __JIGSClass_h_GNUSTEP_JAVA_INCLUDE
#define __JIGSClass_h_GNUSTEP_JAVA_INCLUDE

#include <jni.h>
#include <Foundation/Foundation.h>
#include "GSJNI.h"

/*
 * This function returns the class of the jobject argument.
 * The jobject argument /must/ be a java object of a class wrapping 
 * an objective-C class.  It is most safely used on the 'this' 
 * argument of a java native method call.  
 */

inline Class JIGSClassOfThis (JNIEnv *env, jobject this);

#endif /*__JIGSClass_h_GNUSTEP_JAVA_INCLUDE*/