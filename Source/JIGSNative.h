/* JIGSNative.h - Entering and Exiting native method implementations
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

#ifndef __JIGSNative_h_GNUSTEP_JAVA_INCLUDE
#define __JIGSNative_h_GNUSTEP_JAVA_INCLUDE

#include <jni.h>
#include <Foundation/Foundation.h>
#include "GSJNI.h"

/*
 * Clean things upon entering and exiting a native implementation 
 * of a java method.
 *
 * Always begin *any* Java Interface native call with 
 * 
 * JIGS_ENTER;
 * 
 * (just after declaration of variables and *before* any objc code is
 * actually used)
 *
 * and finish it with 
 *
 * JIGS_EXIT;
 *
 * (just before the return statement)
 *
 * or 
 *
 * JIGS_EXIT_WITH_VALUE (ret_value);
 *
 * Important: `ret_value' must be a simple variable whose value was
 * computed inside the JIGS_ENTER/JIGS_EXIT_WITH_VALUE tags, not an
 * expression or a function call.
 * 
 * And (important) you need to call the JNIEnv * argument of your
 * native call 'env'.  
 */

#define JIGS_ENTER                                   \
BOOL registeredThread = GSRegisterCurrentThread ();  \
NSAutoreleasePool *pool = [NSAutoreleasePool new];   \
NS_DURING

#define JIGS_EXIT                                            \
NS_HANDLER                                                   \
JIGSRaiseJExceptionFromNSException (env, localException);    \
NS_ENDHANDLER                                                \
RELEASE (pool);                                              \
if (registeredThread) GSUnregisterCurrentThread ();

#define JIGS_EXIT_WITH_VALUE(ret_value)                      \
NS_HANDLER                                                   \
JIGSRaiseJExceptionFromNSException (env, localException);    \
ret_value = 0;                                               \
NS_ENDHANDLER                                                \
RELEASE (pool);                                              \
if (registeredThread) GSUnregisterCurrentThread ();          \
return (ret_value);


/*
 * Use the following when entering the JNI_OnLoad function of 
 * a library (where usually the classes and selectors of the library 
 * are registered).  It is particularly important because JNI_OnLoad  
 * might be called from an arbitrary Java thread.
 *
 */
#define JIGS_ONLOAD_ENTER                                 \
BOOL registeredThread = GSRegisterCurrentThread ();       \
NSAutoreleasePool *pool = [NSAutoreleasePool new];        

#define JIGS_ONLOAD_EXIT                                     \
RELEASE (pool);                                              \
if (registeredThread) GSUnregisterCurrentThread ();          \
return JNI_VERSION_1_2;

#endif /*__JIGSNative_h_GNUSTEP_JAVA_INCLUDE*/



