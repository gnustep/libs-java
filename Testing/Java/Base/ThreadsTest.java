/* ThreadsTest: test of threads with gnustep base wrappers

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

class MyThread extends Thread 
{
  static NSMutableArray array;
  int number;

  static void createArray ()
  {
    array = new NSMutableArray ();
    array.addObject ("a string");
  }

  static void checkArray ()
  {
    System.out.println (array);
  }
  
  public MyThread (int aNumber)
  {
    number = aNumber;
  }

  private void step (String object)
  {
    /* We want to do something which causes the thread to be 
       playing with GNUstep stuff for quite a while, to maximixe 
       possibilities of thread conflicts.  Launching external tasks 
       is a good exercise of this kind. */
    
    NSTask task = new NSTask ();
    task.setLaunchPath ("/usr/bin/gcc");
    NSMutableArray arguments = new NSMutableArray ();
    arguments.addObject ("--version");
    task.setArguments (arguments);
    task.launch();
    task.waitUntilExit ();

    System.out.println ("<Thread " + number + ">: " + array);
  }
  
  public void run () 
  {
    System.out.println ("<Thread " + number + ">: Starting; " + array);
    step ("0");
    step ("1");
    step ("2");
    step ("3");
    step ("4");
    step ("5");
  }
}

class ThreadsTest
{ 
  public static void main (String[] args) 
    throws Throwable
  {
    MyThread.createArray ();
    MyThread one = new MyThread (1);
    MyThread two = new MyThread (2);  
    MyThread three = new MyThread (3);
    MyThread four = new MyThread (4);
    MyThread five = new MyThread (5);
    MyThread six = new MyThread (6);
    MyThread seven = new MyThread (7);

    System.out.println ("<Main Thread>: Starting the first thread...");
    one.start ();
    System.out.println ("<Main Thread>: Starting the second thread...");
    two.start ();
    System.out.println ("<Main Thread>: Starting the third thread...");
    three.start ();
    System.out.println ("<Main Thread>: Starting the fourth thread...");
    four.start ();
    System.out.println ("<Main Thread>: Starting the fifth thread...");
    five.start ();
    System.out.println ("<Main Thread>: Starting the sixth thread...");
    six.start ();
    System.out.println ("<Main Thread>: Starting the seventh thread...");
    seven.start ();
    System.out.println ("<Main Thread>: Now sleeping for seven seconds...");
    Thread.currentThread ().sleep (7 * 1000);

    System.out.println ("<Main Thread>: Reading the array...");
    MyThread.checkArray ();

    /* Happy end */
    System.out.println ("<Main Thread>: ==> test passed");
  }
}
