/* NSTaskTest: test of gnu.gnustep.base.NSTask

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

class NSTaskTest
{ 
  public static void main (String[] args) 
    throws Throwable
  {
    NSMutableArray arguments;
    NSTask task;

    /* Create the task */
    task = new NSTask ();

    /* Set the launch path */
    task.setLaunchPath ("/usr/bin/gcc");

    arguments = new NSMutableArray ();
    arguments.addObject ("--version");
    task.setArguments (arguments);

    /* Print out description */
    System.out.println (" * Created NSTask with:");
    System.out.println ("");
   
    System.out.println ("   >- launchPath: " + task.launchPath ());
    System.out.println ("");

    System.out.println ("   >- arguments: " + task.arguments ());
    System.out.println ("");

    System.out.println ("   >- environment: " + task.environment ());
    System.out.println ("");

    System.out.println ("   >- currentDirectoryPath: " + 
			task.currentDirectoryPath ());
    System.out.println ("");
    System.out.println ("");

    System.out.println (" * Now Launching it !");

    System.out.println ("");
    System.out.println ("< begin task output >");

    /* Should print out something like egcs-2.91.66 */
    task.launch ();
    task.waitUntilExit ();

    System.out.println ("< end task output >");
    System.out.println ("");

    int status = task.terminationStatus ();

    if (status == 0)
      System.out.println ("   >- Succeded");
    else
      System.out.println ("   >- Failed");

    System.out.println ("");

    /* Happy end */
    System.out.println ("test passed <AFAIK>");
  }
}
