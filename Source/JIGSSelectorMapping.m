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
#include "JIGSMapper.h"
#include "GSJNI.h"
#include <string.h>
#include <pthread.h>

/* Selector Mapping Table.  
   This table is sort of a usual map table, only it is meant to be 
   used in both ways (given a key, get a value; given a value, get a key).

   Optimizing the table did not seem a priority, because the table is
   actually used only when morphing selectors, and this is not such a
   frequent thing.  NB: The table is *not* used in messaging.

   There is the issue whether this table is redundant with the one
   used for messaging.  Well, the one used for messaging should be
   much faster than this one (it jumps to the class, then only checks
   the list of selectors for that class, and keeps the java signature
   in a form ready for messaging), and should work without a wrink
   under adverse conditions (mapping conflicts between classes) while
   this one is more limited.

*/

/* A type representing a java selector */
typedef struct java_selector
{
  const char *name;     
  const char *signature;
  // See similar entry in JIGSSelectorMappingEntry for explanation
  BOOL unresolved;
} *jSEL;

/**
 ** Now the very private table stuff 
 **/

/* Lock protecting the table*/
static pthread_mutex_t JIGSSelectorMappingLock;

/* The table itself, divided into two tables.  One, for class
   selectors, the other one, for instance one.  The reason why we do a
   difference is that we always want instance selectors to take
   precedence over class selectors.  Thus, we always look first into 
   the instance selector mapping table.*/
struct _JIGSSelectorMappingEntry
{
  SEL objcSelector;       
  jSEL javaSelector;
};

static struct _JIGSSelectorMappingEntry *JIGSClassSelMapTable = NULL;
static struct _JIGSSelectorMappingEntry *JIGSInstanceSelMapTable = NULL;

/* Number of entries in the table */
static int classEntries = 0;
static int instanceEntries = 0;

static BOOL JIGSInitLock = NO;

/*
 * resolveJavaSignature resolves a java signature into the complete 
 * java signature.  The returned string is malloced using malloc. 
 */
static const char *resolveJavaSignature (JNIEnv *env, const char *signature)
{
  NSString *originalSignature;
  NSMutableString *resolvedSignature;
  NSScanner *scanner;
  NSString *string;
  NSString *convertedString;
  static NSCharacterSet *classOrArrayCS = nil;
  static NSCharacterSet *classCS = nil;  
  static NSCharacterSet *endClassCS = nil;  
  static NSCharacterSet *arrayCS = nil;

  originalSignature = [NSString stringWithCString: signature];
  resolvedSignature = [NSMutableString new];
  scanner = [NSScanner scannerWithString: originalSignature];
  
  if (classOrArrayCS == nil)
    {
      classOrArrayCS = [NSCharacterSet characterSetWithCharactersInString: 
					 @"L["];
      RETAIN (classOrArrayCS);
      classCS = [NSCharacterSet characterSetWithCharactersInString: @"L"];
      RETAIN (classCS);
      endClassCS = [NSCharacterSet characterSetWithCharactersInString: @";"];
      RETAIN (endClassCS);
      arrayCS = [NSCharacterSet characterSetWithCharactersInString: @"["];
      RETAIN (arrayCS);
    }

  while (1)
    {
      /* Scans up to a L (object) or a [ (array) */
      if ([scanner scanUpToCharactersFromSet: classOrArrayCS 
		   intoString: &string])
	{
	  [resolvedSignature appendString: string];
	}

      if ([scanner isAtEnd] == YES)
	break;

      /* If it is a array: */
      if ([scanner scanCharactersFromSet: arrayCS  intoString: &string])
	{
	  [resolvedSignature appendString: string];
	  /* If it is an array of objects */
	  if ([scanner scanCharactersFromSet: classCS intoString: &string])
	    {
	      [resolvedSignature appendString: string];
	      /* Then copy the java class name as it is.  This because 
		 this class name is already the full class name. */
	      [scanner scanUpToCharactersFromSet: endClassCS  
		       intoString: &string];
	      [resolvedSignature appendString: string];
	    }
	  /* If it is not an array of objects, we can safely continue */
	  continue;
	}
      
      /* If it is a class name: */
      if ([scanner scanCharactersFromSet: classCS  intoString: &string])
	{
	  /* FIXME/TODO: Manage the case of packages beginning with
	     'L', eg: class name Livius.Titus.Historia (not really
	     standard but anyway) */
	  [resolvedSignature appendString: string];
	  /* Then get the java class name. */
	  [scanner scanUpToCharactersFromSet: endClassCS  
		   intoString: &string];
	  /* Try resolving it */
	  convertedString = _JIGSLongJavaClassNameForObjcClassName (env, 
								    string);
	  if (convertedString != nil)
	    {
	      [resolvedSignature appendString: convertedString];
	    }
	  else
	    {
	      [resolvedSignature appendString: string];	
	    }
	}
    }

  return strdup ([resolvedSignature cString]);
}

