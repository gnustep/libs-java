/* NSRect.java - class representing a GNUstep NSRect 
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

/*
 * Instances of this class contain four public variables: x, y, width, height. 
 * You are required to set and read these variables directly.
 */

public final class NSRect extends Object 
  implements Cloneable
{
  // Constants
  public static NSRect ZeroRect = new NSRect (0, 0, 0, 0);

  // Instance variables
  public float x;
  public float y;
  public float width;
  public float height;

  // Constructors
  public NSRect ()
  {
    super ();
    x = 0;
    y = 0;
    width = 0;
    height = 0;
  }
  
  public NSRect (float anX, float anY, float aWidth, float aHeight)
  {
    super ();
    x = anX;
    y = anY;
    width = aWidth;
    height = aHeight;
  }

  public NSRect (NSPoint origin, NSSize size)
  {
    super ();
    x = origin.x;
    y = origin.y;
    width = size.width;
    height = size.height;
  }

  public NSRect (String string) 
  {
    super ();
    // TODO
    // Need to parse something of the kind of 
    // "{x=0.400000; y=3.500000; width=93.000000; height=2.300000}
  }
  
  
  // Instance Methods
  public Object clone ()
    throws CloneNotSupportedException
  {
    NSRect cloned;
    
    cloned = (NSRect)super.clone ();
    cloned.x = x;
    cloned.y = y;
    cloned.width = width;
    cloned.height = height;
    return cloned;
  }

  public int hashCode ()
  {
    return (int)(x + (234.89345 * y) + (1799.77321 * width) 
		 + (6743.22222 * height));
  }
  
  public boolean equals (Object otherObject)
    {
      if (otherObject instanceof NSRect)
	{
	  return this.isEqualToRect ((NSRect)(otherObject));
	}
    else
      {
	return false;
      }
  }

  public boolean isEqualToRect (NSRect aRect)
  {
    if ((x == aRect.x) && (y == aRect.y) && (width == aRect.width) 
	&& (height == aRect.height))
      return true;
    else
      return false;
  }

  public String toString ()
  {
    return "{x=" + x + "; y=" + y + "; width=" + width 
      + "; height=" + height + "}";
  }

  public boolean intersectsRect (NSRect aRect)
  {
    if ((aRect.x + aRect.width <= x) || (x + width <= aRect.x)
	|| (aRect.y + aRect.height <= y) || (y + height <= aRect.y))
      {
	return false;
      }
    else
      {
	return true;
      }
  }

  public boolean isEmpty ()
  {
    if ((width == 0) || (height == 0))
      return true;
    else
      return false;
  }

  public boolean containsRect (NSRect aRect)
  {
    if ((x < aRect.x) && (y < aRect.y)
	&& ((x + width) > (aRect.x + aRect.width))
	&& ((y + height) > (aRect.y + aRect.height)))
      {
	return true;
      }
    else
      {
	return false;
      }
  }
  
  public boolean containsPoint (NSPoint aPoint)
  {
    return this.containsPoint (aPoint, false);
  }
  

  public boolean containsPoint (NSPoint aPoint, boolean flipped)
  {
    if (flipped)
      {
	if ((aPoint.x >= x) && (aPoint.y >= y)
	    && (aPoint.x < (x + width)) && (aPoint.y < (y + height)))
	  {
	    return true;
	  }
	else
	  {
	    return false;
	  }
      }
    else
      {
	if ((aPoint.x >= x) && (aPoint.y > y)
	    && (aPoint.x < (x + width)) && (aPoint.y <= (y + height)))
	  {
	    return true;
	  } 
	else
	  {
	    return false;
	  }
      }
  }

  public void insetRect (float dx, float dy)
  {
    NSRect rect;
    
    x += dx;
    y += dy;
    width -= 2 * dx;
    height -= 2 * dy;
  }

  public void intersectRect (NSRect aRect)
  {
    float maxX1 = x + width;
    float maxY1 = y + height;
    float maxX2 = aRect.x + aRect.width;
    float maxY2 = aRect.y + aRect.height;

    if ((maxX1 <= aRect.x) || (maxX2 <= x) || (maxY1 <= aRect.y) 
	|| (maxY2 <= y))
      {
	width = 0;
	height = 0;
      }
    else
      {
	float newX, newY, newWidth, newHeight;

	if (aRect.x <= x)
	  newX = x;
	else
	  newX = aRect.x;
	
	if (aRect.y <= y)
	  newY = y;
	else
	  newY = aRect.y;
	
	if (maxX2 >= maxX1)
	  newWidth = width;
	else
	  newWidth = maxX2 - newX;
	
	if (maxY2 >= maxY1)
	  newHeight = height;
	else
	  newHeight = maxY2 - newY;
	
	x = newX;
	y = newY;
	width = newWidth;
	height = newHeight;
      }
  }

  public void makeIntegral ()
  {
    x = (float)Math.floor (x);
    y = (float)Math.floor (y);
    width = (float)Math.ceil (width);
    height = (float)Math.ceil (height);
  }

  public void offsetRect (float dx, float dy)
  {
    x += dx;
    y += dy;
  }
  
  public void unionRect (NSRect aRect)
  {
    NSRect rect;
    
    float newX, newY, newWidth, newHeight;

    if ((aRect.width == 0) || (aRect.height == 0))
      return;
    
    if ((width == 0) || (height == 0))
      {
	x = aRect.x;
	y = aRect.y;
	width = aRect.width;
	height = aRect.height;
	return;
      }
    
    if (x < aRect.x)
      {
	newX = x;
      }
    else
      {
	newX = aRect.x;
      }
    
    if (y < aRect.y)
      {
	newY = y;
      }
    else
      {
	newY = aRect.y;
      }
    
    if ((x + width) > (aRect.x + aRect.width))
      {
	newWidth = x + width - newX;
      }
    else
      {
	newWidth = aRect.x + aRect.width - newX;
      }

    if ((y + height) > (aRect.y + aRect.height))
      {
	newHeight = y + height - newY;
      }
    else
      {
	newHeight = aRect.y + aRect.height - newY;
      }
    
    x = newX;
    y = newY;
    width = newWidth;
    height = newHeight;
  }

  public NSRect rectByInsettingRect (float dx, float dy)
  {
    NSRect output;
    
    try 
      {
	output = (NSRect)this.clone ();
	output.insetRect (dx, dy);
      }
    catch (CloneNotSupportedException e)
      {
	output = null;
      }
    
    return output;
  }
  
  public NSRect rectByIntersectingRect (NSRect aRect)
  {
    NSRect output;
    
    try 
      {
	output = (NSRect)this.clone ();
	output.intersectRect (aRect);
      }
    catch (CloneNotSupportedException e)
      {
	output = null;
      }
    
    return output;
  }
  
  public NSRect rectByMakingIntegral ()
  {
    NSRect output;
    
    try 
      {
	output = (NSRect)this.clone ();
	output.makeIntegral ();
      }
    catch (CloneNotSupportedException e)
      {
	output = null;
      }
    
    return output;
  }
  
  public NSRect rectByOffsettingRect (float dx, float dy)
  {
    NSRect output;
    
    try 
      {
	output = (NSRect)this.clone ();
	output.offsetRect (dx, dy);
      }
    catch (CloneNotSupportedException e)
      {
	output = null;
      }
    
    return output;
  }
  
  public NSRect rectByUnioningRect (NSRect aRect)
  {
    NSRect output;
    
    try 
      {
	output = (NSRect)this.clone ();
	output.unionRect (aRect);
      }
    catch (CloneNotSupportedException e)
      {
	output = null;
      }
    
    return output;
  }

  public NSPoint origin ()
  {
    return new NSPoint (x, y);
  }

  public void setOrigin (NSPoint newOrigin)
  {
    x = newOrigin.x;
    y = newOrigin.y;
  }

  public NSSize size ()
  {
    return new NSSize (width, height);
  }
  
  public void setSize (NSSize newSize)
  {
    width = newSize.width;
    height = newSize.height;
  }

  public float maxX ()
  {
    return x + width;
  }
  
  public float midX ()
  {
    return x + (width / 2);
  }

  public float maxY()
  {
    return y + height;
  }
  
  public float midY()
  {
    return y + (height / 2);
  }
}
