/* WCClass.m: A class to be wrapped          -*-objc-*-

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
#include "WCLibrary.h"
#include "WCMethod.h"
#include "WCHeaderParser.h"

static NSCharacterSet *plusMinus = nil;
static NSCharacterSet *whiteSpace = nil;

static NSValue *yesValue = nil;
static NSValue *noValue = nil;

/* Routine which sets `method' to need a long jni method name if
   needed, by using the information in `jniNames' and
   `needsLongJniName'.  This function should be called in succession
   for all the methods; it will progressively shrink the jniNames and
   needsLongJniName arrays; the entry number 0 in jniNames and
   needsLongJniName matches the method we are working on. */
static void setNeedsLongJniName (NSMutableArray *jniNames,
				 NSMutableArray *needsLongJniName,
				 WCMethod *method)
{
  NSString *jniMethodName;
  int index;

  /* Get the short jni name of the method we are wrapping */
  jniMethodName = [jniNames objectAtIndex: 0];
  /* Remove it from jniNames */
  [jniNames removeObjectAtIndex: 0];
  /* Look for the first method with the same short jni name in 
     jniNames, if any */
  index = [jniNames indexOfObject: jniMethodName];
  /* Found - mark both this method and the other one as needing 
     a long jni name */
  if (index != NSNotFound)
    {
      [needsLongJniName replaceObjectAtIndex: 0  withObject: yesValue];
      /* In the following, we use (index + 1) rather than
	 (index) because needsLongJniName still contains the
	 object at index 0 while in jniNames we already
	 removed it */
      [needsLongJniName replaceObjectAtIndex: (index + 1)  
			withObject: yesValue];
    }
  /* Now if we need a long jni name, tell it to the method */
  if ([[needsLongJniName objectAtIndex: 0] isEqualToValue: yesValue])
    {
      [method setOutputFullJniName: YES];
    }
  /* That's it, remove ourselves */
  [needsLongJniName removeObjectAtIndex: 0];
}


@implementation WCClass

+ (id) newWithDictionary: (NSDictionary *)dict
{
  return [[self alloc] initWithDictionary: dict];
}

- (id) initWithDictionary: (NSDictionary *)dict
{
  NSDictionary *dictionary;
  NSArray *array;
  NSString *name;
  int i, count;

  name = [dict objectForKey: @"java name"];
  ASSIGN (javaName, name);

  name = [dict objectForKey: @"objective-c name"];
  if (name != nil)
    {
      ASSIGN (objcName, name);
    }
  else
    {
      ASSIGN (objcName, [self shortJavaName]);
    }

  array = [dict objectForKey: @"class methods"];
  ASSIGN (classMethods, array);

  array = [dict objectForKey: @"initializers"];
  ASSIGN (initializers, array);

  array = [dict objectForKey: @"instance methods"];
  ASSIGN (instanceMethods, array);

  dictionary = [dict objectForKey: @"method name mapping"];
  ASSIGN (methodNameMapping, dictionary);

  array = [dict objectForKey: @"prerequisite libraries"];
  ASSIGN (prerequisiteLibraries, array);

  array = [dict objectForKey: @"hardcoded constants"];
  ASSIGN (hardcodedConstants, array);

  array = [dict objectForKey: @"enumerations"];
  ASSIGN (enumerations, array);

  name = [dict objectForKey: @"file to include in preamble java code"];
  ASSIGN (fileWithPreambleJavaCode, name);

  name = [dict objectForKey: @"file to include in java code"];
  ASSIGN (fileWithIncludedJavaCode, name);

  name = [dict objectForKey: @"file to include in objective-c code"];
  ASSIGN (fileWithIncludedObjcCode, name);

  /* This allows to explicitly declare the declaration you want to be
     used for a method in your class, overriding the results of
     WrapCreator's standard header parsing routine.  Useful when a
     method is declared with different argument types in different
     classes/protocols, and you want a specific one to be used for
     your class - the WrapCreator standard parsing stuff will not do
     that, because it is designed for the standard case (ie, every
     method is always declared with the same signature in all
     classes), thus disregards information about where the method
     declaration comes from.  */
  array = [dict objectForKey: @"method declarations"];
  classMethodDeclarations = [NSMutableDictionary new];
  instanceMethodDeclarations = [NSMutableDictionary new];

  if (plusMinus == nil)
    {
      plusMinus = [NSCharacterSet characterSetWithCharactersInString: @"+-"];
      RETAIN (plusMinus);
      whiteSpace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
      RETAIN (whiteSpace);
    }

  count = [array count];
  for (i = 0; i < count; i++)
    {
      NSString *declaration = [array objectAtIndex: i];
      NSString *methodName; 
      NSScanner *scanner;
      
      if ([declaration hasSuffix: @";"] == NO)
	{
	  declaration = [declaration stringByAppendingString: @";"];
	}

      /* Get method name */
      methodName = [WCHeaderParser methodNameFromMethodDeclaration: 
				     declaration];
      scanner = [NSScanner scannerWithString: declaration];

      /* Get if it is a class method */
      [scanner scanCharactersFromSet: whiteSpace  intoString: NULL];
      [scanner scanCharactersFromSet: plusMinus   intoString: &name];

      if ([name isEqualToString: @"+"]) 
	{
	  [classMethodDeclarations setObject: declaration  forKey: methodName];
	}
      else
	{
	  [instanceMethodDeclarations setObject: declaration  
				      forKey: methodName];
	}
    }

  // TODO: Class specific configurations read here
  return self;
}

