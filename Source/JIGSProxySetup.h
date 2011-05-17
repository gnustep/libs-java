/* JIGSProxySetup.h - Tools to build `fake` Objc classes delivering 
   messages to Java objects.

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

#ifndef __JIGSProxySetup_h_GNUSTEP_JAVA_INCLUDE
#define __JIGSProxySetup_h_GNUSTEP_JAVA_INCLUDE

#include <objc/objc-api.h>

#include "GSJNI.h"

/*
 * These functions, methods and data tables are not public.
 */

/*
 * This is a table to manage selectors->jmethodID.
 * Each class needs its little table, because jmethodIDs 
 * depend on the class.  
  
 * Class methods are [of course] registered as methods of the meta
 * class.  
 
 * This table makes forwarding faster by caching all the jmethodIDs.
 * Allocation is only slightly slower, because when we get a list of
 * the methods of a java class, which we are obliged to do at
 * allocation time, we get the jmethodIDs nearly for free.
 
 * Moreover, this table in principle allows the same selector to be
 * bounded to invoke different java methods when called on different
 * classes.  Viceversa, different selectors can invoke the same java
 * method on different classes.
 
 * Disadvantage: this table consumes memory.  This looks like a minor
 * problem nowadays - messaging speed seems more important.  */
struct _JIGSSelectorIDTable
{
  int classCount;       // Number of classes in the list
  
  // Each class has an entry like the following one:
  struct _JIGSSelectorIDEntry
    {
      Class class;      // Class
      jclass javaClass; // Cached pointer to the Java Class
      int selIDCount;   // Number of selector->ID entries for this class

      // The selector->ID entries for this class:
      struct _JIGSSelectorID 
	{
	  // Beware: the following Objc selector will be initialized with 
	  // the method name (char*).  This is replaced by the selector 
	  // after the method is registered with the runtime.
	  SEL selector;       // Objc Selector used to find the method later
	  char *types;        // Objc info on return type and arguments
	  jmethodID methodID; // Cache jmethodID
	  BOOL isConstructor; // YES for constructors
	  int numberOfArgs;   // Cached number of arguments
	} *selIDTable; // The table itself
    } *classTable;
};

/*
 * Register a java class with the objective-C runtime. 
 */
BOOL _JIGS_register_java_class_simple (JNIEnv *env, NSString *className, 
				       NSString *superclassName, 
				       BOOL isRootClass);


#endif /* __JIGSProxySetup_h_GNUSTEP_JAVA_INCLUDE */
