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
#include "NSJavaVirtualMachine.h"

/* A global reference to the JIGS class. 
   Global thread locking could be done with respect to this class. 
   We don't do it now, but we load a reference to
   gnu/gnustep/java/JIGS anyway, as a safety check and as a
   remind that the JIGS has been initialized. */

/*
 * If this is NULL, JIGS has not yet been initialized.
 */
static jclass JIGS = NULL;

void JIGSInit (JNIEnv *env)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new]; 
  
  if (JIGS == NULL)
    {
      JavaVM *jvm;
#if	defined(GS_FAKE_MAIN) || defined(GS_PASS_ARGUMENTS)
      extern char**	environ;
      static char	*args[2] = { "java", 0 };
      
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

      // Get the JavaVM to register it with NSJavaVirtualMachine
      if ((*env)->GetJavaVM (env, &jvm) < 0)
	{
	  // Exception raised !
	  RELEASE (pool);
	  return;	  
	}
      [NSJavaVirtualMachine registerJavaVM: jvm];

      // Create the basic java wrapper
      JIGSRegisterJavaRootClass (env);
      _JIGSMapperInitialize (env);
      _JIGSBaseStructInitialize (env);
    }
  RELEASE (pool);
}


