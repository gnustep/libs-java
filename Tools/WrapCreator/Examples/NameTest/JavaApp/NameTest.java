/* NameTest.java -  Useless java code testing running Objc stuff using JIGS
   Copyright (C) 2001 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: May 2001
   
   This file is part of JIGS, the GNUstep Java Interface Library.

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

import gnu.gnustep.base.*;

class NameTest
{
  public boolean nameShouldChange (String newName)
  {
    if (newName.equals ("Micro$oft"))
      {
	return false;
      }

    return true;
  }

  public static void failed (String why)
  {
    System.out.println (why + " ==> test FAILED");
    System.exit (1);
  }

  public void test ()
  {
    Name name = new Name ();
    
    name.setName ("Test");
    if (!(name.name ()).equals ("Test"))
      {
	failed ("Could not set name to Test");
      }

    name.setName ("Test2");
    if (!(name.name ()).equals ("Test2"))
      {
	failed ("Could not set name to Test2");
      }

    NSObject.retainObject (this);
    name.setDelegate (this);

    if (!(name.delegate () == this))
      {
	failed ("Could not set delegate");	
      }

    name.setName ("Test3");
    if (!(name.name ()).equals ("Test3"))
      {
	failed ("Could not set name to Test3");
      }

    name.setName ("Micro$oft");
    if (!(name.name ()).equals ("Test3"))
      {
	failed ("Argh - Could set name to Micro$oft");
      }

    System.out.println ("Test passed.  Sleep well.");   
  }
  
  
  public static void main (String[] args)
  {
    NameTest test = new NameTest ();
    
    test.test ();
  }
}
