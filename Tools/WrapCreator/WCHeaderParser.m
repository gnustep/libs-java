/* HeaderParser: parse useful info in an objective-C header file -*-objc-*-

   Copyright (C) 2000, 2001 Free Software Foundation, Inc.

   Author:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: August 2000, July 2001
   
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
static NSCharacterSet *whiteSpaceOrBeginEnum = nil;
static NSCharacterSet *endEnumBodyKey = nil;
static NSCharacterSet *endEnumBodyValue = nil;
static NSCharacterSet *atSymbol = nil;
static NSCharacterSet *endClassName = nil;
static NSCharacterSet *subclassSymbol = nil;

static inline void skipObjcType (NSScanner *scanner)
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

/* We remove any space character from the string */
static NSString *trimString (NSString *string)
{
  NSString *result;
  int i, count = [string length];
  unichar original[count];
  unichar trimmed[count];
  int charsCopied = 0;

  [string getCharacters: original];
  
  for (i = 0; i < count; i++)
    {
      unichar c = original[i];
      
      if (c != ' '  &&  c != '\t'  &&  c != '\n'  &&  c != '\r')
	{
	  trimmed[charsCopied] = c;
	  charsCopied++;
	}
    }
  
  result = [[NSString alloc] initWithCharacters: trimmed  length: charsCopied];
  AUTORELEASE (result);
  
  return result;    
}

@interface WCHeaderParser (Internals)
- (void) parseObjectiveC;
- (void) parseC;
- (NSDictionary *) parseEnumBodyUsingScanner: (NSScanner *)scanner;
- (void) recordEnumeration: (NSString *)enumIdentifier
	    withDictionary: (NSDictionary *)enumDictionary;
@end

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
      endEnumBodyKey = [NSCharacterSet characterSetWithCharactersInString: 
					 @"=,}"];
      endEnumBodyValue = [NSCharacterSet characterSetWithCharactersInString: 
					   @",}"];
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
      [tmpSet addCharactersInString: @"{"];
      whiteSpaceOrBeginEnum = [tmpSet copy];
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
      RETAIN (endEnumBodyKey);
      RETAIN (endEnumBodyValue);
      RETAIN (atSymbol);
      RETAIN (subclassSymbol);
    }
}

/* This facility is used by WCClass.  It's here because it is a
   separate facility and it makes more sense to put it here (in a
   parser class) than elsewhere. */
+ (NSString *) methodNameFromMethodDeclaration: (NSString *)declaration
{
  NSScanner *scanner = [NSScanner scannerWithString: declaration];
  NSString *string;
  NSMutableString *methodName;
  int argument;

  /* Skip spaces */
  [scanner scanCharactersFromSet: whiteSpace intoString: NULL];

  /* Read the +/- */
  [scanner scanCharactersFromSet: plusMinusOrEndClass intoString: &string];

  if (([string isEqualToString: @"+"] == NO) 
      && ([string isEqualToString: @"-"] == NO))
    {
      [NSException raise: @"WCHeaderParserException"
		   format: @"A method declaration must begin with either + or -, while `%@' does not", 
		   declaration];
    }

  /* Skip return type */
  skipObjcType (scanner);
  methodName = [NSMutableString new];
  argument = 0;
  while (1)
    {
      if ([scanner isAtEnd])
	{
	  break;
	}
      
      /* Skip spaces */
      [scanner scanCharactersFromSet: whiteSpace intoString: NULL];

      if ([scanner isAtEnd])
	{
	  break;
	}
      
      /* Read method name component */
      [scanner scanUpToCharactersFromSet: argOrEndMethod  
	       intoString: &string];
      
      [methodName appendString: [string stringByTrimmingSpaces]];
      
      [scanner scanCharactersFromSet: argOrEndMethod intoString: &string];
      if ((argument == 0) && [string isEqualToString: @";"])
	{
	  break;
	}
      else if ([string isEqualToString: @":"])
	{
	  [methodName appendString: @":"];
	}
      else /* Something's wrong ! */
	{
	  [NSException raise: @"WCHeaderParserException"
		       format: @"Error parsing method declaration `%@'", 
		       declaration];
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
	  break;
	}
      argument++;
    }

  return methodName;
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

  classMethods = [NSMutableDictionary new];
  instanceMethods = [NSMutableDictionary new];
  enumerations = [NSMutableDictionary new];
  unresolvedTypedefs = [NSMutableDictionary new];

  [self parseObjectiveC];
  [self parseC];

  return self;
}

