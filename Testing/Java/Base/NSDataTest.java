/* NSDataTest: test of gnu.gnustep.base.NSData

   Copyright (C) 2001 Free Software Foundation, Inc.

   Author:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: February 2001
   
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

/* This test is really meant to test the special methods of NSData which 
   take/return byte[] */

class NSDataTest
{ 
  public static void main (String[] args) 
    throws Throwable
  {
    byte bytes[] = new byte[100];
    byte newBytes[];

    for (int i = 0; i < 100; i++)
      {
	bytes[i] = (byte)(i - 50);
      }
    
    NSData data;
    NSMutableData dataTwo;
    
    /* Create a data now */
    data = new NSData (bytes);
    System.out.println ("");
    System.out.println (" * Created data from bytes: " + data);
    System.out.println ("");

    dataTwo = new NSMutableData (bytes);
    System.out.println ("");
    System.out.println (" * Created mutabledata from bytes: " + dataTwo);
    System.out.println ("");

    System.out.println ("");
    System.out.println (" * Getting the bytes back and comparing with the original ones: ");
    newBytes = data.bytes ();
    for (int i = 0; i < 100; i++)
      {
	if (bytes[i] != newBytes[i])
	  {
	    System.out.println ("==> Test failed");
	    System.exit (1);
	  }
      }    
    System.out.println ("    OK");
    System.out.println ("");


    /* Happy end */
    System.out.println ("test passed");
  }

}
