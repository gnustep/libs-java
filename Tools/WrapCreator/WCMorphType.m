/* WCMorphType.m                                             -*-objc-*-

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

#include "WCMorphType.h"

@implementation WCMorphType

- (id) initWithObjcType: (NSString *)name
	       javaType: (NSString *)javaName
		jniType: (NSString *)jniName
     javaToObjcFunction: (NSString *)java2objc
     objcToJavaFunction: (NSString *)objc2java
{
  self = [super initWithObjcType: name];
  ASSIGN (javaType, javaName);
  ASSIGN (jniType, jniName);
  ASSIGN (javaToObjcFunction, java2objc);
  ASSIGN (objcToJavaFunction, objc2java);
  return self;
}

- (NSString *) description
{
  NSString *output;

  output = [NSString stringWithFormat: @"<WCMorphType objcType: %@ javaType: %@ "
		     @"jniType: %@ java2objc: %@ objc2java: %@>", 
		     objcType, javaType, jniType, javaToObjcFunction, 
		     objcToJavaFunction];
  return output;
}


- (NSString *) javaType
{
  return javaType;
}

- (NSString *) jniType
{
  return jniType;
}

- (NSString *) codeToConvertToObjc: (NSString *)jniArgument
		      givingResult: (NSString *)objcResult
{
  NSString *output;

  output = [NSString stringWithFormat: @"%@ = %@ (env, %@);", 
		     objcResult, javaToObjcFunction, jniArgument];

  return output;
}

- (NSString *) codeToConvertToJava: (NSString *)objcArgument
		      givingResult: (NSString *)jniResult;
{
  NSString *output;

  output = [NSString stringWithFormat: @"%@ = %@ (env, %@);", 
		     jniResult, objcToJavaFunction, objcArgument];

  return output;
}

@end

