//
//  BPDelegate.m
//  BaramPreference
//
//  Created by Ha-young Jeong on 08. 05. 20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BPDelegate.h"

@implementation BPDelegate

- (void)awakeFromNib
{
  [NSApp activateIgnoringOtherApps:YES];

  [[BPController sharedPrefsWindowController] showWindow:nil];
}

@end
