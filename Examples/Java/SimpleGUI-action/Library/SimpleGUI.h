/* SimpleGUI.h -  A library for simple GUI programming -*-objc-*-
   Copyright (C) 2000 Free Software Foundation, Inc.
   
   Written by:  Nicola Pero <nicola@brainstorm.co.uk>
   Date: June 2000, October 2000
   
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
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
   */ 

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <GNUstepGUI/GSVbox.h>

/*
 * This demo library provides a single object, SimpleGUI.
 * To create a GUI app, you create a SimpleGUI object, 
 * then add buttons to the main window of your app by using 
 * addButtonWithTitle:action:target:.  The application 
 * is then started by invoking the SimpleGUI's method -start.
 *
 * The target of each button is notified of the user pressing 
 * one of the buttons through the specified action.
 *
 */

@interface SimpleGUI : NSObject
{
  NSString *title;
  GSVbox *box;
  id delegate;
}
- (id) initWithTitle: (NSString *)title;
- (void) start;
- (void) applicationDidFinishLaunching: (NSNotification *)aNotification;
- (void) addButtonWithTitle: (NSString *)title
		     action: (SEL)action
		     target: (id)target;
@end
