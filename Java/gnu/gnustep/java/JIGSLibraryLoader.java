/* JIGSLibraryLoader.java - class loading JIGS libraries
   Copyright (C) 2000, 2001 Free Software Foundation, Inc.

   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: September 2000, June 2001
   
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

class JIGSLibraryLoader
{
  static
  {
    System.loadLibrary ("gnustep-java-loader");
  }
  
  /* The 'debug' flag is set according to whether we link in debugging
     versions of the libraries or not.
     All libraries linked in *must* be of the same type, so we have a 
     global flag.
     
     This flag is set when the first library (libgnustep-java, which 
     incidentally loads libgnustep-base) is loaded.  We try the 
     following steps (exiting as soon as we can load a library, and 
     set the debug flag according to the library we loaded):

     1. If the environment variable JIGS_DEBUG is set to 'yes' 
        or 'YES' then the debugging version is tried first and 
        a warning is issued if the debugging version is not present;
	if the environment variable is set to something else, 
	the not debugging version is tried first, and a warning 
	is issued if it can't be loaded;

     2. the not debugging version is tried; 
     3. the debugging version is tried.

     4. Well, if neither version is present we can't go on so we raise
        and exception.  
	
*/
  static boolean debug;
  /* The following for future expansions, right now profiling shared 
     libraries is impossible */
  static boolean profile = false;

  /* Static methods */
  static String completeName (String name)
    {
      String extension = "";

      if (debug == true)
	extension = "d";
      
      if (profile == true)
	extension += "p";

      if (extension.equals ("") == false)
	extension = "_" + extension;

      return name + extension;
    }

  static void loadLibrary (String name)
    throws UnsatisfiedLinkError, SecurityException
    {
      /* In case of an exception, we need to catch the exception and
	 print the library name to stderr, otherwise the
	 UnsatisfiedLinkError does not tell us which library could not
	 be found ! */
      try 
	{
	  System.loadLibrary (completeName (name));
	} 
      catch (UnsatisfiedLinkError e) 
	{
	  System.err.println ("Could not load library " 
			      + completeName (name));
	  throw e;
	} 
      catch (SecurityException e)
	{
	  System.err.println ("Could not load library " 
			      + completeName (name));
	  throw e;
	}
    }
  
  static boolean tryLoading (String completeName)
    throws SecurityException
  {
      try 
	{
	  System.loadLibrary (completeName);
	} 
      catch (UnsatisfiedLinkError e) 
	{
	  return false;
	} 
      return true;
    }

  /* The JIGS class static initializer calls the following method
     which tries to load the correct version of libgnustep-java and
     sets the debug flag accordingly */
  static void initialize ()
    throws UnsatisfiedLinkError, SecurityException
  {
    int result = debuggingEnabled ();
    
    if (result == yes)
      {
	if (tryLoading ("gnustep-java_d"))
	  {
	    debug = true;
	    return;
	  }
	else
	  {
	    System.out.println ("Warning: JIGS_DEBUG=yes but we could not load the debugging version");
	    System.out.println ("of the gnustep-java library!  Trying with the not-debugging one.");
	  }
      }
    else if (result == no)
      {
	if (tryLoading ("gnustep-java"))
	  {
	    debug = false;
	    return;
	  }
	else
	  {
	    System.out.println ("Warning: JIGS_DEBUG=no but we could not load the not debugging version");
	    System.out.println ("of the gnustep-java library!  Trying with the debugging one.");
	  }
      } 
    
    /* Then try the not-debugging version */
    if (tryLoading ("gnustep-java"))
      {
	debug = false;
	return;
      }
    
    /* Then try the debugging version */
    if (tryLoading ("gnustep-java_d"))
      {
	debug = true;
	return;
      }
    
    /* Not any luck - give up - but make sure we tell the users what
       the problem is */
    System.err.println ("Could not load libgnustep-java");
    throw new UnsatisfiedLinkError ("Could not load libgnustep-java");
  }
  
  /* Read from environment (from the JIGS_DEBUG variable) whether 
     to enable debugging or not. */
  static final int notDefined = 0;
  static final int yes = 1;
  static final int no = -1;
  /* Return one of the previous values */
  native static int debuggingEnabled ();
}

