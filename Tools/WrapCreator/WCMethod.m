/* WCMethod.m: An instance of this class represents a method to be wrapped

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

#include "WCClass.h"
#include "WCMethod.h"
#include "WCType.h"
#include "WCLibrary.h"

static NSCharacterSet *whiteSpace = nil;
static NSCharacterSet *plusMinus = nil;
static NSCharacterSet *openBracket = nil;
static NSCharacterSet *closeBracket = nil;
static NSCharacterSet *argOrEndMethod = nil;
static NSCharacterSet *endMethod = nil;
static NSCharacterSet *whiteSpaceOrEndMethod = nil;
static NSArray *emptyArray = nil;

static WCType *scanObjcType (NSScanner *scanner)
{
  NSString *string;
  WCType *ret;

  /* Skip spaces */
  [scanner scanCharactersFromSet: whiteSpace intoString: NULL];
  
  /* Look for the return type now */
  if ([scanner scanCharactersFromSet: openBracket intoString: &string] == YES)
    {
      if ([string isEqualToString: @"("])
	{
	  // Found; parse type
	  // FIXME: Nested parenthesis 
	  [scanner scanUpToCharactersFromSet: closeBracket  intoString: &string];
	  ret = [WCType sharedTypeWithObjcType: string];
	  [scanner scanCharactersFromSet: closeBracket intoString: NULL];
	} 
      else
	{
	  return nil;
	}
    }
  else
    {
      ret = [WCType sharedTypeWithObjcType: @"id"];
    }
  return ret;
}

static NSString *convertToJNI (NSString *string)
{
  int i, length;
  unichar c;
  NSMutableString *convertedString;
  static NSCharacterSet *alphanum = nil;

  if (alphanum == nil)
    {
      alphanum = RETAIN ([NSCharacterSet alphanumericCharacterSet]);
    }

  length = [string length];

  convertedString = [NSMutableString new];

  for (i = 0; i < length; i++)
    {
      c = [string characterAtIndex: i];
      if (c == '_')
	{	  
	  [convertedString appendString: @"_1"];
	}
      else if (c == ';')
	{	  
	  [convertedString appendString: @"_2"];
	}
      else if (c == '[')
	{	  
	  [convertedString appendString: @"_3"];
	}
      else if (c == '.')
	{	  
	  [convertedString appendString: @"_"];
	}
      else if ([alphanum characterIsMember: c] == NO)
	{
	  /* This needs to output _0XXX for UNICODE character XXX */
	  [convertedString appendFormat: @"_0%d", c];
	}
      else
	{
	  [convertedString appendString: [NSString stringWithCharacters: &c 
						   length: 1]];
	}
    }

  return convertedString;
}


@implementation WCMethod

+ (void) initialize
{
  if (self == [WCMethod class])
    {
      NSMutableCharacterSet *tmpSet;

      plusMinus = [NSCharacterSet characterSetWithCharactersInString: @"+-"];
      whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
      openBracket = [NSCharacterSet characterSetWithCharactersInString: @"("];
      closeBracket = [NSCharacterSet characterSetWithCharactersInString: @")"];
      argOrEndMethod = [NSCharacterSet characterSetWithCharactersInString: @":;"];
      endMethod = [NSCharacterSet characterSetWithCharactersInString: @";"];
      emptyArray = [NSArray arrayWithObjects: nil];

      tmpSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
      [tmpSet addCharactersInString: @";"];
      whiteSpaceOrEndMethod = [tmpSet copy];
      RELEASE (tmpSet);

      RETAIN (plusMinus);
      RETAIN (whiteSpace);
      RETAIN (openBracket);
      RETAIN (closeBracket);
      RETAIN (argOrEndMethod);
      RETAIN (endMethod);
      RETAIN (emptyArray);
    }
}

+ (id) newWithObjcMethodDeclaration: (NSString *)objcMethodDeclaration
			      class: (WCClass *)aClass
		      isConstructor: (BOOL)flag
{
  return [[self alloc] initWithObjcMethodDeclaration: objcMethodDeclaration
		       class: aClass
		       isConstructor: flag];
}