/* The following methods are internals - are called by init */
- (void) parseObjectiveC
{
  NSString *string;
  NSScanner *scanner;
  NSMutableString *methodName;
  int startIndex;
  BOOL isClassMethod = NO;

  if ([WCLibrary verboseOutput] == YES)
    {
      printf ("Parsing header file for Objective-C classes and methods...\n");
    }

  scanner = [NSScanner scannerWithString: header];

  /* Loop on the class interfaces */
  while (1)
    {
      if ([scanner isAtEnd] == YES)
	{
	  break;
	}

      /* Scan up to next class interface declaration */
      [scanner scanUpToCharactersFromSet: atSymbol intoString: NULL];
      
      [scanner scanUpToCharactersFromSet: whiteSpace intoString: &string];
      
      if (([string isEqualToString: @"@interface"] == NO) 
	  && ([string isEqualToString: @"@protocol"] == NO))
	{ 
	  continue;
	}
     
      if ([WCLibrary verboseOutput] == YES)
	{
	  printf ("X");
	  fflush (stdout);
	}
 
      /* Loop on the list of methods */
      while (1)	
	{
	  int argument;
	  
	  /* Look for method declaration */
	  [scanner scanUpToCharactersFromSet: plusMinusOrEndClass 
		   intoString: NULL];
	  /* Save the starting index */
	  startIndex = [scanner scanLocation];
	  /* Read the +/- */
	  [scanner scanCharactersFromSet: plusMinusOrEndClass 
		   intoString: &string];
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
	      isClassMethod = YES;
	    }
	  else if ([string isEqualToString: @"-"] == YES)
	    {
	      isClassMethod = NO;
	    }
	  else
	    {
	      [NSException raise: @"WCHeaderParserException"
			   format: @"Could not parse the header file"];
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
	      
	      [scanner scanCharactersFromSet: argOrEndMethod 
		       intoString: &string];
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
		  if ([string length] > 0)
		    {
		      break;
		    }
		  else
		    {

		      [NSException raise: @"WCHeaderParserException"
			format: @"Error while parsing the header file"];
		    }
		}
	      argument++;
	    }
	  if (methodName != nil)
	    {
	      NSRange methodDeclarationRange;
	      int endIndex = [scanner scanLocation];
	      
	      methodDeclarationRange = NSMakeRange (startIndex, 
						    (endIndex - startIndex));
	      
	      
	      string = [header substringWithRange: methodDeclarationRange];
	      
	      if (isClassMethod == YES)
		{
		  [classMethods setObject: string  forKey: methodName];
		}
	      else
		{
		  [instanceMethods setObject: string  forKey: methodName];
		}
	    }
	}
    }

  if ([WCLibrary verboseOutput] == YES)
    {
      printf ("\n");
    }
}

