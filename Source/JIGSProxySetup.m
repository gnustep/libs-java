/* JIGSProxySetup.m - Tools to build `fake` Objc classes delivering 
   messages to Java objects.

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

#include "ObjcRuntimeUtilities.h"
#include "GSJNI.h"
#include "JIGSProxyIMP.h"
#include "JIGSProxySetup.h"
#include "NSJavaVirtualMachine.h"
#include "java.lang.Object.h"
#include <string.h>
#include "JIGSSelectorMapping.h"
#include <Foundation/NSDebug.h>

static jclass GSJNIMethods = NULL;

/*
 * The global table of methods. 
 * This table is private to JavaProxySetup.m and JavaProxyIMP.m
 */
struct _JIGSSelectorIDTable *_JIGS_selIDTable = NULL;
objc_mutex_t _JIGS_selIDTableLock = NULL;

/*
 * Each of these variables store the @encoding for that particular 
 * type on this machine.
 * 
 * We assume all they can be represented as a single basic type, 
 * so that each one is a single character.
 *
 */

char _JAVA_BOOLEAN = '\0';
char _JAVA_BYTE = '\0';
char _JAVA_CHAR = '\0';
char _JAVA_SHORT = '\0';
char _JAVA_INT = '\0';
char _JAVA_LONG = '\0';
char _JAVA_FLOAT = '\0';
char _JAVA_DOUBLE = '\0';

// Compiler complains if we try making them really constant, 
// so we initialize them dynamically
static void initialize_c_to_java_mapping_of_types (void)
{
  _JAVA_BOOLEAN = (@encode (jboolean))[0];
  _JAVA_BYTE    = (@encode (jbyte))[0];
  _JAVA_CHAR    = (@encode (jchar))[0];
  _JAVA_SHORT   = (@encode (jshort))[0];
  _JAVA_INT     = (@encode (jint))[0];
  _JAVA_LONG    = (@encode (jlong))[0];
  _JAVA_FLOAT   = (@encode (jfloat))[0];
  _JAVA_DOUBLE  = (@encode (jdouble))[0];  
}

/*
 * Convert a java signature character to an objc signature character
 *
 */

static char
convertSignature (char signature)
{
  switch (signature)
    {
    case 'z': 
      return _JAVA_BOOLEAN;
    case 'b':
      return _JAVA_BYTE;
    case 'c':
      return _JAVA_CHAR;
    case 's':
      return _JAVA_SHORT;
    case 'i':
      return _JAVA_INT;
    case 'j':
      return _JAVA_LONG;
    case 'f':
      return _JAVA_FLOAT;
    case 'd':
      return _JAVA_DOUBLE;
    case 'l': 
      return _C_ID;
    case 'v': 
      return _C_VOID;
    case ':':
      return _C_SEL;
    default:
      return signature;
    }
}

/*
 * Create the objc struct for the Java method.
 * The method IMPlementation is _JIGS_##returnType##_IMP_JavaMethod.
 * jmethod should be a reference to a Java Method object. 
 * 
 * Return NO upon exception thrown (this should never happen).
 */

BOOL _JIGS_prepare_method_struct
(JNIEnv *env, MethodList *ml, int index, jobject jmethod, BOOL isConstructor, 
 BOOL isStatic, const char *className, struct _JIGSSelectorID *tableEntry,
 // This two last arguments are used to check the name against names of 
 // methods which have not yet been registered
 struct _JIGSSelectorIDEntry *classTable, int count)
{
  static jclass java_reflect_Method;
  static jclass java_reflect_Constructor;
  static jmethodID GSJNIMethods_getMethodSignature = NULL;
  static jmethodID GSJNIMethods_getConstructorSignature = NULL;
  static jmethodID method_getName = NULL;
  static jmethodID constructor_getName = NULL;
  static jmethodID method_toString = NULL;
  static jmethodID constructor_toString = NULL;
  jstring jmethodName;
  char *methodName;
  char *tmpName;
  char *tmpToString;
  int numberOfArguments;
  // Signature as created by the gnu/gnustep/java/GSJNIMethods code
  jstring signature;
  const char *cSignature;
  char *types;  
  int i;
  const char *method_types;
  const char *method_name;
  IMP methodIMP = NULL;

  // The following is used to exit upon exception
#define CLEAN_FAIL_EXIT  { (*env)->PopLocalFrame (env, NULL); return NO; }
  
