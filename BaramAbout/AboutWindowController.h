// -*- mode:objc -*-
//
//  AboutWindowController.h
//  Baram
//
//  Created by Hayoung Jeong on 7/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AboutWindowController : NSWindowController {
  IBOutlet NSTextField *productName;
  IBOutlet NSTextField *version;
  IBOutlet NSTextField *releaseDate;
  IBOutlet NSTextField *copyright;
}

- (IBAction)homepage:(id)sender;
- (IBAction)donate:(id)sender;
- (IBAction)checkUpdate:(id)sender;

@end
