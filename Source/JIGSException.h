/* JIGSException.h - Exception morphing and managing
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

#ifndef __JIGSException_h_GNUSTEP_JAVA_INCLUDE
#define __JIGSException_h_GNUSTEP_JAVA_INCLUDE


#include <jni.h>
#include <Foundation/Foundation.h>
#include "GSJNI.h"

/*
 * Create a GNUstep exception from a pending java exception.
 * The name of the exception is taken from the java exception classname;
 * the reason is taken from the java exception message.
 *
 * This method is guaranteed to clear the pending java exception (if any) 
 * and throw a GNUstep exception. 
 *
 * If the pending java exception is [exactly] of class 
 * gnu.gnustep.base.NSException, the name of the exception is taken from 
 * the 'name' field of the exception instead of being the vague 
 * gnu.gnustep.base.NSException.
 *
 */
void JIGSRaiseNSExceptionFromJException (JNIEnv *env);


/*
 * Raise a Java exception of class exceptionName, with message
 * exceptionMessage. 
 * 
 * NB: This is currently unused
 * 
 */

void JIGSRaiseJExceptionWithName (JNIEnv *env, const char *exceptionName, 
				  const char *exceptionMessage);

/*
 * The following method returns with a pending java exception. 

 * It tries to build a java exception of class gnu.gnustep.base.NSException,
 * with name and reason taken from the argument. 

 * It is guaranteed that it will return with a pending java exception, 
 * even if it fails to build the gnu.gnustep.base.NSException object.

 * `name` and `reason` must not be nil.
 */
void JIGSRaiseJException (JNIEnv *env, NSString *name, NSString *reason);


/*
 * Call JIGSRaiseJException with NSException's name and reason.
 *
 */
void JIGSRaiseJExceptionFromNSException (JNIEnv *env, NSException *le);


#endif /*__JIGSException_h_GNUSTEP_JAVA_INCLUDE*/
