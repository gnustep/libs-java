/* WCCustomType.m                                               -*-objc-*-

   Copyright (C) 2000 Free Software Foundation, Inc.

   Author:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: September 2000
   
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

#include "WCCustomType.h"
#include "WCType.h"

@implementation WCCustomType 

- (id) initWithObjcType: (NSString *)aType
	  primitiveType: (NSString *)primitiveType
{
  WCPrimitiveType *primitiveTypeObject;

  if ([aType isEqualToString: primitiveType])
    {
      NSLog (@"WARNING: WCCustomType: trying to map %@ to itself!", aType);
      RELEASE (self);
      return (id)[WCType sharedTypeWithObjcType: aType];
    }

  /* Get the primitive type we are typedefing */
  primitiveTypeObject = (WCPrimitiveType *)[WCType sharedTypeWithObjcType: 
						     primitiveType];
  
  if ([primitiveTypeObject isKindOfClass: [WCPrimitiveType class]] == NO)
    {
      [NSException raise: NSGenericException
		   format: @"WCCustomType: Type %@ is not primitive", 
		   primitiveType];
      return nil;
    }
  
  /* All right, proceed */
  self = [super initWithObjcType: aType];
  ASSIGN (objcType, aType);
  ASSIGN (javaType, [primitiveTypeObject javaType]);
  ASSIGN (jniType, [primitiveTypeObject jniType]);
  ASSIGN (javaArgumentType, [primitiveTypeObject javaArgumentType]);

  return self;
}
@end

