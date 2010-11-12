//
//  main.m
//  BaramRemapper
//
//  Created by Ha-young Jeong on 08. 05. 20.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../common/BIMConstants.h"
#import "../common/BIMUserDefaults.h"
#import "BRServer.h"

BIMUserDefaults *defaults;
BRServer        *server;
CFMachPortRef   eventTap;

CGEventRef myCGEventCallback(CGEventTapProxy proxy,
			     CGEventType type,
			     CGEventRef event,
			     void *refcon)
{	
  if ((type == kCGEventTapDisabledByTimeout) ||
      (type == kCGEventTapDisabledByUserInput)) {
    NSLog(@"EventTap is disabled by timeout or userInput. (ignored)");
    CGEventTapEnable(eventTap, YES);
    return event;
  }

  if ((type != kCGEventKeyDown) && (type != kCGEventKeyUp) && (type != kCGEventFlagsChanged))
    return event;

  CGKeyCode keycode = (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
  CGEventFlags modifiers = CGEventGetFlags(event);
  NSArray *shortcuts = [defaults objectForKey:kBIMShortcutsKey];

  for (id shortcut in shortcuts) {
    NSInteger shortcuttype       = [[shortcut objectForKey:kCGEventTypeKey] integerValue];

    //if ([[shortcut objectForKey:kCGEventFlagsOptionKey] integerValue] == 0)
    //  continue;

    if (type != shortcuttype) 
      continue;

    if (type == kCGEventKeyDown) {
      NSInteger shortcutkeycode    = [[shortcut objectForKey:kCGEventKeyCodeKey] integerValue];

      if (keycode != shortcutkeycode)
	continue;
    }

    NSInteger st = [[shortcut objectForKey:kShortcutTypeKey] integerValue];

    if (!((st == kBIMSwitchShortcut) ||
	  (st == kBIMHanjaShortcut) ||
	  (st == kBIMJapaneseShortcut) ||
	  (st == kBIMRomanShortcut)))
      continue;

    NSUInteger shortcutmodifiers = [[shortcut objectForKey:kCGEventFlagsKey] unsignedIntegerValue];
    NSUInteger shortcutmask      = [[shortcut objectForKey:kCGEventFlagsMaskKey] unsignedIntegerValue];

    if ((modifiers & shortcutmask) == (shortcutmodifiers & shortcutmask)) {
      if ([server sendShortcutEvent:st])
	return NO; // ignore this event
      else
	return event;
    }
  }

  [shortcuts release];

  return event;
}

int main(int argc, char *argv[])
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  defaults = [[BIMUserDefaults alloc] init];

  // create server object
  server = [[BRServer alloc] init];

  // build connection
  NSConnection *connection = [NSConnection serviceConnectionWithName:kBRConnection
							  rootObject:server];
  if (connection == nil) {
    NSLog(@"Can not establish connection");

    [pool drain];
    exit(0);
  }
  [connection setDelegate:server];

  [[NSDistributedNotificationCenter defaultCenter]
    postNotificationName:kBaramRemapperDidLaunchNotification
    object:nil 
    userInfo:nil
    deliverImmediately:YES];

  CGEventMask        eventMask;
  CFRunLoopSourceRef runLoopSource;

  // Create an event tap. We are interested in key presses.
  eventMask = (CGEventMaskBit(kCGEventKeyDown) | 
               CGEventMaskBit(kCGEventKeyUp) | 
               CGEventMaskBit(kCGEventFlagsChanged));
  eventTap = CGEventTapCreate(kCGSessionEventTap, 
                              kCGHeadInsertEventTap, 
                              kCGEventTapOptionDefault, 
                              eventMask, 
                              myCGEventCallback, 
                              nil);
  if (!eventTap) {
    NSLog(@"Baram: failed to create event tap");
    exit(1);
  }

  // Create a run loop source.
  runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault,
                                                eventTap,
                                                0);

  // Add to the current run loop.
  CFRunLoopAddSource(CFRunLoopGetCurrent(), 
                     runLoopSource, 
                     kCFRunLoopCommonModes);

  // Enable the event tap
  CGEventTapEnable(eventTap, true);

  // Set it all running
  CFRunLoopRun();

  [connection release];
  [server release];
  [defaults release];

  [pool drain];
  return 0;
}
