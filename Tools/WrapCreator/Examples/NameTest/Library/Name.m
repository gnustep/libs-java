/* Name.m -  A demo library doing nothing useful -*-objc-*-
   Copyright (C) 2001 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: May 2001
   
   This file is part of the GNUstep Java Interface Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
   */ 

#include "Name.h"

@implementation Name

- (id) init
{
  ASSIGN (name, @"");
  return [super init];
}

- (NSString *)name
{
  return name;
}

- (void)setName: (NSString *)aName
{
  if (delegate != nil)
    {
      if ([delegate respondsToSelector: @selector (nameShouldChange:)])
	{
	  if (![delegate nameShouldChange: aName])
	    {
	      return;
	    }
	}
    }
  
  ASSIGN (name, aName);
}

- (void)setDelegate: (id)aDelegate
{
  delegate = aDelegate;
}

- (id)delegate
{
  return delegate;
}

@end

