/* GSJNIMethods.java - Java side utilities to inspect java methods

   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <n.pero@mi.flashnet.it>
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
import java.text.CharacterIterator;
import java.text.StringCharacterIterator;
import java.util.Vector;

public class GSJNIMethods
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
	if ((cl.getName ()).equals ("gnu.gnustep.base.NSSelector"))
	  {
	    /* A selector */
	    return ":";
	  }
	else
	  {
	    return "l";
	  }
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

  /* Now methods used to build the argument signature used in morphing 
     of selectors.  This is not the one used in dispatching, and we need 
     full information about the class of object arguments. */
  
  public static String jniSignatureOfClass (Class cl)
  {
    // A generic object
    if ((cl.isPrimitive ()) == false)
      {
	if ((cl.isArray ()) == false)
	  {
	    return "L" + cl.getName () + ";";
	  }
	else
	  {
	    return cl.getName ();
	  }
      }
    else // A primitive type
      {
	if (cl == Boolean.TYPE)
	  {
	    return "Z";
	  }
	else if (cl == Character.TYPE)
	  {
	    return "C";
	  }
	else if (cl == Byte.TYPE)
	  {
	    return "B";
	  }
	else if (cl == Short.TYPE)
	  {
	    return "S";
	  }
	else if (cl == Integer.TYPE)
	  {
	    return "I";
	  }
	else if (cl == Long.TYPE)
	  {
	    return "J";
	  }
	else if (cl == Float.TYPE)
	  {
	    return "F";
	  }
	else if (cl == Double.TYPE)
	  {
	    return "D";
	  }
	else if (cl == Void.TYPE)
	  {
	    return "V";
	  }
      }
    return "?";
  }

  public static String getMethodArgumentSignature (Method method)
  {
    Class [] args;

    args = method.getParameterTypes ();
    return argumentSignature (args);
  }

  public static String argumentSignature (Class[] parameterTypes)
  {
    StringBuffer str = new StringBuffer ();
    int i;

    for (i = 0; i < parameterTypes.length; i++)
      {
	if (i != 0)
	  str.append (" ");

	str.append (GSJNIMethods.jniSignatureOfClass (parameterTypes[i]));
      }
    
    return str.toString ();
  }

  /* Converts back */
  public static Class[] parameterTypes (String argumentSignature)
    throws ClassNotFoundException
  {
    Vector vector = new Vector ();
    StringCharacterIterator iterator;
    Class newClass;
    boolean done = false;

    iterator = new StringCharacterIterator (argumentSignature);

    while (!done)
      {
	newClass = nextClassFromJniSignature (iterator, argumentSignature);
	if (newClass == null)
	  {
	    done = true;
	  }
	else
	  {
	    vector.add (newClass);
	  }
	iterator.next ();
      }

    return (Class[])(vector.toArray (new Class[] { }));
  }

  /* 
   * Read next class signature from the string pointed to by the iterator.
   * After the operation, the iterator points to the next useful character 
   * in the string.
   */
  public static Class nextClassFromJniSignature (StringCharacterIterator 
						 iterator, 
						 String argumentSignature)
    throws ClassNotFoundException
  {
    char c;
    int beginIndex, endIndex;
    int tmpBeginIndex;
    String className;
    
    c = iterator.current ();
    switch (c)
      {
      case CharacterIterator.DONE: return null;
      case 'Z': return (Boolean.class);
      case 'C': return (Character.class);
      case 'B': return (Byte.class);
      case 'S': return (Short.class);
      case 'I': return (Integer.class);
      case 'J': return (Long.class);
      case 'F': return (Float.class);
      case 'D': return (Double.class);
      case '[': // ARRAY
	{
	  /* We need code simply to find out where the array name ends */
	  int i;
	  beginIndex = iterator.getIndex ();
	  /* First, we jump all the [ */
	  while ((c != CharacterIterator.DONE) && c == '[')
	    {
	      c = iterator.next ();
	    }
	  /* Now, we jump the class declaration */
	  switch (c) 
	    {
	    case CharacterIterator.DONE: 
	      System.err.println ("Parsing error, end of signature inside array signature");
	      break;
	    case 'Z': 
	    case 'C': 
	    case 'B': 
	    case 'S': 
	    case 'I': 
	    case 'J': 
	    case 'F': 
	    case 'D': 
	      break;
	    case 'L': 
	      /* Find where the class name ends */
	      tmpBeginIndex = iterator.getIndex () + 1;
	      endIndex = argumentSignature.indexOf (';', tmpBeginIndex);
	      /* Move on till the endIndex */
	      iterator.setIndex (endIndex);
	      break;
	    }
	  // Here we are, 
	  endIndex = iterator.getIndex () + 1;
	  className = argumentSignature.substring (beginIndex, endIndex);
	  /* Get the class from the name */
	  return (Class.forName (className));
	}
      case 'L':
	/* Find where the class name ends */
	beginIndex = iterator.getIndex () + 1;
	endIndex = argumentSignature.indexOf (';', beginIndex);
	/* Move on till the endIndex */
	iterator.setIndex (endIndex);
	/* Get the class name */
	className = argumentSignature.substring (beginIndex, endIndex);
	/* Get the class from the name */
	return Class.forName (className);
      case 'V': /* That's worrying */
      case '?': /* That's even more worrying */
      default:  /* Finally, default is the most worrying one */
	System.err.println ("Parsing error, unknown character `" + c + "' found while parsing signature");
	return (Object.class);
      }
  }
}


