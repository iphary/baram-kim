//
//  BRClientWrapper.m
//  Baram
//
//  Created by Ha-young Jeong on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BRClientWrapper.h"

@implementation BRClientWrapper

- (id)initWithClient:(id)client
{
  if (self = [super init]) {
    [self setClient:client];
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"client:0x%08x", _client, nil];
}

- (id)client
{
  return _client;
}

- (void)setClient:(id)client
{
  _client = client;
}

@end
