/* NSProcessInfoTest: test of gnu.gnustep.base.NSProcessInfo

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

class NSProcessInfoTest
{ 
  public static void main (String[] args) 
    throws Throwable
  {
    NSProcessInfo process;

    /* Get process info */
    process = NSProcessInfo.processInfo ();

    /* Force the system to garbage-collect now. */
    System.gc ();

    /* Print out description */
    System.out.println ("NSProcessInfo reports:");
    System.out.println ("");
    
    System.out.println ("* hostName:");
    System.out.println (process.hostName ());
    System.out.println ("");

    System.out.println ("* processName:");
    System.out.println (process.processName ());
    System.out.println ("");

    /* Here we implicitly test NSArray too */
    System.out.println ("* arguments:");
    System.out.println (process.arguments ());
    System.out.println ("");

    /* Here we implicitly test NSDictionary too */
    System.out.println ("* environement:");
    System.out.println (process.environment ());
    System.out.println ("");

    System.out.println ("* globallyUniqueString:");
    System.out.println (process.globallyUniqueString ());
    System.out.println ("");

    /* Happy end */
    System.out.println ("test passed <AFAIK>");
  }
}
