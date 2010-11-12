//
//  BRServer.h
//  BaramRemapper
//
//  Created by Ha-young Jeong on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BRServerProtocol.h"
#import "BRClientProtocol.h"

@interface BRServer : NSObject<BRServerProtocol> {
  id <BRClientProtocol> _client;
}

- (BOOL)sendShortcutEvent:(NSInteger)type;

@end
