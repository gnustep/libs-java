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

import java.util.*;
import gnu.gnustep.base.*;

public class Hashtable3Benchmark implements Benchmark
{
  Hashtable a;
  NSObject o;
    
  public Hashtable3Benchmark ()
  {
    a = new Hashtable ();
    a.put ("Nicola", "Name");
    a.put ("Uno", "One");
    a.put ("Due", "Two");
    a.put ("Tre", "Three");
    o = new NSObject ();    
    a.put (o, "Four");
  }

  public String name ()
  {
    return "Getting the string value for a NSObject key from a Hashtable";
  }

  public Object executeBasicOperation ()
  {
    return a.get (o);
  }
}