- (id) initWithObjcMethodDeclaration: (NSString *)objcMethodDeclaration
			       class: (WCClass *)aClass  
		       isConstructor: (BOOL)flag
{
  NSString *string;
  NSString *string_2;
  NSMutableString *tmpMethodName = [NSMutableString new];
  NSMutableArray *tmpArguments = [NSMutableArray new];
  NSScanner *scanner;
  WCType *type;
  int argument = 0;

  ASSIGN (class, aClass);
  isConstructor = flag;

  scanner = [NSScanner scannerWithString: objcMethodDeclaration];

  /* Read +/- for class/instance method */
  [scanner scanUpToCharactersFromSet: plusMinus  intoString: NULL];
  if ([scanner scanCharactersFromSet: plusMinus intoString: &string] == NO)
    {
      [NSException raise: @"WCMethodException"
		   format: @"Could not parse method declaration %@", 
		   objcMethodDeclaration];
    }
  
  if ([string isEqualToString: @"+"] == YES)
    {
      isClassMethod = YES;
      if (isConstructor == YES)
	{
	  [NSException raise: NSGenericException
		       format: @"Trying to create a WCMethod both class method "
		       @"and constructor (%@)", objcMethodDeclaration];	  
	}
    }
  else if ([string isEqualToString: @"-"] == YES)
    {
      isClassMethod = NO;
    }
  else
    {
      [NSException raise: @"WCMethodException"
		   format: @"Could not find a single + or - at the beginning "
		   @"of method declaration %@", objcMethodDeclaration];
    }

  /* Scan return type */
  returnType = scanObjcType (scanner);
  if (returnType == nil)
    {
      [NSException raise: @"WCMethodException"
		   format: @"Could not find return type in method declaration %@", 
		   objcMethodDeclaration];
    }

  /* Now scan each part of the method name and its corresponding argument */
  while (1)
    {
      /* Skip spaces */
      [scanner scanCharactersFromSet: whiteSpace intoString: NULL];
      
      /* Read method name component */
      [scanner scanUpToCharactersFromSet: argOrEndMethod  intoString: &string];
      
      [scanner scanCharactersFromSet: argOrEndMethod intoString: &string_2];
      if (argument == 0)
	{
	  if ([string_2 isEqualToString: @";"])
	    {
	      ASSIGN (methodName, [string stringByTrimmingSpaces]);
	      ASSIGN (arguments, emptyArray);
	      ASSIGN (javaMethodName, [class javaMethodForObjcMethod: methodName]);
	      return self;
	    }
	}
      
      if ([string_2 isEqualToString: @":"])
	{
	  NSMutableString *string_3 = [NSMutableString stringWithString: string];
	  [string_3 trimSpaces];
	  [string_3 appendString: @":"];
	  [tmpMethodName appendString: string_3];
	}
      else
	{
	  [NSException raise: @"WCMethodException"
		       format: @"Could not parse arguments in method declaration "
		       @"%@", objcMethodDeclaration];
	}

      /* Scan argument type */
      type = scanObjcType (scanner);
      if (type == nil)
	{
	  [NSException raise: @"WCMethodException"
		       format: @"Could not parse argument %d in method declaration "
		       @"%@", argument, objcMethodDeclaration];
	}

      [tmpArguments addObject: type];
      
      /* Skip spaces */
      [scanner scanCharactersFromSet: whiteSpace intoString: NULL];
      
      /* Skip argument name */
      [scanner scanUpToCharactersFromSet: whiteSpaceOrEndMethod 
	       intoString: &string];

      /* Skip spaces */
      [scanner scanCharactersFromSet: whiteSpace intoString: NULL];
      
      /* Now check if next character it is a ; */
      if ([scanner scanCharactersFromSet: endMethod intoString: &string] == YES)
	{
	  if ([string isEqualToString: @";"])
	    {
	      ASSIGN (methodName, [NSString stringWithString: tmpMethodName]);
	      ASSIGN (arguments, [NSArray arrayWithArray: tmpArguments]);
	      ASSIGN (javaMethodName, [class javaMethodForObjcMethod: methodName]);
	      return self;
	    }
	  else
	    {
	      // Not sure this exception makes sense (similar in other places)
	      [NSException raise: @"WCMethodException"
			   format: @"Could not parse end of method declaration %@", 
			   objcMethodDeclaration];
	    }
	}
      argument++;
    }
  /* Never reached */
  return self;
}

