/* NSDateTest: test of gnu.gnustep.base.NSDate

   Copyright (C) 2000 Free Software Foundation, Inc.

   Author:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: September 2000
   
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

/* This test is really meant to test the mapping NSTimeInterval --> double */

class NSDateTest
{ 
  public static void main (String[] args) 
    throws Throwable
  {
    NSDate dateOne;
    NSDate dateTwo;
    
    /* Create a date now */
    dateOne = new NSDate ();
    dateTwo = dateOne;
    System.out.println ("");
    System.out.println (" * Created date: " + dateOne);
    dateOne = (NSDate)(dateOne.addTimeInterval (2));
    System.out.println ("   Adding 2 seconds it becomes: " + dateOne);
    dateOne = (NSDate)(dateOne.addTimeInterval (120));
    System.out.println ("   Adding 2 minutes it becomes: " + dateOne);
    dateOne = (NSDate)(dateOne.addTimeInterval (7200));
    System.out.println ("   Adding 2 hours it becomes: " + dateOne);

    /* Print out time interval since reference date */
    System.out.println ("   Time interval since reference date: " 
			+ dateOne.timeIntervalSinceReferenceDate ());
    System.out.println ("   Time interval since now: " 
			+ dateOne.timeIntervalSinceNow ());

    System.out.println ("");
    System.out.println (" * When the program started it was: " + dateTwo);
    System.out.println ("");
    System.out.println (" * And the earlier date of the two is: "
			+ dateTwo.earlierDate (dateOne));
    System.out.println ("");
    if (dateTwo.earlierDate (dateOne) != dateTwo)
      {
	System.out.println ("==> Test failed");
	System.exit (1);
      }
    
    /* Happy end */
    System.out.println ("test passed");
  }

}
