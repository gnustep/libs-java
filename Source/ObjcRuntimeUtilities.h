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

#include <objc/objc-api.h>
#include <objc/thr.h>
#include <Foundation/Foundation.h>

/* 
 * This code could be reused for building interfaces to other languages.
 *
 * It mainly deals with facilities useful for creating Objective-C
 * classes of objects which can act as proxies to objects in other
 * languages.
 *
 * At present this code only works with the GNU Objective-C Runtime, 
 * because we need to access the runtime internal structures to add 
 * classes and methods. 
 *  
 */

/*
 * GSJavaInterface_new_class:
 *
 * Create a new Objective-C class called name, inheriting from
 * superClass.  

 * If ivarNumber is zero, the new class has not any more instance
 * variables than the class it inherits from.

 * Otherwise, appropriate optional arguments should be provided; they
 * should come in couples; the first one is the ivar name, the second
 * one the ivar type.  For example: 
 * GSJavaInterface_new_class ("MyNiceClass", "NSObject", 2, 
 *                             "aJavaObject", @encode (jobject), 
 *                             "tag", @encode (int)); 
 * creates a class as it would be created by
 *
 * @interface MyNiceClass : NSObject 
 * {
 *   jobject aJavaObject;
 *   int     tag;
 * }
 * @end

 * Return NO upon failure (because the class already exists or the
 * superclass does not exist), and YES upon success.
 
 * This method is completely general and could be used in other 
 * interfaces.  */

BOOL
GSJavaInterface_new_class
(const char *name, const char *superclassName, int ivarNumber, ...);

/*
 * GSJavaInterface_add_method_list:
 *
 * Add the list `ml' of methods to an existing Class `class'.
 * They are registered as instance methods. 
 * To add class methods, you simply need to pass the meta class 
 * [(Class)class->class_pointer] instead of the class.
 *
 * This method is completely general and could be used in other
 * interfaces.  Actually, it could be in the objc runtime itself.
 * 
 */

void 
GSJavaInterface_add_method_list 
(Class class, MethodList *ml);

/*
 * GSJavaInterface_build_runtime_Objc_signature:
 *
 * This method creates a runtime objc signature which can be used 
 * to describe type for a selector *on this machine* (you need this 
 * signature for example to build the MethodList to pass to the 
 * GSJavaInterface_add_method_list above).
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
 * On my machine, GSJavaInterface_build_runtime_Objc_signature ("i@:@")
 * returns "i12@0:4@8", which I can then use as selector type when 
 * creating entries in MethodList.
 *
 */

inline const char *
GSJavaInterface_build_runtime_Objc_signature 
(const char *);

#endif /* __ObjcRuntimeUtilitis_h_GNUSTEP_JAVA_INCLUDE */






















