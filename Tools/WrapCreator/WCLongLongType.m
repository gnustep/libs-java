/* WCLongLongType.m                                            -*-objc-*-

   Copyright (C) 2001 Free Software Foundation, Inc.

   Author:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: May 2001
   
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

#include "WCLongLongType.h"

@implementation WCLongLongType 

- (id) initWithObjcType: (NSString *)aType
{
  self = [super initWithObjcType: aType];
  ASSIGN (objcType, aType);

  if (sizeof (long long) != 8)
    {
      NSLog (@"Warning - long long is too big.");
    }
  
  javaType = @"long";
  jniType = @"jlong";
  javaArgumentType = @"J";

  return self;
}
@end

