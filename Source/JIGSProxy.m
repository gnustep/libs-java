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
  _JIGSMapperRemoveProxiedJava (realObject);
  (*env)->DeleteGlobalRef (env, realObject);

  // Following code is the equivalent of [super dealloc]
  if (super_dealloc == 0)
    {
      super_dealloc = get_imp (NSClassFromString (@"NSObject"), 
			       @selector (dealloc));
    }
  super_dealloc (rcv, sel);
}

/*
 * Register the java.lang.Object class
 */
void JIGSRegisterJavaRootClass (JNIEnv *env)
{
  MethodList *ml;
  const char *signature;
  
  // Register java.lang.Object class
  _JIGS_register_java_class_simple (env, @"java.lang.Object", 
				    @"NSObject", YES);
 
  // Add to it the dealloc method
  ml = ObjcUtilities_alloc_method_list (1);
  signature = ObjcUtilities_build_runtime_Objc_signature ("v@:");
  ObjcUtilities_insert_method_in_list (ml, 0, "dealloc", signature, 
				       (IMP)_java_lang_Object__dealloc_);
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

  // If class exists, return.
  if (NSClassFromString (className) != Nil)
    return;
  
  // Else, get the java superclass of className
  superclassName = GSJNI_SuperclassNameFromClassName (env, className); 
  
  // Register the superclass (this recursively registers 
  // all the superclasses up to Object if needed)
  JIGSRegisterJavaClass (env, superclassName);

  // Now register the class itself.
  _JIGS_register_java_class_simple (env, className, superclassName, NO);
}