- (NSString *) description
{
  return [NSString stringWithFormat: @"<WCMethod %@>", methodName];
}

- (NSString *) outputJavaWrapper
{
  NSMutableString *output;

  if ([WCLibrary outputJavadoc])
    {
      output = [NSMutableString stringWithString: @"  /**\n"];
      [output appendString: @"   * Wraps the Objective-C method\n"];
      [output appendString: @"   * <B>"];
      [output appendString: methodName];
      [output appendString: @"</B>\n   */\n"];
      [output appendString: @"  public "];
    }
  else
    {
      output = [NSMutableString stringWithString: @"  public "];
    }

  if (isConstructor == YES) /* A constructor */
      {
	/* Here we need to ouput something like: 

	    public SimpleGUI (String title)
	      {
	        super (ALLOC_ONLY);
	        realObject = this.initWithTitle (title);
	      }
	      
	   We then output initWithTitle as a (semi-)normal native method below 
	*/
	int i, count;
	[output appendString: [class shortJavaName]];
	[output appendString: [self outputJavaArguments]];
	[output appendString: @"\n  {\n    super (ALLOC_ONLY);\n    realObject = this."];
	[output appendString: [self outputJavaMethodName]];
	[output appendString: @" ("];
	count = [arguments count];
	for (i = 0; i < count; i ++)
	  {
	    if (i != 0)
	      {
		[output appendString: @", "];
	      }
	    
	    [output appendString: [NSString stringWithFormat: @"arg%d", i]];
	  }
  	[output appendString: @");\n  }\n\n  "];
      }
  else /* Not a constructor */
    {
      if (isClassMethod == YES)
	{
	  [output appendString: @"static "];
	}
    }

  [output appendString: @"native "];
  if (isConstructor == NO)
    {
      [output appendString: [returnType javaType]];
      [output appendString: @" "];
    }
  else /* it is a constructor */
    {
      [output appendString: @"long "];
    }
  [output appendString: [self outputJavaMethodName]];
  [output appendString: [self outputJavaArguments]];
  [output appendString: @";"];

  [output appendString: @"\n"];
  return output;

}

- (NSString *) outputJavaMethodName
{
  if (javaMethodName != nil)
    {
      return javaMethodName;
    }
  else 
    {
      NSArray *methodNameComponents;
      
      methodNameComponents = [methodName componentsSeparatedByString: @":"];
      return [methodNameComponents objectAtIndex: 0];
    }
}  

- (NSString *) outputJavaArguments
{
  NSMutableString *output;
  int i, count;

  output = [NSMutableString stringWithString: @" ("];
  
  count = [arguments count];
  for (i = 0; i < count; i ++)
    {
      WCType *t = (WCType *)[arguments objectAtIndex: i];
      
      if (i != 0)
	{
	  [output appendString: @", "];
	}
      
      [output appendString: [t javaType]];
      [output appendString: @" "];
      [output appendString: [NSString stringWithFormat: @"arg%d", i]];
    }
  
  [output appendString: @")"];

  return output;
}

