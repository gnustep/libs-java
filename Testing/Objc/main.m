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

int main (void)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  JNIEnv *env;
  Class javaLangSystem;
  SEL selector;
  typedef NSString *(*getPropIMP)(id, SEL, NSString *);
  getPropIMP imp;
  NSString *result;

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

  printf ("And that's enough for today: test passed.\n");

  /*
   * The following crashes Sun's JVM because they have not implemented 
   * destroying a virtual machine; moreover their thread support is buggy,
   * which doesn't allow us to catch the exception, so better comment it out.
   */

  /*
    NSLog (@"Now destroying the Java Virtual Machine...");
    [NSJavaVirtualMachine destroyVirtualMachine];
  */

  RELEASE (pool);
  return 0;
}
