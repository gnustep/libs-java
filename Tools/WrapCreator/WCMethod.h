/* WCMethod.h: A method to be wrapped          -*-objc-*-

   Copyright (C) 2000 Free Software Foundation, Inc.

   Author:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: August 2000
   
   This file is part of JIGS, the GNUstep Java Interface.
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */

#ifndef __WCMethod_h_GNUSTEP_WrapCreator_INCLUDE
#define __WCMethod_h_GNUSTEP_WrapCreator_INCLUDE

@class WCClass;
@class WCType;

@interface WCMethod : NSObject
{
  WCType *returnType;
  NSString *methodName;
  /* If not-nil, use it instead of guessing it from methodName */
  NSString *javaMethodName;
  /* An array of (Type *) */
  NSArray *arguments;
  BOOL isClassMethod;
  BOOL isConstructor;
  /* We are a method of this class */
  WCClass *class;
}
+ (id) newWithObjcMethodDeclaration: (NSString *)objcMethodDeclaration
			      class: (WCClass *)aClass
		      isConstructor: (BOOL)flag;

- (id) initWithObjcMethodDeclaration: (NSString *)objcMethodDeclaration
			       class: (WCClass *)aClass
		       isConstructor: (BOOL)flag;

- (NSString *) outputJavaWrapper;

- (NSString *) outputObjcWrapper;

- (NSString *) outputSelectorMapping;
@end

@interface WCMethod (InternalMethods)
- (NSString *) outputJavaMethodName;
- (NSString *) outputJavaArguments;
- (NSString *) outputJniMethodName;
- (NSString *) outputJavaArgumentSignature;
@end

#endif
