/* JIGSException.m - Exception morphing and managing
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

#include "GSJNI.h"

static NSString *GSJNIException = @"GSJNIException";
static jclass gnu_gnustep_base_NSException = NULL;

/*
 * This is made to work well with gnu.gnustep.base.NSException.
 * If it is an exception of that class, we use "name", if not-null, 
 * to set the name of the exception.
 *
 */
// NB: This is guaranteed to throw a GNUstep exception in *any* case.
void JIGSRaiseNSExceptionFromJException (JNIEnv *env)
{
  jthrowable exc, exception;
  static jclass java_lang_Exception = NULL;
  jmethodID jid = NULL;
  jfieldID jfid = NULL;
  jstring jstr = NULL;
  NSString *exceptionName;
  NSString *exceptionDescription;

  // NB: This is a local reference we will need to delete !
  // We can't use PushLocalFrame because there is a pending exception
  exc = (*env)->ExceptionOccurred (env);
  if (exc == NULL)
    {
      // Uhm.  We have been called with no Java Exception pending!
      // Well, this is a good reason for throwing an exception. :-)
      [NSException raise: NSInternalInconsistencyException 
		   format: @"RaiseNSExceptionFromJException called "
		   @"without a pending Java exception"];
    }

  // We need to clear the exception before doing anything else. 
  (*env)->ExceptionClear (env);

  exceptionName = GSJNI_NSStringFromClassOfObject (env, exc);

  // NB: We don't do the same for subclasses  
  if ([exceptionName isEqualToString: @"NSException"])
  {
    if (gnu_gnustep_base_NSException == NULL)
      {
	gnu_gnustep_base_NSException = GSJNI_NewClassCache 
	  (env, "gnu/gnustep/base/NSException");
	
      if (gnu_gnustep_base_NSException == NULL)
	{
	  (*env)->DeleteLocalRef (env, exc);
	  // Describing the exception has the side effect
	  // of clearing it.
	  (*env)->ExceptionDescribe (env); 
	  [NSException raise: GSJNIException
		       format: @"Could not get global reference to "
		       @"gnu/gnustep/base/NSException to describe "
		       @"exception: %@", exceptionName];
	}

      if (jfid == NULL)
	{
	  jfid = (*env)->GetFieldID (env, gnu_gnustep_base_NSException,
				     "name", "Ljava/lang/String;");
	  if (jfid == NULL)
	    {
	      (*env)->DeleteLocalRef (env, exc);
	      (*env)->ExceptionDescribe (env); 
	      [NSException raise: GSJNIException
			   format: @"Could not get name field ID of "
			   @"gnu/gnustep/base/NSException, to describe "
			   @"exception: %@", exceptionName];
	    }
	}
      }
    
    if ((*env)->PushLocalFrame (env, 1) < 0)
      {
	(*env)->ExceptionClear (env);
      }
    else
      {    
	jstr = (*env)->GetObjectField (env, gnu_gnustep_base_NSException, 
				       jfid);
	
	if (jstr != NULL)
	  {
	    exceptionName = GSJNI_NSStringFromJString (env, jstr);
	  } 

	if (exceptionName == NULL)
	  {
	    exceptionName = @"gnu.gnustep.base.NSException";
	    (*env)->ExceptionClear (env);
	  }
	(*env)->PopLocalFrame (env, NULL);
      }
  }

  if (java_lang_Exception == NULL)
    {
      java_lang_Exception = GSJNI_NewClassCache (env, "java/lang/Exception");
      
      if (java_lang_Exception == NULL)
	{
	  (*env)->DeleteLocalRef (env, exc);
	  (*env)->ExceptionDescribe (env); 
	  [NSException raise: GSJNIException
		       format: @"Could not get global reference to "
		       @"java/lang/Exception to describe exception: %@", 
		       exceptionName];
	}
    }

  jid = (*env)->GetMethodID (env, java_lang_Exception, "getMessage", 
			     "()Ljava/lang/String;");
  if (jid == NULL)
    {
      (*env)->DeleteLocalRef (env, exc);
      (*env)->ExceptionDescribe (env);
      [NSException raise: GSJNIException 
		   format: @"Could not get the jmethodID of getMessage"
		   @"of java/lang/Exception to describe exception: %@", 
		   exceptionName];
    }
 
  if ((*env)->PushLocalFrame (env, 1) < 0)
    {
      (*env)->DeleteLocalRef (env, exc);
      (*env)->ExceptionDescribe (env);
      [NSException raise: GSJNIException 
		   format: @"Could not create enough JNI local references "
		   @"to get a description of the exception: %@",
		   exceptionName];
    }      
  
  // Get the message
  jstr = (*env)->CallObjectMethod (env, exc, jid);

  (*env)->DeleteLocalRef (env, exc);

  exception = (*env)->ExceptionOccurred (env);
  if (exception)  // Oh oh - something is really wrong here
    {
      (*env)->ExceptionDescribe (env);
      (*env)->PopLocalFrame (env, NULL);
      [NSException raise: GSJNIException 
		   format: @"Exception occurred while getting a description "
		   @"of exception: %@", exceptionName];
    }
  
  if (jstr == NULL) // Oh oh - something really wrong here
    {
      (*env)->PopLocalFrame (env, NULL);
      [NSException raise: GSJNIException 
		   format: @"NULL description of exception: %@", 
		   exceptionName];
    }
  
  exceptionDescription = GSJNI_NSStringFromJString (env, jstr);
  if (exceptionDescription == nil)
    {
      (*env)->PopLocalFrame (env, NULL);
      [NSException raise: GSJNIException 
		   format: @"Exception while converting string of "
		   @"exception: %@", exceptionName];
    }

  (*env)->PopLocalFrame (env, NULL);
  [NSException raise: exceptionName  format: exceptionDescription];
}

