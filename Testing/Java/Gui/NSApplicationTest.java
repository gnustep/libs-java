/* NSApplicationTest: test of gnu.gnustep.gui.NSApplication

   Copyright (C) 2000 Free Software Foundation, Inc.

   Author:  Nicola Pero <n.pero@mi.flashnet.it>
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
import gnu.gnustep.gui.*;

class NSApplicationTest
{ 
  int state = 1;
  static boolean failed = false;

  public static void main (String[] args) 
    throws Throwable
  {
    NSApplication application;
    NSApplicationTest applicationTest;

    application = NSApplication.sharedApplication ();

    applicationTest = new NSApplicationTest ();

    NSObject.retainObject (applicationTest);
    application.setDelegate (applicationTest);

    /* FIXME - HOW DO WE DO THE FOLLOWING ?? */
    //return NSApplicationMain (argc, argv);

    application.run ();
  }

  public void applicationWillFinishLaunching (NSNotification not)
  {
    if (failed)
      return;

    System.out.println (" *1* applicationWillFinishLaunching called");
    if (state != 1)
      {
	System.out.println (" ==> Test failed - this should have been the 1th step");
	failed = true;
	NSApplication.sharedApplication ().terminate (this);
	System.exit (1);
      }

    checkNotification (not);

    state = 2;
  }

  public void applicationDidFinishLaunching (NSNotification not)
  {
    if (failed)
      return;

    System.out.println (" *2* applicationDidFinishLaunching called");
    if (state != 2)
      {
	System.out.println (" ==> Test failed - this should have been the 2nd step");
	failed = true;
	NSApplication.sharedApplication ().terminate (this);
	System.exit (1);
      }

    checkNotification (not);

    state = 3;
    NSApplication.sharedApplication ().terminate (this);
  }

  public boolean applicationShouldTerminate (Object sender)
  {
    if (failed)
      return true;

    System.out.println (" *3* applicationShouldTerminate called");
    if (state != 3)
      {
	System.out.println (" Test failed - this should have been the 3rd step");
	failed = true;
	return true;
      }

    state = 4;
    return true;
  }

  public void applicationWillTerminate (NSNotification not)
  {
    if (failed)
      return;

    System.out.println (" *4* applicationWillTerminate called");
    if (state != 4)
      {
	System.out.println ("==> Test failed - this should have been the 4th step");
	failed = true;
	NSApplication.sharedApplication ().terminate (this);
	System.exit (1);
      }

    checkNotification (not);

    System.out.println ("==> Test passed <AFAIK>");
    state = 5;
  }

  public static void checkNotification (NSNotification not)
  {
    Object object;

    if (not == null)
      {
	System.out.println (" Test failed - null notification");
	failed = true;
	NSApplication.sharedApplication ().terminate (null);
	System.exit (1);
      }

    object = not.object ();

    if (object != NSApplication.sharedApplication ())
      {
	System.out.println (" Test failed - object of notification is not correct");
	failed = true;
	NSApplication.sharedApplication ().terminate (null);
	System.exit (1);
      }
    
  }
}