  if ((*env)->PushLocalFrame (env, 3) < 0)
    {
      return NO; // Exception thrown
    }

  /*
   * Set method name
   */
  if (isConstructor == NO)
    {
      if (java_reflect_Method == NULL)
	{
	  java_reflect_Method = GSJNI_NewClassCache 
	    (env, "java/lang/reflect/Method");
	  
	  if (java_reflect_Method == NULL)
	    CLEAN_FAIL_EXIT;
	}
      
      if (method_getName == NULL)
	{
	  method_getName = (*env)->GetMethodID (env, java_reflect_Method, 
						"getName", 
						"()Ljava/lang/String;");
	  if (method_getName == NULL)
	    CLEAN_FAIL_EXIT;
	}
      jmethodName = (*env)->CallObjectMethod (env, jmethod, method_getName);
    }
  else
    {
      if (java_reflect_Constructor == NULL)
	{
	  java_reflect_Constructor = GSJNI_NewClassCache 
	    (env, "java/lang/reflect/Constructor");
	  
	  if (java_reflect_Constructor == NULL)
	    CLEAN_FAIL_EXIT;
	}
      
      if (constructor_getName == NULL)
	{
	  constructor_getName = 
	    (*env)->GetMethodID (env, java_reflect_Constructor, "getName", 
				 "()Ljava/lang/String;");
	  if (constructor_getName == NULL)
	    CLEAN_FAIL_EXIT;
	}
      jmethodName = (*env)->CallObjectMethod (env, jmethod, 
					      constructor_getName);
    }      

  methodName = (char *)(*env)->GetStringUTFChars (env, jmethodName, NULL);
  if (methodName == NULL)
    CLEAN_FAIL_EXIT;
  
  tmpName = (void *)strdup (methodName);
  (*env)->ReleaseStringUTFChars (env, jmethodName, methodName);

  if (isConstructor == NO)
    {
      if (method_toString == NULL)
	{
	  method_toString = (*env)->GetMethodID (env, java_reflect_Method, 
						 "toString", 
						 "()Ljava/lang/String;");
	  if (method_toString == NULL)
	    CLEAN_FAIL_EXIT;
	}
  
      jmethodName = (*env)->CallObjectMethod (env, jmethod, method_toString);
    }
  else 
    {
      if (constructor_toString == NULL)
	{
	  constructor_toString = (*env)->GetMethodID 
	    (env, java_reflect_Constructor, "toString", 
	     "()Ljava/lang/String;");
	  if (constructor_toString == NULL)
	    CLEAN_FAIL_EXIT;
	}
      
      jmethodName = (*env)->CallObjectMethod (env, jmethod, 
					      constructor_toString);
    }
  
  methodName = (char *)(*env)->GetStringUTFChars (env, jmethodName, NULL);
  if (methodName == NULL)
    CLEAN_FAIL_EXIT;
  
  /* NSLog (@"Method Name: %s", methodName); */

  tmpToString = (void *)strdup (methodName);
  (*env)->ReleaseStringUTFChars (env, jmethodName, methodName);
  
  // Need to invoke 'GetParameterTypes', 'GetReturnType' on the Java 
  // Method object, to get the parameters; then check class of each, 
  // and prepare an objective-C signature.
  // Get static method list
  
  if (GSJNIMethods == NULL)
    {
      GSJNIMethods = GSJNI_NewClassCache (env, 
					  "gnu/gnustep/java/GSJNIMethods");
      
      if (GSJNIMethods == NULL)
	{
	  NSLog (@"GNUstep Java Interface installation problem: ");
	  NSLog (@"Could not load java class gnu.gnustep.java.GSJNIMethods");
	  NSLog (@"Please make sure that the class is in your classpath");
	  free (tmpName);
	  free (tmpToString);
	  CLEAN_FAIL_EXIT;
	}
    }
  
