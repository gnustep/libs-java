/* SimpleGUI.java -  A library for simple GUI programming; java wrapper
   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: June 2000
   
   This file is part of the GNUstep Java Interface Library.

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

/*
 * You may use the following as a reference skeleton of how to wrap.
 */

/* REQUIRED: This is always needed */
import gnu.gnustep.base.*;

/* REQUIRED: Must extend NSObject */
class SimpleGUI extends NSObject
{
  /* REQUIRED: Load the native library */
  static
  {
    System.loadLibrary ("SimpleGUI.A");
  }

  /* REQUIRED: This magic code should be in all wrapper classes */
  protected SimpleGUI (GSInitializationType type)
  {
    super (type);
  }

  /* Generic constructor */
  public SimpleGUI ()
  {
    super ();
  }

  /* Please notice how a java constructor with arguments is implemented */
  public SimpleGUI (String title)
   {
     super (ALLOC_ONLY);
     this.initWithTitle (title);
   }

  /* Objective-C methods which are exposed - for each of these methods, 
   * a native implementation must be supplied on the objective-C side 
   */
  public static native NSObject createNew ();
  /* initXxx: methods are wrapped in the same way as any other method */ 
  native void initWithTitle (String title);
  public native void start ();
  public native void addButtonWithTitle (String title, int tag);
  public native void setDelegate (Object aDelegate);
  public native Object delegate ();    
}


