/* GSJNIArray.m - Conversion to/from JNI Arrays
   Copyright (C) 2001 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: February 2001
   
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

#include "GSJNIArray.h"

NSData *GSJNI_initNSDataFromJbyteArray (JNIEnv *env, NSData *data, 
					       jbyteArray array)
{
  NSData *returnData;
  jbyte *bytes;
  unsigned length;

  length = (*env)->GetArrayLength (env, array);

  bytes = (*env)->GetByteArrayElements (env, array, NULL);
  if (bytes == NULL)
    {
      /* OutOfMemoryError */
      return nil;
    }

  returnData = [data initWithBytes: bytes  length: length];
  
  (*env)->ReleaseByteArrayElements (env, array, bytes, 0);

  return returnData;
}

NSData *GSJNI_NSDataFromJbyteArray (JNIEnv *env, jbyteArray array)
{
  return AUTORELEASE (GSJNI_initNSDataFromJbyteArray (env, [NSData alloc], 
						      array));
}

jbyteArray GSJNI_jbyteArrayFromNSData (JNIEnv *env, NSData *data)
{
  const jbyte *bytes;
  unsigned length;
  jbyteArray javaArray;
  
  length = [data length];
  bytes = [data bytes];

  javaArray = (*env)->NewByteArray (env, length);
  if (javaArray == NULL)
    {
      /* OutOfMemory exception thrown */
      return NULL;
    }
  
  (*env)->SetByteArrayRegion (env, javaArray, 0, length, (jbyte *)bytes);
  if ((*env)->ExceptionCheck (env))
    {
      /* No reason for this to happen - except a bug in NSData */
      return NULL;
    }
  
  return javaArray;
}

