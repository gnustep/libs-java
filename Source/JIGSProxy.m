/* JIGSProxy.m - Functions providing access to the JIGSProxy facilities

   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: July 2000
   
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

#include "JIGSProxy.h"
#include "JIGSProxySetup.h"
#include "ObjcRuntimeUtilities.h"
#include "java.lang.Object.h"
#include "NSJavaVirtualMachine.h"
#include "JIGSMapper.h"

static jclass JIGSKeyValueCoding = NULL;
static jmethodID JIGSValueForKey = NULL;
static jmethodID JIGSTakeValueForKey = NULL;

// This is roughly the implementation of 'dealloc' of our java.lang.Object 
// class.  When the class is created at run-time, this method is added to it.
void _java_lang_Object__dealloc_ (id rcv, SEL sel)
{
  JNIEnv *env = JIGSJNIEnv ();
  jobject realObject;
  static IMP super_dealloc = 0;

  // Delete Global Reference to realObject so that the java garbage
  // collector can free it
  realObject = ((_java_lang_Object *)(rcv))->realObject;
  _JIGSMapperRemoveObjcProxy (env, realObject);
  (*env)->DeleteGlobalRef (env, realObject);
  
  // Following code is the equivalent of [super dealloc]
  if (super_dealloc == 0)
    {
      super_dealloc = get_imp (NSClassFromString (@"NSObject"), 
			       @selector (dealloc));
    }
  super_dealloc (rcv, sel);
}

// This is the implementation of 'handleQueryWithUnboundKey:' of our
// java.lang.Object class.  When the class is created at run-time,
// this method is added to it.
id _java_lang_Object__handleQueryWithUnboundKey_ (id rcv, SEL sel, 
						  NSString *key)
{
  JNIEnv *env = JIGSJNIEnv ();
  static IMP super_handleQuery = 0;

  /* We basically execute the Java call
     
     gnu.gnustep.java.JIGSKeyValueCoding.jvalueForKey (rcv, key);
     
     which does it - or throws an exception if a problem is found.
  */
  if (JIGSValueForKey == NULL)
    {
      JIGSValueForKey = (*env)->GetStaticMethodID 
	(env, JIGSKeyValueCoding, "jvalueForKey",
	 "(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;");
    }
  
  if (JIGSValueForKey != NULL)
    {
      jobject realObject;
      jobject result;
      
      realObject = ((_java_lang_Object *)(rcv))->realObject;
      
      result = (*env)->CallStaticObjectMethod (env, JIGSKeyValueCoding, 
					       JIGSValueForKey, 
					       realObject,
					       JIGSJstringFromNSString (env, 
									key));
      if ((*env)->ExceptionCheck (env))
	{
	  (*env)->ExceptionClear (env);
	}
      else
	{
	  /* No exception - must have worked ! */
	  return JIGSIdFromJobject (env, result);
	}
    }


  // Following code is the equivalent of 
  // return [super handleQueryWithUnboundKey: key]
  if (super_handleQuery == 0)
    {
      super_handleQuery = get_imp (NSClassFromString (@"NSObject"), 
				   @selector (handleQueryWithUnboundKey:));
    }
  return super_handleQuery (rcv, sel, key);
}


