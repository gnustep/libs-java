/* gnu/gnustep/java/JIGSLibraryLoader.java Native code
   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: September 2000
   
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
#include "gnu/gnustep/java/JIGSLibraryLoader.h"
#include <stdlib.h>

#define result_yes 1
#define result_no -1
#define result_undefined 0

JNIEXPORT jint JNICALL 
Java_gnu_gnustep_java_JIGSLibraryLoader_debuggingEnabled (JNIEnv *env, 
							  jclass this)
{
  char *result;

  result = getenv ("JIGS_DEBUG");

  if (result == NULL)
    return result_undefined;

  if (!strcmp (result, "yes")) // result == "yes"
    return result_yes;

  if (!strcmp (result, "YES")) // result == "YES"
    return result_yes;
  
  return result_no;
}

