/* NSButtonTest2: test of gnu.gnustep.gui.NSButton

   Copyright (C) 2000 Free Software Foundation, Inc.

   Author:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: November 2000
   
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

/* The difference between this test and NSButtonTest is that in this
   test the button sends an action to an Objective-C object. */

class NSButtonTest2
{ 
  public static void main (String[] args) 
    throws Throwable
  {
    NSApplication application;
    NSButtonTest2 buttonTest;

    (NSProcessInfo.processInfo ()).setProcessName ("NSButtonTest2");

    application = NSApplication.sharedApplication ();
    buttonTest = new NSButtonTest2 ();

    NSObject.retainObject (buttonTest);
    application.setDelegate (buttonTest);

    application.run ();
  }

  NSWindow window;

  public void applicationWillFinishLaunching (NSNotification not)
  {
    NSButton button;
    NSRect rect;

    button = new NSButton ();
    button.setTarget (NSApplication.sharedApplication ());
    button.setAction (new NSSelector ("terminate", 
				      new Class[] { Object.class }));
    button.setTitle ("Quit This Test");
    button.sizeToFit ();

    rect = button.frame ();
    window = new NSWindow (rect, NSWindow.TitledWindowMask 
			   | NSWindow.ClosableWindowMask 
			   | NSWindow.MiniaturizableWindowMask 
			   | NSWindow.ResizableWindowMask, 
			   NSWindow.Retained, false);
    window.setTitle ("GNUstep");
    window.setContentView (button);
  }
  
  public void applicationDidFinishLaunching (NSNotification not)
  {
    window.center ();
    window.makeKeyAndOrderFront (this);
  }
}
