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

int main (int argc, char **argv, char **penv)
{
  NSAutoreleasePool *pool;
  JNIEnv *env;
  Class javaLangSystem;
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

  printf ("Now loading the java.lang.System class...");
  JIGSRegisterJavaClass (env, @"java.lang.System");
  printf ("ok\n");

  printf ("Now asking for its class pointer...");
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

  result = imp (javaLangSystem, selector, @"java.version");
  printf (" java.vm.version == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"java.vendor");
  printf (" java.vendor == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"java.vendor.url");
  printf (" java.vendor.url == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"java.vendor.uri");
  printf (" java.vendor.uri == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"java.home");
  printf (" java.home == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"java.vm.specification.version");
  printf (" java.vm.specification.version == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"java.vm.specification.vendor");
  printf (" java.vm.specification.vendor == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"java.vm.specification.name");
  printf (" java.vm.specification.name == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"java.vm.version");
  printf (" java.vm.version == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"java.vm.vendor");
  printf (" java.vm.vendor == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"java.vm.name");
  printf (" java.vm.name == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"java.class.version");
  printf (" java.class.version == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"java.class.path");
  printf (" java.class.path == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"os.name");
  printf (" os.name == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"os.arch");
  printf (" os.arch == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"os.version");
  printf (" os.version == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"user.name");
  printf (" user.name == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"user.home");
  printf (" user.home == %s\n", [result cString]);

  result = imp (javaLangSystem, selector, @"user.dir");
  printf (" user.dir == %s\n", [result cString]);

  /* Testing overloaded methods */
  printf ("Now testing overloaded methods by loading in the java.lang.StringBuffer class...");
  JIGSRegisterJavaClass (env, @"java.lang.StringBuffer");
  printf ("ok\n");
  
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
