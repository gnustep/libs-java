/* GSJNIMethods.java - Java side utilities to inspect java methods

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

package gnu.gnustep.java;

import java.lang.reflect.Constructor;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;

class GSJNIMethods
{
  /*
   * Return the static methods of a class
   */
  public static Method[] getStaticMethods (Class cl)
  {
    Method [] methods = cl.getMethods ();
    int count = methods.length;  
    Method [] tmpMethods = new Method [count];
    Method [] returnMethods;
    int i, j;

    // We copy only the static methods into the tmpMethods array.
    j = 0;
    for (i = 0; i < count; i++)
      {
	if ((Modifier.isStatic(methods[i].getModifiers ())) == true)
	  {
	    tmpMethods[j] = methods[i];
	    j++;
	  }
      }
    
    // Java arrays are not C arrays: we can't resize the tmpMethods array!
    // So we need to copy it into even another array.
    returnMethods = new Method[j];
    for (i = 0; i < j; i++)
      {
	returnMethods[i] = tmpMethods[i];
      }

    return returnMethods;
  }

  /*
   * Return the instance methods of a class
   */
  public static Method[] getInstanceMethods (Class cl)
  {
    Method [] methods = cl.getMethods ();
    int count = methods.length;  
    Method [] tmpMethods = new Method [count];
    Method [] returnMethods;
    int i, j;

    j = 0;
    for (i = 0; i < count; i++)
      {
	if ((Modifier.isStatic(methods[i].getModifiers ())) == false)
	  {
	    tmpMethods[j] = methods[i];
	    j++;
	  }
      }

    returnMethods = new Method[j];
    for (i = 0; i < j; i++)
      {
	returnMethods[i] = tmpMethods[i];
      }

    return returnMethods;
  } 

  /*
   * Signature of a class
   */
  public static String signatureOfClass (Class cl)
  {
    // A generic object
    if ((cl.isPrimitive ()) == false)
      {
	return "l";
      }
    else // A primitive type
      {
	if (cl == Boolean.TYPE)
	  {
	    return "z";
	  }
	else if (cl == Character.TYPE)
	  {
	    return "c";
	  }
	else if (cl == Byte.TYPE)
	  {
	    return "b";
	  }
	else if (cl == Short.TYPE)
	  {
	    return "s";
	  }
	else if (cl == Integer.TYPE)
	  {
	    return "i";
	  }
	else if (cl == Long.TYPE)
	  {
	    return "j";
	  }
	else if (cl == Float.TYPE)
	  {
	    return "f";
	  }
	else if (cl == Double.TYPE)
	  {
	    return "d";
	  }
	else if (cl == Void.TYPE)
	  {
	    return "v";
	  }
      }
    return "?";
  }

  /*
   * Return the signature of a method (in the form: ABBBBB, 
   * where A is the return type, and B are the *real* arguments).
   */
  public static String getMethodSignature (Method method)
  {
    Class ret;
    Class [] args;
    StringBuffer str = new StringBuffer ();
    int i;

    // Return type
    ret = method.getReturnType ();
    str.append (GSJNIMethods.signatureOfClass (ret));

    // Then the arguments (rcv, sel omitted)
    args = method.getParameterTypes ();
    for (i = 0; i < args.length; i++)
      {
	str.append (GSJNIMethods.signatureOfClass (args[i]));
      }
    
    return str.toString ();
  }

  /*
   * Return the signature of a constructor (in the form: ABBBBB, 
   * where A is the return type, and B are the *real* arguments).
   */
  public static String getConstructorSignature (Constructor constructor)
  {
    Class ret;
    Class [] args;
    StringBuffer str = new StringBuffer ();
    int i;

    // Skip Return type; use only the arguments (rcv, sel omitted)
    str.append ("l");
    args = constructor.getParameterTypes ();
    for (i = 0; i < args.length; i++)
      {
	str.append (GSJNIMethods.signatureOfClass (args[i]));
      }
    
    return str.toString ();
  }
}
