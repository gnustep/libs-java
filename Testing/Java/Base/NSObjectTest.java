/* NSObjectTest: test of gnu.gnustep.base.NSObject

   Copyright (C) 2000 Free Software Foundation, Inc.

   Author:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: July 2000
   
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

import gnu.gnustep.base.NSObject;
import gnu.gnustep.base.NSException;

class NSObjectTest
{ 
  public static void main (String[] args) 
    throws Throwable
  {
    NSObject objectOne;
    NSObject objectTwo;
    boolean testEquality;
    
    /* Create two NSObject */
    objectOne = new NSObject ();
    objectTwo = new NSObject (); 
    
    /* Describe them */
    System.out.println ("Created two NSObjects:");
    System.out.println ("* The first one is " + objectOne);
    System.out.println ("* The second one is " + objectTwo);
    System.out.println ("");

    /* Print hashcodes */
    System.out.println ("They have the following hashcodes:");
    System.out.println ("* First object: " + objectOne.hashCode ());
    System.out.println ("* Second object: " + objectTwo.hashCode ());
    System.out.println ("");    

    /* Now we change the object one */
    objectOne = null;
    objectOne = new NSObject ();
    /* Force the system to garbage-collect now. */
    System.gc ();

    /* Print info about the new object */
    System.out.println ("Replaced the first object with a new one:");
    System.out.println ("* The new object is: " + objectOne);
    System.out.println ("* And has hashcode: " + objectOne.hashCode ());
    System.out.println ("");

    /* Right, now test if equality works */
    System.out.println ("Now trying to compare the objects using equals ()");
    compare (objectOne, objectTwo, false);
    compare (objectTwo, objectOne, false);
    compare (objectOne, objectOne, true);
    compare (objectTwo, objectTwo, true);
    compare (objectOne, "\"a java String\"", false);
    compare (objectOne, null, false);
    System.out.println ("");

    /* Now try with the following which should raise an exception */
    System.out.println ("Now trying to clone () " + objectOne);
    System.out.println ("This should raise an exception which we catch");
    testClone (objectOne);
    System.out.println ("");

    /* Happy end */
    System.out.println ("test passed");
  }

  /* Tests - they do not return upon failing */

  public static void compare (Object one, Object two, 
			      boolean expectedResult)
  {
    String output = "* ";
    String descriptionOfOne;
    String descriptionOfTwo;
    boolean result;

    descriptionOfOne = one.toString ();
    if (two != null)
      {
	descriptionOfTwo = two.toString ();
      }
    else
      {
	descriptionOfTwo = "(null)";
      }

    result = one.equals (two);

    if (result)
      {
	output += descriptionOfOne + " and " + descriptionOfTwo
	  + " are equal";
      }
    else
      {
	output += descriptionOfOne + " and " + descriptionOfTwo
	  + " are not equal";
      }
    
    if (result != expectedResult)
      {
	output += " ==> test FAILED";
	System.out.println (output);
	System.exit (1);
      }
    else
      {
	output += " ==> test passed";
	System.out.println (output);
      }
  }

  public static void testClone (NSObject argument)
  {
    boolean testPassed = false;
    
    try 
      { 
	NSObject newObject = (NSObject)argument.clone ();
      }
    catch (NSException e)
      {
	testPassed = true;
	System.out.println ("* Catched exception:");
	System.out.println ("* " + e);
	System.out.println ("* ==> test passed");
      }
    catch (CloneNotSupportedException e)
      {
	//
      }

    if (testPassed == false)
      {
	System.out.println ("* No exception ==> test FAILED");
	System.exit (1);
      }
  }
}