- (NSString *) outputObjcWrapper
{
  NSMutableString *output;
  int i;
  int count = [arguments count];
  NSString *arg[count];
  NSString *objc_arg[count];
  int indentSpace, indentThisLine;
  
  /* Prepare name for arguments */
  for (i = 0; i < count; i++)
    {
      arg[i] = [NSString stringWithFormat: @"arg%d", i];
      objc_arg[i] = [NSString stringWithFormat: @"objc_arg%d", i];
    }

  /* Output method declaration */
  output = [NSMutableString stringWithString: @"JNIEXPORT "];
  if (isConstructor == NO)
    {
      [output appendString: [returnType jniType]];
    }
  else /* Constructor */
    {
      [output appendString: @"jlong"];
    }
  [output appendString: @" JNICALL\n"];
  [output appendString: [self outputJniMethodName]];
  [output appendString: @" (JNIEnv *env, "];
  if (isClassMethod == YES)
    {
      [output appendString: @"jclass class"];
    }
  else /* Not a class method */
    {
      [output appendString: @"jobject this"];
    }

  for (i = 0; i < count; i++)
    {
      WCType *t = (WCType *)[arguments objectAtIndex: i];
      
      [output appendString: @", "];
      [output appendString: [t jniType]];
      [output appendString: @" "];
      [output appendString: arg[i]];
     }

  [output appendString: @")\n{\n"];

  /* Output variable declaration */

  if (isClassMethod == NO)
    {
      [output appendString: @"  "];
      [output appendString: [class objcName]];
      [output appendString: @" *we;\n"];
    }
  else
    {
      [output appendString: @"  Class objcClass;\n"];
    }

  for (i = 0; i < count; i++)
    {
      WCType *t = (WCType *)[arguments objectAtIndex: i];
      
      [output appendString: @"  "];
      [output appendString: [t objcType]];
      // Safety space.  Ugly with objects but safer.
      [output appendString: @" "];
      [output appendString: objc_arg[i]];
      [output appendString: @";\n"];
    }

  if (isConstructor == YES)
    {
      [output appendString: @"  id objc_new;\n"];
      [output appendString: @"  jlong java;\n"];
    }
  else if ([returnType isVoidType] == NO)
    {
      [output appendString: @"  "];
      [output appendString: [returnType objcType]];
      [output appendString: @" ret;\n"];
      [output appendString: @"  "];
      [output appendString: [returnType jniType]];
      [output appendString: @" jni_ret;\n"];
    }


  [output appendString: @"\n  JIGS_ENTER;\n"];

  /* Convert object and arguments to objective-C */

  if (isClassMethod == NO)
    {
      [output appendString: @"  we = JIGSIdFromThis (env, this);\n"];
    }
  else
    {
      [output appendString: @"  objcClass = JIGSClassFromThisClass (env, class);\n"];
    }

  for (i = 0; i < count; i++)
    {
      WCType *t = (WCType *)[arguments objectAtIndex: i];
      
      [output appendString: @"  "];
      [output appendString: [t codeToConvertToObjc: arg[i]
			       givingResult: objc_arg[i]]];
      [output appendString: @"\n"];
    }

  /* Invoke the method */

  if (isConstructor == YES)
    {
      [output appendString: @"  objc_new = ["];
      indentSpace = 14;
    }
  else if ([returnType isVoidType] == NO)
    {
      [output appendString: @"  ret = ["];
      indentSpace = 9;
    }
  else 
    {
      [output appendString: @"  ["];
      indentSpace = 3;
    }

  if (isClassMethod == YES)
    {
      [output appendString: @"objcClass "];
      indentSpace += 10;
    }
  else
    {
      [output appendString: @"we "];
      indentSpace += 3;
    }

  if (count == 0)
    {
      /* No arguments ! */
      [output appendString: methodName];
    }
  else
    {
      NSArray *methodNameComponents;

      methodNameComponents = [methodName componentsSeparatedByString: @":"];

      for (i = 0; i < count; i++)
	{
	  NSString *string = [methodNameComponents objectAtIndex: i];

	  if (i != 0)
	    {
	      int j;

	      [output appendString: @"\n"];
	      indentThisLine = indentSpace - [string length];
	      if (indentThisLine > 0)
		{
		  for (j = 0; j < indentThisLine; j++)
		    {
		      [output appendString: @" "];
		    }
		}
	    }
	  else
	    {
	      indentSpace += [string length];
	    }
	  [output appendString: string];
	  [output appendString: @": "];
	  [output appendString: objc_arg[i]];
	}
    }

  [output appendString: @"];\n"];

  /* Convert the return value and exit */

  if (isConstructor == YES)
    {
      [output appendString: @"  _JIGSMapperAddJavaProxy (env, objc_new, this);\n"];
      [output appendString: @"  java = JIGS_ID_TO_JLONG (objc_new);\n"];
      [output appendString: @"  JIGS_EXIT_WITH_VALUE (java);\n"];
    }
  else if ([returnType isVoidType] == YES)
    {
      [output appendString: @"  JIGS_EXIT;\n"];
    }
  else 
    {
      [output appendString: @"  "];
      [output appendString: [returnType codeToConvertToJava: @"ret"
					givingResult: @"jni_ret"]];
      [output appendString: @"\n"];
      [output appendString: @"  JIGS_EXIT_WITH_VALUE (jni_ret);\n"];
    }

  [output appendString: @"}\n"];
  return output;
}

