//
//  BRClientProtocol.h
//  BaramRemapper
//
//  Created by Ha-young Jeong on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol BRClientProtocol

- (BOOL)alive;
- (BOOL)handleShortcutEvent:(NSInteger)type;

@end
