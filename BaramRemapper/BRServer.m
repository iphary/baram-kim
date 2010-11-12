//
//  BRServer.m
//  BaramRemapper
//
//  Created by Ha-young Jeong on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BRServer.h"
#import "../common/BIMConstants.h"

@implementation BRServer

- (id)init
{
  if (self = [super init]) {
    _client = nil;
    
    NSLog(@"start remapper server");
  }

  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (BOOL)sendShortcutEvent:(NSInteger)type
{
  NSLog(@"sendShortcutEvent");

  if ([_client alive]) {
    return [_client handleShortcutEvent:type];
  } else {
    [[NSDistributedNotificationCenter defaultCenter]
      postNotificationName:kBaramRemapperDidLaunchNotification
      object:nil 
      userInfo:nil
      deliverImmediately:YES];
  }

  return NO;
}

#pragma mark -
#pragma mark server protocol

- (BOOL)alive:(id)sender
{
	return YES;
}

- (void)addObserver:(id)sender
{
	_client = sender;
}


@end
