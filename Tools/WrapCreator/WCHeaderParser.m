/* HeaderParser: parse methods out of an objective-C header file -*-objc-*-

   Copyright (C) 2000 Free Software Foundation, Inc.

   Author:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: August 2000
   
   This file is part of JIGS, the GNUstep Java Interface.
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */

#include "WCHeaderParser.h"
#include "WCLibrary.h"

static NSCharacterSet *whiteSpace = nil;
static NSCharacterSet *openBracket = nil;
static NSCharacterSet *closeBracket = nil;
static NSCharacterSet *plusMinusOrEndClass = nil;
static NSCharacterSet *argOrEndMethod = nil;
static NSCharacterSet *endMethod = nil;
static NSCharacterSet *whiteSpaceOrEndMethod = nil;
static NSCharacterSet *whiteSpaceOrAtSymbol = nil;
static NSCharacterSet *atSymbol = nil;
static NSCharacterSet *endClassName = nil;
static NSCharacterSet *subclassSymbol = nil;

static void skipObjcType (NSScanner *scanner)
{
  /* Skip spaces */
  [scanner scanCharactersFromSet: whiteSpace intoString: NULL];
  
  /* Look for the return type now */
  if ([scanner scanCharactersFromSet: openBracket intoString: NULL] == YES)
    {
      [scanner scanUpToCharactersFromSet: closeBracket  intoString: NULL];
      [scanner scanCharactersFromSet: closeBracket intoString: NULL];
    }
}


@implementation WCHeaderParser
+ (void) initialize
{
  if (self == [WCHeaderParser class])
    {
      NSMutableCharacterSet *tmpSet;

      whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
      openBracket = [NSCharacterSet characterSetWithCharactersInString: @"("];
      closeBracket = [NSCharacterSet characterSetWithCharactersInString: @")"];

      plusMinusOrEndClass = [NSCharacterSet 
			      characterSetWithCharactersInString: @"+-@"];
      argOrEndMethod = [NSCharacterSet characterSetWithCharactersInString: @":;"];
      endMethod = [NSCharacterSet characterSetWithCharactersInString: @";"];
      atSymbol = [NSCharacterSet characterSetWithCharactersInString: @"@"];
      subclassSymbol = [NSCharacterSet characterSetWithCharactersInString: @":"];

      tmpSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
      [tmpSet addCharactersInString: @";"];
      whiteSpaceOrEndMethod = [tmpSet copy];
      RELEASE (tmpSet);

      tmpSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
      [tmpSet addCharactersInString: @"@"];
      whiteSpaceOrAtSymbol = [tmpSet copy];
      RELEASE (tmpSet);

      tmpSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy];
      [tmpSet addCharactersInString: @"(<{+-;:@"];
      endClassName = [tmpSet copy];
      RELEASE (tmpSet);


      RETAIN (whiteSpace);
      RETAIN (openBracket);
      RETAIN (closeBracket);
      RETAIN (plusMinusOrEndClass);
      RETAIN (argOrEndMethod);
      RETAIN (endMethod);
      RETAIN (atSymbol);
      RETAIN (subclassSymbol);
    }
}

+ (id) newWithHeaderFile: (NSString *)fileName
{
  return [[self alloc] initWithHeaderFile: fileName];
}

- (id) initWithHeaderFile: (NSString *)fileName
{
  NSString *string;

  string = [NSString stringWithContentsOfFile: fileName];
  if (string == nil)
    {
      return nil;
    }

  ASSIGN (header, string);

  return self;
}

