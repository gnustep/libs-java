/* NSSelectorTest: test of gnu.gnustep.base.NSSelector

   Copyright (C) 2000 Free Software Foundation, Inc.

   Author:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: July 2000, October 2000
   
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
import gnu.gnustep.base.NSSelector;
import gnu.gnustep.java.GSJNIMethods;

class NSSelectorTest
{ 
  public static void main (String[] args) 
    throws Throwable
  {
    NSSelector selectorOne;    
    NSSelector selectorTwo;
    Boolean result;

    /* Create two NSSelector */
    selectorOne = new NSSelector ("toString", new Class[] { });
    selectorTwo = new NSSelector ("equals", new Class[] { Object.class });
    
    /* Describe them */
    System.out.println ("Created two NSSelectors:");
    System.out.println ("* The first one is " + selectorOne);
    System.out.println ("* The second one is " + selectorTwo);
    System.out.println ("");

    /* Print hashcodes */
    System.out.println ("They have the following hashcodes:");
    System.out.println ("* First object: " + selectorOne.hashCode ());
    System.out.println ("* Second object: " + selectorTwo.hashCode ());
    System.out.println ("");    

    /* Right, now test if equality works */
    System.out.println ("Now trying to compare the selectors using equals ()");
    if (selectorOne.equals (selectorTwo))
      {
	System.out.println ("* Selector one and two are equal ==> test failed");
	System.exit (1);
      }

    System.out.println ("* Selector one and two are different");

    if (selectorOne.equals (selectorOne))
      {
	System.out.println ("* Selector one and one are equal");
      }
    else
      {
	System.out.println ("* Selector one and one are different ==> test failed");
	System.exit (1);
      }

    System.out.println ("");

    /* Now trying to invoke a selector */
    System.out.println ("Trying to invoke the equals selector");
    
    result = (Boolean)selectorTwo.invoke ("test string", 
					  "different test string");
    if (result.booleanValue () == false)
      {
	System.out.println ("* test string != different test string");
      }
    else
      {
	System.out.println ("* test string == different test string ??");
	System.out.println (" ==> test failed");
	System.exit (1);
      }

    result = (Boolean)selectorTwo.invoke ("test string", "test string");
    if (result.booleanValue () == true)
      {
	System.out.println ("* test string == test string");
      }
    else
      {
	System.out.println ("* test string != test string ??");
	System.out.println (" ==> test failed");
	System.exit (1);
      }

    System.out.println ("");
    System.out.println ("Now some testing some private JIGS internal functions");
    System.out.println ("Testing the signature management functions");

    printArray ("");
    printArray ("I");
    printArray ("IJB");
    printArray ("Ljava.lang.String;");
    printArray ("Ljava.lang.String;ILjava.lang.Object;");
    printArray ("Ljava.lang.String;[ILjava.lang.Object;");
    printArray ("Ljava.lang.String;[[ILjava.lang.Object;");
    printArray ("Ljava.lang.String;[[[Ljava.util.Vector;ILjava.lang.Object;");
    printArray ("ILjava.lang.String;I[II[I[[Ljava.util.Vector;[[[[[Ljava.util.Vector;J");

    /* Happy end */
    System.out.println ("test passed");
  }

  static public void printArray (String string)
    throws ClassNotFoundException
  {
    int i;
    Object[] array = GSJNIMethods.parameterTypes (string);

    System.out.println ("* Trying signature " + string);

    for (i = 0; i < array.length; i++)
      {
	System.out.println ("  " + i + ": " + array[i]);
      }
  }
}

