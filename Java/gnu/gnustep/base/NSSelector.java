/* NSSelector.java - class implementing a selector as in Objective-C
   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: October 2000
   
   This file is part of JIGS, the GNUstep Java Interface Library.

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

import java.lang.*;
import java.lang.reflect.*;
// For the private part
import gnu.gnustep.java.GSJNIMethods;

public final class NSSelector extends Object 
  implements Cloneable
{
  // Instance variables
  String methodName;
  Class[] parameterTypes;

  // Constructors 

  // 'parameter types' is an essential part of a Java selector, 
  // and can't be left out.  This is enforced by not providing any way 
  // to construct a NSSelector without specifying the parameter types. 

  // NB: This restriction should not be removed - and btw can't be removed
  // without breaking the internals of JIGS.
  public NSSelector (String aMethodName, Class[] someParameterTypes)
  {
    super ();
    methodName = aMethodName;
    parameterTypes = someParameterTypes;
  }

  /* This is the selector we invoke from objective-C when morphing 
     an objective-C selector */
  public NSSelector (String aMethodName, String argumentSignature)
    throws ClassNotFoundException
  {
    super ();
    methodName = aMethodName;
    parameterTypes = GSJNIMethods.parameterTypes (argumentSignature);
  }

  // Instance Methods - overridden methods from Object
  public Object clone ()
    throws CloneNotSupportedException
  {
    return (NSSelector)super.clone ();
  }

  public boolean equals (Object otherObject)
  {
    if (otherObject instanceof NSSelector)
      {
	return (methodName.equals (((NSSelector)otherObject).methodName) 
		&& parameterTypes.equals 
		(((NSSelector)otherObject).parameterTypes));
      }
    else
      {
	return false;
      }
  }

  public int hashCode ()
  {
    return methodName.hashCode ();
  }

  public String toString ()
  {
    int i;
    String string = "";

    for (i = 0; i < parameterTypes.length; i++)
      {
	string += (parameterTypes[i].getName ());
      }

    return methodName + " (" + string + ")";
  }
  
  // Instance methods - new methods
  public boolean implementedByClass (Class targetClass)
  {
    boolean implemented = true;

    try
      {
	targetClass.getMethod (methodName, parameterTypes);
      }
    catch (Exception e)
      {
	implemented = false;
      }

    return implemented;
  }

  public boolean implementedByObject (Object target)
  {
    boolean implemented = true;

    try
      {
	(target.getClass ()).getMethod (methodName, parameterTypes);
      }
    catch (Exception e)
      {
	implemented = false;
      }

    return implemented;
  }

  public Object invoke (Object target, Object[] arguments)
    throws NoSuchMethodException, SecurityException, IllegalAccessException, 
           IllegalArgumentException, InvocationTargetException
  {
    Method method;
    
    method = this.methodOnObject (target);
    return method.invoke (target, arguments);
  }

  public Object invoke (Object target)
    throws NoSuchMethodException, SecurityException, IllegalAccessException, 
           IllegalArgumentException, InvocationTargetException
  {
    return this.invoke (target, new Object[] { });
  }

  public Object invoke (Object target, Object argument)
    throws NoSuchMethodException, SecurityException, IllegalAccessException, 
           IllegalArgumentException, InvocationTargetException
  {
    return this.invoke (target, new Object[] { argument });
  }

  public Object invoke (Object target, Object argument1, Object argument2)
    throws NoSuchMethodException, SecurityException, IllegalAccessException, 
           IllegalArgumentException, InvocationTargetException
  {
    return this.invoke (target, new Object[] { argument1, argument2 });
  }
  
  public Method methodOnClass (Class targetClass)
    throws NoSuchMethodException, SecurityException
  {
    return targetClass.getMethod (methodName, parameterTypes);
  }

  public Method methodOnObject (Object target)
    throws NoSuchMethodException, SecurityException
  {
    return (target.getClass ()).getMethod (methodName, parameterTypes);
  }

  public String name ()
  {
    return methodName;
  }

  public Class[] parameterTypes ()
  {
    return parameterTypes;
  }

  // Private methods used by the JIGS engine
  private String _parameterTypesSignature ()
  {
    return GSJNIMethods.argumentSignature (parameterTypes);
  }

}

