#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "../Library/SimpleGUI.h"

@interface Controller: NSObject
{}
- (void) simpleGUIButtonPressed: (int)tag;
@end

@implementation Controller: NSObject
{}
- (void) simpleGUIButtonPressed: (int)tag
{
  switch (tag)
    {
    case 1:
      printf ("Hello World 1\n");
      break;
    case 2:
      printf ("Hello World 2\n");
      break;
    default:
      printf ("Problem\n");
      break;
    }  
}

@end

int main (void)
{
  NSAutoreleasePool *pool;
  SimpleGUI *gui;

  pool = [NSAutoreleasePool new];
  gui = [[SimpleGUI alloc] initWithTitle: @"Test (ObjC)"];
  [gui addButtonWithTitle: @"Print \"Hello World 1\""  tag: 1];
  [gui addButtonWithTitle: @"Print \"Hello World 2\""  tag: 2];
  [gui setDelegate: [Controller new]];
  [gui start];  
  RELEASE (pool);
  return 0;
}
