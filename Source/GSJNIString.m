/* GSJNIString.m - Conversion to/from JNI Strings
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

#include "GSJNIString.h"

// Return NULL upon exception raised.
inline NSString *
GSJNI_NSStringFromASCIIJString (JNIEnv *env, jstring string)
{
  char *cString;
  NSString *gnustepString;

  // Get a C string from the jstring
  cString = (char *)(*env)->GetStringUTFChars (env, string, NULL);
  if (cString == NULL)
    {
      // OutOfMemoryError thrown
      return NULL;
    }
  
  // Create a GNUstep string from the C string
  gnustepString = [NSString stringWithCString: cString];
  
  // Release the C string
  (*env)->ReleaseStringUTFChars (env, string, cString);
  
  return gnustepString;
}

// NB: Return NULL upon exception raised.
inline jstring
GSJNI_JStringFromASCIINSString (JNIEnv *env, NSString *string)
{
  return (*env)->NewStringUTF (env, [string cString]);
}

// NB: Return NULL upon exception thrown.
inline NSString *
GSJNI_NSStringFromJString (JNIEnv *env, jstring string)
{
  unichar *uniString;
  jsize length;
  NSString *gnustepString;
  
  // Get a Unicode string from the jstring
  uniString = (unichar *)(*env)->GetStringChars (env, string, NULL);
  if (uniString == NULL)
    {
      // OutOfMemoryError thrown
      return NULL;
    }
  
  // Get the Unicode string length
  length = (*env)->GetStringLength (env, string);
  
  // Create a GNUstep string from the Unicode string
  gnustepString = [NSString stringWithCharacters: uniString 
			    length: length];
  
  // Release the C string
  (*env)->ReleaseStringChars (env, string, uniString);
  
  return gnustepString;  
}

// NB: Return NULL upon exception thrown
inline jstring
GSJNI_JStringFromNSString (JNIEnv *env, NSString *string)
{
  jstring javaString;
  int length = [string length];
  unichar uniString[length];

  // Get a unicode representation of the string in the buffer
  [string getCharacters: uniString];

  // Create a java string using the buffer
  javaString = (*env)->NewString (env, uniString, length);
  // NB: if javaString is NULL, an exception has been thrown.

  return javaString;
}

