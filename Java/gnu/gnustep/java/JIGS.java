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
      /* Safety check */
      initialize ();
    }

  /* List of loaded libraries */
  static Vector loadedLibraries = new Vector ();

  /* The main method used by outside */
  static public void loadLibrary (String name)
    {
      if (loadedLibraries.contains (name))
	return;
      
      /* We do not give second chances :) */
      loadedLibraries.add (name);
      
      JIGSLibraryLoader.loadLibrary (name);
    }

  /*
   * It is safe (but useless) to call the following more than once.
   */
  static native public void initialize ();
}