static jSEL resolveJavaSelector (JNIEnv *env, jSEL selector)
{
  if (selector->unresolved == YES)
    {
      jSEL newJavaSelector;
      
      newJavaSelector = malloc (sizeof (jSEL));
      newJavaSelector->name = selector->name;
      newJavaSelector->signature = resolveJavaSignature (env, 
							 selector->signature);
      newJavaSelector->unresolved = NO;
      return newJavaSelector;
    }
  
  /* No need to resolve */
  return NULL;
}

/** 
 **  private functions to access the table 
 **/

static void JIGSSelectorMappingTableCreate ()
{
  pthread_mutex_init (&JIGSSelectorMappingLock, NULL);
  /* The table is only 'created' when something is first added to it */
}

/*
 * Add entry to the table.  We assume the entry is *not* already there.  
 * If the entry is already there, this one is added at the end of the 
 * table, so it will never be used.
 */
static void JIGSSelectorMappingAddInstanceEntry (SEL selector, 
						 const char *javaName, 
						 const char *javaSignature,
						 BOOL unresolved,
						 BOOL copy)
{
  jSEL newJavaSelector;

  pthread_mutex_lock (&JIGSSelectorMappingLock);
  /* Resize table */
  if (JIGSInstanceSelMapTable == NULL)
    {
      instanceEntries = 1;
      JIGSInstanceSelMapTable = malloc (sizeof (struct _JIGSSelectorMappingEntry));
    }
  else
    {
      instanceEntries++;
      JIGSInstanceSelMapTable = realloc (JIGSInstanceSelMapTable, 
				 (sizeof (struct _JIGSSelectorMappingEntry) 
				  * instanceEntries));
    }
  /* Add at the end */
  (JIGSInstanceSelMapTable[instanceEntries - 1]).objcSelector = selector;
  
  newJavaSelector = malloc (sizeof (jSEL));
  if (copy)
    {
      newJavaSelector->name = strdup (javaName);
      newJavaSelector->signature = strdup (javaSignature);
      newJavaSelector->unresolved = unresolved;
    }
  else
    {
      newJavaSelector->name = javaName;
      newJavaSelector->signature = javaSignature;
      newJavaSelector->unresolved = unresolved;
    }
  (JIGSInstanceSelMapTable[instanceEntries - 1]).javaSelector 
    = newJavaSelector;

  pthread_mutex_unlock (&JIGSSelectorMappingLock);
}

static void JIGSSelectorMappingAddClassEntry (SEL selector, 
					      const char *javaName, 
					      const char *javaSignature,
					      BOOL unresolved,
					      BOOL copy)
{
  jSEL newJavaSelector;

  pthread_mutex_lock (&JIGSSelectorMappingLock);
  /* Resize table */
  if (JIGSClassSelMapTable == NULL)
    {
      classEntries = 1;
      JIGSClassSelMapTable = malloc (sizeof (struct _JIGSSelectorMappingEntry));
    }
  else
    {
      classEntries++;
      JIGSClassSelMapTable = realloc (JIGSClassSelMapTable, 
				      (sizeof(struct _JIGSSelectorMappingEntry) 
				       * classEntries));
    }
  /* Add at the end */
  (JIGSClassSelMapTable[classEntries - 1]).objcSelector = selector;
  
  newJavaSelector = malloc (sizeof (jSEL));
  if (copy)
    {
      newJavaSelector->name = strdup (javaName);
      newJavaSelector->signature = strdup (javaSignature);
      newJavaSelector->unresolved = unresolved;
    }
  else
    {
      newJavaSelector->name = javaName;
      newJavaSelector->signature = javaSignature;
      newJavaSelector->unresolved = unresolved;
    }
  (JIGSClassSelMapTable[classEntries - 1]).javaSelector = newJavaSelector;

  pthread_mutex_unlock (&JIGSSelectorMappingLock);
}

