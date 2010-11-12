// -*- mode:objc -*-
//
//  BIMTrigger.h
//  Baram
//
//  Created by Hayoung Jeong on 7/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BIMTrigger : NSObject {
  BOOL      enabled;
  BOOL      alert;
  BOOL      changeInputMode;
  NSInteger minLength;
  NSMutableDictionary *triggers;
}

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL alert;
@property (nonatomic, assign) BOOL changeInputMode;
@property (nonatomic, retain) NSMutableDictionary *triggers;

- (void)readProperties:(NSNotification *)notification;
- (BOOL)enabledForClient:(NSString *)bundleId;
- (BOOL)replaceInputString:(NSString *)inputString toTriggerString:(NSString *)triggerString;

@end
