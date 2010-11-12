//
//  BRClientWrapper.h
//  Baram
//
//  Created by Ha-young Jeong on 9/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BRClientWrapper : NSObject {
  id   _client;
}

- (id)initWithClient:(id)client;

- (id)client;
- (void)setClient:(id)client;

@end
