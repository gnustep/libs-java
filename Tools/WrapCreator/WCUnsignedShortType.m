/* WCUnsignedShortType.m

   Copyright (C) 2000 Free Software Foundation, Inc.

   Author:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: August 2000, February 2001
   
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

#include "WCUnsignedShortType.h"

@implementation WCUnsignedShortType 

- (id) initWithObjcType: (NSString *)aType
{
  self = [super initWithObjcType: aType];
  ASSIGN (objcType, aType);
  if (sizeof (unsigned short) == 2)
    {
      javaType = @"char";
      jniType = @"jchar";
      javaArgumentType = @"C";
    }
  else if (sizeof (unsigned short) == 4)
    {
      javaType = @"long";
      jniType = @"jlong";
      javaArgumentType = @"J";
    }
  else 
    {
      NSLog (@"Warning: sizeof unsigned short is weird.");
      javaType = @"char";
      jniType = @"jchar";
      javaArgumentType = @"C";
    }

  return self;
}
@end

