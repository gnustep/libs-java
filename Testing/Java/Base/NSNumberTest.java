/* NSNumberTest: test of morphing numbers

   Copyright (C) 2001 Free Software Foundation, Inc.

   Author:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: May 2001
   
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

class NSNumberTest
{ 
  /* Boolean must come back exactly of the same class as they went out,
     so we check the what is returned by using `equals' */
  public static void testBooleanBackAndForth (Object object)
  {
    String output = "  Passing " + object + " (" + object.getClass () + ")...";
    NSMutableArray array = new NSMutableArray ();
    array.addObject (object);

    if (!(array.objectAtIndex (0)).equals (object))
      {
	output += " got a different value (" + array.objectAtIndex (0) 
	  + ") ==> test FAILED";
	System.out.println (output);
	System.exit (1);
      }
    else
      {
	output += " got the same value ==> test passed";
	System.out.println (output);
      }
    
  }

  /* We compare the `longValue' of the number before and after passing
     it through the interface, because we can't be sure it comes back
     exactly of the same class. */
  public static void testIntegerBackAndForth (java.lang.Number object)
  {
    String output = "  Passing " + object + " (" + object.getClass () + ")...";
    NSMutableArray array = new NSMutableArray ();
    array.addObject (object);

    long original = object.longValue ();
    long result = ((java.lang.Number)(array.objectAtIndex (0))).longValue ();
    

    if (original != result)
      {
	output += " got another value (" + result + ") ==> test FAILED";
	System.out.println (output);
	System.exit (1);
      }
    else
      {
	output += " got the same value ==> test passed";
	System.out.println (output);
      }
    
  }

  /* We compare the `doubleValue' of the number before and after passing
     it through the interface */
  public static void testFloatBackAndForth (java.lang.Number object)
  {
    String output = "  Passing " + object + " (" + object.getClass () + ")...";
    NSMutableArray array = new NSMutableArray ();
    array.addObject (object);

    double original = object.doubleValue ();
    double result = ((java.lang.Number)(array.objectAtIndex (0))).doubleValue ();

    if (original != result)
      {
	output += " got another value (" + result + ") ==> test FAILED";
	System.out.println (output);
	System.exit (1);
      }
    else
      {
	output += " got the same value ==> test passed";
	System.out.println (output);
      }
    
  }
  
  public static void main (String[] args) 
    throws Throwable
  {
    NSMutableArray array;

    System.out.println (" * Test adding morphed objects to a NSMutableArray, and getting them back");
    System.out.println ("   this makes them go back and forth the interface; we test they come back");
    System.out.println ("   reasonably the same as they went");

    testBooleanBackAndForth (java.lang.Boolean.TRUE);
    testBooleanBackAndForth (java.lang.Boolean.FALSE);

    testIntegerBackAndForth (new Byte ((byte)1));
    testIntegerBackAndForth (new Byte ((byte)100));
    testIntegerBackAndForth (new Byte ((byte)-1));
    testIntegerBackAndForth (new Byte ((byte)-100));
    testIntegerBackAndForth (new Byte ((byte)0));

    testIntegerBackAndForth (new Integer ((int)1));
    testIntegerBackAndForth (new Integer ((int)10000));
    testIntegerBackAndForth (new Integer ((int)-1));
    testIntegerBackAndForth (new Integer ((int)-10000));
    testIntegerBackAndForth (new Integer ((int)0));

    testIntegerBackAndForth (new Short ((short)1));
    testIntegerBackAndForth (new Short ((short)10000));
    testIntegerBackAndForth (new Short ((short)-1));
    testIntegerBackAndForth (new Short ((short)-10000));
    testIntegerBackAndForth (new Short ((short)0));

    testIntegerBackAndForth (new Long ((long)1));
    testIntegerBackAndForth (new Long ((long)100233e4));
    testIntegerBackAndForth (new Long ((long)-1));
    testIntegerBackAndForth (new Long ((long)-100233e4));
    testIntegerBackAndForth (new Long ((long)0));

    testFloatBackAndForth (new Float ((float)1));
    testFloatBackAndForth (new Float ((float)1.00233e4));
    testFloatBackAndForth (new Float ((float)-1));
    testFloatBackAndForth (new Float ((float)-1.00233e4));
    testFloatBackAndForth (new Float ((float)-3.1415296));
    testFloatBackAndForth (new Float ((float)0));

    testFloatBackAndForth (new Double ((double)1));
    testFloatBackAndForth (new Double ((double)1.00233e4));
    testFloatBackAndForth (new Double ((double)-1));
    testFloatBackAndForth (new Double ((double)-1.002334243e-4));
    testFloatBackAndForth (new Double ((double)-3.14152961122334455667788));
    testFloatBackAndForth (new Double ((double)0));


    System.out.println ("test passed");
  }
  
}

