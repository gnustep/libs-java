/* JIGSInit - Initialization of JIGS
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

#ifndef __JIGSInit_h_GNUSTEP_JAVA_INCLUDE
#define __JIGSInit_h_GNUSTEP_JAVA_INCLUDE

#include <jni.h>
#include <Foundation/Foundation.h>
#include "GSJNI.h"

#if defined(LIB_FOUNDATION_LIBRARY)

BOOL GSRegisterCurrentThread (void);
void GSUnregisterCurrentThread (void);

#endif /* LIB_FOUNDATION_LIBRARY */

/*
 * Initialize JIGS. 
 * Calling this more than once is safe, but useless.
 * It can return with a GSJNIException.
 *
 * From Java, you may call it by calling gnu.gnustep.java.JIGS.initialize ().
 * This is automatically done whenever the class NSObject.java is loaded 
 * into your java application.
 *
 * To call JIGSInit from Objective-C, you first need to start a Java 
 * Virtual Machine, as in the following example: 
 
 JNIEnv *env;
 
 [NSJavaVirtualMachine startDefaultVirtualMachine]; 
 env = [NSJavaVirtualMachine JNIEnvHandleOfCurrentThread];
 
 JIGSInit (env);

 */
void JIGSInit (JNIEnv *env);

#endif /*__JIGSInit_h_GNUSTEP_JAVA_INCLUDE*/



