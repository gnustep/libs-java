/* WCType.m: A class for objc/java type conversion -*-objc-*-

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

#include "WCType.h"
#include "WCTypeLoader.h"

static NSMutableArray *registeredTypes;

//static
NSString *normalizeObjcType (NSString *objcType)
{
  NSScanner *scanner;
  NSString *string;
  NSMutableString *outputString;
  static NSCharacterSet *whitespace = nil;

  if (whitespace == nil)
    {
      whitespace = RETAIN ([NSCharacterSet whitespaceAndNewlineCharacterSet]);
    }

  outputString = [NSMutableString new];

  objcType = [objcType stringByReplacingString: @"*" withString: @" *"];

  scanner = [NSScanner scannerWithString: objcType];

  while (1)
    {
      [scanner scanUpToCharactersFromSet: whitespace intoString: &string];
      [outputString appendString: string];
      [scanner scanCharactersFromSet: whitespace intoString: NULL];
      if ([scanner isAtEnd] == YES)
	{
	  break;
	}
      [outputString appendString: @" "];
    }

  return AUTORELEASE ([outputString copy]);
}

@implementation WCType

+ (void) initialize 
{
  if (self == [WCType class])
    {
      registeredTypes = [NSMutableArray new];
    }
}

+ (id) sharedTypeWithObjcType: (NSString *)name
{
  WCType *t; 

  name = [name stringByTrimmingSpaces];
  name = normalizeObjcType (name);

  t = [self existingSharedTypeWithObjcType: name];
  if (t != nil)
    {
      return t;
    }
  else
    {
      return [WCTypeLoader typeWithObjcType: name];
    }
}

+ (WCType *) existingSharedTypeWithObjcType: (NSString *)name
{
  int i;

  for (i = 0; i < [registeredTypes count]; i++)
    {
      WCType *t = [registeredTypes objectAtIndex: i];
      
      if ([t->objcType isEqualToString: name] == YES)
	{
	  return t;
	}
    }
  return nil;
}

- (id) init
{
  [NSException raise: NSGenericException
	       format: @"Bug: [WCType -init] should never get called!"];
  return nil;
}

/* This registers the object in the registeredTypes array */
- (id) initWithObjcType: (NSString *)type
{
  WCType *t;

  /* Safety check */
  t = [isa existingSharedTypeWithObjcType: type];
  if (t != nil)
    { 
      RELEASE (self);
      return t;
    }
  else 
    {
      ASSIGN (objcType, type);
      [registeredTypes addObject: self];
      return self;
    }
}

- (void) dealloc
{
  RELEASE (objcType);
}

- (NSString *) description
{
  return [NSString stringWithFormat: @"<WCType objcType: %@>", objcType];
}

- (NSString *) objcType
{
  return objcType;
}

- (NSString *) javaType
{
  [self subclassResponsibility: _cmd];
  return nil;
}

- (NSString *) jniType
{
  [self subclassResponsibility: _cmd];
  return nil;
}

- (NSString *) javaArgumentType
{
  [self subclassResponsibility: _cmd];
  return nil;
}

- (BOOL) isVoidType
{
  return NO;
}

- (NSString *) codeToConvertToObjc: (NSString *)jniArgument
		      givingResult: (NSString *)objcResult
{
  [self subclassResponsibility: _cmd];
  return nil;
}

- (NSString *) codeToConvertToJava: (NSString *)objcArgument
		      givingResult: (NSString *)jniResult;
{
  [self subclassResponsibility: _cmd];
  return nil;
}
@end

