/* JIGSMapper.h - Java proxies of Objc objects
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

#ifndef __JIGSMapper_h_GNUSTEP_JAVA_INCLUDE
#define __JIGSMapper_h_GNUSTEP_JAVA_INCLUDE

#include <jni.h>
#include <Foundation/Foundation.h>

/*
 * JIGSMapper contains code to manage mapping tables.

 * Each proxy (both on Java and Objc side) contains an ivar pointing 
 * to its real object 

 * We need a 'mapping table' to make a lookup in the reverse
 * direction, ie, given a real object, find, if any, the proxy
 * pointing to it (this is needed so that we don't create more than
 * one proxy to a single real object).  The mapping table is actually
 * used only when passing objects as arguments or return values
 * through the interface. 
 */

/* Public functions to be used in the java native method implementations
   to map jobjects to/from ids */

/*
 * Use the following to get the id of the 'this' argument of a java
 * native wrapper method call.  This is fast because we know that
 * 'this' is a gnu/gnustep/base/NSObject.
 *
 * *Never* use with an argument different from the 'this' argument of
 * a native method call: the overhead of the generic method is tiny,
 * but it's safer.  The following will crash if you pass a generic
 * argument.  */

id JIGSIdFromThis (JNIEnv *env, jobject this);

/*
 * The following functions are the more general and slow of the proxying 
 * functions. 
 *
 * Given an object, they check its class to understand if it is a
 * proxy or a real object.  They convert it in both cases, creating a
 * proxy if needed.  
 *
 * Whenever you need to convert a jobject to/from an id, the following 
 * functions should do the job.
 *
 * Exceptions: 
 * For strings, if you can be sure they are strings, you can use
 * JIGSJstringFromNSString directly.  Arguments of java methods have
 * their classes checked by the java runtime so if the argument is
 * declared of type String, using JIGSJstringFromNSString should be
 * safe.  
 *
 * The other exception is JIGSJbyteArratFromNSData etc which is useful
 * mainly in the wrapping of NSData itself.
 *
 * To morph a java object of class NSPoint, NSSize, NSRect or NSRange
 * into a C struct, use the appropriate functions in JIGSBaseStruct.  */

jobject JIGSJobjectFromId (JNIEnv *env, id object);

id JIGSIdFromJobject (JNIEnv *env, jobject object);


jstring JIGSJstringFromNSString (JNIEnv *env, NSString *string);

NSString *JIGSNSStringFromJstring (JNIEnv *env, jstring string);


jbyteArray JIGSJbyteArrayFromNSData (JNIEnv *env, NSData *data);

NSData *JIGSNSDataFromJbyteArray (JNIEnv *env, jbyteArray bytes);

/* Special method - initialize an already allocated data object by
   using the bytes from the jbyteArray.  Return the result of
   initWithBytes:length:.  data could also be a NSMutableData. */
NSData *JIGSInitNSDataFromJbyteArray (JNIEnv *env, NSData *data, 
				      jbyteArray bytes);

/*
 * Return a local reference to a java array containing the objects in
 * the NSArray array.  Each objects is passed through the mapper
 * before putting it into the Java array.  */
jobjectArray JIGSJobjectArrayFromNSArray (JNIEnv *env, NSArray *array);

/*
 * Return an autoreleased NSArray containing the objects objects.  Each 
 * object in the java array is passed through the mapper to get the 
 * corresponding Objective-C object before putting it into the NSArray.
 */
NSArray *JIGSNSArrayFromJobjectArray (JNIEnv *env, jobjectArray objects);

/* Special method - initialize an already allocated array object by
   using the objects from the jobjectArray.  Return the result of
   initWithObjects:count:.  array could also be mutable. */
NSArray *JIGSInitNSArrayFromJobjectArray (JNIEnv *env, NSArray *array, 
					  jobjectArray objects);

/*
 * Create new proxies. 
 * 
 * Whenever you create a new object and need to return an jobject for
 * it, you may follow the general road, which is call
 * JIGSJobjectFromId or JIGSIdFromJobject (which will create
 * automatically a new proxy for you if there is no proxy).
 * But, if you are sure that the new object has no proxy (for example 
 * because you just created it by copying another object), you can 
 * just create the new proxy directly (this is faster).  
 * Warning: if you are not sure that the object has no proxy, don't
 * call these methods.  */

id JIGSCreateNewObjcProxy (JNIEnv *env, jobject proxiedJava);

jobject JIGSCreateNewJavaProxy (JNIEnv *env, id proxiedObject);