- (void) setOutputFullJniName: (BOOL)flag
{
  outputFullJniName = flag;
}

- (NSString *) outputJniMethodName
{
  NSMutableString *output;
  output = [NSMutableString stringWithString: @"Java_"];
  [output appendString: [class jniName]];
  [output appendString: @"_"];
  // TODO: Convert strange characters in java method name 
  // into the JNI convention
  [output appendString: [self outputJavaMethodName]];

  if (outputFullJniName == YES)
    {
      int count = [arguments count];
      
      if (count > 0)
	{
	  int i;

	  /* Output the long full JNI name to prevent clashes for
	     overridden methods */
	  [output appendString: @"__"];

	  for (i = 0; i < count; i++)
	    {
	      WCType *t = (WCType *)[arguments objectAtIndex: i];

	      /* Argh - here we could have a nightmare problem: we
		 could have an argument of a class whose full java
		 class name can't be determined...  The programmer has
		 to fix this by adding a `class method name mapping
		 hints' to his .jigs file.  Everything should work
		 anyway if he does not use this method. */
	      if ([t javaArgumentType] == nil)
		{
		  printf ("\nWARNING!\n");
		  printf ("Can not determine the full java name of class `%s'\n",
			  [[t javaType] cString]);
		  printf ("Please add a `class name mapping hints' to your .jigs file\n");
		  printf ("telling me how to map that name!  Otherwise, your java code\n");
		  printf ("will crash whenever you try accessing the method wrapping\n");
		  printf ("`%s'\n\n", [methodName cString]);
		  printf ("* IF YOU IGNORE THIS WARNING, YOUR WRAPPER LIBRARY WILL BE BROKEN *\n\n\n");
		}
	      [output appendString: convertToJNI ([t javaArgumentType])];
	    }
	}
    }

  return output;
}

- (NSString *) outputJavaArgumentSignature
{
  NSMutableString *output;
  int i, count;
  BOOL flag = NO;

  output = [NSMutableString stringWithString: @"\""];
  
  count = [arguments count];
  for (i = 0; i < count; i ++)
    {
      WCType *t = (WCType *)[arguments objectAtIndex: i];
      NSString *arg = [t javaArgumentType];
      
      if (arg == nil)
	{
	  /* Try a last guess - it is our own class name ? */
	  arg = [t javaType];
	  if ([[class objcName] isEqualToString: arg])
	    {
	      /* Yes, so we know what the long java name of our class is */
	      [output appendFormat: @"L%@;", [class javaName]];
	    }
	  else 
	    {
	      /* No - Worst case - conversion could not be done here */
	      [output appendFormat: @"L%@;", arg];
	      /* Set the flag meaning that the conversion has to be done 
		 at run-time */
	      flag = YES;
	    }
	}
      else
	{
	  [output appendString: arg];
	}
    }

  [output appendString: @"\", "];
  if (flag)
    {
      [output appendString: @"YES"];
    }
  else
    {
      [output appendString: @"NO"];
    }

  return output;
}


- (NSString *) outputSelectorMapping
{
  NSMutableString *output;
// { "start", NULL, "", NO, NO },
  output = [NSMutableString stringWithString: @"   { \""];
  [output appendString: methodName];
  [output appendString: @"\", "];
  if (javaMethodName != nil)
    {
      [output appendFormat: @"\"%@\", ", javaMethodName];
    }
  else
    {
      [output appendString: @"NULL, "];
    }
  [output appendFormat: @"%@, ", [self outputJavaArgumentSignature]];
  if (isClassMethod)
    {
      [output appendString: @"YES }"];
    }
  else
    {
      [output appendString: @"NO }"];
    }

  return output;
}
@end
