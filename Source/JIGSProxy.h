/* JIGSProxy.h - Public functions to control the JIGSProxy

   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: July 2000
   
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

#ifndef __JIGSProxy_h_GNUSTEP_JAVA_INCLUDE
#define __JIGSProxy_h_GNUSTEP_JAVA_INCLUDE

#include <jni.h>
#include <Foundation/Foundation.h>

/* This file contains the only public functions exposed by JIGSProxy*.
 * Other code, including other parts of the JIGS, should only use the
 * following functions to control the JIGSProxy.
 */

/* JIGSRegisterJavaRootClass registers the java.lang.Object class with
 * the objective-C runtime.  This needs to be done before any other
 * java class is registered.  This function is usually called by
 * JIGSInit.  From user code, please call JIGSInit */
void JIGSRegisterJavaRootClass (JNIEnv *env);

/* Use this to register a new java class.  It will register the class
 * and all its superclasses.  'Registering' a java class means making
 * the class available to objective-C: you can create objects of that
 * class in objective-C (as if they were objective-C objects), and
 * send methods to them.  Make _sure_ 'className' is a valid java
 * class name.  Calling it on an already registered java class is OK
 * (but useless).*/
void JIGSRegisterJavaClass (JNIEnv *env, NSString *className);

/*
 * When you register a new class, the java methods of the class need
 * to be exposed as Objective-C selectors.  This mapping can be
 * configured at run-time but the code and the APIs is still 
 * to finish.  Anyway, when it is finished, new functions to 
 * change mappings will be provided here. */

#endif /* __JIGSProxy_h_GNUSTEP_JAVA_INCLUDE */

