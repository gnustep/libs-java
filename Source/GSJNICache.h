/* GSJNICache.h - Caching facilities
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

#ifndef __GSJNICache_h_GNUSTEP_JAVA_INCLUDE
#define __GSJNICache_h_GNUSTEP_JAVA_INCLUDE

#include <jni.h>

/*
 * Prepare a global cached reference to a class.
 */

/* Return a new global reference to class className.
 * Return NULL upon exception thrown
 */
jclass GSJNI_NewClassCache (JNIEnv *env, const char *className);

#endif /*__GSJNICache_h_GNUSTEP_JAVA_INCLUDE*/
