/* JIGSSelectorMapping.m - Managing mapping between Objective-C method 
   names and Java ones

   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: October 2000
   
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

#ifndef __JIGSSelectorMapping_h_GNUSTEP_JAVA_INCLUDE
#define __JIGSSelectorMapping_h_GNUSTEP_JAVA_INCLUDE

#include <Foundation/Foundation.h>
#include "GSJNI.h"

/*
  whenever a 'javaSignature' is found, we mean the following: a (char
  *) showing the java argument signature ("" meaning a method taking
  no args); the list of java signatures for args is the following:
  Z boolean 
  B byte
  C char
  S short
  I int
  J long
  F float
  D double
  Lfully-qualified-class-name;   object of the specified class 
  [any-of-the-preceding-codes  array of the specified type [This does 
                               not work yet (0.7.0) in messaging though]

  For example, a signature of

  "ILjava.lang.String;"

  means a method with arguments (int, String) */

/*
 * Create the table mutex lock.
 * Safe to be called many times, but this should never happen.
 * Called by JIGSInit.
 *
 */
void _JIGSSelectorMappingInitialize (JNIEnv *env);


/*
 * Register a selector mapping for an objc proxy selector, managing 
 * any conflicts and stuff in the mapping table.  
 * The return value is the method_name which has been registered 
 * and which has to be used in objective-C.
 *
 * The method will first look if the java selector has already been 
 * mapped to some objective-C selector, and use it if it has. 
 * Otherwise, it will try to use the short objective-C form for the 
 * method name, then fall back on the long form which should always 
 * work.
 */
const char *JIGSRegisterObjcProxySelector (JNIEnv *env, 
					   const char *fullJavaName, 
					   const char *shortJavaName, 
					   const char *javaSignature,
					   const char *objcSignature,
					   int numberOfArguments,
					   BOOL isStatic);

/*
 * The following one must be called for each method of an obj-C object 
 * exposed to java.
 *
 * This is called in JNI_OnLoad for each wrapper library; it registers 
 * all the method mapping we are using with the table. 
 *
 * If there is a conflict, a warning will be issued, unless the stuff 
 * was compiled with JIGS_NO_WARN_FOR_SELECTOR_CONFLICT.  NB: After the 
 * warning, *no* action will be taken - this will never give a problem 
 * till you morph precisely the selector generating the conflict.  When 
 * you do, you will get the one of the two registered selectors which 
 * was registered for first.
 *
 * NB: shortJavaName, javaSignature are *not* copied.  That's OK if they 
 * are constant strings; if you have allocated them, you should not free 
 * them.
 *
 */

void JIGSRegisterJavaProxySelector (JNIEnv *env, 
				    SEL selector,
				    const char *shortJavaName,
				    const char *javaSignature, 
				    BOOL unresolved,
				    BOOL isStatic);

/* The following stuff is support for libraries having a big table 
   of methods to be registered */

/* An entry to be registered with the mapping table.  Never register
   entries for initializers - these are not to be morphed. */
typedef struct 
{
  // The objective-C name of the method - the same used to get the selector -  
  // such as `setDelegate:'
  char *objcName;
  // If javaName == NULL, JIGSRegisterObjcProxySelectors guesses it at
  // run time from objcName, by removing anything from the first ':'
  // afterwards.  So, if no special mapping is needed, just put NULL 
  // in here.
  char *javaName; 
  // javaSignature is the signature of the arguments, as discussed at
  // the beginning of this file
  char *javaSignature;
  // unresolved == NO is the standard case, in which javaSignature 
  // is the real javaSignature.
  // unresolved == YES means that javaSignature actually needs to 
  // be partially resolved at run-time (this is done lazily only when 
  // the javaSignature is accessed) - this consists in trying to find 
  // short class names in the JIGS class name map table.  This will 
  // work eg, if you put in javaSignature LNSMenu; instead of 
  // Lgnu.gnustep.gui.NSMenu;
  BOOL unresolved;
  // isStatic == YES iff it is a static (class) method, NO otherwise.
  // This is used so that when there is a conflict in the mapping of
  // selectors, selectors registered as 'instance' ones takes the
  // priority over 'class' ones.  The difference is meaningless in all
  // other respects.
  BOOL isStatic;
} JIGSSelectorMappingEntry;

/* Register a list of method mapping.  (JIGSSelectorMappingEntry *) is
   supposed to be a big constant list of methods to be registered. */
void JIGSRegisterJavaProxySelectors (JNIEnv *env, int count, 
				     JIGSSelectorMappingEntry *list);

/*
 * The following method converts a full java name: 

 * public int java.lang.String.length()

 * to a simplified form, 

 * length ()
 
 * [NB: We do add a space between the function and the brackets and also 
 * a space after the commas for arguments: "length (String, boolean)"]

 * The simplified form is always composed as in the following examples: 

 * name ()             [if no arguments]
 * name (String)       [one String argument]
 * name (String, int)  [first argument String, second argument int]

 */

const char *JIGSLongSelectorName (const char *fullJavaName, 
				  BOOL isConstructor);


/*
 * This method only adds a number of ":" equal to the number of
 * arguments at the end of javaName.

 * For example, JIGSShortSelectorName ("length", 2) will give:

 * "length::"

 * The result is always composed as follows:

 * name                [if no arguments]
 * name:               [one argument]
 * name::              [two arguments]

 */
const char *JIGSShortSelectorName (const char *javaName, 
				   int numberOfArguments);

/*
 * Morphing functions.
 */

SEL JIGSSELFromNSSelector (JNIEnv *env, jobject selector);
jobject JIGSNSSelectorFromSEL (JNIEnv *env, SEL selector);



#endif /* __JIGSSelectorMapping_h_GNUSTEP_JAVA_INCLUDE */