- (void) parseC
{
  /* scopeDepth is the number of pending open '{' (or '(') that we
     encountered.  We want to ignore anything which is not in the
     top-most scope, which means we ignore anything found when
     (scopeDepth > 0) [except of course the closing } or ) which
     reduces scopeDepth]
     
     We also need special code to ignore anything inside string
     literals, and preprocessor comments (lines beginning with #),
     even if we try to avoid preprocessor comments completely by
     passing -P to the preprocessor. */
  int scopeDepth = 0;
  int length = [header length];
  /* we parse most of the header accessing the unichars directly */
  unichar *buffer = objc_malloc (sizeof (unichar) * length);
  /* location is the next character we will read */
  int location;
  /* When we find something interesting, then we use a scanner to do 
     the high-level parsing of the enum declarations */
  NSScanner *scanner;
  
  if ([WCLibrary verboseOutput] == YES)
    {
      printf ("Parsing header file for C enumerations...\n");
    }
  
  /* Get the header file as a unicode buffer of chars */
  [header getCharacters: buffer  range: NSMakeRange (0, length)];
  location = 0;
  
  /* And prepare a reusable scanner for when we find something
     interesting in the header. */
  scanner = [NSScanner scannerWithString: header];
  /* FIXME the following one */
  [scanner setCharactersToBeSkipped: nil];
  
#define checkThatNextCharIs(X) \
if (!(location < length  &&  buffer[location] == X)) {break;} \
else {location++;}

#define skipSpaces \
[scanner scanCharactersFromSet: whiteSpace intoString: NULL]; \
location = [scanner scanLocation]; \
if ([scanner isAtEnd]) break;

  /* Ignore first line if it is a preprocessor comment */
  if (buffer[0] == '#')
    {
      while (location < length  &&  buffer[location] != '\n')
	{
	  location++;
	}
    }
  
  /* Loop on the chars - we parse the stuff quickly to spot out the
     relevant bits.  Then we use higher-level NSScanner stuff to
     analyze the relevant bits when we find them. */
  while (location < length)
    {
      unichar c = buffer[location];

      location++;
      switch (c)
	{
	case '\n':
	  {
	    if (location < length  &&  buffer[location] == '#')
	      {
		/* Line info comment from the preprocessor - Ignore to end
		   of line */
		while (location < length  &&  buffer[location] != '\n')
		  {
		    location++;
		  }
	      }
	    break;
	  }
	case '"':
	  {
	    /* It's important that we recognize strings because we
	       don't want to be confused by things like `enum' inside
	       a string, or more commonly, open or close brackets
	       inside a string */
	    BOOL inString = YES;

	    while (inString  &&  location < length)
	      {
		switch (buffer[location])
		  {
		  case '"':
		    {
		      inString = NO;
		      break;
		    }
		  case '\\':
		    {
		      /* Ignore next char */
		      location++;
		      break;
		    }
		  }
		location++;
	      }
	    break;
	  }
	case '{':
	case '(':
	  {
	    scopeDepth++;
	    break;
	  }
	case '}':
	case ')':
	  {
	    scopeDepth--;
	    if (scopeDepth < 0)
	      {
		printf ("Error in parsing C code - found more closing brackets than opening ones!\n"); 
		exit (1);
	      }
	    break;
	  }
	case 'e':
	  {
	    /* Ignore if not at the topmost scope */
	    if (scopeDepth != 0)
	      {
		break;
	      }
	    checkThatNextCharIs ('n');
	    checkThatNextCharIs ('u');
	    checkThatNextCharIs ('m');

	    /* We now check that next char is some sort of whitespace */
	    if (!(location < length  &&  (buffer[location] == ' '
					  || buffer[location] == '\t'
					  || buffer[location] == '\n'
					  || buffer[location] == '\r')))
	      {
		break;
	      }
	    /* Yes - it is an enum at level 0 !! - process it ! 

	       NB: Here we *only* process things like 

	       enum _NSRectEdge
	       {
	         NSMinXEdge,
	         NSMinYEdge,
	         NSMaxXEdge,
	         NSMaxYEdge
	       };

	       Anything involving a typedef is instead processes when
	       `typedef enum' is encountered.  */
	    {
	      NSString *enumIdentifier;
	      NSDictionary *enumDictionary;
	      
	      /* Now that we have spotted something interesting (which
		 is going to be quite a rare thing) we sort of enter
		 into lossy high-level code programming style -
		 prepare the scanner */
	      [scanner setScanLocation: location];
	      
	      skipSpaces;
	      
	      /* TODO: Skip __attribute__((xxx)) if any */
	      
	      /* Check what follows - if it is a '{', then no luck
		 - quit to the main loop. */
	      if (location < length  &&  buffer[location] == '{')
		{
		  break;
		}
	      
	      /* It is an identifier - read it */
	      [scanner scanUpToCharactersFromSet: whiteSpace  
		       intoString: &enumIdentifier];
	      location = [scanner scanLocation];
	      if ([scanner isAtEnd])
		{
		  break;
		}
	      
	      skipSpaces;
	      
	      if (location < length  &&  buffer[location] != '{')
		{
		  /* Ack !  It is just a variable or a function returning 
		     an enum - not a declaration :-( */
		  break;
		}
	      
	      enumDictionary = [self parseEnumBodyUsingScanner: scanner];
	      
	      /* Now, save the enumDictionary for the enumIdentifier
		 in our enumeration dictionary.  Save it with full
		 correct format `enum _NSRectEdge' to prevent
		 confusion. */
	      enumIdentifier = [NSString stringWithFormat: @"enum %@", 
					 enumIdentifier];
	      [self recordEnumeration: enumIdentifier
		    withDictionary: enumDictionary];
	      location = [scanner scanLocation];
	    }
	    break;
	  }
	case 't':
	  {
	    BOOL foundSpaces = NO;

	    if (scopeDepth != 0)
	      {
		break;
	      }
	    /* Might be the beginning of a `typedef enum'
	       declaration */
	    checkThatNextCharIs ('y');
	    checkThatNextCharIs ('p');
	    checkThatNextCharIs ('e');
	    checkThatNextCharIs ('d');
	    checkThatNextCharIs ('e');
	    checkThatNextCharIs ('f');
	    
	    /* Skip spaces - but there *must* be some */
	    while (location < length && (buffer[location] == ' '
					 || buffer[location] == '\t'
					 || buffer[location] == '\r'
					 || buffer[location] == '\n'))
	      {
		foundSpaces = YES;
		location++;
	      }
	    
	    if (!foundSpaces)
	      {
		break;
	      }

	    checkThatNextCharIs ('e');
	    checkThatNextCharIs ('n');
	    checkThatNextCharIs ('u');
	    checkThatNextCharIs ('m');

	    /* Skip spaces - but there *must* be some */
	    foundSpaces = NO;
	    while (location < length && (buffer[location] == ' '
					 || buffer[location] == '\t'
					 || buffer[location] == '\r'
					 || buffer[location] == '\n'))
	      {
		foundSpaces = YES;
		location++;
	      }
	    
	    if (!foundSpaces)
	      {
		break;
	      }
	    
	    /* We got it :-) now let's process that */
	    {
	      /* Eg, in `typedef enum _NSRectEdge { xxx, yyy } NSRectEdge;'
		 enumIdentifier is `enum _NSRectEdge', while
		 typedefIdentifier is `NSRect' */
	      NSString *enumIdentifier = nil;
	      NSString *typedefIdentifier = nil;
	      NSDictionary *enumDictionary = nil;

	      /* Now that we have spotted something interesting (which
		 is going to be quite a rare thing) we sort of enter
		 into lossy high-level code programming style -
		 prepare the scanner */
	      [scanner setScanLocation: location];
	      
	      skipSpaces;
	      
	      /* TODO: Skip __attribute__((xxx)) if any */
	      
	      /* If now we have a '{', then the enum has no identifier */
	      if (location < length  &&  buffer[location] == '{')
		{
		  enumDictionary = [self parseEnumBodyUsingScanner: scanner];
		}
	      else
		{
		  /* It is an enum identifier - read it */
		  [scanner scanUpToCharactersFromSet: whiteSpaceOrBeginEnum
			   intoString: &enumIdentifier];
		  location = [scanner scanLocation];
		  if ([scanner isAtEnd])
		    {
		      break;
		    }

		  enumIdentifier = [NSString stringWithFormat: @"enum %@", 
					     enumIdentifier];
		  
		  skipSpaces;
		  
		  if (location < length  &&  buffer[location] == '{')
		    {
		      enumDictionary = [self parseEnumBodyUsingScanner:
					       scanner];
		    }
		}

	      location = [scanner scanLocation];

	      /* Now read the typedefIdentifier (which must always be
                 there) */
	      skipSpaces;
	      
	      [scanner scanUpToCharactersFromSet: whiteSpaceOrEndMethod
		       intoString: &typedefIdentifier];
	      
	      /* Now, we look at what we parsed to decide how to store it */
	      
	      if (enumDictionary != nil)
		{
		  [self recordEnumeration: typedefIdentifier
			withDictionary: enumDictionary];
		  
		  if (enumIdentifier != nil)
		    {
		      [self recordEnumeration: enumIdentifier
			    withDictionary: enumDictionary];
		    }
		}
	      else
		{
		  if (enumIdentifier == nil)
		    {
		      printf ("Error - inconsistent typedef for %s\n",
			      [typedefIdentifier lossyCString]);
		    }
		  else
		    {
		      [unresolvedTypedefs setObject: enumIdentifier
					  forKey: typedefIdentifier];
		    }
		}
	      location = [scanner scanLocation];
	    }
	    break;
	  }
	}
    }
  
  objc_free (buffer);
}

