// -*- mode:objc -*-
//
//  BIMServer.h
//  Baram
//
//  Created by Hayoung Jeong on 8/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

@class BRServer;

@interface BIMServer : IMKServer {
  BRServer       *remapper;
  NSMutableArray *inputControllerArray;
}

- (void)registerUserDefaults;

// remapper connection
- (BOOL)alive;
- (void)connectToRemapper;
- (void)connectionForRemapperHasDied;
- (void)checkConnection;
- (id)remapperWrapperForClient:(id)sender;
- (void)remapperRegisterClient:(id)sender;
- (void)remapperUnregisterClient:(id)sender;
- (void)remapperActivateClient:(id)sender;
- (void)remapperDeactiveClient:(id)sender;
- (BOOL)handleShortcutEvent:(NSInteger)type;

- (void)checkUpdate;

@end
