/* 

   Copyright (C) 2001 Free Software Foundation, Inc.

   Author:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: November 2001
   
   This file is part of GNUstep.
   
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

import gnu.gnustep.base.*;

public class NSArray3Benchmark implements Benchmark
{
  NSMutableArray a;

  public NSArray3Benchmark ()
  {
    a = new NSMutableArray ();
    a.addObject ("Nicola");
  }

  public String name ()
  {
    return "Replacing a string in a NSMutableArray";
  }

  public Object executeBasicOperation ()
  {
    a.replaceObjectAtIndex (0, "Nicola");
    return a;
  }
}
