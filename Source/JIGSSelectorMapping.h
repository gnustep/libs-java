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

/*
 * The following method (descriptive fantasy name "strim") 
 * converts a full java name: 

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

const char *strim (const char *fullName, BOOL isConstructor);


/*
 * Map a java method name of a certain java class to an objc method name 
 *
 */
const char *
mapJavaMethodName (const char *javaName, const char *className, 
		   int numberOfArguments, const char *javaSignature, 
		   const char *types, BOOL isConstructor);


#endif /* __JIGSSelectorMapping_h_GNUSTEP_JAVA_INCLUDE */