static jSEL JIGSSelectorMappingFindInstanceSelector (JNIEnv *env, SEL selector)
{
  int i;

  pthread_mutex_lock (&JIGSSelectorMappingLock);
  for (i = 0; i < instanceEntries; i++)
    {
      if (sel_isEqual ((JIGSInstanceSelMapTable[i]).objcSelector, selector))
	{                                                      
	  pthread_mutex_unlock (&JIGSSelectorMappingLock);
	  if (((JIGSInstanceSelMapTable[i]).javaSelector)->unresolved == YES)
	    {
	      (JIGSInstanceSelMapTable[i]).javaSelector = 
		resolveJavaSelector (env, 
				     JIGSInstanceSelMapTable[i].javaSelector);
	    }
	  return (JIGSInstanceSelMapTable[i]).javaSelector;	
	}                                                      
    }
  /* Not found */
  pthread_mutex_unlock (&JIGSSelectorMappingLock);
  return NULL;
}

static jSEL JIGSSelectorMappingFindClassSelector (JNIEnv *env, SEL selector)
{
  int i;

  pthread_mutex_lock (&JIGSSelectorMappingLock);
  for (i = 0; i < classEntries; i++)
    {
      if (sel_isEqual ((JIGSClassSelMapTable[i]).objcSelector, selector))
	{                                                      
	  pthread_mutex_unlock (&JIGSSelectorMappingLock);
	  if (((JIGSClassSelMapTable[i]).javaSelector)->unresolved == YES)
	    {
	      (JIGSClassSelMapTable[i]).javaSelector = 
		resolveJavaSelector (env, 
				     JIGSClassSelMapTable[i].javaSelector);
	    }
	  return (JIGSClassSelMapTable[i]).javaSelector;	
	}                                                      
    }
  
  /* Not found */
  pthread_mutex_unlock (&JIGSSelectorMappingLock);
  return NULL;
}

static jSEL JIGSSelectorMappingFindSelector (JNIEnv *env, SEL selector)
{
  jSEL result;

  result = JIGSSelectorMappingFindInstanceSelector (env, selector);
  if (result != NULL)
    {
      return result;
    }
  else
    {
      result = JIGSSelectorMappingFindClassSelector (env, selector);
      return result;
    }
}

static SEL 
JIGSSelectorMappingFindInstanceJavaMethod (JNIEnv *env, 
					   const char *javaName, 
					   const char *javaSignature)
{
  int i;
  
  pthread_mutex_lock (&JIGSSelectorMappingLock);
  for (i = 0; i < instanceEntries; i++)
    {
      if (!strcmp (((JIGSInstanceSelMapTable[i]).javaSelector)->name, 
		   javaName))
	{
	  if (((JIGSInstanceSelMapTable[i]).javaSelector)->unresolved == YES)
	    {
	      (JIGSInstanceSelMapTable[i]).javaSelector = 
		resolveJavaSelector (env, 
				     JIGSInstanceSelMapTable[i].javaSelector);
	    }
	  if (!strcmp (((JIGSInstanceSelMapTable[i]).javaSelector)->signature, 
		       javaSignature))
	    {
	      pthread_mutex_unlock (&JIGSSelectorMappingLock);
	      return (JIGSInstanceSelMapTable[i]).objcSelector;	
	    }
	}                                                      
    }
  /* Not found */
  pthread_mutex_unlock (&JIGSSelectorMappingLock);
  return NULL;
}


static SEL JIGSSelectorMappingFindClassJavaMethod (JNIEnv *env, 
						   const char *javaName, 
						   const char *javaSignature)
{
  int i;
  
  pthread_mutex_lock (&JIGSSelectorMappingLock);
  for (i = 0; i < classEntries; i++)
    {
      if (!strcmp (((JIGSClassSelMapTable[i]).javaSelector)->name, 
		   javaName))
	{    
	  if (((JIGSClassSelMapTable[i]).javaSelector)->unresolved == YES)
	    {
	      (JIGSClassSelMapTable[i]).javaSelector = 
		resolveJavaSelector (env, 
				     JIGSClassSelMapTable[i].javaSelector);
	    }                                               
	  if (!strcmp (((JIGSClassSelMapTable[i]).javaSelector)->signature, 
		       javaSignature))
	    {
	      pthread_mutex_unlock (&JIGSSelectorMappingLock);
	      return (JIGSClassSelMapTable[i]).objcSelector;	
	    }
	}                                                      
    }
  /* Not found */
  pthread_mutex_unlock (&JIGSSelectorMappingLock);
  return NULL;
}