- (NSString *) declarationOfMethod: (NSString *)objcMethodName
		     isClassMethod: (BOOL)flag
{
  NSScanner *scanner;
  NSString *string;
  NSMutableString *methodName;
  int startIndex;

  scanner = [NSScanner scannerWithString: header];

  /* Loop on the class interfaces */
  while (1)
    {
      if ([scanner isAtEnd] == YES)
	{
	  return nil;
	}

      /* Scan up to next class interface declaration */
      [scanner scanUpToCharactersFromSet: atSymbol intoString: NULL];

      [scanner scanUpToCharactersFromSet: whiteSpace intoString: &string];

      if (([string isEqualToString: @"@interface"] == NO) 
	  && ([string isEqualToString: @"@protocol"] == NO))
	{
	  continue;
	}

      /* Loop on the list of methods */
      while (1)	{
	  int argument;

	  /* Look for method declaration */
	  [scanner scanUpToCharactersFromSet: plusMinusOrEndClass intoString: NULL];
	  /* Save the starting index */
	  startIndex = [scanner scanLocation];
	  /* Read the +/- */
	  [scanner scanCharactersFromSet: plusMinusOrEndClass intoString: &string];
	  /* @end */
	  if ([string isEqualToString: @"@"] == YES)
	    {
	      [scanner scanUpToCharactersFromSet: whiteSpace 
		       intoString: &string];
	      
	      if (([string isEqualToString: @"private"] == NO) 
		  && ([string isEqualToString: @"protected"] == NO)
		  && ([string isEqualToString: @"public"] == NO))
		{
		  methodName = nil;
		  break;
		}
	      else
		{
		  continue;
		}
	    }
	  if ([string isEqualToString: @"+"] == YES)
	    {
	      if (flag == NO)
		continue;
	    }
	  else if ([string isEqualToString: @"-"] == YES)
	    {
	      if (flag == YES)
		continue;
	    }
	  else
	    {
	      [NSException raise: @"WCHeaderParserException"
			   format: @"Could not find method %@ in the header file", 
			   objcMethodName];
	    }
	  /* Skip return type */
	  skipObjcType (scanner);
	  methodName = [NSMutableString new];
	  argument = 0;
	  while (1)
	    {
	      /* Skip spaces */
	      [scanner scanCharactersFromSet: whiteSpace intoString: NULL];
	      
	      /* Read method name component */
	      [scanner scanUpToCharactersFromSet: argOrEndMethod  
		       intoString: &string];

	      [methodName appendString: [string stringByTrimmingSpaces]];
	      
	      [scanner scanCharactersFromSet: argOrEndMethod intoString: &string];
	      if (argument == 0)
		{
		  if ([string isEqualToString: @";"])
		    {
		      break;
		    }
		}
	      
	      if ([string isEqualToString: @":"])
		{
		  [methodName appendString: @":"];
		}
	      else
		{
		  methodName = nil;
		  break;
		}

	      /* Skip argument type */
	      skipObjcType (scanner);
      
	      /* Skip spaces */
	      [scanner scanCharactersFromSet: whiteSpace intoString: NULL];
      
	      /* Skip argument name */
	      [scanner scanUpToCharactersFromSet: whiteSpaceOrEndMethod 
		       intoString: &string];

	      /* Skip spaces */
	      [scanner scanCharactersFromSet: whiteSpace intoString: NULL];
      
	      /* Now check if next character it is a ; */
	      if ([scanner scanCharactersFromSet: endMethod 
			   intoString: &string] == YES)
		{
		  if ([string isEqualToString: @";"])
		    {
		      break;
		    }
		  else
		    {

		      [NSException raise: @"WCHeaderParserException"
				   format: @"Error while parsing method %@ "
				   @"in the header file", 
				   objcMethodName];
		    }
		}
	      argument++;
	    }
	  if ([methodName isEqualToString: objcMethodName] == YES)
	    {
	      NSRange methodDeclarationRange;
	      int endIndex = [scanner scanLocation];
	      
	      methodDeclarationRange = NSMakeRange (startIndex, 
						    (endIndex - startIndex));
	     

	      return [header substringWithRange: methodDeclarationRange];
	    }
      }
    }
}

- (NSString *) getSuperclassOfClass: (NSString *)objcClassName
{
  NSScanner *scanner;
  NSString *string;
  
  scanner = [NSScanner scannerWithString: header];
  
  /* Loop on the class interfaces */
  while (1)
    {
      if ([scanner isAtEnd] == YES)
	{
	  break;
	}
      
      /* Scan up to next class interface declaration */
      [scanner scanUpToString: @"@interface" intoString: NULL];
      [scanner scanString: @"@interface" intoString: NULL];

      /* Skip spaces */
      [scanner scanCharactersFromSet: whiteSpace intoString: NULL];
      
      /* Read up to the end of class name */
      [scanner scanUpToCharactersFromSet: endClassName intoString: &string];
      
      string = [string stringByTrimmingSpaces];

      if ([string isEqualToString: objcClassName] == NO)
	{
	  continue;
	}

      /* Skip whitespaces */
      [scanner scanCharactersFromSet: whiteSpace intoString: NULL];

      if ([scanner scanCharactersFromSet: subclassSymbol 
		   intoString: &string] == YES)
	{
	  if ([string isEqualToString: @":"])
	    {
	      /* Skip whitespaces */
	      [scanner scanCharactersFromSet: whiteSpace intoString: NULL];
	      /* Read up to the end of superclass name */
	      [scanner scanUpToCharactersFromSet: endClassName 
		       intoString: &string];	      
	      string = [string stringByTrimmingSpaces];
	      if ([string isEqualToString: @""] == NO)
		{
		  if ([WCLibrary verboseOutput] == YES)
		    {
		      printf ("%s inherits from %s\n", [objcClassName cString], 
			      [string cString]);
		    }
		  return string;
		}
	    }
	}
    }
  NSLog (@"Could not find superclass of class %@", objcClassName);
  NSLog (@"Assuming it is NSObject");
  return @"NSObject";
}
@end





