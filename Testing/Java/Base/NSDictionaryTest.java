/* NSDictionaryTest: test of gnu.gnustep.base.NSDictionary

   Copyright (C) 2001 Free Software Foundation, Inc.

   Author:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: February 2001
   
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

class NSDictionaryTest
{ 
  public static void main (String[] args) 
    throws Throwable
  {
    NSMutableDictionary dictionaryOne;
    NSDictionary dictionaryTwo;
    NSArray arrayOne;
    NSArray arrayTwo;
    boolean testEquality;
    
    /* Create a NSMutableDictionary */
    System.out.println ("Creating a mutable dictionary and putting stuff in it...");
    dictionaryOne = new NSMutableDictionary ();    

    dictionaryOne.setObjectForKey ("value1", "key1");
    dictionaryOne.setObjectForKey ("value2", "key2");
    dictionaryOne.setObjectForKey ("value1", "key3");
    dictionaryOne.setObjectForKey ("value2", "key4");
    dictionaryOne.setObjectForKey ("value1", "key5");
    dictionaryOne.setObjectForKey ("value2", "key1");

    System.out.println ("Got " + dictionaryOne);
    System.out.println ("");

    System.out.println ("Creating a dictionary from the first one");
    dictionaryTwo = new NSDictionary (dictionaryOne);
    System.out.println ("Got " + dictionaryTwo);
    System.out.println ("");

    System.out.println ("Getting the keys");
    arrayOne = dictionaryTwo.allKeys ();
    System.out.println ("Got " + arrayOne);
    System.out.println ("");

    System.out.println ("For each key, getting the value and checking it's value1 or value2");
    for (int i = 0; i < arrayOne.count (); i++)
      {
	Object object, expected;
	object = dictionaryOne.objectForKey (arrayOne.objectAtIndex (i));
	
	if (!object.equals ("value1") && !object.equals ("value2"))
	  {
	    System.out.println (object + " is not value1 or value2");
	    System.out.println ("==> test failed");
	    System.exit (1);
	  }
      }
    System.out.println ("Yes - check passed");
    System.out.println ("");

    System.out.println ("Now creating a dictionary from two java arrays");
    dictionaryTwo = new NSDictionary (new String [] { "value0", "value1" },
				      new String [] { "key0", "key1" });
    System.out.println ("Got " + dictionaryTwo);
    
    /* Happy end */
    System.out.println ("test passed");
  }

}