- (NSString *)objcName
{
  return objcName;
}

- (NSString *)javaName
{
  return javaName;
}

- (NSString *)jniName
{
  // FIXME: Better conversion java name->jni name
  return [javaName stringByReplacingString: @"." withString: @"_"];
}

- (NSString *)packageName
{
  NSString *packageName;
      
  packageName = [javaName stringByDeletingPathExtension];
      
  if (([packageName isEqualToString: @""] == NO) 
      && ([packageName isEqualToString: javaName] == NO))
    {
      return packageName;
    }
  else
    {
      return nil;
    }  
}

- (NSString *)shortJavaName
{
  NSString *shortJavaName;
      
  shortJavaName = [javaName pathExtension];
      
  if ([shortJavaName isEqual: @""] == NO)
    {
      return shortJavaName;
    }
  else
    {
      return javaName;
    }
}

- (NSString *)javaMethodForObjcMethod: (NSString *)methodName
{
  NSString *output;

  output = [methodNameMapping objectForKey: methodName];
  if (output != nil)
    {
      return output;
    }
  
  return [WCLibrary javaMethodForObjcMethod: methodName];
}

- (NSString *) declarationOfMethod: (NSString *)methodName
		     isClassMethod: (BOOL)flag
{
  static WCHeaderParser *wc = nil; 
  NSString *returnString = nil;

  if (wc == nil)
    {
      wc = [WCLibrary headerParser];
    }

  if (flag == YES)
    {
      returnString = [classMethodDeclarations objectForKey: methodName];
    }
  else
    {
      returnString = [instanceMethodDeclarations objectForKey: methodName];
    }

  if (returnString != nil)
    {
      return returnString;
    }
  else
    {
      /* FIXME: Should ask to WCLibrary for it too ? */
      return [wc declarationOfMethod: methodName  isClassMethod: flag];
    }
}

- (NSArray *)prerequisiteLibraries
{
  NSMutableArray *arrayOne;
  NSArray *arrayTwo;
  NSObject *object;
  int i, count;

  arrayOne = [[WCLibrary prerequisiteLibraries] mutableCopy];
  arrayTwo = prerequisiteLibraries;

  if (arrayOne == nil)
    {
      arrayOne = [NSMutableArray new];
    }

  AUTORELEASE (arrayOne);

  /* Now merge the two; WCLibrary ones come before and we don't 
     want replicates. */
  count = [arrayTwo count];
  for (i = 0; i < count; i++)
    {
      object = [arrayTwo objectAtIndex: i];
      if ([arrayOne containsObject: object] == NO)
	{
	  [arrayOne addObject: object];
	}
    }

  return arrayOne;
}

