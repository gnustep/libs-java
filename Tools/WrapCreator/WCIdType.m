/* WCIdType.m                                                 -*-objc-*-

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

#include "WCIdType.h"

/* An `id' is not an `NSObject' because if you declare a method to
   take an `id' argument, you can pass to it any java object in Java,
   while if you declare it to take an `NSObject' argument, you can
   pass to it in java only objects of class NSObject or a subclass. */

@implementation WCIdType 

- (id) initWithObjcType: (NSString *)aType
{
  self = [super initWithObjcType: @"id"];

  return self;
}

- (NSString *) description
{
  return [NSString stringWithFormat: @"<WCIdType>"];
}

- (NSString *) javaType
{
  return @"Object";
}

- (NSString *) jniType
{
  return @"jobject";
}

- (NSString *) codeToConvertToObjc: (NSString *)jniArgument
		      givingResult: (NSString *)objcResult
{
  return [NSString stringWithFormat: @"%@ = JIGSIdFromJobject (env, %@);",
		   objcResult, jniArgument];
}

- (NSString *) codeToConvertToJava: (NSString *)objcArgument
		      givingResult: (NSString *)jniResult;
{
  return [NSString stringWithFormat: @"%@ = JIGSJobjectFromId (env, %@);",
		   jniResult, objcArgument];
}
@end

