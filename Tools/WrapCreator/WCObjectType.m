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
#include "WCLibrary.h"

@implementation WCObjectType 

/* Warning: we assume aType is like in @"NSString *"  */
- (id) initWithObjcType: (NSString *)aType
{
  NSMutableString *type;
  NSString *name;

  self = [super initWithObjcType: aType];

  type = [NSMutableString stringWithString: aType];
  /* Remove the last "*" */
  [type deleteCharactersInRange:  NSMakeRange ([type length] - 1, 1)];
  /* Remove remaining spaces */
  [type trimTailSpaces];
  /* Now ask the library to do the mapping - this returns a full 
     java name (such as gnu.gnustep.gui.NSCell) or nil. */
  name = [WCLibrary javaClassNameForObjcClassName: type];
  if (name == nil)
    {
      /* No luck.  Use the objc name for the short java name, 
	 leave the long java name unknown.  This usually is not of 
	 particular harm. */
      ASSIGN (javaType, type);
      longJavaType = nil;
    }
  else
    {
      /* Lucky !  We have both the short and the long java name */
      ASSIGN (javaType, [name pathExtension]);
      if ([javaType isEqual: @""])
	{
	  ASSIGN (javaType, name);
	}

      ASSIGN (longJavaType, name);
    }

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
  if (longJavaType != nil)
    {
      return [NSString stringWithFormat: @"L%@;", longJavaType];
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

