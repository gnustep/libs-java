#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "../Library/SimpleGUI.h"

@interface Controller: NSObject
{}
- (void) firstButtonPressed: (id)sender;
- (void) secondButtonPressed: (id)sender;
@end

@implementation Controller: NSObject
{}
- (void) firstButtonPressed: (id)sender
{
  printf ("Hello World 1\n");
}

- (void) secondButtonPressed: (id)sender
{
  printf ("Hello World 2\n");
}
@end

int main (void)
{
  NSAutoreleasePool *pool;
  SimpleGUI *gui;
  Controller *controller;

  pool = [NSAutoreleasePool new];
  gui = [[SimpleGUI alloc] initWithTitle: @"Test (ObjC)"];
  controller = [Controller new];
  [gui addButtonWithTitle: @"Print \"Hello World 1\""  
       action: @selector (firstButtonPressed:)
       target: controller];
  [gui addButtonWithTitle: @"Print \"Hello World 2\""  
       action: @selector (secondButtonPressed:)
       target: controller];
  [gui start];
  RELEASE (pool);
  return 0;
}