static SEL JIGSSelectorMappingFindJavaMethod (JNIEnv *env, 
					      const char *javaName, 
					      const char *javaSignature)
{
  SEL result;

  result = JIGSSelectorMappingFindInstanceJavaMethod (env, javaName, 
						      javaSignature);
  if (result != NULL)
    {
      return result;
    }
  else
    {
      result = JIGSSelectorMappingFindClassJavaMethod (env, javaName, 
						       javaSignature);
      return result;
    }
}

/* Cached stuff used when converting selectors */
static jclass nsselector = NULL;
static jfieldID name_field = NULL;
static jmethodID signature_method = NULL;
static jmethodID new_selector = NULL;

/**
 ** Now the functions exposed to other parts of JIGS
 **
 **
 **/

void _JIGSSelectorMappingInitialize (JNIEnv *env)
{
  if (JIGSInitLock == NO)
    {
      JIGSInitLock = YES;
      JIGSSelectorMappingTableCreate ();
      nsselector = GSJNI_NewClassCache (env, "gnu/gnustep/base/NSSelector");
      
      if (nsselector == NULL)
	{
	  NSLog (@"JIGS Critical: could not get gnu.gnustep.base.NSSelector");
	  return;
	}
      
      signature_method = (*env)->GetMethodID (env, nsselector,
					      "_parameterTypesSignature", 
					      "()Ljava/lang/String;");
      if (signature_method == NULL)
	{
	  NSLog (@"JIGS Critical: could not get method _parameterTypesSignature of class gnu.gnustep.base.NSSelector");
	  return;
	}

      name_field = (*env)->GetFieldID (env, nsselector, "methodName", 
				       "Ljava/lang/String;");  
      if (name_field == NULL)
	{
	  NSLog (@"JIGS Critical: could not get field name of class gnu.gnustep.base.NSSelector");
	  return;
	}

      new_selector 
	= (*env)->GetMethodID (env, nsselector, "<init>", 
			       "(Ljava/lang/String;Ljava/lang/String;)V");
      if (new_selector == NULL)
	{
	  NSLog (@"JIGS Critical: could not get method to create a new gnu.gnustep.base.NSSelector");
	  return;
	}

      /* The methods of NSObject which have been exposed */

      /* Does it make sense to expose these two ??? */
      //JIGSRegisterJavaProxySelector (@selector(copy), "clone", "", NO);
      //JIGSRegisterJavaProxySelector (@selector(mutableCopy), "mutableClone", 
      //                               "", NO);

      JIGSRegisterJavaProxySelector (env, @selector(isEqualTo:), "equals", 
				     "Ljava.lang.Object;", NO, NO);
      JIGSRegisterJavaProxySelector (env, @selector(hash), "hashCode", "", 
				     NO, NO);
      JIGSRegisterJavaProxySelector (env, @selector(description), "toString", 
				     "", NO, NO);
      /* What about the two release/retain methods ? */
    }
}

