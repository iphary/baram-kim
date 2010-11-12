// -*- mode:objc -*-
//
//  BaramApplicationDelegate.h
//  Baram
//
//  Created by Ha-young Jeong on 08. 04. 30.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "../libhangul/hangul.h"

@interface ApplicationDelegate : NSObject {
  IBOutlet NSMenu           *_menu;
}

- (NSMenu *)menu;
- (void)selectInputMode:(NSString*)mode;

@end
