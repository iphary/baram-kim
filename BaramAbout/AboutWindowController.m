//
//  AboutWindowController.m
//  Baram
//
//  Created by Hayoung Jeong on 7/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AboutWindowController.h"

@implementation AboutWindowController

- (void)awakeFromNib {
  [[self window] center];
  [productName setStringValue:NSLocalizedString(@"Baram", @"Baram")];
  [version     setStringValue:NSLocalizedString(@"Version", @"Version")];
  [releaseDate setStringValue:NSLocalizedString(@"Release", @"Release")];
  [copyright   setStringValue:NSLocalizedString(@"Copyright", @"Copyright")];
}

- (void)windowWillClose:(NSNotification *)notification
{
  [[NSApplication sharedApplication] terminate:self];
}

- (IBAction)homepage:(id)sender {
  NSURL *url = [NSURL URLWithString:@"http://baram.or.kr"];
  [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)donate:(id)sender {
  NSURL *url = [NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=1035628"];
  [[NSWorkspace sharedWorkspace] openURL:url];
}

- (IBAction)checkUpdate:(id)sender {
  [[NSWorkspace sharedWorkspace] launchApplication:@"BaramUpdater.app"];
}

@end
