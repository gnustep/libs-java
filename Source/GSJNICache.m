/* GSJNICache.m - Caching facilities
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

#include "GSJNICache.h"

// Return NULL upon exception raised
jclass GSJNI_NewGlobalClassCache (JNIEnv *env, const char *className)
{
  jclass tmp_local_ref;
  jclass ret_global_ref;

  if ((*env)->PushLocalFrame (env, 1) < 0)
    {
      // Exception Thrown
      return NULL;
    }      
  
  tmp_local_ref = (*env)->FindClass (env, className);
  if (tmp_local_ref == NULL)
    {
      // Exception Thrown
      (*env)->PopLocalFrame (env, NULL);
      return NULL;
    }
      
  ret_global_ref = (*env)->NewGlobalRef (env, tmp_local_ref);
  if (ret_global_ref == NULL)
    {
      // Exception Thrown
      (*env)->PopLocalFrame (env, NULL);
      return NULL;
    }
  
  (*env)->PopLocalFrame (env, NULL);
  return ret_global_ref;
}

