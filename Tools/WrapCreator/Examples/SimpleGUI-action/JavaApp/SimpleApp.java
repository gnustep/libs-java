/* SimpleGUI.app -  A demo java application written using JIGS
   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: July 2000, October 2000
   
   This file is part of JIGS, the GNUstep Java Interface Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
   */ 

import gnu.gnustep.base.*;

class SimpleApp 
{
  public void firstButtonPressed (Object sender)
  {
      System.out.println ("Hello World 1");
  }

  public void secondButtonPressed (Object sender)
  {
      System.out.println ("Hello World 2");
  }

  public static void main (String[] args)
  {
    SimpleApp app = new SimpleApp ();
    NSObject.retainObject (app);

    SimpleGUI gui = new SimpleGUI ("Test (java)");

    gui.addButtonWithTitle ("Print \"Hello World 1\"", 
			    new NSSelector ("firstButtonPressed", 
					    new Class[] { Object.class }),
			    app);
    gui.addButtonWithTitle ("Print \"Hello World 2\"", 
			    new NSSelector ("secondButtonPressed", 
					    new Class[] { Object.class }),
			    app);
    
    gui.start ();
  }
}
