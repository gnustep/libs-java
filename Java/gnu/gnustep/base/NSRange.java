/* NSRange.java - class representing a GNUstep NSRange structure
   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: June 2000
   
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

/**
 * This class wraps the Objective-C struct <B>NSRange</B>.  Instances of this
 * class in Java contain two public fields: location, length.  You are
 * required to set and read these variables directly.  
 */

public final class NSRange extends Object 
  implements Cloneable
{
  // Constants
  public static NSRange ZeroRange = new NSRange (0, 0);

  // Instance variables
  public int location;
  public int length;

  // Constructors
  public NSRange ()
  {
    super ();
    location = 0;
    length = 0;
  }

  public NSRange (int aLocation, int aLength)
  {
    super ();
    location = aLocation;
    length = aLength;
  }

  public NSRange (String string) 
  {
    super ();
    // TODO
    // Need to parse something of the kind of "{location=23; length=35}"
  }

  // Instance Methods
  public Object clone ()
    throws CloneNotSupportedException
  {
    NSRange cloned;
    
    cloned = (NSRange)super.clone ();
    cloned.location = location;
    cloned.length = length;
    return cloned;
  }

  public int hashCode ()
  {
    return ((122 * length) - location);
  }
  
  public boolean equals (Object otherObject)
  {
    if (otherObject instanceof NSRange)
      {
	return this.isEqualToRange ((NSRange)(otherObject));
      }
    else
      {
	return false;
      }
  }

  public boolean isEqualToRange (NSRange aRange)
  {
    if ((location == aRange.location) && (length == aRange.length))
      return true;
    else
      return false;
  }

  /**
   * Returns true if aLocation is contained in this range 
   */
  public boolean locationInRange (int aLocation)
  {
    if ((aLocation >= location) && (aLocation < (location + length)))
      return true;
    else
      return false;
  }
  
  public int maxRange ()
  {
    return location + length;
  }

  public boolean intersectsRange (NSRange aRange)
  {
    if (((location + length) < aRange.location) 
	|| (location > (aRange.location + aRange.length)))
      {
	return false;
      }
    else
      {
	return true;
      }
  }
  
  public boolean isSubrangeOfRange (NSRange aRange)
  {
    if ((location >= aRange.location)
	&& (location + length < (aRange.location + aRange.length)))
      {
	return true;
      }
    else
      {
	return false;
      }
  }

  public NSRange rangeByIntersectingRange (NSRange aRange)
  {
    NSRange output;

    try 
      {
	output = (NSRange)this.clone ();
	output.intersectRange (aRange);
      }
    catch (CloneNotSupportedException e)
      {
	output = null;
      }    
    
    return output;
  }

  public NSRange rangeByUnioningRange (NSRange aRange)
  {
    NSRange output;
    
    try 
      {
	output = (NSRange)this.clone ();
	output.unionRange (aRange);
      }
    catch (CloneNotSupportedException e)
      {
	output = null;
      }
    
    return output;
  } 

  public void intersectRange (NSRange aRange)
  {
    int newLocation;
    int newLength;
    int maxRange1;
    int maxRange2;    

    if (location > aRange.location)
      newLocation = location;
    else
      newLocation = aRange.location;
    
    maxRange1 = location + length;
    maxRange2 = aRange.location + aRange.length;
    
    if (maxRange1 < maxRange2)
      newLength = maxRange1 - location;
    else
      newLength = maxRange2 - aRange.location;
    
    location = newLocation;
    length = newLength;
  } 

  public void unionRange (NSRange aRange)
  {
    int newLocation;
    int newLength;
    int maxRange1;
    int maxRange2;
    
    if (location < aRange.location)
      newLocation = location;
    else
      newLocation = aRange.location;

    maxRange1 = location + length;
    maxRange2 = aRange.location + aRange.length;
    
    if (maxRange1 > maxRange2)
      newLength = maxRange1 - location;
    else
      newLength = maxRange2 - aRange.location;

    location = newLocation;
    length = newLength;
  }
  
  public boolean isEmpty ()
  {
    if (length == 0)
      return true;
    else
      return false;
  }

  public String toString ()
  {
    return "{location=" + location + "; length=" + length + "}";
  }
}
