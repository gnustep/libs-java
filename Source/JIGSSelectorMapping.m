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

#include "JIGSSelectorMapping.h"
#include "GSJNI.h"

const char *strim (const char *fullName, BOOL isConstructor)
{
  static NSCharacterSet *whitespace = nil;
  static NSCharacterSet *openBracket = nil;
  static NSCharacterSet *closeBracket = nil;
  static NSArray *modifiers = nil;
  NSString *inputString = [NSString stringWithCString: fullName];
  NSScanner *scanner = [NSScanner scannerWithString: inputString];
  NSMutableString *outputString = [NSMutableString new];
  NSString *word;
  NSString *tmp;
  unsigned int scanLocation = 0;

  if (whitespace == nil)
    {
      whitespace = [NSCharacterSet whitespaceCharacterSet];
      openBracket = [NSCharacterSet characterSetWithCharactersInString: @"("];
      closeBracket = [NSCharacterSet characterSetWithCharactersInString: @")"];
      modifiers = [NSArray arrayWithObjects: @"private", @"protected", 
			   @"public", @"final", @"native", @"synchronized",
			   @"static", @"transient", @"volatile", nil];
      RETAIN (whitespace);
      RETAIN (openBracket);
      RETAIN (closeBracket);
      RETAIN (modifiers);
    }

  // Parse modifiers
  while (1)
    {
      scanLocation = [scanner scanLocation];
      //
      // Get next word
      //
      [scanner scanUpToCharactersFromSet: whitespace  intoString: &word];
      // If it's one of the modifiers we want to discard
      if ([modifiers containsObject: word])
	{
	  continue;
	}

      // Else, it is something else: get out
      break;
    }

  if (isConstructor == YES) 
    {
      // what we already have is the {method name + args}; rewind
      [scanner setScanLocation: scanLocation];
    }
  // if (isConstructor == NO) what we have is instead the return type, 
  // which we don't output.

  [scanner scanUpToCharactersFromSet: openBracket  intoString: &word];

  // word is already the method name

  if (isConstructor == NO)
    {
      // Remove any leading stuff
      tmp = [word pathExtension];
      if ((tmp != nil) && ([tmp isEqualToString: @""] == NO))
	{
	  word = tmp;
	}
    }
  
  [outputString appendString: word];
  
  // Now, the arguments 
  [scanner scanUpToCharactersFromSet: closeBracket  intoString: &word];

  // Query-replace "," with ", "
  word = [word stringByReplacingString: @"," withString: @", "];

  [outputString appendString: @" "];
  [outputString appendString: word];
  [outputString appendString: @")"];

  //NSLog (@"Strimmed %s to %@", fullName, outputString);
  
  // Discard all the rest
  return [outputString cString];
}


/*
 * Map a java method name of a certain java class to an objc method name 
 *
 */
const char *
mapJavaMethodName (const char *javaName, const char *className, 
		   int numberOfArguments, const char *javaSignature, 
		   const char *types, BOOL isConstructor)
{
  NSMutableString *objcName;
  int i;
  BOOL isOK;
  const char *cObjcName = NULL;

  isOK = YES;
  
  if (isConstructor == YES)
    {
      if (numberOfArguments == 0)
	{
	  return "init";
	}
      else
	{
	  return strim (javaSignature, isConstructor);
	}
    }
  else
    {
      // TODO: Use the following code only as a standard way 
      // of mapping method names!  Access some config somewhere 
      // otherwise
      objcName = [NSMutableString stringWithCString: javaName];
      
      for (i = 0; i < numberOfArguments; i++)
	{
	  [objcName appendString: @":"];
	}
      
      cObjcName = [objcName cString];
    }
  
  return cObjcName;
}
