/* NSKeyValueCodingTest: test of using key value coding for Objc objects

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

class NSKeyValueCodingTest
{ 
  public static void main (String[] args) 
    throws Throwable
  {
    NSProcessInfo process;

    /* Get process info */
    process = NSProcessInfo.processInfo ();

    /* Call setValueForKey for processName */
    process.takeValueForKey ("ciao", "processName");

    /* Check that it worked */
    if (!((process.valueForKey ("processName")).equals ("ciao")))
      {
	System.out.println ("test FAILED <AFAIK>");
	System.exit (1);
      }

    /* Happy end */
    System.out.println ("test passed");
  }
}