  if (isConstructor == YES)
    {
      if (GSJNIMethods_getConstructorSignature == NULL)
	{
	  GSJNIMethods_getConstructorSignature = (*env)->GetStaticMethodID 
	    (env, GSJNIMethods, "getConstructorSignature", 
	     "(Ljava/lang/reflect/Constructor;)Ljava/lang/String;");
	  if (GSJNIMethods_getConstructorSignature == NULL)
	    {
	      free (tmpName);
	      free (tmpToString);
	      CLEAN_FAIL_EXIT;
	    }
	}
      signature = (*env)->CallStaticObjectMethod 
	(env, GSJNIMethods, GSJNIMethods_getConstructorSignature, jmethod);
      if ((*env)->ExceptionCheck (env))
	{
	  NSLog (@"Exception while getting constructor signature");
	  free (tmpName);
	  free (tmpToString);
	  CLEAN_FAIL_EXIT;
	}
    }
  else // Not a constructor
    {
      if (GSJNIMethods_getMethodSignature == NULL)
	{
	  GSJNIMethods_getMethodSignature = (*env)->GetStaticMethodID 
	    (env, GSJNIMethods, "getMethodSignature", 
	     "(Ljava/lang/reflect/Method;)Ljava/lang/String;");
	  if (GSJNIMethods_getMethodSignature == NULL)
	    {
	      NSLog (@"Could not get method signature");
	      free (tmpName);
	      free (tmpToString);
	      CLEAN_FAIL_EXIT;
	    }
	}

      signature = (*env)->CallStaticObjectMethod 
	(env, GSJNIMethods, GSJNIMethods_getMethodSignature, jmethod);
      if ((*env)->ExceptionCheck (env))
	{
	  NSLog (@"Exception while getting method signature");
	  free (tmpName);
	  free (tmpToString);
	  CLEAN_FAIL_EXIT;
	}
    }
  
  cSignature = [GSJNI_NSStringFromASCIIJString (env, signature) cString];

  /* NSLog (@"Signature: %s", cSignature); */

  numberOfArguments = strlen (cSignature);
  if (numberOfArguments > 0)
    {
      numberOfArguments -= 1;
    }

  types = (char *)alloca (sizeof (char) * numberOfArguments + 4);
  types[0] = convertSignature (cSignature[0]);
  /* NB - the compiler always uses _C_ID here.  */
  types[1] = _C_ID;
  types[2] = ':';

  for (i = 3; i < numberOfArguments + 3; i++)
    {
      types[i] = convertSignature (cSignature [i - 2]);
    }
  types[i] = '\0';

  /* NSLog (@"** types: %s  ** arguments: %d", types, numberOfArguments); */

  method_types = ObjcUtilities_build_runtime_Objc_signature (types);
  /*  NSLog (@"Mapped types to %s", method_types);  */
  
  if (isConstructor)
    {
      if (numberOfArguments == 0)
	{
	  method_name = "init";
	}
      else
	{
	  method_name =  JIGSLongSelectorName (tmpToString, isConstructor);
	}
    }
  else
    {
      /* We ask for the (java name, java argument signature) */
      static jmethodID GSJNIMethods_getMethodArgumentSignature = NULL;
      jstring argSignature;
      const char*cArgSignature;

      if (GSJNIMethods_getMethodArgumentSignature == NULL)
	{
	  GSJNIMethods_getMethodArgumentSignature = (*env)->GetStaticMethodID 
	    (env, GSJNIMethods, "getMethodArgumentSignature", 
	     "(Ljava/lang/reflect/Method;)Ljava/lang/String;");
	  if (GSJNIMethods_getMethodArgumentSignature == NULL)
	    {
	      NSLog (@"Could not get method argument signature");
	      free (tmpName);
	      free (tmpToString);
	      CLEAN_FAIL_EXIT;
	    }
	}

      argSignature = (*env)->CallStaticObjectMethod 
	(env, GSJNIMethods, GSJNIMethods_getMethodArgumentSignature, jmethod);
      if ((*env)->ExceptionCheck (env))
	{
	  NSLog (@"Exception while getting method argument signature");
	  free (tmpName);
	  free (tmpToString);
	  CLEAN_FAIL_EXIT;
	}

      cArgSignature = [GSJNI_NSStringFromASCIIJString (env, argSignature) 
						      cString];

      /* NSLog (@"Got arg signature of: %s", cArgSignature); */

      method_name = JIGSRegisterObjcProxySelector (env, tmpToString, tmpName, 
						   cArgSignature, method_types,
						   numberOfArguments, 
						   isStatic);
    }
  /* NSLog (@"Mapped method to %s", method_name); */
  
