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

public class NSArray10Benchmark implements Benchmark
{
  NSMutableArray a;
  Object o;

  public NSArray10Benchmark ()
  {
    a = new NSMutableArray ();

    /* Put a few (1000) objects in the array to simulate some real
       life stress situation ... this fills a bit the JIGS internal
       tables ... performance in this case is affected by how good the
       tables are.  */
    int i;
    for (i = 0; i < 1000; i++)
      {
	a.addObject (new Object ());
      }
    o = new Object ();
  }

  public String name ()
  {
    return "Adding then Removing a java Object from a NSMutableArray";
  }

  public Object executeBasicOperation ()
  {
    a.addObject (o);
    a.removeObjectAtIndex (1000);
    
    return a;
  }
}
