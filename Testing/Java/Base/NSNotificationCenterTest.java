/* NSNotificationCenterTest: test of gnu.gnustep.base.NSNotificationCenter

   Copyright (C) 2000 Free Software Foundation, Inc.

   Author:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: October 2000
   
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

class NSNotificationCenterTest
{ 
  public static void main (String[] args) 
    throws Throwable
  {
    NSNotificationCenter nc;

    nc = NSNotificationCenter.defaultCenter ();

    System.out.println (" * Getting the default notification center"); 
    System.out.println ("    Got " + nc);
    System.out.println ("");
    
    NSSelector selector = new NSSelector ("notification", 
					  new Class[] { NSNotification.class }
					  );
    NSNotificationCenterTest nct = new NSNotificationCenterTest ();

    /* We pass this object to objective C as a weak reference so we need 
       to do this */
    NSObject.retainObject (nct);

    System.out.println (" * Registering object to receive TestNotification..."); 
    nc.addObserver (nct, selector, "TestNotification", nct);
    System.out.println ("");

    System.out.println (" * Posting TestNotification..."); 
    nc.postNotificationName ("TestNotification", nct, null);

    if (nct.didReceiveNotification () == false)
      {
	System.out.println ("    Notification not received! :(");
	System.out.println ("");
	System.out.println ("==> test failed");
	System.exit (1);
      }
    
    System.out.println ("");
    System.out.println ("test passed");
  }

  /* Instance Stuff */

  public NSNotificationCenterTest ()
  {  }

  boolean received = false;

  public void notification (NSNotification aNot)
  {
    System.out.println ("    Notification received! :)");
    received = true;
  }

  public boolean didReceiveNotification ()
  {
    return received;
  }
}
