/* gnu/gnustep/java/JIGS.java Native code
   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: July 2000
   
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

#include <jni.h>
#include "gnu/gnustep/java/JIGS.h"
#include "JIGS.h"

JNIEXPORT void JNICALL 
Java_gnu_gnustep_java_JIGS_initialize (JNIEnv *env, jclass this)
{
  /* NB: JIGSInit is already protected by an autorelease pool */
  JIGSInit (env);
}

/*
 * Now the forceMultithreading machine.
 *
 */

/* A nop method used below */
@interface _JIGS_Force_Thread : NSObject
+ (void) _JIGSFake: (id)sender;
@end

@implementation _JIGS_Force_Thread
+ (void) _JIGSFake: (id)sender 
{ 
  return; 
}
@end

JNIEXPORT void JNICALL 
Java_gnu_gnustep_java_JIGS_forceMultithreading (JNIEnv *env, jclass this)
{
  /* We don't use JIGS_ENTER because we don't want the exception 
     handler. */

  /*
   * If this is not the default thread, the following will force GNUstep 
   * in multi-thread state immediately.
   */
  BOOL registeredThread = GSRegisterCurrentThread ();
  NSAutoreleasePool *pool = [NSAutoreleasePool new]; 
  
  if ([NSThread isMultiThreaded] == NO)
    {
      /* It didn't - so we do it manually */

      /* Detaching any thread puts GNUstep into multithreading state.
	 What we are doing in the thread has no importance, so we use an 
	 auxiliary no-operation method. */
      [NSThread detachNewThreadSelector: @selector (_JIGSFake:)  
		toTarget: [_JIGS_Force_Thread class]  withObject: nil];
    }

  /* FIXME: We need to wait for the thread to be detached before
     continuing !  <This is only because when we exit this method, we
     want GNUstep to be for sure in multithreading mode.> */

  RELEASE (pool);
  if (registeredThread) GSUnregisterCurrentThread ();
}

