//
//  BIMTrigger.m
//  Baram
//
//  Created by Hayoung Jeong on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BIMTrigger.h"
#import "../common/BIMConstants.h"

@implementation BIMTrigger
@synthesize enabled;
@synthesize alert;
@synthesize changeInputMode;
@synthesize triggers;

- (id)init {
  if (self = [super init]) {
    [[NSNotificationCenter defaultCenter]
      addObserver:self
	 selector:@selector(readProperties:)
	     name:NSUserDefaultsDidChangeNotification
	   object:nil];

    [[NSDistributedNotificationCenter defaultCenter]
      addObserver:self
	 selector:@selector(readProperties:)
	     name:kBIMUserDefaultsDidChangeNotification
	   object:nil];

    self.triggers = [NSMutableDictionary dictionary];

    [self readProperties:nil];
  }

  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];

  [self.triggers release];
  [super dealloc];
}

- (void)readProperties:(NSNotification *)notification {
  NSDictionary *properties = [[NSUserDefaults standardUserDefaults] objectForKey:kBIMTriggerPropertiesKey];

  self.enabled = [[properties objectForKey:kBIMTriggerEnableKey] boolValue];
  self.alert = [[properties objectForKey:kBIMTriggerAlertKey] boolValue];
  self.changeInputMode = YES;

  minLength = 0;
  [self.triggers removeAllObjects];

  for (id entry in [properties objectForKey:kBIMTriggerArrayKey]) {
    NSString *triggerString = [entry objectForKey:@"triggerString"];
    NSInteger length = [triggerString length];
    if ((minLength == 0) || (minLength > length))
      minLength = length;

    [self.triggers setObject:[NSNumber numberWithBool:YES]
		      forKey:triggerString];
  }
}

- (BOOL)enabledForClient:(NSString *)bundleId {
  NSArray *appSpecific = [[NSUserDefaults standardUserDefaults] arrayForKey:kBIMAppSpecificSetupKey];

  for (id entry in appSpecific) {
    if ([bundleId hasPrefix:[entry objectForKey:@"bundleIdentifier"]])
      return [[entry objectForKey:@"trigger"] boolValue];
  }

  return self.enabled;
}

- (BOOL)replaceInputString:(NSString *)inputString toTriggerString:(NSString *)triggerString {
  DLOG(@"inputString:%@ triggerString:%@", inputString, triggerString);

  if ([inputString length] < minLength)
    return NO;

  NSNumber *enabled = [self.triggers objectForKey:triggerString];
  if (enabled) {
    if ([enabled boolValue]) {
      if (self.alert)
	NSBeep();

      return YES;
    }
  }

  return NO;
}

@end
