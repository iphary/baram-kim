//
//  ApplicationController.m
//  Baram
//
//  Created by Ha-young Jeong on 08. 07. 02.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "UpdaterController.h"
#import "../common/BIMConstants.h"
#import "../common/BIMUserDefaults.h"
#import <Sparkle/Sparkle.h>

@implementation UpdaterController

-(void)awakeFromNib
{
  BIMUserDefaults *defaults = [[BIMUserDefaults alloc] init];

  [defaults setObject:[NSDate date]
	    forKey:kBIMUpdateLastCheckKey];

  [defaults synchronize];
  [defaults release];

  SUUpdater *updater = [[SUUpdater alloc] init];
  [updater checkForUpdates:self];
}

-(void)updaterDidNotFindUpdate:(SUUpdater *)update
{
  NSLog(@"BaramUpdater : <updaterDidNotFindUpdate> :%@", update);
  
  [[NSApplication sharedApplication] terminate:self];
}

- (void)updaterWillRelaunchApplication:(SUUpdater *)updater
{
  [[NSApplication sharedApplication] terminate:self];
}

@end
