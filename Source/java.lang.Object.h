/* Object.h - Objective-C wrapper for the Java Object class

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

#ifndef __java_lang_Object_h_GNUSTEP_JAVA_INCLUDE
#define __java_lang_Object_h_GNUSTEP_JAVA_INCLUDE

#include <jni.h>
#include <Foundation/Foundation.h>

/*
 * Explanation:
 *
 * This is a fake interface with no implementation.
 * 
 * At run-time, we will dynamically generate a class, called
 * 'java.lang.Object' which implements this interface.
 *
 * We can't compile it at compile time because of the dots 
 * in the name.
 *
 * The interface _java_lang_Object is useful only inside the JIGS -
 * don't use it in application code.  It is used as follows: whenever
 * we have an object which we know that at run-time will be of class
 * java.lang.Object, we can safely cast it to a _java_lang_Object
 * object, and then access its ivar directly, as follows:
 *
 * (_java_lang_Object *)object->realObject 
 */


@interface _java_lang_Object : NSObject
{
  @public
  // A pointer to the real java object we are proxying.
  jobject realObject;
}
@end

// The java.lang.Object class has a 'dealloc' implementation, which is 
// loaded in the class at run-time.  See JIGSProxy.m.

#endif /* __java_lang_Object_h_GNUSTEP_JAVA_INCLUDE */
