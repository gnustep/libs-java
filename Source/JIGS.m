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
  CREATE_AUTORELEASE_POOL (JIGSInitPool);
  JIGSInit (env);
  RELEASE (JIGSInitPool);
}

