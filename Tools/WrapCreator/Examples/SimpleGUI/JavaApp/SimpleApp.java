/* SimpleGUI.app -  A demo java application written using JIGS
   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: July 2000
   
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
  public void simpleGUIButtonPressed (int tag)
  {
    switch (tag)
      {
      case 1:
	System.out.println ("Hello World 1");
	break;
      case 2:
	System.out.println ("Hello World 2");
	break;
      default:
	System.out.println ("Bug");
	break;
      }  
  }

  public static void main (String[] args)
  {
    SimpleGUI gui = new SimpleGUI ("Test (java)");
    gui.addButtonWithTitle ("Print \"Hello World 1\"", 1);
    gui.addButtonWithTitle ("Print \"Hello World 2\"", 2);

    SimpleApp app = new SimpleApp ();
    NSObject.retainObject (app);
    gui.setDelegate (app);

    gui.start ();
  }
}
