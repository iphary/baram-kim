//
//  main.m
//  Baram
//
//  Created by Ha-young Jeong on 08. 04. 30.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

// BIM sub components
#import "BIMServer.h"
#import "DictionaryEngine.h"
#import "JapaneseEngine.h"
#import "BIMTrigger.h"

// connection name
NSString *const kConnectionName = @"Baram_1_Connection";

BIMServer        *server;
IMKCandidates    *candidatesEngine = nil;
DictionaryEngine *dictionaryEngine = nil;
JapaneseEngine   *japaneseEngine = nil;
BIMTrigger       *triggerEngine = nil;

int main(int argc, char *argv[])
{
  NSString*       identifier = [[NSBundle mainBundle] bundleIdentifier];
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  //find the bundle identifier and then initialize the input method server
  server = [[BIMServer alloc] initWithName:(NSString*)kConnectionName
			  bundleIdentifier:identifier];

  // BIM subcomponents
  dictionaryEngine = [[DictionaryEngine alloc] init];
  japaneseEngine   = [[JapaneseEngine alloc] init];
  triggerEngine    = [[BIMTrigger alloc] init];

  //load the bundle explicitly because in this case the input method is a background only application
  [NSBundle loadNibNamed:@"MainMenu"
	    owner:[NSApplication sharedApplication]];

  //create the candidate window
  candidatesEngine = [[IMKCandidates alloc] initWithServer:server
						 panelType:kIMKSingleColumnScrollingCandidatePanel];
	
  //finally run everything
  [[NSApplication sharedApplication] run];

  [server release];
  [candidatesEngine release];
  [dictionaryEngine release];
  [japaneseEngine release];
  [triggerEngine release];

  [pool release];
  return 0;    
}
