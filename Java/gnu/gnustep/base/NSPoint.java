/* NSPoint.java - class representing a GNUstep NSPoint structure
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
 * This class wraps the Objective-C struct <B>NSPoint</B>.
 * Instances of this class in Java contain two public fields: x, y.  
 * You are required to set and read these variables directly.
 */

public final class NSPoint extends Object 
  implements Cloneable
{
  // Constants
  public static NSPoint ZeroPoint = new NSPoint (0, 0);

  // Instance variables
  public float x;
  public float y;

  // Constructors
  public NSPoint ()
  {
    super ();
    x = 0;
    y = 0;
  }

  public NSPoint (float anX, float anY)
  {
    super ();
    x = anX;
    y = anY;
  }

  public NSPoint (String string) 
  {
    super ();
    // TODO
    // Need to parse something of the kind of "{x=23.400000; y=35.599998}"
  }

  // Instance Methods
  public Object clone ()
    throws CloneNotSupportedException
  {
    NSPoint cloned;
    
    cloned = (NSPoint)super.clone ();
    cloned.x = x;
    cloned.y = y;
    return cloned;
  }

  public int hashCode ()
  {
    return (int)(x + (11987.89345 * y));
  }
  
  public boolean equals (Object otherObject)
  {
    if (otherObject instanceof NSPoint)
      {
	return this.isEqualToPoint ((NSPoint)(otherObject));
      }
    else
      {
	return false;
      }
  }

  public boolean isEqualToPoint (NSPoint aPoint)
  {
    if ((x == aPoint.x) && (y == aPoint.y))
      return true;
    else
      return false;
  }
  
  public float distanceToPoint (NSPoint aPoint)
  {
    double tmp;
    
    tmp = Math.pow ((x - aPoint.x), 2) + Math.pow ((y - aPoint.y) ,2);
    tmp = Math.sqrt (tmp);
    
    return (float)tmp;
  }
  
  public String toString ()
  {
    return "{x=" + x + "; y=" + y + "}";
  }
}
