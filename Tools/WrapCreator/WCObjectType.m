/* WCObjectType.m                                           -*-objc-*-

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

#include "WCObjectType.h"

@implementation WCObjectType 

/* Warning: we assume aType is like in @"NSString *"  */
- (id) initWithObjcType: (NSString *)aType
{
  NSMutableString *type;

  self = [super initWithObjcType: aType];

  type = [NSMutableString stringWithString: aType];
  /* Remove the last "*" */
  [type deleteCharactersInRange:  NSMakeRange ([type length] - 1, 1)];
  /* Remove remaining spaces */
  [type trimTailSpaces];
  /* Store it for later use */
  ASSIGN (javaType, type);

  return self;
}

- (NSString *) description
{
  return [NSString stringWithFormat: @"<WCObjectType objcType: %@>", objcType];
}

- (NSString *) javaType
{
  return javaType;
}

- (NSString *) javaArgumentType
{
  /* We hard-code the most basic and common guesses at all */
  if ([javaType isEqualToString: @"NSArray"])
    {
      return @"Lgnu.gnustep.base.NSArray;";
    }
  else if ([javaType isEqualToString: @"NSDictionary"])
    {
      return @"Lgnu.gnustep.base.NSDictionary;";
    }
  else if ([javaType isEqualToString: @"NSMutableArray"])
    {
      return @"Lgnu.gnustep.base.NSMutableArray;";
    }
  else if ([javaType isEqualToString: @"NSMutableDictionary"])
    {
      return @"Lgnu.gnustep.base.NSMutableDictionary;";
    }
  else if ([javaType isEqualToString: @"NSNotification"])
    {
      return @"Lgnu.gnustep.base.NSNotification;";
    }

  /* This has to be determined at run-time */
  return nil;
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

