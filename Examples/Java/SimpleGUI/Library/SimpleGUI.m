/* SimpleGUI.h -  A library for simple GUI programming
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
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
   */ 

#include "SimpleGUI.h"

@implementation SimpleGUI : NSObject
+ (id) new
{
  return [[self alloc] init];
}

- (id) init
{
  return [self initWithTitle: @"SimpleGUI app"];
}

- (id) initWithTitle: (NSString *)aTitle
{
  [NSApplication sharedApplication]; 
  box = [GSVbox new];
  ASSIGN (title, aTitle);
  return self;
}

- (void) start
{
  NSMenu *menu;  
  menu = AUTORELEASE ([NSMenu new]);

  [menu addItemWithTitle: @"Quit" 
	action: @selector (terminate:)
	keyEquivalent: @"q"];	
  
  [NSApp setMainMenu: menu];
  [NSApp setDelegate: self];
  [NSApp run];
}

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification
{
  NSRect winFrame;
  NSWindow *win;

  winFrame.size = [box frame].size;
  winFrame.origin = NSMakePoint (100, 120);
  
  win = [[NSWindow alloc] initWithContentRect: winFrame
			  styleMask: (NSTitledWindowMask 
				      | NSMiniaturizableWindowMask)
			  backing: NSBackingStoreBuffered
			  defer: YES];
  [win setReleasedWhenClosed: YES];
  [win setContentView: box];
  [box release];
  [win setTitle: title];
  [title release];
  [win makeKeyAndOrderFront: self]; 
}

- (void) addButtonWithTitle: (NSString *)aTitle
			tag: (int)tag
{
  NSButton *button;
  
  button = [NSButton new];
  [button setTitle: aTitle];
  [button setTag: tag];
  [button setAction: @selector (buttonPressed:)];
  [button setTarget: self];
  [button sizeToFit];
  [button setFrameSize: NSMakeSize ([button frame].size.width + 6, 
				    [button frame].size.height + 4)];
  AUTORELEASE (button);
  [box addView: button];
}

- (void) buttonPressed: (id)sender
{
  if ([delegate respondsToSelector: @selector (simpleGUIButtonPressed:)])
    {
      [delegate simpleGUIButtonPressed: [sender tag]];
    } 
}

- (void) setDelegate: (id)aDelegate
{
  delegate = aDelegate;
}

- (id) delegate
{
  return delegate;
}

@end

