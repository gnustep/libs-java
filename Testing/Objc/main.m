/* main.m: Main body of JavaTest -*-objc-*-

   Copyright (C) 2000 Free Software Foundation, Inc.

   Author:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: September 2000
   
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

#include <Foundation/Foundation.h>
#include <java/JIGS.h>

void
test_primitive_type (int type, JNIEnv *env)
{
  Class myClass;
  NSObject *instance;
  SEL selector;
  SEL selector_2;
  NSString *javaClassName = nil;
  NSString *javaClassType = nil;
  NSString *javaClassValue = nil;
  NSString *format;
  typedef NSObject *(*newBooleanIMP)(id, SEL, jboolean);
  typedef NSObject *(*newByteIMP)(id, SEL, jbyte);
  typedef NSObject *(*newCharIMP)(id, SEL, jchar);
  typedef NSObject *(*newShortIMP)(id, SEL, jshort);
  typedef NSObject *(*newIntIMP)(id, SEL, jint);
  typedef NSObject *(*newLongIMP)(id, SEL, jlong);
  typedef NSObject *(*newFloatIMP)(id, SEL, jfloat);
  typedef NSObject *(*newDoubleIMP)(id, SEL, jdouble);
  typedef jboolean (*booleanValueIMP)(id, SEL);
  typedef jbyte (*byteValueIMP)(id, SEL);
  typedef jchar (*charValueIMP)(id, SEL);
  typedef jshort (*shortValueIMP)(id, SEL);
  typedef jint (*intValueIMP)(id, SEL);
  typedef jlong (*longValueIMP)(id, SEL);
  typedef jfloat (*floatValueIMP)(id, SEL);
  typedef jdouble (*doubleValueIMP)(id, SEL);

  switch (type)
    {
    case 0:
      {
	printf ("** Testing passing jbool to Java **\n");
	javaClassName = @"java.lang.Boolean";
	javaClassType = @"boolean";
	javaClassValue = @"booleanValue";
	break;
      }
    case 1:
      {
	printf ("** Testing passing jbyte to Java **\n");
	javaClassName = @"java.lang.Byte";
	javaClassType = @"byte";
	javaClassValue = @"byteValue";
	break;
      }
    case 2:
      {
	printf ("** Testing passing jchar to Java **\n");
	javaClassName = @"java.lang.Character";
	javaClassType = @"char";
	javaClassValue = @"charValue";
	break;
      }
    case 3:
      {
	printf ("** Testing passing jshort to Java **\n");
	javaClassName = @"java.lang.Short";
	javaClassType = @"short";
	javaClassValue = @"shortValue";
	break;
      }
    case 4:
      {
	printf ("** Testing passing jint to Java **\n");
	javaClassName = @"java.lang.Integer";
	javaClassType = @"int";
	javaClassValue = @"intValue";
	break;
      }
    case 5:
      {
	printf ("** Testing passing jlong to Java **\n");
	javaClassName = @"java.lang.Long";
	javaClassType = @"long";
	javaClassValue = @"longValue";
	break;
      }
    case 6:
      {
	printf ("** Testing passing jfloat to Java **\n");
	javaClassName = @"java.lang.Float";
	javaClassType = @"float";
	javaClassValue = @"floatValue";
	break;
      }
    case 7:
      {
	printf ("** Testing passing jdouble to Java **\n");
	javaClassName = @"java.lang.Double";
	javaClassType = @"double";
	javaClassValue = @"doubleValue";
	break;
      }
    }

  printf ("Registering %s class...\n", [javaClassName cString]);
  JIGSRegisterJavaClass (env, javaClassName);
  myClass = NSClassFromString (javaClassName);
    
  if (myClass == Nil)
    {
      printf ("Failed\n"); abort ();
    }

  /* Get the constructor with a single String argument */
  format = [NSString stringWithFormat: @"%@ (%@)", javaClassName, 
		     javaClassType];
  selector = NSSelectorFromString (format);
  selector_2 = NSSelectorFromString (javaClassValue);

