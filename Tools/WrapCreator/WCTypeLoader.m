/* WCTypeLoader.m: Loads the type needed

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

/* This class knows all the WCType concrete subclasses, and creates 
   the right one for the right objective-C type. */

#include "WCBOOLType.h"
#include "WCCharType.h"
#include "WCDoubleType.h"
#include "WCIdType.h"
#include "WCFloatType.h"
#include "WCIntType.h"
#include "WCMorphType.h"
#include "WCObjectType.h"
#include "WCType.h"
#include "WCTypeLoader.h"
#include "WCUnsignedIntType.h"
#include "WCVoidType.h"

/* Default morphing types.  Oh - it would be nice to have constant objects */
#define DEFAULT_MORPHTYPES_NUMBER 5

static const struct morphType
{ 
  NSString *objcName; 
  NSString *javaName; 
  NSString *jniName;
  NSString *java2objc; 
  NSString *objc2java; 
} defaultMorphTypes[DEFAULT_MORPHTYPES_NUMBER] = {
  { @"NSString *", @"String", @"jstring", 
    @"GSJNI_NSStringFromJString", @"GSJNI_JStringFromNSString"},

  { @"NSPoint", @"NSPoint", @"jobject", 
    @"JIGSNSPointConvertToStruct", @"JIGSNSPointConvertToJobject"},

  { @"NSSize", @"NSSize", @"jobject", 
    @"JIGSNSSizeConvertToStruct", @"JIGSNSSizeConvertToJobject"},

  { @"NSRect", @"NSRect", @"jobject", 
    @"JIGSNSRectConvertToStruct", @"JIGSNSRectConvertToJobject"},

  { @"NSRange", @"NSRange", @"jobject", 
    @"JIGSNSRangeConvertToStruct", @"JIGSNSRangeConvertToJobject"}
  
};

@implementation WCTypeLoader

/* name should already be normalized */
+ (id) typeWithObjcType: (NSString *)name
{
  int i;

  if ([name isEqualToString: @"void"] == YES)
    {
      return [[WCVoidType alloc] initWithObjcType: @"void"];
    }

  if ([name isEqualToString: @"id"] == YES)
    {
      return [[WCIdType alloc] initWithObjcType: @"id"];
    }

  if ([name isEqualToString: @"BOOL"] == YES)
    {
      return [[WCBOOLType alloc] initWithObjcType: @"BOOL"];
    }

  if (([name isEqualToString: @"int"] == YES) 
      || ([name isEqualToString: @"signed"] == YES) 
      || ([name isEqualToString: @"signed int"] == YES))
    {
      return [[WCIntType alloc] initWithObjcType: name];
    }

  if (([name isEqualToString: @"unsigned int"] == YES) 
      || ([name isEqualToString: @"unsigned"] == YES))
    {
      return [[WCUnsignedIntType alloc] initWithObjcType: name];
    }

  if ([name isEqualToString: @"unsigned char"] == YES)
    return [[WCCharType alloc] initWithObjcType: name  signed: NO];

  if ([name isEqualToString: @"signed char"] == YES)
    return [[WCCharType alloc] initWithObjcType: name  signed: YES];

  if ([name isEqualToString: @"char"] == YES)
#if CHAR_MIN == 0
    return [[WCCharType alloc] initWithObjcType: name  signed: NO];
#else
  return [[WCCharType alloc] initWithObjcType: name  signed: YES];
#endif
  
  if ([name isEqualToString: @"float"] == YES)
    return [[WCFloatType alloc] initWithObjcType: name];

  if ([name isEqualToString: @"double"] == YES)
    return [[WCDoubleType alloc] initWithObjcType: name];

  for (i = 0; i < DEFAULT_MORPHTYPES_NUMBER; i++)
    {
      struct morphType morph = defaultMorphTypes[i];

      if ([name isEqualToString: morph.objcName])
	{
	  return [[WCMorphType alloc] initWithObjcType: name
				      javaType: morph.javaName
				      jniType: morph.jniName
				      javaToObjcFunction: morph.java2objc
				      objcToJavaFunction: morph.objc2java];
	}
    }
  
  if ([name hasSuffix: @"*"] == YES)
    {
      /* name is a wrapped objective-C class */ 
      return [[WCObjectType alloc] initWithObjcType: name];
    }
  
  [NSException raise: NSGenericException
	       format: @"Unknown objective-C type %@", name];
  return nil;
}

@end

  