  if (types[0] == _C_ID)
    {
      methodIMP = (IMP)_JIGS_id_IMP_JavaMethod;
    }
  else if (types[0] == _C_VOID)
    {
      methodIMP = (IMP)_JIGS_void_IMP_JavaMethod;
    }
  else if (types[0] == _JAVA_BOOLEAN)
    {
      methodIMP = (IMP)_JIGS_jboolean_IMP_JavaMethod;
    }
  else if (types[0] == _JAVA_BYTE)
    {
      methodIMP = (IMP)_JIGS_jbyte_IMP_JavaMethod;
    }
  else if (types[0] == _JAVA_CHAR)
    {
      methodIMP = (IMP)_JIGS_jchar_IMP_JavaMethod;
    }
  else if (types[0] == _JAVA_SHORT)
    {
      methodIMP = (IMP)_JIGS_jshort_IMP_JavaMethod;
    }
  else if (types[0] == _JAVA_INT)
    {
      methodIMP = (IMP)_JIGS_jint_IMP_JavaMethod;
    }
  else if (types[0] == _JAVA_LONG)
    {
      methodIMP = (IMP)_JIGS_jlong_IMP_JavaMethod;
    }
  else if (types[0] == _JAVA_FLOAT)
    {
      methodIMP = (IMP)_JIGS_jfloat_IMP_JavaMethod;
    }
  else if (types[0] == _JAVA_DOUBLE)
    {
      methodIMP = (IMP)_JIGS_jdouble_IMP_JavaMethod;
    }
  else
    {
      free (tmpName);
      free (tmpToString);
      (*env)->PopLocalFrame (env, NULL);
      [NSException raise: @"Java Interface Error"
		   format: @"Unrecognized return type to IMP for java method"];
    }  
  ObjcUtilities_insert_method_in_list (ml, index, method_name, method_types, 
					 methodIMP);
  
  tableEntry->numberOfArgs = numberOfArguments;
  tableEntry->selector = (void *)strdup (method_name); 
  tableEntry->types = (char *)strdup (method_types);
  tableEntry->isConstructor = isConstructor;
  tableEntry->methodID = (*env)->FromReflectedMethod (env, jmethod);
  if ((*env)->ExceptionCheck (env))
    {
      NSLog (@"Exception while getting constructor/method jmethodID");
      free (tmpName);
      free (tmpToString);
      (*env)->PopLocalFrame (env, NULL);
      return NO;
    }

  free (tmpName);
  free (tmpToString);
  (*env)->PopLocalFrame (env, NULL);
  return YES; // TODO
#undef CLEAN_FAIL_EXIT
}

/*
 * Register a new Java class. 
 * The superclass must be known, and be specified.
 * This method inspects the list of Java class methods using the Java
 * Reflection API, and creates methods to mirror the Java ones.  
 *
 * Return NO upon exception thrown (this should never happen).
 *
 * className must be of the standard Java form, as in "java.lang.String"
 *
 * isRootClass must be 'YES' only for java.lang.Object.  This class
 * is then created with an additional ivar, called 'realObject'.
 */

