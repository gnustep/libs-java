/* JIGS.java - the JIGS object
   Copyright (C) 2000 Free Software Foundation, Inc.

   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: July 2000, September 2000
   
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
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.  */

package gnu.gnustep.java;

import java.lang.*;
import java.util.*;

public class JIGS
{
  static
    {
      /* The following loads libgnustep-java.so or libgnustep-java_d.so 
	 according to the environment variable JIGS_DEBUG and to which 
	 of the two libraries is actually available. */
      JIGSLibraryLoader.initialize ();
      /* Don't call JIGS.initialize () here to avoid a recursive 
	 initialization when JIGS is initialized from Objective-C. 
	 JIGS.initialize () [which is exactly the same as JIGSInit () 
	 in objective-C] is called from gnu.gnustep.base.NSObject
      */
    }

  /* List of loaded libraries */
  static Vector loadedLibraries = new Vector ();
  
  /* The main method used by outside */
  static public void loadLibrary (String name)
  {
    synchronized (loadedLibraries)
      {
	if (loadedLibraries.contains (name))
	  return;
	
	/* We do not give second chances :) */
	loadedLibraries.add (name);
      }
    
    JIGSLibraryLoader.loadLibrary (name);
  }
  
  /*
   * It is safe (but useless) to call the following more than once.
   * It is exactly the same as JIGSInit.
   */
  static native public void initialize ();

  /*
   * The following will force GNUstep to get immediately into
   * multithreading state.
   * 
   * In normal circumstances, it is only recommended to people
   * suffering from thread-safe-paranoia and using GNUstep DO from
   * multiple Java threads, because JIGS already makes automatically
   * GNUstep go multithreading when it detects that you are accessing
   * it from a different Java thread, and this is usually what you
   * want.
   *
   * In some cases, if you have some objects which are initialized in
   * a different way if GNUstep is multithreading or not (and I'm told
   * that some DO objects are), you may want to have GNUstep go
   * multithreading before initializing the objects.
   *
   * There are two ways of doing this: one is detaching a Java thread
   * using the Java API, and then doing a no-operation call to GNUstep
   * from this thread.
   *
   * The other one is via the following utility method.  */
  static native public void forceMultithreading ();
}

