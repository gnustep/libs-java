/* NSButtonTest: test of gnu.gnustep.gui.NSButton

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

class NSButtonTest
{ 
  public static void main (String[] args) 
    throws Throwable
  {
    NSApplication application;
    NSButtonTest buttonTest;

    (NSProcessInfo.processInfo ()).setProcessName ("NSButtonTest");

    application = NSApplication.sharedApplication ();
    buttonTest = new NSButtonTest ();

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
    button.setTarget (this);
    button.setAction (new NSSelector ("buttonPress", 
				      new Class[] { Object.class }));
    button.setTitle ("Print Quote");
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
  
  public void buttonPress (Object sender)
  {
    System.out.println ("Ahi Pisa, vituperio de le genti");
  }

  public void applicationDidFinishLaunching (NSNotification not)
  {
    window.center ();
    window.makeKeyAndOrderFront (this);
  }

  public boolean applicationShouldTerminateAfterLastWindowClosed 
    (NSApplication app)
  {
    return true;
  }

}
