//
//  BIMServer.m
//  Baram
//
//  Created by Hayoung Jeong on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BIMServer.h"
#import "BRClientWrapper.h"
#import "../BaramRemapper/BRServerProtocol.h"
#import "../common/BIMConstants.h"

@implementation BIMServer
- (id)initWithName:(NSString *)name bundleIdentifier:(NSString *)bundleIdentifier {
  if (self = [super initWithName:name
		bundleIdentifier:bundleIdentifier]) {

    inputControllerArray = [[NSMutableArray alloc] init];

    [self registerUserDefaults];
    [self connectToRemapper];
    [self checkUpdate];
  }

  return self;
}

- (id)initWithName:(NSString *)name controllerClass:(Class)controllerClassID delegateClass:(Class)delegateClassID {
  if (self = [super initWithName:name controllerClass:controllerClassID delegateClass:delegateClassID]) {
    inputControllerArray = [[NSMutableArray alloc] init];

    [self registerUserDefaults];
    [self connectToRemapper];
    [self checkUpdate];
  }

  return self;
}

- (void)registerUserDefaults {
  NSString *userDefaults = [[[NSBundle mainBundle] resourcePath]
				stringByAppendingPathComponent:@"UserDefaults.plist"];

  NSMutableDictionary *defaults = [NSMutableDictionary dictionaryWithContentsOfFile:userDefaults];
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
  [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)connectToRemapper {
  DLOG(@"Connecting to BaramRemapper");
  remapper = [[NSConnection rootProxyForConnectionWithRegisteredName:kBRConnection
			     host:nil] retain];
	NSLog(@"Connected remapper: %@", remapper);
  [remapper setProtocolForProxy:@protocol(BRServerProtocol)];
  
  [[NSDistributedNotificationCenter defaultCenter]
    addObserver:self
    selector:@selector(connectionForRemapperHasDied)
    name:kBaramRemapperDidLaunchNotification
    object:nil
    suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];

  [remapper addObserver:self];
}

- (BOOL)alive {
  return YES;
}

- (void)connectionForRemapperHasDied {
  NSLog(@"The connection for BaramRemapper has died.");

  [remapper release];
  remapper = nil;

  [[NSDistributedNotificationCenter defaultCenter]
    removeObserver:self
    name:kBaramRemapperDidLaunchNotification
    object:nil];

  [self connectToRemapper];
}

- (void)checkConnection {
  if (![remapper alive:self]) {
    NSLog(@"remapper connection is died.");
    [self connectionForRemapperHasDied];
  }
}

- (id)remapperWrapperForClient:(id)sender {
  [self checkConnection];
    
  for (id wrapper in inputControllerArray) {
    if ([wrapper client] == sender)
      return wrapper;
  }

  return nil;
}

- (id)remapperWrapperForActiveClient {
  return [inputControllerArray objectAtIndex:0];
}

- (void)remapperRegisterClient:(id)sender {
  if ([self remapperWrapperForClient:sender])
    return;

  BRClientWrapper *wrapper = 
    [[BRClientWrapper alloc] initWithClient:sender];

  [inputControllerArray addObject:wrapper];
  [wrapper release];
}

- (void)remapperUnregisterClient:(id)sender {
  id wrapper = [self remapperWrapperForClient:sender];

  if ([wrapper client] == sender) {
    [inputControllerArray removeObject:wrapper];
  }
}

- (void)remapperActivateClient:(id)sender {
  BRClientWrapper *wrapper = [self remapperWrapperForClient:sender];

  if (!wrapper) {
    [self remapperRegisterClient:sender];

    wrapper = [self remapperWrapperForClient:sender];
  }

  [wrapper retain];
  [inputControllerArray removeObject:wrapper];
  [inputControllerArray insertObject:wrapper
			 atIndex:0];
  [wrapper release];
}

- (void)remapperDeactiveClient:(id)sender {
  BRClientWrapper *wrapper = [self remapperWrapperForClient:sender];

  if (wrapper && ([inputControllerArray count] > 2)) {
    [wrapper retain];
    [inputControllerArray removeObject:wrapper];
    NSInteger index = [inputControllerArray count] - 1;
    [inputControllerArray insertObject:wrapper 
			   atIndex:index];
    [wrapper release];
  }
}

- (BOOL)handleShortcutEvent:(NSInteger)type {
  DLOG(@"delegate: handleShortcutEvent:%d", type);

  BRClientWrapper *wrapper = [self remapperWrapperForActiveClient];

  if (wrapper)
    return [[wrapper client] handleShortcutEvent:type];
  else
    return NO;
}


- (void)checkUpdate {
  double checkInterval;

  switch ([[NSUserDefaults standardUserDefaults]
	    integerForKey:kBIMUpdateCheckPeriodKey]) {
  case 1 : // dayly
    checkInterval = 60.0*60.0*24.0; break;
  case 2 : // weekly
    checkInterval = 60.0*60.0*24.0*7.0; break;
  case 3 : // monthly
    checkInterval = 60.0*60.0*24.0*30.0; break;
  default : // never 
    return;
    break;
  }

  NSTimeInterval interval = [(NSDate*)[[NSUserDefaults standardUserDefaults] objectForKey:kBIMUpdateLastCheckKey] timeIntervalSinceNow];
  double nextCheck;

  if (interval < -checkInterval) {
    NSString *updater = [[[NSBundle mainBundle] sharedSupportPath]
			    stringByAppendingPathComponent:@"BaramUpdater.app"];

    [[NSWorkspace sharedWorkspace] launchApplication:updater];

    nextCheck = checkInterval;
  } else {
    nextCheck = checkInterval+interval;
  }

  // schedule next update check
  [NSTimer scheduledTimerWithTimeInterval:nextCheck
				   target:self
				 selector:@selector(checkUpdate:)
				 userInfo:nil
				  repeats:NO];
}

@end
