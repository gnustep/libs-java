/* NSSize.java - class representing a GNUstep NSSize structure
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
 * This class wraps the Objective-C struct <B>NSSize</B>.
 * Instances of this class in Java contain two public fields: width, height.  
 * You are required to set and read these variables directly.
 */

public final class NSSize extends Object 
  implements Cloneable
{
  // Constants
  public static NSSize ZeroSize = new NSSize (0, 0);

  // Instance variables
  public float width;
  public float height;

  // Constructors
  public NSSize ()
  {
    super ();
    width = 0;
    height = 0;
  }

  public NSSize (float aWidth, float aHeight)
  {
    super ();
    width = aWidth;
    height = aHeight;
  }

  public NSSize (String string) 
  {
    super ();
    // TODO
    // Need to parse something of the kind of 
    // "{width=23.400000; height=35.599998}"
  }

  // Instance Methods
  public Object clone ()
    throws CloneNotSupportedException
  {
    NSSize cloned;
    
    cloned = (NSSize)super.clone ();
    cloned.width = width;
    cloned.height = height;
    return cloned;
  }

  public int hashCode ()
  {
    return (int)(width + (10551.84342 * height));
  }
 
  public boolean equals (Object otherObject)
  {
    if (otherObject instanceof NSSize)
      {
	return this.isEqualToSize ((NSSize)(otherObject));
      }
    else
      {
	return false;
      }
  }

  public boolean isEqualToSize (NSSize aSize)
  {
    if ((width == aSize.width) && (height == aSize.height))
      return true;
    else
      return false;
  }

  /**
   * Returns true if and only if width or height is zero.
   */
  public boolean isEmpty ()
  {
    if ((width == 0) || (height == 0))
      return true;
    else
      return false;
  }

  public String toString ()
  {
    return "{width=" + width + "; height=" + height + "}";
  }
}