- (void) outputWrappers
{
  NSString *path;
  NSMutableString *objcOutput;
  NSMutableString *javaOutput;
  NSMutableString *selectorMapOutput;
  NSMutableString *selectorMapList;
  NSString *declaration;
  WCMethod *method;
  int i, count;
  NSArray *libraries;
  int selectorMappingCount = 0;
  WCHeaderParser *wc = [WCLibrary headerParser];

  /* The following three arrays will contain WCMethod objects for each
     of the method to wrap */
  NSMutableArray *initializerMethodArray;
  NSMutableArray *classMethodArray;
  NSMutableArray *instanceMethodArray;

  /* Now The stuff to manage short vs long JNI names */

  /* The short jni names of all the methods of this class in a long list */
  NSMutableArray *jniNames;
  /* For each of them, whether we need a long jni name */
  NSMutableArray *needsLongJniName;
  /* Some temporary ivars */
  BOOL tmpBool;
  /* This will hold additional code loaded from files */
  NSString *addCode;

  javaOutput = [NSMutableString stringWithString: @"/* Wrapper for class "];
  [javaOutput appendString: objcName];
  [javaOutput appendString: @", generated by JIGS Wrap Creator\n"];
  [javaOutput appendString: @"   This file is automatically generated, "];
  [javaOutput appendString: @"do not edit!\n"];
  [javaOutput appendString: @"*/\n"];

  if ([self packageName] != nil)
    {
      [javaOutput appendFormat: @"package %@;\n\n", [self packageName]];
    }
  
  [javaOutput appendString: @"import gnu.gnustep.java.JIGS;\n"];
  [javaOutput appendString: @"import gnu.gnustep.base.*;\n\n"];
  // TODO: Additional imports ?

  if (fileWithPreambleJavaCode != nil)
    {
      [javaOutput appendString: @"/* CUSTOM PREMABLE JAVA CODE */\n"];
      addCode = [WCLibrary fileWithRelativePath: fileWithPreambleJavaCode];
      [javaOutput appendString: addCode];
      [javaOutput appendString: @"\n/* END OF CUSTOM PREMABLE JAVA CODE */\n"];
    }

  if ([WCLibrary outputJavadoc])
    {
      [javaOutput appendString: @"/**\n"];
      [javaOutput appendString: @" * This class wraps the Objective-C class <B>"];
      [javaOutput appendString: objcName];
      [javaOutput appendString: @"</B>.\n"];
      [javaOutput appendString: @" * It was automatically generated by JIGS WrapCreator. \n"];
      [javaOutput appendString: @" */\n"];
    }

  [javaOutput appendString: @"public class "];
  [javaOutput appendString: [self shortJavaName]];
  [javaOutput appendString: @" extends "];
  [javaOutput appendString: [wc getSuperclassOfClass: objcName]];
  [javaOutput appendString: @"\n{\n"];
  [javaOutput appendString: @"\n  static\n  {"];

  libraries = [self prerequisiteLibraries];
  count = [libraries count];
  for (i = 0; i < count; i++)
    {
      [javaOutput appendString: @"\n    JIGS.loadLibrary (\""];
      [javaOutput appendString: (NSString *)[libraries objectAtIndex: i]];
      [javaOutput appendString: @".A\");"];      
    }

  [javaOutput appendString: @"\n    JIGS.loadLibrary (\""];
  [javaOutput appendString: [WCLibrary shortLibraryName]];
  [javaOutput appendString: @".A\");\n"];
  [javaOutput appendString: @"  }\n\n  protected "];
  [javaOutput appendString: [self shortJavaName]];
  [javaOutput appendString: @" (GSInitializationType type)\n  {\n     "
	      @"super (type);\n  }\n\n"];

  objcOutput = [NSMutableString stringWithString: @"/* Wrapper for class "];
  [objcOutput appendString: objcName];
  [objcOutput appendString: @", generated by JIGS Wrap Creator\n"];
  [objcOutput appendString: @"   This file is automatically generated, do not edit!\n"];
  [objcOutput appendString: @"*/\n"];
  
  [objcOutput appendString: @"#include <Foundation/Foundation.h>\n"];
  [objcOutput appendString: @"#include <jni.h>\n"];
  [objcOutput appendString: @"#include <java/JIGS.h>\n"];
  // FIXME: #include "./SimpleGUI.h"
  [objcOutput appendFormat: @"#include \"%@\"\n", [WCLibrary libraryHeader]];
  [objcOutput appendString: @"\n"];

   selectorMapOutput = [NSMutableString stringWithString: @"/* List of selector mappings for class "];
  [selectorMapOutput appendString: objcName];
  [selectorMapOutput appendString: @"\n   generated by JIGS Wrap Creator\n"];
  [selectorMapOutput appendString: @"   This file is automatically generated, "];
  [selectorMapOutput appendString: @"do not edit!\n"];
  [selectorMapOutput appendString: @"*/\n"];
  [selectorMapOutput appendString: @"\n"];

  selectorMapList = [NSMutableString stringWithString: @""];

  /* Now the methods */

  /*
    We now have the problem that normal methods should have the name
    of the native function implementing them built in the short way,
    while overloaded native methods should have the name built in the
    long way.  The long way is much more dangerous, so we want to use
    the short one whenever possible.

    We solve this problem in a slow but very safe way: we first build
    a list of all the methods of the class and get a list of their jni
    names.  We use this list to check, whenever we output the wrapper
    for a method, if its short method jni name is not unique, in which
    case we output the long jni name.  Speed doesn't seem worth the
    effort needed to attain it in this context. */


  /* Prepare the arrays */
  initializerMethodArray = [NSMutableArray new];
  classMethodArray = [NSMutableArray new];
  instanceMethodArray = [NSMutableArray new];

  jniNames = [NSMutableArray new];
  needsLongJniName = [NSMutableArray new];

  /* Prepare the values to put in needsLongJniName */
  if (yesValue == nil)
    {
      tmpBool = YES;
      yesValue = [NSValue value: &tmpBool  withObjCType: @encode (BOOL)];
      RETAIN (yesValue);
      tmpBool = NO;
      noValue = [NSValue value: &tmpBool  withObjCType: @encode (BOOL)];
      RETAIN (noValue);
    }      

  /* Now fill in the list of methods */
  if (initializers != nil)
    {
      count = [initializers count];
      
      for (i = 0; i < count; i++)
	{
	  declaration = [self declarationOfMethod: 
				[initializers objectAtIndex: i]
			      isClassMethod: NO];
	  method = [WCMethod newWithObjcMethodDeclaration: declaration
			     class: self
			     isConstructor: YES];
	  [initializerMethodArray addObject: method];
	  [jniNames addObject: [method outputJniMethodName]];
	  [needsLongJniName addObject: noValue];
	}
    }

  if (classMethods != nil)
    {
      count = [classMethods count];
      for (i = 0; i < count; i++)
	{
	  declaration = [self declarationOfMethod: 
				[classMethods objectAtIndex: i]
			      isClassMethod: YES];
	  method = [WCMethod newWithObjcMethodDeclaration: declaration
			     class: self
			     isConstructor: NO];      

	  [classMethodArray addObject: method];
	  [jniNames addObject: [method outputJniMethodName]];
	  [needsLongJniName addObject: noValue];
	}
    }

  if (instanceMethods != nil)
    {
      count = [instanceMethods count];
      
      for (i = 0; i < count; i++)
	{
	  declaration = [self declarationOfMethod: 
				[instanceMethods objectAtIndex: i]
			      isClassMethod: NO];
	  method = [WCMethod newWithObjcMethodDeclaration: declaration
			     class: self
			     isConstructor: NO];
	  [instanceMethodArray addObject: method];
	  [jniNames addObject: [method outputJniMethodName]];
	  [needsLongJniName addObject: noValue];
	}
    }

  /* Second phase - we really output the wrappers */
 
  if (initializers != nil)
    {
      [javaOutput appendString: @"  /* Constructors */\n"];
      [javaOutput appendString: @"\n"];
      [objcOutput appendString: @"/* Initializers */\n"];
      [objcOutput appendString: @"\n"];

      count = [initializers count];

      for (i = 0; i < count; i++)
	{
	  if ([WCLibrary verboseOutput] == YES)
	    {
	      printf ("Wrapping initializer %s\n", 
		      [[initializers objectAtIndex: i] cString]);
	    }
	  method = [initializerMethodArray objectAtIndex: i];

	  setNeedsLongJniName (jniNames, needsLongJniName, method);

	  [javaOutput appendString: [method outputJavaWrapper]];
	  [javaOutput appendString: @"\n"];
	  [objcOutput appendString: [method outputObjcWrapper]];
	  [objcOutput appendString: @"\n"];
	}
    }

  if (hardcodedConstants != nil)
    {
      NSString *string;

      [javaOutput appendString: @"  /* Constants (Hardcoded) */\n"];
      [javaOutput appendString: @"\n"];

      count = [hardcodedConstants count];
	    
      for (i = 0; i < count; i++)
	{
	  string = [hardcodedConstants objectAtIndex: i];

	  if ([WCLibrary verboseOutput] == YES)
	    {
	      printf ("Adding hardcoded constant %s\n", [string cString]);
	    }
	  [javaOutput appendString: @"  public static "];
	  [javaOutput appendString: string];
	  [javaOutput appendString: @";\n"];
	}
      [javaOutput appendString: @"\n"];
    }

  if (enumerations != nil)
    {
      NSString *string;

      [javaOutput appendString: @"  /* Constants (Enumerations) */\n"];
      [javaOutput appendString: @"\n"];
      
      count = [enumerations count];
      
      for (i = 0; i < count; i++)
	{
	  NSDictionary *dict;
	  NSArray *keys;
	  int j, keysCount;

	  string = [enumerations objectAtIndex: i];

	  if ([WCLibrary verboseOutput] == YES)
	    {
	      printf ("Generating constants for enumeration %s\n", 
		      [string lossyCString]);
	    }
	  [javaOutput appendString: @"  /* "];
	  [javaOutput appendString: string];
	  [javaOutput appendString: @" */\n"];

	  dict = [wc dictionaryForEnumeration: string];
	  keys = [dict allKeys];
	  keysCount = [keys count];

	  for (j = 0; j < keysCount; j++)
	    {
	      NSString *key = [keys objectAtIndex: j];

	      if ([WCLibrary outputJavadoc])
		{
		  [javaOutput appendString: @"  /** Wraps a constant from the Objective-C enumeration type\n"];
		  [javaOutput appendString: @"   * <B>"];
		  [javaOutput appendString: string];
		  [javaOutput appendString: @"</B>\n */\n"];
		}
	      [javaOutput appendString: @"  public static int "];
	      [javaOutput appendString: key];
	      [javaOutput appendString: @" = "];
	      [javaOutput appendString: [dict objectForKey: key]];
	      [javaOutput appendString: @";\n"];
	    }
	}
      [javaOutput appendString: @"\n"];
    }

  if (classMethods != nil)
    {
      [javaOutput appendString: @"  /* Static Methods */\n"];
      [javaOutput appendString: @"\n"];
      [objcOutput appendString: @"/* Class methods */\n"];
      [objcOutput appendString: @"\n"];
      
      count = [classMethods count];
      selectorMappingCount += count;

      for (i = 0; i < count; i++)
	{
	  if ([WCLibrary verboseOutput] == YES)
	    {
	      printf ("Wrapping class method %s\n", 
		      [[classMethods objectAtIndex: i] cString]);
	    }
	  method = [classMethodArray objectAtIndex: i];

	  setNeedsLongJniName (jniNames, needsLongJniName, method);

	  [javaOutput appendString: [method outputJavaWrapper]];
	  [javaOutput appendString: @"\n"];
	  [objcOutput appendString: [method outputObjcWrapper]];
	  [objcOutput appendString: @"\n"];
	  [selectorMapList appendString: [method outputSelectorMapping]];
	  if ((i + 1 < count) || [instanceMethods count] > 0)
	    {
	      [selectorMapList appendString: @",\n"];
	    }
	  else
	    {
	      [selectorMapList appendString: @"\n"];
	    }
	}
    }

  if (instanceMethods != nil)
    {
      [javaOutput appendString: @"  /* Instance Methods */\n"];
      [javaOutput appendString: @"\n"];
      [objcOutput appendString: @"/* Instance Methods */\n"];
      [objcOutput appendString: @"\n"];
      
      count = [instanceMethods count];
      selectorMappingCount += count;
      
      for (i = 0; i < count; i++)
	{
	  if ([WCLibrary verboseOutput] == YES)
	    {
	      printf ("Wrapping instance method %s\n", 
		      [[instanceMethods objectAtIndex: i] cString]);
	    }
	  method = [instanceMethodArray objectAtIndex: i];

	  setNeedsLongJniName (jniNames, needsLongJniName, method);

	  [javaOutput appendString: [method outputJavaWrapper]];
	  [javaOutput appendString: @"\n"];
	  [objcOutput appendString: [method outputObjcWrapper]];
	  [objcOutput appendString: @"\n"];
	  [selectorMapList appendString: [method outputSelectorMapping]];
	  if (i + 1 < count)
	    {
	      [selectorMapList appendString: @",\n"];
	    }
	  else
	    {
	      [selectorMapList appendString: @"\n"];
	    }
	}
    }

  if (fileWithIncludedJavaCode != nil)
    {
      [javaOutput appendString: @"  /* CUSTOM JAVA CODE */\n"];
      addCode = [WCLibrary fileWithRelativePath: fileWithIncludedJavaCode];
      [javaOutput appendString: addCode];
      [javaOutput appendString: @"\n  /* END OF CUSTOM JAVA CODE */\n\n"];
    }
  [javaOutput appendString: @"}\n/* END OF FILE */\n"];

  if (fileWithIncludedObjcCode != nil)
    {
      [objcOutput appendString: @"/* CUSTOM OBJECTIVE-C CODE */\n"];
      addCode = [WCLibrary fileWithRelativePath: fileWithIncludedObjcCode];
      [objcOutput appendString: addCode];
      [objcOutput appendString: @"\n/* END OF CUSTOM OBJECTIVE-C CODE */\n\n"];
    }
  [objcOutput appendString: @"/* END OF FILE */\n"];  

  /* Now we can prepare the real selector mapping table */
  [selectorMapOutput appendFormat: @"#define %@_count %d\n\n", 
		     objcName, selectorMappingCount];
  [selectorMapOutput appendFormat: @"JIGSSelectorMappingEntry %@_map_list[%@_count] =\n",
		     objcName, objcName];
  [selectorMapOutput appendString: @"{\n   /* There is an entry in this list for each method\n"];
  [selectorMapOutput appendString: @"      exposed to java, with the exception of constructors.\n"];
  [selectorMapOutput appendString: @"      Each entry has the following form:\n\n"];
  [selectorMapOutput appendString: @"      { objC name, java name, java argument types, needsLookup, isClassMethod }\n\n"];
  [selectorMapOutput appendString: @"      java name might be NULL when no special mapping is required:\n"];
  [selectorMapOutput appendString: @"      it is obtained from the objC name then.\n"];
  [selectorMapOutput appendString: @"      The needsLookup flag is 'NO' if the java argument signature is ready\n"];
  [selectorMapOutput appendString: @"      to be used by JIGS.  This means all class names have been expanded to\n"];
  [selectorMapOutput appendString: @"      their long form, as in 'gnu.gnustep.base.NSSet' instead of 'NSSet'.\n"];
  [selectorMapOutput appendString: @"      If some of them are not, the lookup has to be done at run-time,\n"];
  [selectorMapOutput appendString: @"      which is what 'needsLookup'==YES means.  Beware: ready==NO is much\n"];
  [selectorMapOutput appendString: @"      faster and only exposed Objc classes can be looked up at runtime. */\n\n"];
  [selectorMapOutput appendString: selectorMapList];
  [selectorMapOutput appendString: @"};\n"];
  
  /* Create directories for Java file */
  [WCLibrary createJavaDirectoryForClass: javaName];
  /* Write the Java Code to file */
  path = [WCLibrary javaWrapperFileForClass: javaName];
  if ([javaOutput writeToFile: path  atomically: YES] == NO)
    {
      NSLog (@"Error - could not write to file %@", path);
    }
  /* Write Objc Code to file */
  path = [WCLibrary objcWrapperFileForClass: objcName];
  if ([objcOutput writeToFile: path  atomically: YES] == NO)
    {
      NSLog (@"Error - could not write to file %@", path);
    }
  /* Write selector mapping table to file */
  path = [WCLibrary selectorMapFileForClass: objcName];
  if ([selectorMapOutput writeToFile: path  atomically: YES] == NO)
    {
      NSLog (@"Error - could not write to file %@", path);
    }
}

- (NSString *)description 
{
  return [NSString stringWithFormat:@"<%@ 0x%08x: objc=%@ java=%@>",
		   NSStringFromClass ([self class]),
		   self, objcName, javaName];
}

@end



