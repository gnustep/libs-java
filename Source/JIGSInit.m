/* JIGSInit - Initialization of JIGS
   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: June 2000
   
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

#include "JIGS.h"
#include "JIGSSelectorMapping.h"

#if defined(LIB_FOUNDATION_LIBRARY)
/* Use a global lock. */
static objc_mutex_t JIGSLock = NULL;

BOOL GSRegisterCurrentThread (void)
{
  objc_mutex_lock (JIGSLock);
  return YES;
}

void GSUnregisterCurrentThread (void)
{
  objc_mutex_unlock (JIGSLock);
}
#endif /* LIB_FOUNDATION_LIBRARY */



/* A global reference to the JIGS class. 
   Global thread locking could be done with respect to this class. 
   We don't do it now, but we load a reference to
   gnu/gnustep/java/JIGS anyway, as a safety check and as a
   remind that the JIGS has been initialized. */

/*
 * If this is NULL, JIGS has not yet been initialized.
 */
static jclass JIGS = NULL;

static Class (*_original_lookup_class)(const char* name) = 0;

/*
 * Little function to load a java class as an ObjC class when the ObjC
 * runtime asks for a class and can't find it.
 */
static Class
_jigs_lookup_class(const char* name)
{
  CREATE_AUTORELEASE_POOL(pool);
  Class		c;
  NSString	*className = [NSString stringWithCString: name];

  _objc_lookup_class = _original_lookup_class;

  NS_DURING
    {
      JIGSRegisterJavaClass (JIGSJNIEnv (), className);
      c = NSClassFromString (className);
    }
  NS_HANDLER
    {
      c = Nil;
    }
  NS_ENDHANDLER

  _objc_lookup_class = _jigs_lookup_class;
  RELEASE(pool);
  return c;
}

void JIGSInit (JNIEnv *env)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new]; 
  
  if (JIGS == NULL)
    {
      JavaVM *jvm;
      /*
       * On some systems, GNUstep can't really read the arguments 
       * and environment without help/hack from the programmer. 
       *
       * This is a first hack of that kind for JIGS.  A more refined
       * version will allow the programmer to call a function from
       * Java to initialize GNUstep with the program arguments he
       * provides.  If the programmer does not call the function, it
       * would anyway work like the following.  NB: The following is 
       * not used if on your system GNUstep can reliably get the args 
       * and program name (eg, from the /proc filesystem).
       */
#if defined(GS_FAKE_MAIN) || defined(GS_PASS_ARGUMENTS)
      extern char **environ;
      static char  *args[2] = { "java", 0 };
      
      [NSProcessInfo initializeWithArguments: args
				       count: 1
				 environment: environ]; 
#elif defined(LIB_FOUNDATION_LIBRARY)
      extern char **environ;
      static char  *args[2] = { "java", 0 };
      
      [NSProcessInfo initializeWithArguments: args
		                       count: 1
                   		 environment: environ];
#endif
      JIGS = GSJNI_NewClassCache (env, "gnu/gnustep/java/JIGS");

      if (JIGS == NULL)
	{
	  // Exception raised
	  RELEASE (pool);
	  return;
	}

      // Make sure the default thread is initialized 
      GSCurrentThread ();

#if defined(LIB_FOUNDATION_LIBRARY)
      JIGSLock = objc_mutex_allocate ();
#endif     

      // Get the JavaVM to register it with NSJavaVirtualMachine
      if ((*env)->GetJavaVM (env, &jvm) < 0)
	{
	  // Exception raised !
	  RELEASE (pool);
	  return;	  
	}
      [NSJavaVirtualMachine registerJavaVM: jvm];

      _JIGSSelectorMappingInitialize (env);

      // Create the basic java wrapper
      JIGSRegisterJavaRootClass (env);
      _JIGSMapperInitialize (env);
      _JIGSBaseStructInitialize (env);

      _original_lookup_class = _objc_lookup_class;
      _objc_lookup_class = _jigs_lookup_class;
    }
  RELEASE (pool);
}


