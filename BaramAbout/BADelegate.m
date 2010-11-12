//
//  BADelegate.m
//  BaramAbout
//
//  Created by Ha-young Jeong on 10. 7. 31.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BADelegate.h"
#import "AboutWindowController.h"

@implementation BADelegate

- (void)awakeFromNib
{
  [NSApp activateIgnoringOtherApps:YES];

  AboutWindowController *aboutWindowController = [[AboutWindowController alloc] initWithWindowNibName:@"AboutWindow"];

  [aboutWindowController showWindow:self];
}

@end