// This is the implementation of 'handleTakeValue:forUnboundKey:' of
// our java.lang.Object class.  When the class is created at run-time,
// this method is added to it.
void _java_lang_Object__handleTakeValueForUnboundKey_ (id rcv, SEL sel, 
						       id value, NSString *key)
{
  JNIEnv *env = JIGSJNIEnv ();
  static IMP super_handleTakeValue = 0;

  /* We basically execute the Java call
     
     gnu.gnustep.java.JIGSKeyValueCoding.jtakeValueForKey (rcv, value, key);
     
     which does it - or throws an exception if a problem is found.
  */
  if (JIGSTakeValueForKey == NULL)
    {
      JIGSTakeValueForKey = (*env)->GetStaticMethodID 
	(env, JIGSKeyValueCoding, "jtakeValueForKey",
	 "(Ljava/lang/Object;Ljava/lang/Object;Ljava/lang/String;)V");
    }
  
  if (JIGSTakeValueForKey != NULL)
    {
      jobject realObject;

      realObject = ((_java_lang_Object *)(rcv))->realObject;

      (*env)->CallStaticVoidMethod (env, JIGSKeyValueCoding, 
				    JIGSTakeValueForKey, 
				    realObject,
				    JIGSJobjectFromId (env, value), 
				    JIGSJstringFromNSString (env, key));

      if ((*env)->ExceptionCheck (env))
	{
	  (*env)->ExceptionClear (env);
	}
      else
	{
	  /* No exception - must have worked ! */
	  return;
	}
    }
  
  // Following code is the equivalent of 
  // [super handleTakeValue: value  ofUnboundKey: key]
  if (super_handleTakeValue == 0)
    {
      super_handleTakeValue = get_imp 
	(NSClassFromString (@"NSObject"), 
	 @selector (handleTakeValue:forUnboundKey:));
    }
  super_handleTakeValue (rcv, sel, value, key);
}


/*
 * Register the java.lang.Object class
 */
void JIGSRegisterJavaRootClass (JNIEnv *env)
{
  MethodList *ml;
  const char *signature;

  // Save pointer to JIGSKeyValueCoding class
  JIGSKeyValueCoding = GSJNI_NewClassCache 
    (env, "gnu/gnustep/java/JIGSKeyValueCoding");

  if (JIGSKeyValueCoding == NULL)
    {
      NSLog (@"Error - Could not find gnu.gnustep.java.JIGSKeyValueCoding");
    }
  
  
  // Register java.lang.Object class
  _JIGS_register_java_class_simple (env, @"java.lang.Object", 
				    @"NSObject", YES);
 
  // Add to it the custom dealloc, handleQueryWithUnboundKey: and
  // handleTakeValue:forUnboundKey: methods
  ml = ObjcUtilities_alloc_method_list (3);

  /* dealloc */
  signature = ObjcUtilities_build_runtime_Objc_signature ("v@:");
  ObjcUtilities_insert_method_in_list (ml, 0, "dealloc", signature, 
				       (IMP)_java_lang_Object__dealloc_);

  /* handleQueryWithUnboundKey: */
  signature = ObjcUtilities_build_runtime_Objc_signature ("@@:@");
  ObjcUtilities_insert_method_in_list 
    (ml, 1, "handleQueryWithUnboundKey:", 
     signature, 
     (IMP)_java_lang_Object__handleQueryWithUnboundKey_);

  /* handleTakeValue:forUnboundKey: */
  signature = ObjcUtilities_build_runtime_Objc_signature ("v@:@@");
  ObjcUtilities_insert_method_in_list 
    (ml, 2, "handleTakeValue:forUnboundKey:", 
     signature, 
     (IMP)_java_lang_Object__handleTakeValueForUnboundKey_);

  ObjcUtilities_register_method_list (NSClassFromString (@"java.lang.Object"),
				      ml);
}


/*
 * Register a new Java class (only if needed).
 * It registers all needed superclasses up to Object.
 * Warning: className *must* be valid.
 *
 */
void JIGSRegisterJavaClass (JNIEnv *env, NSString *className)
{
  NSString *superclassName;

  // If class exists in Objc, return.
  if (NSClassFromString (className) != Nil)
    return;
  
  // Else, get the java superclass of className
  superclassName = GSJNI_SuperclassNameFromClassName (env, className); 

  // If a java exception was thrown, that means probably the java 
  // class does not exist.  Clear the java exception and throw an 
  // Objective-C one.
  if ((*env)->ExceptionCheck (env))
    {
      (*env)->ExceptionClear (env);
      [NSException raise: @"JIGSRegisterJavaClassException"  
		   format: @"Could not determine the Java superclass of the Java class `%@'", className]; 
    }
  
  // Register the superclass (this recursively registers 
  // all the superclasses up to Object if needed)
  JIGSRegisterJavaClass (env, superclassName);

  // Now register the class itself.
  _JIGS_register_java_class_simple (env, className, superclassName, NO);
}