/* The following method parses the core of the enum (the part between 
   the {}), returning a dictionary of variableName = variableValue.
   Eg, in the definition 

   `typedef enum _NSComparisonResult 
    {
      NSOrderedAscending = -1, NSOrderedSame, NSOrderedDescending
    } 
    NSComparisonResult;'

    the method would be called to parse

    {
      NSOrderedAscending = -1, NSOrderedSame, NSOrderedDescending
    } 

    and it would return the dictionary

    {
      "NSOrderedAscending" = "-1";
      "NSOrderedSame" = "0";
      "NSOrderedAscending" = "1";
    }
*/
- (NSDictionary *) parseEnumBodyUsingScanner: (NSScanner *)scanner
{
#undef skipSpaces
#define skipSpaces \
[scanner scanCharactersFromSet: whiteSpace intoString: NULL]; \
if ([scanner isAtEnd]) break;

  NSMutableDictionary *enumDictionary;
  //NSString *string;
  NSString *key, *value;
  BOOL done = NO;
  /* Last enum value read, needed to compute next if not specified */
  int lastValue = -1;                   
  NSString *string = [scanner string];
  NSString *tmp;

  enumDictionary = [NSMutableDictionary new];

  /* Skip { */
  [scanner scanString: @"{"  intoString: NULL];
  
  /* We're inside the enum now :-) - loop on declarations */
  while (!done)
    {
      skipSpaces;
      
      /* It is an identifier - read it into the key */
      if (![scanner scanUpToCharactersFromSet: endEnumBodyKey  
		    intoString: &key])
	  {
	      /* Ops - no identifier - should mean it's finished -
                 usually it happens if your last enum entry has got 
		 a comma after it, as in 

		 enum hello { nicola, ettore, };

		 we just try to sneak out */
	      [scanner setScanLocation: ([scanner scanLocation] + 1)];
	      break;
	  }
      if ([scanner isAtEnd])
	{
	  break;
	}

      key = trimString (key);

      skipSpaces;
      
      switch ([string characterAtIndex: [scanner scanLocation]])
	{
	case '=':
	  {
	    /* Wow - this one has got a value */
	    [scanner setScanLocation: ([scanner scanLocation] + 1)];
	    skipSpaces;
	    [scanner scanUpToCharactersFromSet: endEnumBodyValue  
		     intoString: &value];
	    value = trimString (value);
	    if ([scanner isAtEnd])
	      {
		break;
	      }
	    /* Warning - if you have put an expression to compute as
	       value, the following is likely to return 0. */
	    lastValue = [value intValue];
	    
	    [scanner scanCharactersFromSet: endEnumBodyValue
		     intoString: &tmp];
	    if ([tmp isEqualToString: @"}"])
	      {
		done = YES;
	      }
	    break;
	  }
	case '}':
	  {
	    /* End of enum body - mark it as finished, then fall back
               on the code for ',' which computes the value */
	    done = YES;
	  }
	case ',':
	  {
	    /* No value - compute it */
	    [scanner setScanLocation: ([scanner scanLocation] + 1)];
	    lastValue++;
	    value = [NSString stringWithFormat: @"%d", lastValue];
	    break;
	  }

	}
      [enumDictionary setObject: value  forKey: key];
    }
  return enumDictionary;
}

