/* ObjcRuntimeUtilities.h - Utilities to add classes and methods 
   in the Objective-C runtime, at runtime.

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

#ifndef __ObjcRuntimeUtilities_h_GNUSTEP_JAVA_INCLUDE
#define __ObjcRuntimeUtilities_h_GNUSTEP_JAVA_INCLUDE

/* 
 * This code is by no means tied to Java.  
 */

/*
 * ObjcUtilities_build_runtime_Objc_signature:
 *
 * This method creates a runtime objc signature which can be used 
 * to describe type for a selector *on this machine* (you need this 
 * signature for example to add a method to class, using the
 * class_addMethod function).
 *
 * It takes as argument a 'naive' objc signature, in the form of 
 * a string obtained by concatenating the following strings: 
 *
 * @encode(return_type)
 *
 * @encode(Class) if it's a class method, or @encode(id) if it's an
 * instance method (corresponding to the first hidden argument, self)
 *
 * @encode(SEL) (corresponding to the second hidden argument, the selector)
 *
 * @encode(arg1) @encode(arg2) ... if there are any real arguments. 
 * 
 * An example is: 
 * "i@:@" for an instance method returning int and taking an object arg. 
 * (NB: "i" = @encode(int), "@" = @encode(id), ":" = @encode(SEL)).
 *
 * On my machine, ObjcUtilities_build_runtime_Objc_signature ("i@:@")
 * returns "i12@0:4@8", which I can then use as selector type when 
 * adding a method to a class.
 *
 */

const char *ObjcUtilities_build_runtime_Objc_signature (const char *);

#endif /* __ObjcRuntimeUtilitis_h_GNUSTEP_JAVA_INCLUDE */
