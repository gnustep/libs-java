/* ObjcRuntimeUtilities2.m - Utilities to add classes and methods 
   in the Objective-C runtime, at runtime; ObjC code.

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

/* This file contains the only function of ObjCRuntimeUtilites which must
 * be compiled using the Objective-C compiler.
 */

#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSString.h>

const char *ObjcUtilities_build_runtime_Objc_signature (const char *types)
{
#if defined(LIB_FOUNDATION_LIBRARY)
  NSMethodSignature *sig;
  
  sig = [NSMethodSignature signatureWithObjCTypes: types];
  return [sig methodType];
#else
  NSMethodSignature	*sig;
  NSMutableString	*str;
  unsigned		count;
  unsigned		index;
  
  sig = [NSMethodSignature signatureWithObjCTypes: types];
  str = [NSMutableString stringWithCapacity: 128];
  [str appendFormat: @"%s", [sig methodReturnType]];
  count = [sig numberOfArguments];
  for (index = 0; index < count; index++)
    {
      [str appendFormat: @"%s", [sig getArgumentTypeAtIndex: index]];
    }
  return [str UTF8String];
#endif  
}