- (void) recordEnumeration: (NSString *)enumIdentifier
	    withDictionary: (NSDictionary *)enumDictionary
{
  NSArray *aliasesToResolv;
  int i, count;

  if ([enumerations objectForKey: enumIdentifier] != nil)
    {
      printf ("WARNING: Found multiple declarations for enumeration %s\n", 
	      [enumIdentifier lossyCString]);
      return;
    }

  if ([WCLibrary verboseOutput] == YES)
    {
      printf ("Recorded enumeration %s\n", [enumIdentifier lossyCString]);
    }
  
  [enumerations setObject: enumDictionary  forKey: enumIdentifier];
  /* Now look on the unresolvedTypedefs dictionary to see if we have
     pending unresolvedTypedefs referring to this enumeration.

     For example, we might be recording now the _NSRectEdge
     enumeration, and the unresolvedTypedefs might be telling us that
     NSRectEdge is a typedef for _NSRectEdge.  In that case, we add
     NSRectEdge to enumerations with the same enumDictionary as
     _NSRectEdge, and remove NSRectEdge from the
     unresolvedTypedefs. */
  aliasesToResolv = [unresolvedTypedefs allKeysForObject: enumIdentifier];
  count = [aliasesToResolv count];
  
  for (i = 0; i < count; i++)
    {
      if ([WCLibrary verboseOutput] == YES)
	{
	  printf ("Recorded enumeration %s\n", 
		  [[aliasesToResolv objectAtIndex: i] lossyCString]);
	}
      [enumerations setObject: enumDictionary
		    forKey: [aliasesToResolv objectAtIndex: i]];
    }

  [unresolvedTypedefs removeObjectsForKeys: aliasesToResolv]; 
}

- (NSString *) declarationOfMethod: (NSString *)objcMethodName
		     isClassMethod: (BOOL)flag
{
  NSString *returnString = nil;

  if (flag == YES)
    {
      returnString = [classMethods objectForKey: objcMethodName];
    }
  else
    {
      returnString = [instanceMethods objectForKey: objcMethodName];
    }
  
  if (returnString == nil)
    {
      [NSException raise: @"WCHeaderParserException"
		   format: @"Could not find method %@ in the header file", 
		   objcMethodName];
    }

  return returnString;
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

- (NSArray *) enumerationTypes
{
  return [enumerations allKeys];
}

- (NSDictionary *) dictionaryForEnumeration: (NSString *)enumeration
{
  return [enumerations objectForKey: enumeration];
}
@end







