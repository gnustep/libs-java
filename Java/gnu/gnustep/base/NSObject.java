/* NSObject.java - the base proxy class
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
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.  */
package gnu.gnustep.base;

import gnu.gnustep.java.JIGS;

public class NSObject implements Cloneable
{
  /*
   * This integer is, in practice, a C pointer to the real object that 
   * this objects proxies.
   * We need to access it directly from native code; but native code 
   * does not care about the private modifier.
   * It should never be accessed from java (except from constructors), 
   * and that is why it is private.
   */
  private long realObject;
  
  static 
  {
    JIGS.initialize ();
  }
  
  /*
   * We can't implement a constructor as native. 
   * So, each constructor should be paired to a method constructor_native, 
   * with the same args, and implemented as native. 
   * The implementation of the constructor should invoke super (), 
   * then set this.realObject to the result of the constructor_native 
   * call, exactly as in the following example.
   */
  public NSObject ()
  {
    super ();
    this.realObject = this.NSObject_native ();
  }

  private native long NSObject_native ();

  /*
   * A similar trick with finalize; this is specific to NSObject.
   */
  protected void finalize () 
    throws Throwable
  {
    this.finalize_native (this.realObject);
    super.finalize ();
  }

  private native void finalize_native (long pointer)
    throws Throwable;
  
  /*
   * Here we have the exposed NSObject methods 
   */

  public native boolean equals (Object anObject);

  public native int hashCode ();

  public native Object clone()
    throws java.lang.CloneNotSupportedException;

  public native Object mutableClone ();

  public native String toString ();

  public String description ()
  {
    return this.toString ();
  }

  // (apple) native public Object valueForKey (String keyName);
  // (apple) native public void takeValueForKey (Object anObject, 
  //                                             String keyName);   

  /*
    GNUstep specific extension 
  */

  /* Use the following methods to deal transparently with weak
     references passed to Objective-C methods.  For example, if you want to
     set your java object 'javaDelegate' as delegate of the objective-C
     object 'objcObject', do as follows:

       NSObject.retainObject (javaDelegate);
       objcObject.setDelegate (javaDelegate);

     If you don't do this (or don't retain in some other way javaDelegate
     on the objective-C side before passing it to setDelegate), your
     program will segfault.  This is not a bug in the JIGS: it can't be
     otherwise.

     Warning: you need to 'retain' javaDelegate _before_ passing it through
     the JIGS.  But you don't need to retain javaDelegate if it already
     passed through the JIGS and some objective-C object is already keeping
     a reference to it.

     After you are done with the object (for example, when you set a
     different delegate), you should `release' it, as in the following
     example which changes the delegate of objcObject:
      
       NSObject.retainObject (newJavaDelegate);
       objcObject.setDelegate (newJavaDelegate);
       NSObject.releaseObject (javaDelegate);

     The rule is: you 'retain' the object before setting it as delegate,
     and 'release' it after having set another delegate.  
   
     Normally, you don't need these methods, they are needed only when
     calling Objective-C methods which store a reference to the argument
     without retaining it, such 'setDelegate:' and 'setTarget:'. */

  static native public void retainObject (Object object);
  static native public void releaseObject (Object object);
}