#define TEST_TYPE(newIMP, valueIMP, type, testValue) \
({	newIMP imp_;                \
	valueIMP imp_2;             \
	type test = testValue;      \
	type result;                \
	                            \
	instance = [myClass alloc]; \
        imp_ = (newIMP)[instance methodForSelector: selector];        \
	instance = imp_ (instance, selector, test);                   \
	printf ("Instance %s; ", [[instance description] cString]); \
                                                                            \
	imp_2 = (valueIMP)[instance methodForSelector: selector_2];  \
	result = imp_2 (instance, selector_2); \
                                          \
	if (result != test)               \
	  {                               \
	    printf ("FAILED\n");          \
	    abort ();                     \
	  }                               \
	else                              \
	  {                               \
	    printf ("Ok\n");              \
	  }                               \
})

  switch (type)
    {
    case 0:
      {
	TEST_TYPE (newBooleanIMP, booleanValueIMP, jboolean, 1);
	TEST_TYPE (newBooleanIMP, booleanValueIMP, jboolean, 0);
	break;
      }
    case 1:
      {
	TEST_TYPE (newByteIMP, byteValueIMP, jbyte, 1);
	TEST_TYPE (newByteIMP, byteValueIMP, jbyte, 0);
	TEST_TYPE (newByteIMP, byteValueIMP, jbyte, -1);
	break;
      }
    case 2:
      {
	TEST_TYPE (newCharIMP, charValueIMP, jchar, 121);
	TEST_TYPE (newCharIMP, charValueIMP, jchar, 0);
	break;
      }
    case 3:
      {
	TEST_TYPE (newShortIMP, shortValueIMP, jshort, 12);
	TEST_TYPE (newShortIMP, shortValueIMP, jshort, 0);
	TEST_TYPE (newShortIMP, shortValueIMP, jshort, -11);
	break;
      }
    case 4:
      {
	TEST_TYPE (newIntIMP, intValueIMP, jint, 132);
	TEST_TYPE (newIntIMP, intValueIMP, jint, 0);
	TEST_TYPE (newIntIMP, intValueIMP, jint, -12);
	break;
      }
    case 5:
      {
	TEST_TYPE (newLongIMP, longValueIMP, jlong, 10002);
	TEST_TYPE (newLongIMP, longValueIMP, jlong, 0);
	TEST_TYPE (newLongIMP, longValueIMP, jlong, -2334);
	break;
      }
    case 6:
      {
	TEST_TYPE (newFloatIMP, floatValueIMP, jfloat, 123.2);
	TEST_TYPE (newFloatIMP, floatValueIMP, jfloat, 0);
	TEST_TYPE (newFloatIMP, floatValueIMP, jfloat, -33.3);
	break;
      }
    case 7:
      {
	TEST_TYPE (newDoubleIMP, doubleValueIMP, jdouble, 1.3);
	TEST_TYPE (newDoubleIMP, doubleValueIMP, jdouble, 0);
	TEST_TYPE (newDoubleIMP, doubleValueIMP, jdouble, -12.99);
	break;
      }
    }
  /* We happily leak the instance */
}

