/* NSJavaVirtualMachine.h - A class to run a JVM in your GNUstep app

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

#ifndef __NSJavaVirtualMachine_h_GNUSTEP_JAVA_INCLUDE
#define __NSJavaVirtualMachine_h_GNUSTEP_JAVA_INCLUDE

#include <jni.h>
#include <Foundation/Foundation.h>

/*
 * JNI specifications do not allow more than one Java Virtual Machine
 * per process.
 
 * We enforce this condition by defining NSJavaVirtualMachine as 
 * a Class without instances.
 
 */

/*
 * High level interface to running a Java Virtual Machine
 *
 */

@interface NSJavaVirtualMachine : NSObject
{
  // No ivars
}

+ (void) startDefaultVirtualMachine;

+ (void) startVirtualMachineWithClassPath: (NSString *)classPath;

/* 
 * Start of a Java Virtual Machine.
 * Raise an exception if a machine is already running, or if the
 * machine could not be started.
 *
 * Pass `nil' as classPath or libraryPath to use the default classPath 
 * or libraryPath.
 */
+ (void) startVirtualMachineWithClassPath: (NSString *)classPath
			      libraryPath: (NSString *)libraryPath;

/*
 * Destroy a running Java Virtual Machine.
 * Raise an exception if this can't be done.
 */
+ (void) destroyVirtualMachine;

/*
 * Return YES if a Java Virtual Machine is running
 */
+ (BOOL) isVirtualMachineRunning;

/*
 * Return the default class path on this machine (usually simply 
 * the contents of the CLASSPATH environment variable).
 */
+ (NSString *) defaultClassPath;

/*
 * Return the default library path on this machine (usually simply 
 * the contents of the LD_LIBRARY_PATH environment variable).
 */
+ (NSString *) defaultLibraryPath;

/* Use these to get JNI handles to invoke low-level JNI functions with
 * the virtual machine.  
 */
+ (JavaVM *) JavaVMHandle;

// NB: JIGSJNIEnv () does the same as the following but it is faster.
+ (JNIEnv *) JNIEnvHandleOfCurrentThread;

+ (void) attachCurrentThread;

+ (void) detachCurrentThread;

/*
 * The following is used to 'register' a running virtual machine
 * (started in some other way) with this class.  It is sort of
 * private; you should never need to call this directly; and, it might
 * be changed in further releases.  It is called automatically by JIGS
 * when you load GNUstep using the JIGS in a running Java environment
 * (the java virtual machine in that case is already running before
 * this code is even loaded).
 *

 * It does nothing if a java virtual machine is already registered as running 
 * and javaVMHandle is the handle of that machine. 

 * It raises an exception if javaVMHandle is NULL, or different from the 
 * java vm registered as running.

 * Otherwise, it checks the javaVMHandle is valid (this test crashes the app 
 * if javaVMHandle is not), then registers it.  */
+ (void) registerJavaVM: (JavaVM *)javaVMHandle;

/*
 * TODO: Provide a user-friendly set of methods to control the JVM 
 * (run code inside it, etc).  Interfaces to JIGS facilities should 
 * be provided in an additional category in another file.
 *
 */
@end

/*
 * A fast function to get the (JNIEnv *) variable.
 */

inline JNIEnv *JIGSJNIEnv ();


/*
 * Apple - compatibility methods. 
 * deprecated.
 */
@interface NSJavaVirtualMachine (AppleCompatibility)
+ (NSJavaVirtualMachine *) defaultVirtualMachine;
- (id) init;
- (id) initWithClassPath: (NSString *)classPath;
- (id) initWithLibraryPath: (NSString *)libraryPath;
- (id) initWithClassPath: (NSString *)classPath
	     libraryPath: (NSString *)libraryPath;
- (void) attachCurrentThread;
- (void) detachCurrentThread;
@end


#endif /* __NSJavaVirtualMachine_h_GNUSTEP_JAVA_INCLUDE */