void JIGSRegisterJavaProxySelector (JNIEnv *env, SEL selector,
				    const char *shortJavaName,
				    const char *javaSignature, 
				    BOOL unresolved,
				    BOOL isStatic)
{
  SEL s;
  jSEL j;

  /* Ehm - how do we manage (unresolved == YES) here ?  It often can't
     simply be resolved at this stage.  We ignore it for now - but
     this means conflicts could arise and not be warned about. */

  if (unresolved == NO)
    {
      if (isStatic)
	{
	  s = JIGSSelectorMappingFindClassJavaMethod (env, shortJavaName, 
						      javaSignature);
	  if (s != NULL)
	    {
	      if (sel_isEqual (s, selector))
		{
		  return;
		}
	      else
		{
#ifndef JIGS_NO_WARN_FOR_SELECTOR_CONFLICT
		  NSLog (@"JIGS WARNING: Conflicting selectors: +%s (%s) maps", 
			 shortJavaName, javaSignature);
		  NSLog (@"to both %@ and %@", NSStringFromSelector (s), 
			 NSStringFromSelector (selector));
#endif /* JIGS_NO_WARN_FOR_SELECTOR_CONFLICT */
		}
	    }
	  
	  j = JIGSSelectorMappingFindClassSelector (env, selector);
	  if (j != NULL)
	    {
	      if (!strcmp (j->name, shortJavaName) && !strcmp (j->signature, 
							       javaSignature))
		{
		  return;
		}
	      else
		{
#ifndef JIGS_NO_WARN_FOR_SELECTOR_CONFLICT
		  NSLog (@"JIGS WARNING: Conflicting selectors: the selector +%@",
			 NSStringFromSelector (selector));
		  NSLog (@"to both %s (%s) and %s (%s)", j->name, j->signature, 
			 shortJavaName, javaSignature);
#endif /* JIGS_NO_WARN_FOR_SELECTOR_CONFLICT */
		}
	    }
	}
      else // not static
	{
	  s = JIGSSelectorMappingFindInstanceJavaMethod (env, shortJavaName, 
							 javaSignature);
	  
	  if (s != NULL)
	    {
	      if (sel_isEqual (s, selector))
		{
		  return;
		}
	      else
		{
#ifndef JIGS_NO_WARN_FOR_SELECTOR_CONFLICT
		  NSLog (@"JIGS WARNING: Conflicting selectors: -%s (%s) maps", 
			 shortJavaName, javaSignature);
		  NSLog (@"to both %@ and %@", NSStringFromSelector (s), 
			 NSStringFromSelector (selector));
#endif /* JIGS_NO_WARN_FOR_SELECTOR_CONFLICT */
		}
	    }

	  j = JIGSSelectorMappingFindInstanceSelector (env, selector);
	  if (j != NULL)
	    {
	      if (!strcmp (j->name, shortJavaName) && !strcmp (j->signature, 
							       javaSignature))
		{
		  return;
		}
	      else
		{
#ifndef JIGS_NO_WARN_FOR_SELECTOR_CONFLICT
		  NSLog (@"JIGS WARNING: Conflicting selectors: the selector -%@",
			 NSStringFromSelector (selector));
		  NSLog (@"to both %s (%s) and %s (%s)", j->name, j->signature, 
			 shortJavaName, javaSignature);
#endif /* JIGS_NO_WARN_FOR_SELECTOR_CONFLICT */
		}
	    }
	}
    }
  
  /* NSLog (@"Registering selector %s (%s), %s", shortJavaName, javaSignature, 
     sel_get_name (selector)); */

  if (isStatic)
    {
      JIGSSelectorMappingAddClassEntry (selector, shortJavaName, 
					javaSignature, unresolved, NO);
    }
  else
    {
      JIGSSelectorMappingAddInstanceEntry (selector, shortJavaName, 
					   javaSignature, unresolved, NO);
    }
}

void JIGSRegisterJavaProxySelectors (JNIEnv *env, int count, 
				     JIGSSelectorMappingEntry *list)
{
  int i, j;
  SEL selector;
  char *name;
  NSAutoreleasePool *pool;

  pool = [NSAutoreleasePool new];

  for (i = 0; i < count; i++)
    {
      selector = sel_getUid (list[i].objcName);

      if (list[i].javaName != NULL)
	{
	  name = strdup (list[i].javaName);
	}
      else // NULL
	{
	  /* NULL means get if from objc name by getting the substring 
	     up to the first ":" if any */

	  char *tmp = list[i].objcName;
	  const char *from = tmp;
	  j = 0;
	  
	  while (tmp[j] != '\0' && tmp[j] != ':')
	    {
	      j++;
	    }
	  
	  name = malloc ((sizeof (char)) * (j + 1));
	  memcpy (name, from, (sizeof (char)) * j);
	  name[j] = '\0';
	}
      JIGSRegisterJavaProxySelector (env, selector, name, 
				     list[i].javaSignature, NO, 
				     list[i].isStatic);
      /* NB: name is not to be freed since it is just put into the 
	 internal table, not copied */
    }
  RELEASE (pool);
}

const char *JIGSLongSelectorName (const char *fullJavaName, BOOL isConstructor)
{
  static NSCharacterSet *whitespace = nil;
  static NSCharacterSet *openBracket = nil;
  static NSCharacterSet *closeBracket = nil;
  static NSArray *modifiers = nil;
  NSString *inputString = [NSString stringWithCString: fullJavaName];
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

  //NSLog (@"Strimmed %s to %@", fullJavaName, outputString);
  
  // Discard all the rest
  return [outputString cString];
}

const char *JIGSShortSelectorName (const char *javaName, 
				   int numberOfArguments)
{
  NSMutableString *objcName;
  int i;

  objcName = [NSMutableString stringWithCString: javaName];
  
  for (i = 0; i < numberOfArguments; i++)
    {
      [objcName appendString: @":"];
    }
  
  return [objcName cString];
}

