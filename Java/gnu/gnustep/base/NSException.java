/* NSException.java - the GNUstep exception class
   GNUstep Java Interface

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

import gnu.gnustep.java.*;
import java.lang.*;

public class NSException extends RuntimeException
{
  String name;
  Object userInfo;
  
  public NSException ()
  {
    this (null, null, null);
  }

  public NSException (String aName)
  {
    this (aName, null, null);
  }

  public NSException (String aName, String aReason)
  {
    this (aName, aReason, null);
  }

  public NSException (String aName, String aReason, Object aUserInfo)
  {
    super (aReason);
    name = aName;
    userInfo = aUserInfo;
  }
  
  public String name ()
  {
    return name;
  }

  public String reason ()
  {
    return this.getMessage ();
  }

  public Object userInfo ()
  {
    return userInfo;
  }
  
  public String toString ()
  {
    return (this.getClass ().getName ()) + "(" + name + "):" 
      + this.getMessage ();
  }
  
}
