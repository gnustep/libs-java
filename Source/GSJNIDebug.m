/* GSJNIDebug.m -  Debugging utilities
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

#include "GSJNIDebug.h"

// Return nil upon exception raised
NSString *GSJNI_DescriptionOfJObject (JNIEnv *env, jobject object)
{
  jclass class;
  jmethodID jid;
  jstring j;
  jthrowable exception;
  NSString *className;
  NSString *string;

  if (object == NULL)
    {
      return @"null";
    }
  
  // Expired Global Weak Reference
  if ((*env)->IsSameObject (env, object, NULL))
    {
      NSLog (@"WARNING! Expired Weak Global Reference Passed "
	     @"to GSJNI_DescriptionOfJObject");
      return @"Expired Weak global Reference (to a Object)";
    }  
  
  // OK - we assume it is a java/lang/Object

  if ((*env)->PushLocalFrame (env, 2) < 0)
    {
      NSLog (@"PROBLEM! PushLocalFrame failed in debugging routine!");
      return nil;
    }      

  // Get object's class
  class  = (*env)->GetObjectClass (env, object);

  // Start with the class description.
  className = GSJNI_DescriptionOfJClass (env, class);

  if (className == nil)
    {
      // Print a debug message and clear the exception
      (*env)->ExceptionDescribe (env);
      NSLog (@"PROBLEM! Exception while trying to get class description "
	     @"in debugging routine!");
      // Try to go on anyway
      className = @"[Problem getting class name]";
    }

  className = [NSString stringWithFormat: @"<%@>", className];
  
  // Get the instance method toString of the class
  jid = (*env)->GetMethodID (env, class, "toString", "()Ljava/lang/String;");
  if (jid == NULL)
    {
      NSLog (@"Could not get method ID of toString in debugging routine!");
      (*env)->PopLocalFrame (env, NULL);
      return [NSString stringWithFormat: @"%@ toString failed", className];
    }
  
  // Invoke the method on the argument
  j = (*env)->CallObjectMethod (env, object, jid);
  
  exception = (*env)->ExceptionOccurred (env);
  if (exception)  // Oh oh - something is really wrong here
    {
      // Print a debug message
      (*env)->ExceptionDescribe (env);
      NSLog (@"Exception while trying to invoke toString object "
	     @"in debugging routine!");
      (*env)->PopLocalFrame (env, NULL);
      return [NSString stringWithFormat: @"%@ toString failed", className];
    }
  
  string = GSJNI_NSStringFromASCIIJString (env, j);
  
  if (string != nil)
    {
      string = [NSString stringWithFormat: @"%@ %@", className, string];
    }
  else
    {
      string = [NSString stringWithFormat: @"%@ toString failed", className];
    }

  (*env)->PopLocalFrame (env, NULL);
  return string;
}

// Return nil upon exception raised
NSString *GSJNI_DescriptionOfJClass (JNIEnv *env, jclass class)
{
  static jclass java_lang_Class; // Cached
  static jmethodID jid = NULL;   // Cached
  jstring j;
  jthrowable exception;
  NSString *returnString;

  // Null
  if (class == NULL)
    {
      return @"Null";
    }

  // Expired Global Weak Reference
  if ((*env)->IsSameObject (env, class, NULL))
    {
      NSLog (@"WARNING! Expired Weak Globale Reference Passed "
	     @"to GSJNI_DescriptionOfJClass");
      return @"Expired Weak global Reference (to a Class ?)";
    }
  
  // Initialize java_lang_Class if needed
  if (java_lang_Class == NULL)
    {
      java_lang_Class = GSJNI_NewGlobalClassCache (env, "java/lang/Class");
      if (java_lang_Class == NULL)
	{
	  NSLog (@"WARNING! Could not get global reference to ");
	  NSLog (@"java/lang/Class in GSJNI_DescriptionOfJClass");
	  // Exception thrown
	  return nil;
	}
    }
  
  if ((*env)->IsInstanceOf (env, class, java_lang_Class) == NO)
    {
      // We don't invoke descriptionOfJObject here to avoid any risk
      // of potential loops, since descriptionOfJObject calls us.
      NSLog (@"WARNING! Reference To An Object which is not a Class Passed "
	     @"to GSJNI_DescriptionOfJClass");
      return [NSString stringWithFormat: @"Not Class rather Object"];
    }
  
  if ((*env)->PushLocalFrame (env, 1) < 0)
    {
      NSLog (@"PROBLEM! PushLocalFrame failed in debugging routine!");
      // Exception Thrown
      return nil;
    }      
  
  if (jid == NULL)
    {
      // Get the instance method toString of the 'Class' class
      jid = (*env)->GetMethodID (env, java_lang_Class, "toString", 
				 "()Ljava/lang/String;");
      if (jid == NULL)
	{
	  NSLog (@"PROBLEM! GetMethodID failed in debugging routine!");
	  (*env)->PopLocalFrame (env, NULL);
	  // Exception Thrown
	  return nil;
	}
    }
  
  // Invoke the method on the argument
  j = (*env)->CallObjectMethod (env, class, jid);
  
  exception = (*env)->ExceptionOccurred (env);
  if (exception)  // Oh oh - something is really wrong here
    {
      NSLog (@"PROBLEM! Exception while trying to get class description "
	     @"in debugging routine!");
      (*env)->PopLocalFrame (env, NULL);
      // Exception Thrown
      return nil;
    }
  
  returnString = GSJNI_NSStringFromASCIIJString (env, j);
  (*env)->PopLocalFrame (env, NULL);
  return returnString;
}

