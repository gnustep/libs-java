/* GSJNIClass.m - Class name related utilities
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

// Eg, converts java.lang.String to java/lang/String
NSString *GSJNI_ConvertJavaClassNameToJNI (NSString *name)
{
  // Use a GNUstep extension for now. 
  return [name stringByReplacingString: @"." withString: @"/"];
}


// Eg, converts java/lang/String to java.lang.String
NSString *GSJNI_ConvertJavaClassNameFromJNI (NSString *name)
{
  // Use a GNUstep extension for now. 
  return [name stringByReplacingString: @"/" withString: @"."];
}

NSString *GSJNI_NSStringFromClassOfObject (JNIEnv *env, jobject object)
{
  static jclass java_lang_Class = NULL; // Cached
  static jmethodID jid = NULL;          // Cached
  jclass class;
  jstring j;
  NSString *returnString;

  if (object == NULL)
    {
      // Should probably raise an exception instead
      return @"Null";
    }
  
  if ((*env)->PushLocalFrame (env, 2) < 0)
    {
      return nil;
    }      
  
  // Get object's class
  class  = (*env)->GetObjectClass (env, object);
  
  // Initialize java_lang_Class if needed
  if (java_lang_Class == NULL)
    {
      java_lang_Class = GSJNI_NewGlobalClassCache (env, "java/lang/Class");
      if (java_lang_Class == NULL)
	{
	  // Exception thrown
	  return nil;
	}
    }
  
  if (jid == NULL)
    {
      jid = (*env)->GetMethodID (env, java_lang_Class, "getName", 
				 "()Ljava/lang/String;");
      if (jid == NULL)
	{
	  (*env)->PopLocalFrame (env, NULL);
	  // Exception Thrown
	  return nil;
	}
    }
  
  // Ask for the name of the class
  j = (*env)->CallObjectMethod (env, class, jid);
  
  if ((*env)->ExceptionCheck (env)) // Oh oh - something really weird 
    {
      (*env)->PopLocalFrame (env, NULL);
      // Exception Thrown
      return nil;
    }
  
  returnString = GSJNI_NSStringFromASCIIJString (env, j);
  (*env)->PopLocalFrame (env, NULL);
  return returnString;
}

inline NSString *GSJNI_ShortClassNameFromLongClassName (NSString *className)
{
  NSString *shortClassName;

  shortClassName = [className pathExtension];
  
  if ([shortClassName isEqual: @""] == NO)
    {
      return shortClassName;
    }
  else
    {
      return className;
    }
}