// The following is currently unused

void JIGSRaiseJExceptionWithName (JNIEnv *env, const char *exceptionName, 
				  const char *exceptionMessage)
{
  jclass exceptionClass;

  if ((*env)->PushLocalFrame (env, 1) < 0)
    {
      // Exception thrown
      return;
    }
  
  exceptionClass = (*env)->FindClass (env, exceptionName);
  
  if (exceptionClass == NULL)
    {
      // Exception thrown
      (*env)->PopLocalFrame (env, NULL);
      return;
    }
  
  (*env)->ThrowNew (env, exceptionClass, exceptionMessage);
  (*env)->PopLocalFrame (env, NULL);
}

void JIGSRaiseJException (JNIEnv *env, NSString *name, NSString *reason)
{
  static jmethodID cid = NULL;
  jthrowable exc;
  
  if (gnu_gnustep_base_NSException == NULL)
    {
      gnu_gnustep_base_NSException = GSJNI_NewClassCache 
	(env, "gnu/gnustep/base/NSException");
      
      if (gnu_gnustep_base_NSException == NULL)
	{
	  // Exception thrown
	  return;
	}
    }
  
  if (cid == NULL)
    {
      cid = (*env)->GetMethodID (env, gnu_gnustep_base_NSException, 
				 "<init>", 
				 "(Ljava/lang/String;Ljava/lang/String;)V");
      if (cid == NULL)
	{
	  // Exception thrown
	  return;
	}
      
    }
  
  if ((*env)->PushLocalFrame (env, 1) < 0)
    {
      // Exception thrown
      return;
    }

  exc = (*env)->NewObject (env, gnu_gnustep_base_NSException, cid, 
			   GSJNI_JStringFromNSString (env, name), 
			   GSJNI_JStringFromNSString (env, reason));
  
  if (exc != NULL)
    {
      // The following always throws an exception.
      (*env)->Throw (env, exc);
    }

  // Clean things
  (*env)->PopLocalFrame (env, NULL);    
}

void JIGSRaiseJExceptionFromNSException (JNIEnv *env, NSException *le)
{ 
  NSString *name;
  NSString *reason;

  if (le == nil)
    {
      name = NSGenericException;
      reason = @"Unknown Reason";
    }
  else
    {
      name = [le name];
      reason = [le reason];
    }

  JIGSRaiseJException (env, name, reason);
}




