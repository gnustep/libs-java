/* NSJavaVirtualMachine.m - Instances of this class represent JVM

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

#include "NSJavaVirtualMachine.h"
#include "JIGSInit.h"

/*
 * This is a JNI reference to the currently running java virtual
 * machine, or NULL if no java virtual machine is running.  
 */
JavaVM *JIGSJavaVM = NULL;

/*
 * Return the (JNIEnv *) associated with the current thread,
 * or NULL if no java virtual machine is running (or if the thread 
 * is not attached to the JVM).
 *
 * NB: This function performs a call.  Better use your (JNIEnv *) if 
 * you already have it.
 *
 */
JNIEnv *JIGSJNIEnv ()
{
  JNIEnv *penv;

  if ((*JIGSJavaVM)->GetEnv (JIGSJavaVM, (void **)&penv, 
			     JNI_VERSION_1_2) == JNI_OK)
    {
      return penv;
    }
  else
    {
      return NULL;
    }
}

@implementation NSJavaVirtualMachine (GNUstepInternals)
+ (void) _attachCurrentThread: (NSNotification *)not
{
  [self attachCurrentThread];
}

+ (void) _detachCurrentThread: (NSNotification *)not
{
  [self detachCurrentThread];
}
@end

@implementation NSJavaVirtualMachine

+ (void) startDefaultVirtualMachine
{
  [self startVirtualMachineWithClassPath: nil libraryPath: nil];
}

+ (void) startVirtualMachineWithClassPath: (NSString *)classPath
{
  [self startVirtualMachineWithClassPath: classPath  libraryPath: nil];
}

+ (void) startVirtualMachineWithClassPath: (NSString *)classPath
			      libraryPath: (NSString *)libraryPath
{
  JavaVMInitArgs jvm_args;
  JavaVMOption options[2];
  jint result;
  JNIEnv *env;
  NSDictionary *environment = [[NSProcessInfo processInfo] environment];
  NSString *path;
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

  if (JIGSJavaVM != NULL)
    {
      [NSException raise: NSGenericException
		   format: @"Only one Java Virtual Machine "
		   @"can be running at each time"];
    }  

  // If we don't pass these options, it assumes they are really @""
  if (classPath == nil)
    {
      classPath = [environment objectForKey: @"CLASSPATH"];
      if (classPath == nil)
	{
	  classPath = @"";
	}
    }
  if (libraryPath == nil)
    {
      libraryPath = [environment objectForKey: @"LD_LIBRARY_PATH"];
      if (libraryPath == nil)
	{
	  libraryPath = @"";
	}
    }

  jvm_args.nOptions = 2;
  
  path = [NSString stringWithFormat: @"-Djava.class.path=%@", 
		   classPath];
  options[0].optionString = (char *)[path cString];

  path = [NSString stringWithFormat: @"-Djava.library.path=%@", 
		   libraryPath];
  options[1].optionString = (char *)[path cString];
  
  jvm_args.version = 0x00010002;
  jvm_args.options = options;
  jvm_args.ignoreUnrecognized = JNI_TRUE;
  
  result = JNI_CreateJavaVM (&JIGSJavaVM, (void **)&env, &jvm_args);
  
  if (result < 0)
    {
      [NSException raise: NSGenericException
		   format: @"Could not start Java Virtual Machine"];
    }

  /* Whenever a thread start or ends, we want to automatically attach
     or detach it to/from the JVM */
  [nc addObserver: self  selector: @selector (_attachCurrentThread:)
      name: NSThreadDidStartNotification  object: nil];

  [nc addObserver: self selector: @selector (_detachCurrentThread:)
      name: NSThreadWillExitNotification  object: nil];

  return;
}

+ (void) destroyVirtualMachine
{
  jint result;
  
  if (JIGSJavaVM == NULL)
    {
      [NSException raise: NSGenericException
		   format: @"destroyJVM called without a JVM running"];
    }
  result = (*JIGSJavaVM)->DestroyJavaVM (JIGSJavaVM);
  if (result < 0)
    {
      [NSException raise: NSGenericException
		   format: @"Could not destroy Java Virtual Machine"];
    }
  else
    {
      JIGSJavaVM = NULL;
    }
}

+ (BOOL) isVirtualMachineRunning
{
  if (JIGSJavaVM == NULL)
    {
      return NO;
    }
  else
    {
      return YES;
    }
}

