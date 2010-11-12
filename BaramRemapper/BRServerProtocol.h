//
//  BRServerProtocol.h
//  BaramRemapper
//
//  Created by Ha-young Jeong on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol BRServerProtocol

- (BOOL)alive:(id)sender;
- (void)addObserver:(id)sender;

@end