/*
 * Register a new java proxy class with the mapper.
 * For example, if you provide a java class with a native
 * implementation which wraps the objective-C class 'MyClass', then
 * you need to register your proxy class with the JIGSMapper so that
 * it knows that, when it needs to create a proxy for an objective-C
 * object of class MyClass, it can create a java object of your proxy 
 * class rather than a java object of the generic proxy class 'NSObject'. 
 *
 * This is necessary since we can't rebuild the full java name from 
 * the short name - eg, @"MyClass" could be gnu.gnustep.base.MyClass 
 * or gnu.gnustep.gui.MyClass or com.your_company.MyClass or 
 * gnu.gnustep.yourFramework.MyClass: we can't know - you need to 
 * register the mapping of classes.
 *
 * Also, when we allocate the real object corresponding to a java proxy, 
 * we need to know which class to allocate it of.  We look in the tree of 
 * registered java proxy classes (see _JIGSAllocClassOfThis). 
 * When we send a static message, we need to do that too.  We can't simply 
 * take the java class of the object and look for the objective-C counterpart 
 * because the java class could be a java subclass of (the java proxy class of) 
 * an objective-C class.  So, we need to look for the first ancestor of 
 * the class which is the java proxy class corresponding to an objective-C 
 * class.  We then send our class message to that class.  (For the programmer, 
 * all this simply amounts at calling JIGSClassFromThisClass).
 *
 * Registering a java proxy class is now also automatically used when
 * 'resolving' a java method signature.  See JIGSSelectorMapping.
 *
 * In your library wrapper, you should call in JNI_OnLoad this
 * function for each class you have wrapped.  */

void JIGSRegisterJavaProxyClass (JNIEnv *env, NSString *fullJavaClassName, 
				 NSString *objcClassName);

/*
 * Use the following to determine which objective-C class to send a static 
 * method to.  This method looks for the first superclass of `class' which 
 * is a java proxy class (ie, has an Objective-C real counterpart).
 */

Class JIGSClassFromThisClass (JNIEnv *env, jclass class);

/*
 * END OF PUBLIC FUNCTIONS
 * The following functions are private to the JIGS internals.
 * You should (usually) never need to access them directly.
 *
 */

#if defined(LIB_FOUNDATION_LIBRARY)
#  ifndef GS_SIZEOF_VOIDP
#    define GS_SIZEOF_VOIDP 4
#  endif
#endif

/*
 * We store pointers to the real object in the java proxy, 
 * in its realObject ivar, which is of type jlong (64 bit).  
 * Use the following macros to convert jlong to/from id.
 *
 */
#if GS_SIZEOF_VOIDP == 4 /* 32 bit machine */

#define JIGS_JLONG_TO_ID(p) (((union {jlong java; id objc[2];}) p).objc[0])
#define JIGS_ID_TO_JLONG(p) ({union {jlong java; id objc[2];} q; q.objc[0] = p; q.objc[1] = 0; q.java;})

#elif GS_SIZEOF_VOIDP == 8 /* 64 bit machine */

#define JIGS_JLONG_TO_ID(p) ((id)(p))
#define JIGS_ID_TO_JLONG(p) ((jlong)(p))

#else /* a different or undefined GS_SIZEOF_VOIDP */

#ifdef GS_SIZEOF_VOIDP
#error Only machines with sizeof (void *) == 4 (32 bit) or 8 (64 bit) are supported.  Your machine has a different sizeof (void *) !
#else /* GS_SIZEOF_VOIDP undefined */
#error Undefined GS_SIZEOF_VOIDP.  Make sure your gnustep-core library version is at least 0.6.6.
#endif 

#endif

/*
 * Initializes the maps and some cache. 
 * Safe to be called many times, but of course useless.
 * Called by JIGSInit.
 *
 */
void _JIGSMapperInitialize (JNIEnv *env);

/*
 * Insert or remove objects from the maps. 
 */

/*
 * _JIGSMapperAddJavaProxy is to be used only in NSObject's native
 * constructors. (and in JIGSMapperCreateNewJavaProxy)
 */
void _JIGSMapperAddJavaProxy (JNIEnv *env, id objc, jobject java);
/*
 * _JIGSMapperRemoveJavaProxy is to be used only in the finalize
 * method in (java) gnu.gnustep.base.NSObject
 */
void _JIGSMapperRemoveJavaProxy (JNIEnv *env, id objc);
/*
 * _JIGSMapperAddObjcProxy is to be used only in the constructors in
 * JIGSProxyIMP (and in JIGSMapperCreateNewObjcProxy)
 */
void _JIGSMapperAddObjcProxy (JNIEnv *env, jobject java, id objc);
/* 
 * _JIGSMapperRemoveObjcProxy is to be used only in the -dealloc
 * method of (objc) java.lang.Object.  
 */
void _JIGSMapperRemoveObjcProxy (JNIEnv *env, jobject java);

/*
 * The following is used by NSObject to decide which Objective-C class 
 * to use to allocate the real object.  
 */
Class _JIGSAllocClassForThis (JNIEnv *env, jobject this);

/*
 * The following is used by JIGSSelectorMapping to resolve java short
 * class names into long ones.  
 */
NSString *_JIGSLongJavaClassNameForObjcClassName (JNIEnv *env, 
						  NSString *className);


/*
 * Implemented by NSObject.m
 */  
void JIGSFinalizeInit ();

#endif /* __JIGSMapper_h_GNUSTEP_JAVA_INCLUDE */