+ (NSString *) defaultClassPath
{
  NSDictionary *environment = [[NSProcessInfo processInfo] environment];

  return [environment objectForKey: @"CLASSPATH"];
}

+ (NSString *) defaultLibraryPath
{
  NSDictionary *environment = [[NSProcessInfo processInfo] environment];

  return [environment objectForKey: @"LD_LIBRARY_PATH"];
}

+ (JavaVM *) JavaVMHandle
{
  return JIGSJavaVM;
}

+ (JNIEnv *) JNIEnvHandleOfCurrentThread
{
  return JIGSJNIEnv ();
}

+ (void) attachCurrentThread
{
  static int count = 0;
  JNIEnv *env;
  JavaVMAttachArgs args;
  jint result;

  if (JIGSJavaVM == NULL)
    {
      /* No JVM - nothing to do */
      return;
    }  
                    
  if (JIGSJNIEnv () != NULL)
    {
      /* The thread is already attached */
      return;
    }

  {
    CREATE_AUTORELEASE_POOL (pool);
    
    args.version = JNI_VERSION_1_2;
    args.name = (char *)[[NSString stringWithFormat: @"GNUstepThread-%d", 
				   count] 
			  cString];
    args.group = NULL;
    
    result = (*JIGSJavaVM)->AttachCurrentThread (JIGSJavaVM, (void **)&env, 
						 &args);
    
    RELEASE (pool);
  }

  if (result < 0)
    {
      [NSException raise: NSGenericException
		   format: @"Could not attach thread to the Java VM"];
    }
  
  count++;
  if (count > 100000)
    {
      /* Duplicated names shouldn't cause any problem */
      count = 0;
    }
  return;
}

+ (void) detachCurrentThread 
{
  jint result;

  if (JIGSJavaVM == NULL)
    {
      /* No JVM - nothing to do */
      return;
    }  
                    
  if (JIGSJNIEnv () == NULL)
    {
      /* The thread is not attached */
      return;
    }

  result = (*JIGSJavaVM)->DetachCurrentThread (JIGSJavaVM);
  
  if (result < 0)
    {
      [NSException raise: NSGenericException
		   format: @"Could not detach thread from the Java VM"];
    }

  return;
}

+ (void) registerJavaVM: (JavaVM *)javaVMHandle
{
  if (javaVMHandle == NULL)
    {
      [NSException raise: NSInvalidArgumentException
		   format: @"Trying to register a NULL Java VM"];
    }
  
  if (JIGSJavaVM != NULL)
    {
      if (javaVMHandle == JIGSJavaVM)
	{
	  return;
	}
      else
	{
	  [NSException raise: NSGenericException
		       format: @"Trying to register a Java VM "
		       @"while one is already running"];
	}
    }  
  
  JIGSJavaVM = javaVMHandle;
  
  // Safety check.  If javaVMHandle is invalid, the following will crash 
  // your app.  The app would crash anyway later on, so it's better to crash 
  // it here, where it is easier to debug.
  JIGSJNIEnv ();
  
  return;
}

+ (void) JIGSInit
{
  JNIEnv *env;

  if (JIGSJavaVM == 0)
    {
      [self startDefaultVirtualMachine];
    }
  env = JIGSJNIEnv ();
  if (env != 0)
    {
      JIGSInit(env);
    }
}
@end

// deprecated Apple-compatibility API
@implementation NSJavaVirtualMachine (AppleCompatibility)
+ (NSJavaVirtualMachine *) defaultVirtualMachine
{
  return AUTORELEASE ([self new]);
}

- (id) init
{
  return [self initWithClassPath: nil  libraryPath: nil];
}

- (id) initWithClassPath: (NSString *)classPath
{
    return [self initWithClassPath: classPath  libraryPath: nil];
}

- (id) initWithLibraryPath: (NSString *)libraryPath
{
    return [self initWithClassPath: nil  libraryPath: libraryPath];
}


- (id) initWithClassPath: (NSString *)classPath
	     libraryPath: (NSString *)libraryPath
{
  [NSJavaVirtualMachine startVirtualMachineWithClassPath: classPath
			libraryPath: libraryPath];
  return self;
}

- (void) attachCurrentThread
{
  return [NSJavaVirtualMachine attachCurrentThread];
}
 
- (void) detachCurrentThread 
{
  return [NSJavaVirtualMachine detachCurrentThread];
}
@end