BOOL _JIGS_register_java_class_simple
(JNIEnv *env, NSString *className, NSString *superclassName, BOOL isRootClass)
{
  MethodList *ml;
  int i;
  int count;
  int classCount;
  Class class;
  jclass javaClass;
  static jclass java_lang_Class = NULL;
  static jmethodID GSJNIMethods_getStaticMethods = NULL;
  static jmethodID class_getConstructors = NULL;
  static jmethodID GSJNIMethods_getInstanceMethods = NULL;
  jobject methodArray;
  jobject jmethod;
  struct _JIGSSelectorIDEntry *classTable;
  struct _JIGSSelectorIDEntry *metaclassTable;
  int size;
  NSAutoreleasePool *pool;
  const char *cClassName = [className cString];

  /* NSLog (@"Registering class %@ with the objective-C runtime", 
     className); */

#define CLEAN_ZERO(X)   NSLog (@#X);
#define CLEAN_ONE       (*env)->PopLocalFrame (env, NULL); 
#define CLEAN_TWO       objc_mutex_unlock (_JIGS_selIDTableLock);
#define CLEAN_THREE     [pool release]; 
#define CLEAN_FOUR      return NO;

#define CLEAN_FAIL_EXIT(X)  {CLEAN_ZERO(X) CLEAN_FOUR} 

  // Look up the Java Class. 
  javaClass = GSJNI_NewClassCache
    (env, [GSJNI_ConvertJavaClassNameToJNI (className)  cString]);
  
  // If we can't find it, give it up now.
  if (javaClass == NULL)
    CLEAN_FAIL_EXIT (Trying to register unknown java class);

  // Create the Objective-C proxy class.
  if (isRootClass == NO)
    {
      if (ObjcUtilities_new_class (cClassName, 
				   [superclassName cString], 0) == NO)
	CLEAN_FAIL_EXIT (ObjcUtilities_new_class returned NO);   
    }
  else
    {
      if (ObjcUtilities_new_class (cClassName, [superclassName cString], 1, 
				   @"realObject", @encode(jobject)) == NO)
	CLEAN_FAIL_EXIT (ObjcUtilities_new_class returned NO on RootClass);   
    }

  class = NSClassFromString (className);

  if (class == Nil)
    CLEAN_FAIL_EXIT (Class was created but could not be loaded);

  if (_JIGS_selIDTable == NULL)
    {
      _JIGS_selIDTableLock = objc_mutex_allocate ();
      _JIGS_selIDTable = (struct _JIGSSelectorIDTable *)NSZoneMalloc 
	(NSDefaultMallocZone (), sizeof (struct _JIGSSelectorIDTable));      
      _JIGS_selIDTable->classCount = 0;
      _JIGS_selIDTable->classTable = NULL;
      //
      initialize_c_to_java_mapping_of_types ();
    }

  // Lock the table 
  objc_mutex_lock (_JIGS_selIDTableLock);
  // We will create a certain amount of temporary objects. 
  // Clean them up at end of the work.
  pool = [NSAutoreleasePool new];

  // Need to redefine CLEAN_FAIL_EXIT to do more
#undef CLEAN_FAIL_EXIT
#define CLEAN_FAIL_EXIT(X) {CLEAN_ZERO(X) CLEAN_TWO CLEAN_THREE CLEAN_FOUR}

  //
  // Insert the class in the table
  //

  (_JIGS_selIDTable->classCount)++; // Class
  (_JIGS_selIDTable->classCount)++; // Meta Class
  classCount = _JIGS_selIDTable->classCount;
  
  // Allocate the space
  size = (classCount) * sizeof (struct _JIGSSelectorIDEntry);
  if (classCount == 2)
    {
      _JIGS_selIDTable->classTable = NSZoneMalloc (NSDefaultMallocZone (), 
						     size);
    }
  else
    {
      _JIGS_selIDTable->classTable 
	= NSZoneRealloc (NSDefaultMallocZone (), 
			 _JIGS_selIDTable->classTable, size);
    }

  // Class Table (used for dispatching instance methods)
  classTable = &((struct _JIGSSelectorIDEntry *)
		 (_JIGS_selIDTable->classTable))[classCount - 2];
  classTable->class = class;
  classTable->javaClass = javaClass; // This is already a global ref
  // MetaClass Table (used for dispatching static methods)
  metaclassTable = &((struct _JIGSSelectorIDEntry *)
		     (_JIGS_selIDTable->classTable))[classCount - 1];
  metaclassTable->class = class->class_pointer;
  metaclassTable->javaClass = javaClass; // This is already a global ref

  // NB: If something in the next part throws an exception, 
  // we are left with an unfinished proxy class !
  
  /*
   * Static Methods
   */

  // Get static method list
  if (GSJNIMethods == NULL)
    {
      GSJNIMethods = GSJNI_NewClassCache (env, 
					  "gnu/gnustep/java/GSJNIMethods");
      
      if (GSJNIMethods == NULL)
	CLEAN_FAIL_EXIT (Could not load java class gnu.gnustep.java.GSJNIMethods);
    }
  
  if (GSJNIMethods_getStaticMethods == NULL)
    {
      GSJNIMethods_getStaticMethods = (*env)->GetStaticMethodID 
	(env, GSJNIMethods, "getStaticMethods", 
	 "(Ljava/lang/Class;)[Ljava/lang/reflect/Method;");

      if (GSJNIMethods_getStaticMethods == NULL)
	CLEAN_FAIL_EXIT (Could not get getStaticMethods);
    }

  // We need three references, for the three methodArray
  if ((*env)->PushLocalFrame (env, 3) < 0)
    CLEAN_FAIL_EXIT (PushLocalFrame failed);

  // PopLocalFrame from now on
#undef CLEAN_FAIL_EXIT
#define CLEAN_FAIL_EXIT(X) {CLEAN_ZERO(X) CLEAN_ONE CLEAN_TWO CLEAN_THREE CLEAN_FOUR}

  methodArray = (*env)->CallStaticObjectMethod 
    (env, GSJNIMethods, GSJNIMethods_getStaticMethods, javaClass);

  if ((*env)->ExceptionCheck (env))
    CLEAN_FAIL_EXIT (Exception in getStaticMethods);
  
  count = (*env)->GetArrayLength (env, methodArray);

  // Prepare the static methods
  if (count == 0)
    {
      metaclassTable->selIDCount = 0;
      metaclassTable->selIDTable = NULL;
    }
  else // (count > 0) 
    {
      ml = ObjcUtilities_alloc_method_list (count);
      
      metaclassTable->selIDCount = count;
      metaclassTable->selIDTable = (struct _JIGSSelectorID *)NSZoneMalloc 
	(NSDefaultMallocZone (), sizeof (struct _JIGSSelectorID) * count);
      
      for (i = 0; i < count; i++)
	{
	  /* NSLog (@"Class Method: %d", i); */
	  // We need a reference for each object in the array
	  if ((*env)->PushLocalFrame (env, 1) < 0)
	    CLEAN_FAIL_EXIT (PushLocalFrame failed);

	  jmethod = (*env)->GetObjectArrayElement (env, methodArray, i);
	  if ((*env)->ExceptionCheck (env))
	    {
	      (*env)->PopLocalFrame (env, NULL);
	      CLEAN_FAIL_EXIT (Exception in GetObjectArrayElement);
	    }
	  
	  if (_JIGS_prepare_method_struct 
	      (env, ml, i, jmethod, NO, YES, cClassName, 
	       &((metaclassTable->selIDTable)[i]), metaclassTable, i) == NO)
	    {
	      (*env)->PopLocalFrame (env, NULL);
	      CLEAN_FAIL_EXIT (Exception Preparing method struct);
	    }

	  (*env)->PopLocalFrame (env, NULL);
	}  
      // Register the static methods 
      ObjcUtilities_register_method_list (class->class_pointer, ml);
      /* NSLog (@"Updating internal table for static methods: %d", count); */
      // Now we replace each method name with its selector
      for (i = 0; i < count; i++)
	{
	  SEL tmpSelector;

	  NSDebugLog (@"Class Method: %s", 
		      (char *)(metaclassTable->selIDTable)[i].selector); 
	  tmpSelector = sel_get_any_uid 
	    ((char *)(metaclassTable->selIDTable)[i].selector);
	  NSZoneFree (NSDefaultMallocZone (), 
		      (void *)(metaclassTable->selIDTable[i].selector));
	  (metaclassTable->selIDTable)[i].selector = tmpSelector;
	}
    }  

  /*
   * Constructor Methods
   *
   */

  // Initialize java_lang_Class if needed
  if (java_lang_Class == NULL)
    {
      java_lang_Class = GSJNI_NewClassCache (env, "java/lang/Class");
      if (java_lang_Class == NULL)
	CLEAN_FAIL_EXIT (Could not cache java.lang.Class);
    }
  
  if (class_getConstructors == NULL)
    {
      class_getConstructors = (*env)->GetMethodID 
	(env, java_lang_Class, "getConstructors", 
	 "()[Ljava/lang/reflect/Constructor;");
      if (class_getConstructors == NULL)
	CLEAN_FAIL_EXIT (Could not get getConstructors ID);
    }
  
  methodArray = (*env)->CallObjectMethod (env, javaClass, 
					  class_getConstructors);
  if ((*env)->ExceptionCheck (env))
    CLEAN_FAIL_EXIT (Exception in getConstructors);
  
  /* NSLog (@"Preparing to get array length"); */

  count = (*env)->GetArrayLength (env, methodArray);
  
  /* NSLog (@"Count is %d", count); */

  // Prepare the constructor methods
  if (count == 0)
    {
      classTable->selIDCount = 0;
      classTable->selIDTable = NULL;
    }
  else // (count > 0) 
    {
      ml = ObjcUtilities_alloc_method_list (count);

      classTable->selIDCount = count;
      classTable->selIDTable = (struct _JIGSSelectorID *)NSZoneMalloc 
	(NSDefaultMallocZone (), sizeof (struct _JIGSSelectorID) * count);
      
      for (i = 0; i < count; i++)
	{
	  /* NSLog (@"Managing constructor %d", i); */
	  // We need a reference for each object in the array
	  if ((*env)->PushLocalFrame (env, 1) < 0)
	    CLEAN_FAIL_EXIT (PushLocalFrame failed);

	  jmethod = (*env)->GetObjectArrayElement (env, methodArray, i);
	  if ((*env)->ExceptionCheck (env))
	    {
	      (*env)->PopLocalFrame (env, NULL);
	      CLEAN_FAIL_EXIT (Exception in GetObjectArrayElement);
	    }
	  if (_JIGS_prepare_method_struct 
	      (env, ml, i, jmethod, YES, NO, cClassName, 
	       &((classTable->selIDTable)[i]), classTable, i) == NO)
	    {
	      (*env)->PopLocalFrame (env, NULL);
	      CLEAN_FAIL_EXIT (Prepare method struct failed);
	    }
	  (*env)->PopLocalFrame (env, NULL);
	}
      /* printf ("REALLY Registering constructor methods: %d\n", count); */
      // Register the constructors 
      ObjcUtilities_register_method_list (class, ml);
      /* NSLog (@"Updating internal table for static methods: %d", count); */
    }
  
  /*
   * Instance Methods
   */
  
  // Get instance method list
  if (GSJNIMethods_getInstanceMethods == NULL)
    {
      GSJNIMethods_getInstanceMethods = (*env)->GetStaticMethodID 
	(env, GSJNIMethods, "getInstanceMethods", 
	 "(Ljava/lang/Class;)[Ljava/lang/reflect/Method;");
      if (GSJNIMethods_getInstanceMethods == NULL) 
	CLEAN_FAIL_EXIT(Could not get getInstanceMethods ID);
    }

  methodArray = (*env)->CallStaticObjectMethod 
    (env, GSJNIMethods, GSJNIMethods_getInstanceMethods, javaClass);
  if ((*env)->ExceptionCheck (env))
    CLEAN_FAIL_EXIT (getInstanceMethods failed);
  
  count = (*env)->GetArrayLength (env, methodArray);
  
  // Prepare the instance methods
  if (count > 0)
    {
      int oldCount = classTable->selIDCount;

      ml = ObjcUtilities_alloc_method_list (count);

      classTable->selIDCount += count;
      if (classTable->selIDTable == NULL)
	{
	  classTable->selIDTable = (struct _JIGSSelectorID *)NSZoneMalloc 
	    (NSDefaultMallocZone (), 
	     sizeof (struct _JIGSSelectorID) * count);
	}
      else
	{
	  classTable->selIDTable = (struct _JIGSSelectorID *)NSZoneRealloc 
	    (NSDefaultMallocZone (), classTable->selIDTable, 
	     sizeof (struct _JIGSSelectorID) * classTable->selIDCount);
	}
      
      
      for (i = 0; i < count; i++)
	{
	  if ((*env)->PushLocalFrame (env, 1) < 0)
	    CLEAN_FAIL_EXIT (PushLocalFrame failed);

	  jmethod = (*env)->GetObjectArrayElement (env, methodArray, i);
	  if ((*env)->ExceptionCheck (env))
	    {
	      (*env)->PopLocalFrame (env, NULL);
	      CLEAN_FAIL_EXIT (Exception in GetObjectArrayElement);
	    }
	  if (_JIGS_prepare_method_struct 
	      (env, ml, i, jmethod, NO, NO, cClassName, 
	       &((classTable->selIDTable)[i + oldCount]), classTable, 
	       i + oldCount) == NO)
	    {
	      (*env)->PopLocalFrame (env, NULL);
	      CLEAN_FAIL_EXIT (Prepare method struct failed);
	    }
	  (*env)->PopLocalFrame (env, NULL);
	}  
      /* printf ("REALLY Registering instance methods: %d\n", count); */
      // Register the instance methods 
      ObjcUtilities_register_method_list (class, ml);
    }

  /* NSLog(@"Registering instance methods with internal selector->ID table");*/
  // Now we replace each instance method name with its selector
  for (i = 0; i < classTable->selIDCount; i++)
    {
      SEL tmpSelector;

      NSDebugLog (@"Instance method: %s", 
	     (char *)(classTable->selIDTable)[i].selector);
      tmpSelector = sel_get_any_uid 
	((char *)(classTable->selIDTable)[i].selector);
      NSZoneFree (NSDefaultMallocZone (), 
		  (void *)(classTable->selIDTable[i].selector));
      (classTable->selIDTable)[i].selector = tmpSelector;
    }

#undef CLEAN_FAIL_EXIT
  (*env)->PopLocalFrame (env, NULL);
  objc_mutex_unlock (_JIGS_selIDTableLock);
  [pool release];
  return YES;
}



