/* JIGSKeyValueCoding.java - Java side utilities to do key/value coding

   Copyright (C) 2001 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <n.pero@mi.flashnet.it>
   Date: May 2001
   
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

import java.lang.reflect.Field;

public class JIGSKeyValueCoding
{
  /* Return the value of the instance variable called key (or _key) of
   * the object object.  Throws a NoSuchFieldException exception if no
   * such instance variable is found.  */
  public static Object jvalueForKey (Object object, String key)
    throws NoSuchFieldException, IllegalAccessException
  {
    Class objectClass = object.getClass ();
    Field field = jfieldForKey (objectClass, key);
    Object result;

    if (field == null)
      {
	throw new NoSuchFieldException ();
      }
    
    result = field.get (object);

    return result;
  }

  /* Set the value of the instance variable called key (or _key) of
   * the object object.  Throws a NoSuchFieldException exception if no
   * such instance variable is found. */
  public static void jtakeValueForKey (Object object, Object value, 
				       String key)
    throws NoSuchFieldException, IllegalAccessException
  {
    Class objectClass = object.getClass ();
    Field field = jfieldForKey (objectClass, key);    

    if (field == null)
      {
	throw new NoSuchFieldException ();
      }
    field.set (object, value);
  }

  public static Field jfieldForKey (Class aClass, String key)
  {
    Field result = null;
    String underscoreKey = "_" + key;

    /* Loop on the class hierarchy examining all fields of the
       object's class and superclasses, private included, looking for
       field with the key name (or with an underscore before it). */
    while (aClass != null)
      {
	result = getAccessibleField (aClass, key);
	
	if (result != null)
	  {
	    return result;
	  }

	result = getAccessibleField (aClass, underscoreKey);
	
	if (result != null)
	  {
	    return result;
	  }
	
	aClass = aClass.getSuperclass ();
      }
    
    return null;
  }

  static final Field getAccessibleField (Class aClass, String fieldName)
  {
    Field result = null;
    
    /* Look for the field */
    try
      {
	result = aClass.getDeclaredField (fieldName);
      }
    catch (Exception e)
      {
	result = null;
      } 
    
    /* Check if we can disable Java accessibility restrictions */
    if (result != null)
      {
	try
	  {
	    result.setAccessible (true);
	  }
	catch (Exception e)
	  {
	    result = null;
	  } 
      }
    
    return result;
  }
  
}


