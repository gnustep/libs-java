/* NSExceptionTest: test of gnu.gnustep.base.NSException

   Copyright (C) 2001 Free Software Foundation, Inc.

   Author:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: December 2001
   
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

class NSExceptionTest
{ 
  public static void main (String[] args) 
    throws Throwable
  {
    /* test 1 */
    boolean caught = false;

    try
      {
	System.out.println ("Raising an NSException from Java");
	throw new NSException ("TestException", 
			       "this is only a test, don't worry");
      }
    catch (NSException e)
      {
	caught = true;
	System.out.println ("Catched exception: " + e);
      }

    if (! caught)
      {
	System.out.println ("Exception not caught ==> test FAILED");
	System.exit (1);
      }

    System.out.println ("");

    /* test 2 */
    caught = false;

    try
      {
	System.out.println ("Passing an index out of bounds to NSArray");
	NSArray a;
	Object b;

	a = new NSArray ();
	b = a.objectAtIndex (12);
      }
    catch (NSException e)
      {
	caught = true;
	System.out.println ("Catched exception: " + e);
      }

    if (! caught)
      {
	System.out.println ("Exception not caught ==> test FAILED");
	System.exit (1);
      }

    System.out.println ("");

    /* test 3 */
    caught = false;

    try
      {
	System.out.println ("Putting a nil object in an NSMutableArray");
	NSMutableArray a;

	a = new NSMutableArray ();
	a.addObject (null);
      }
    catch (NSException e)
      {
	caught = true;
	System.out.println ("Catched exception: " + e);
      }

    if (! caught)
      {
	System.out.println ("Exception not caught ==> test FAILED");
	System.exit (1);
      }

    System.out.println ("");

    /* Done */
    System.out.println ("test passed");
  }
}