int main (int argc, char **argv, char **penv)
{
  NSAutoreleasePool *pool;
  JNIEnv *env;
  Class javaLangSystem;
  Class bogusJavaLangSystem;
  SEL selector;
  typedef NSString *(*getPropIMP)(id, SEL, NSString *);
  getPropIMP imp;
  NSString *result;

#if defined(GS_PASS_ARGUMENTS)
  [NSProcessInfo initializeWithArguments: argv  count: argc  
		 environment: penv];
#elif defined(LIB_FOUNDATION_LIBRARY)
  [NSProcessInfo initializeWithArguments: argv  count: argc  
		 environment: penv];
#endif

  pool = [NSAutoreleasePool new];
  
  printf ("Compiled to test JIGS version %d.%d.%d\n", 
	  GNUSTEP_JAVA_MAJOR_VERSION,
	  GNUSTEP_JAVA_MINOR_VERSION, 
	  GNUSTEP_JAVA_SUBMINOR_VERSION);

  printf ("Now starting the Java Virtual Machine...\n");
  [NSJavaVirtualMachine startDefaultVirtualMachine];

  printf ("Check if the virtual machine is running...");
  if ([NSJavaVirtualMachine isVirtualMachineRunning])
    printf ("yes\n");
  else
    {
      printf ("no ==> test failed\n");
      RELEASE (pool);
      return 0;
    }

  printf ("Getting the (JNIEnv *) of current thread...");
  env = [NSJavaVirtualMachine JNIEnvHandleOfCurrentThread];
  if (env != NULL)
    printf ("ok\n");
  else
    {
      printf ("Could not get it ==> test failed\n");
      RELEASE (pool);
      return 0;
    }

  printf ("Initializing JIGS...");
  JIGSInit (env);
  printf ("ok\n");

/** registering the class manually is no longer needed **/

/*
  printf ("Now loading the java.lang.System class...");
  JIGSRegisterJavaClass (env, @"java.lang.System");
  printf ("ok\n");
*/

  printf ("Now asking for the java.lang.System class pointer...");
  javaLangSystem = NSClassFromString (@"java.lang.System");

  if (javaLangSystem == Nil)
    {
      printf ("Could not get it ==> test failed\n");
      RELEASE (pool);
      return 0;
    }
  else
    {
      printf ("Got %s\n", [[javaLangSystem description] cString]);
    }
    
    
  printf ("Now asking for the java.lang.BogusSystem class pointer...");
  bogusJavaLangSystem = NSClassFromString (@"java.lang.BogusSystem");

  if (bogusJavaLangSystem != Nil)
    {
      printf ("Could get it ==> test failed\n");
      RELEASE (pool);
      return 0;
    }
  else
    {
      printf ("Not found (and not crashed!) ==> test passed\n");
    }

  printf ("Asking for the selector of getProperty:...");
  selector = NSSelectorFromString (@"getProperty:");
  if (selector == NULL)
    {
      printf ("Could not get it ==> test failed\n");
      RELEASE (pool);
      return 0;
    }
  else
    {
      printf ("Got %s\n", [NSStringFromSelector (selector) cString]);
    }

  printf ("Asking if java.lang.System responds to getProperty:...");
  if ([javaLangSystem respondsToSelector: selector])
    {
      printf ("yes\n");
    }
  else
    {
      printf ("no ==> test failed\n");
      RELEASE (pool);
      return 0;
    }

  printf ("Asking for the class method implementation...");
  imp = (getPropIMP)[javaLangSystem methodForSelector: selector];
  printf ("ok\n");

  printf ("Calling it to get some system properties:\n"); 

  /* Make sure we can manage nil results */
#define RESULT (result != nil ? [result cString] : "(nil)")

  result = imp (javaLangSystem, selector, @"java.version");
  printf (" java.vm.version == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"java.vendor");
  printf (" java.vendor == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"java.vendor.url");
  printf (" java.vendor.url == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"java.vendor.uri");
  printf (" java.vendor.uri == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"java.home");
  printf (" java.home == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"java.vm.specification.version");
  printf (" java.vm.specification.version == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"java.vm.specification.vendor");
  printf (" java.vm.specification.vendor == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"java.vm.specification.name");
  printf (" java.vm.specification.name == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"java.vm.version");
  printf (" java.vm.version == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"java.vm.vendor");
  printf (" java.vm.vendor == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"java.vm.name");
  printf (" java.vm.name == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"java.class.version");
  printf (" java.class.version == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"java.class.path");
  printf (" java.class.path == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"os.name");
  printf (" os.name == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"os.arch");
  printf (" os.arch == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"os.version");
  printf (" os.version == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"user.name");
  printf (" user.name == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"user.home");
  printf (" user.home == %s\n", RESULT);

  result = imp (javaLangSystem, selector, @"user.dir");
  printf (" user.dir == %s\n", RESULT);

#undef RESULT

  /* Testing overloaded methods */
  printf ("Now testing overloaded methods by loading in the java.lang.StringBuffer class...");
  JIGSRegisterJavaClass (env, @"java.lang.StringBuffer");
  printf ("ok\n");

  /* Testing invoking Java methods with different types of parameters */
  test_primitive_type (0, env);
  test_primitive_type (1, env);
  test_primitive_type (2, env);
  test_primitive_type (3, env);
  test_primitive_type (4, env);
  test_primitive_type (5, env);
//  test_primitive_type (6, env);
  test_primitive_type (7, env);

  /* Test a method with two parameters */
  {
    Class javaLangMath = NSClassFromString (@"java.lang.Math");
    SEL selector = NSSelectorFromString (@"min::");
    typedef jint (*intIntIntIMP)(id, SEL, jint, jint);    
    intIntIntIMP mathImp;
    jint a, b, result;

    if (selector == NULL)
      {
	printf ("Could not get selector for min::\n");
	exit (1);
      }

    mathImp = (intIntIntIMP)[javaLangMath methodForSelector: selector];

    a = 0; b = 0;
    result = mathImp (javaLangMath, selector, a, b);
    printf (" min (%d, %d) == %d\n", a, b, result);
    if (result != 0)
      {
	printf ("Test failed\n");
	exit (1);
      }

    a = 1; b = 0;
    result = mathImp (javaLangMath, selector, a, b);
    printf (" min (%d, %d) == %d\n", a, b, result);
    if (result != 0)
      {
	printf ("Test failed\n");
	exit (1);
      }

    a = 1; b = -1;
    result = mathImp (javaLangMath, selector, a, b);
    printf (" min (%d, %d) == %d\n", a, b, result);
    if (result != -1)
      {
	printf ("Test failed\n");
	exit (1);
      }
  }


  
#if 0
  /* Testing morphing of numbers - used to debug JIGS internals */
  printf ("Internal hackish JIGS testing - testing morphing of numbers\n");

#if defined(LIB_FOUNDATION_LIBRARY)
# define lossyCString cString
#endif
  
#define TEST_NUMBER_MORPH(CREATION,TYPE) \
({ NSNumber *number; jobject jnumber; \
   number = [NSNumber CREATION]; \
   printf ("Morphing: " #TYPE " %s --> ", [[number description] lossyCString]); \
   jnumber = GSJNI_JNumberFromNSNumber (env, number); \
   printf ("%s\n", [GSJNI_DescriptionOfJObject (env, jnumber)  lossyCString]); \
})

  TEST_NUMBER_MORPH(numberWithBool: YES, Bool);
  TEST_NUMBER_MORPH(numberWithBool: NO, Bool);
  TEST_NUMBER_MORPH(numberWithChar: 'a', Char); 
  TEST_NUMBER_MORPH(numberWithChar: 'A', Char);
  TEST_NUMBER_MORPH(numberWithUnsignedShort: 4, UnsignedShort); 
  TEST_NUMBER_MORPH(numberWithUnsignedShort: 456, UnsignedShort);
  TEST_NUMBER_MORPH(numberWithShort: (short)-1, Short);
  TEST_NUMBER_MORPH(numberWithShort: (short)2345, Short);
  TEST_NUMBER_MORPH(numberWithInt: 12, Int);
  TEST_NUMBER_MORPH(numberWithInt: 0, Int);
  TEST_NUMBER_MORPH(numberWithInt: -134, Int);
  TEST_NUMBER_MORPH(numberWithInt: -13434, Int);
  TEST_NUMBER_MORPH(numberWithLong: 1200345L, Long);
  TEST_NUMBER_MORPH(numberWithLong: -1200345L, Long);
  TEST_NUMBER_MORPH(numberWithUnsignedLong: 1200345UL, UnsignedLong);
  TEST_NUMBER_MORPH(numberWithUnsignedLong: 0, UnsignedLong);
  TEST_NUMBER_MORPH(numberWithFloat: 1.2, Float);
  TEST_NUMBER_MORPH(numberWithFloat: 1.2345, Int);
  TEST_NUMBER_MORPH(numberWithFloat: -4.2, Float);
  TEST_NUMBER_MORPH(numberWithFloat: 0.2, Float);
  TEST_NUMBER_MORPH(numberWithDouble: 1.234566666e-5, Double);
  TEST_NUMBER_MORPH(numberWithDouble: -4.2e-1, Double);
  TEST_NUMBER_MORPH(numberWithDouble: 0, Double);
  printf ("ok (possibly)\n");
#endif /* 0 */

#if 0
  /* Testing key/value coding for Java objects - ahm - well - we want
     to test accessing instance variables of Java objects - the only
     library object I found which had a declared field was
     java.io.StringReader - we set the field (which should be a lock)
     to a string - not very useful but it's just to check that it
     works. */
  {
    Class javaIOStringReader;
    NSObject *instance;
    typedef NSObject *(*newReaderIMP)(id, SEL, NSString *);
    newReaderIMP imp_;
    
    printf ("Now loading the java.io.StringReader class...");
    JIGSRegisterJavaClass (env, @"java.io.StringReader");
    printf ("ok\n");
    
    printf ("Now asking for its class pointer...");
    javaIOStringReader = NSClassFromString (@"java.io.StringReader");
    
    if (javaIOStringReader == Nil)
      {
	printf ("Could not get it ==> test failed\n");
	RELEASE (pool);
	return 0;
      }
    else
      {
	printf ("Got %s\n", [[javaIOStringReader description] cString]);
      }

    printf ("Now creating an instance:\n");
    
    /* Alloc it */
    instance = [javaIOStringReader alloc];
    /* Get the constructor with a single String argument */
    selector = NSSelectorFromString (@"java.io.StringReader (java.lang.String)");
    imp_ = (newReaderIMP)[instance methodForSelector: selector];
    /* Call it on the instance to initialize it <this is when the java
       object is really allocated> */
    instance = imp_ (instance, selector, @"Test");

    printf ("Got instance %s\n", [[instance description] cString]);

    /* Access its 'lock' field using valueForKey */
    printf ("Getting the lock using key/value coding...\n");
    printf ("Got %s\n", 
	    [[[instance valueForKey: @"lock"] description] cString]);
    
    /* Set it - not really meaningful as we set it to a string anyway */
    printf ("Setting the lock to `Hi' using key/value coding...\n");
    [instance takeValue: @"Hi" forKey: @"lock"];

    /* Checking that we set it right */
    printf ("Getting the lock using key/value coding...\n");
    printf ("Got %s\n", 
	    [[[instance valueForKey: @"lock"] description] cString]);

    if (![[instance valueForKey: @"lock"] isEqualToString: @"Hi"])
      {
	printf ("Didn't work :-( -- test FAILED\n");
	abort ();
      }
  }
#endif

  printf ("And that's enough for today: test passed.\n");

  
  /* Sun has not implemented destroying a virtual machine, so the
     following raises an exception.  */

  /*
    NSLog (@"Now destroying the Java Virtual Machine...");
    [NSJavaVirtualMachine destroyVirtualMachine];
  */

  RELEASE (pool);
  return 0;
}