/*
 * Try if method_name can be registered in the table. 
 * Return a selector ready to be put in the table, or NULL if it's 
 * not appropriate to register it using method_name.
 */
static SEL JIGSTryMethodName (JNIEnv *env, const char *method_name, 
			      const char *objcSignature,
			      BOOL isStatic)
{
  SEL selector;
  jSEL jSelector;

  /* Check if this selector is known to the objective-C runtime */
  selector = sel_getUid (method_name);

  if (selector == NULL)
    {
      /* The selector is not known to the objective-C runtime, so 
	 we register it. */
      selector = GSSelectorFromNameAndTypes (method_name, objcSignature);
    }
  else // selector != NULL
    {
      /* Check if this selector is already registered in the table.
	 We don't mind it being registered as class selector if this
	 is an instance selector or vice versa.  (FIXME) */
      if (isStatic == YES)
	{
	  jSelector = JIGSSelectorMappingFindClassSelector (env, selector);
	}
      else // isStatic == NO
	{
	  jSelector = JIGSSelectorMappingFindInstanceSelector (env, selector);
	}
      if (jSelector != NULL)
	{
	  /* Already in the table - we can't use it */
	  selector = NULL;
	}
    }

  return selector;
}

const char *JIGSRegisterObjcProxySelector (JNIEnv *env, 
					   const char *fullJavaName, 
					   const char *shortJavaName, 
					   const char *javaSignature,
					   const char *objcSignature,
					   int numberOfArguments,
					   BOOL isStatic)
{
  SEL selector;
  const char *method_name;

  /* First, looks for (javaName, javaSignature) in the table */
  selector = JIGSSelectorMappingFindJavaMethod (env, shortJavaName, 
						javaSignature);
  
  if (selector != NULL)
    {
      /* Now that's great !  It's already in the table - use it. */
      return sel_getName (selector);
    }

  /* Not in the table.  All right, we need to choose an objc name then. 
     We try first with the short name. */
  method_name = JIGSShortSelectorName (shortJavaName, numberOfArguments);

  selector = JIGSTryMethodName (env, method_name, objcSignature, isStatic);

  if (selector == NULL)
    {
      /* Problem with the short name.  Try the long one then; this
	 should always work, because the long method name encloses
	 java arg information in it, and can't be used by normal
	 objc. */
      method_name = JIGSLongSelectorName (fullJavaName, NO);
      selector = JIGSTryMethodName (env, method_name, objcSignature, isStatic);
      if (selector == NULL)
	{
	  NSLog (@"JIGS CRITICAL: SelectorMapping: Could not register long selector!");
	  NSLog (@"               Ignoring and going on.");
	  /* Force it - FIXME */
	  selector = GSSelectorFromNameAndTypes (method_name, objcSignature);
	}
    }

  /* Now selector should never be NULL */
  if (isStatic)
    {
      JIGSSelectorMappingAddClassEntry (selector, shortJavaName, 
					javaSignature, NO, YES);
    }
  else
    {
      JIGSSelectorMappingAddInstanceEntry (selector, shortJavaName, 
					   javaSignature, NO, YES);
    }
  
  return method_name;
}

SEL JIGSSELFromNSSelector (JNIEnv *env, jobject selector)
{
  /* Need to get info from selector */
  const char *javaName;
  const char *javaSignature;
  jstring name;
  jstring signature;

  name = (*env)->GetObjectField (env, selector, name_field);
  signature = (*env)->CallObjectMethod (env, selector, signature_method);

  javaName = [GSJNI_NSStringFromASCIIJString (env, name) cString];
  javaSignature = [GSJNI_NSStringFromASCIIJString (env, signature) cString];

  return JIGSSelectorMappingFindJavaMethod (env, javaName, javaSignature);
}

jobject JIGSNSSelectorFromSEL (JNIEnv *env, SEL selector)
{
  jobject output;
  jSEL javaSel;
  jstring name;
  jstring signature;

  javaSel = JIGSSelectorMappingFindSelector (env, selector);
  name = GSJNI_JStringFromASCIINSString 
    (env, [NSString stringWithCString: javaSel->name]);

  signature = GSJNI_JStringFromASCIINSString 
    (env, [NSString stringWithCString: javaSel->signature]);

  output = (*env)->NewObject (env, nsselector, new_selector, name, 
			      signature);

  // return NULL upon exception thrown			      
  return output;
}

