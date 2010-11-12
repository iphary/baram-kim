//
//  BaramApplicationDelegate.m
//  Baram
//
//  Created by Ha-young Jeong on 08. 04. 30.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ApplicationDelegate.h"
#import "../common/BIMConstants.h"

@implementation ApplicationDelegate

- (void)awakeFromNib
{
  NSMenuItem *about                = [_menu itemWithTag:0];
  NSMenuItem *preferences          = [_menu itemWithTag:1];
  NSMenuItem *dictionary           = [_menu itemWithTag:2];
  NSMenuItem *reload               = [_menu itemWithTag:3];
  NSMenuItem *checkUpdates         = [_menu itemWithTag:4];
  NSMenuItem *registerSelectedWord = [_menu itemWithTag:5];
	
  if (about) 
    [about setAction:@selector(showAboutPanel:)];
	
  if (preferences) 
    [preferences setAction:@selector(showPreferences:)];
	
  if (dictionary) 
    [dictionary setAction:@selector(showDictionary:)];

  if (reload)
    [reload setAction:@selector(reloadDictionary:)];

  if (checkUpdates) 
    [checkUpdates setAction:@selector(checkUpdates:)];

  if (registerSelectedWord) 
    [registerSelectedWord setAction:@selector(registerSelectedWord:)];

  // register shortcuts
  for (id shortcut in [[NSUserDefaults standardUserDefaults] objectForKey:kBIMShortcutsKey]) {
    if (![shortcut objectForKey:kShortcutEnableKey])
      continue;

    id menuitem;
    switch ([[shortcut objectForKey:kShortcutTypeKey] integerValue]) {
    case kBIMBaramDictionaryShortcut :
      menuitem = dictionary;
      break;
    case kBIMReloadDictionaryShortcut :
      menuitem = reload;
      break;
    case kBIMRegisterSelectedWordShortcut :
      menuitem = registerSelectedWord;
      break;
    default:
      menuitem = nil;
    }

    if (menuitem) {
      [menuitem setKeyEquivalent:
		  [shortcut objectForKey:kShortcutStringIgnoringModifiersKey]];
      [menuitem setKeyEquivalentModifierMask:
		  [[shortcut objectForKey:kCGEventFlagsKey] integerValue]];
    }
  }
}

- (NSMenu *)menu
{
  return _menu;
}

- (void)selectInputMode:(NSString *)mode
{
  NSLog(@"Select input mode : %@", mode);

  NSDictionary *filter = [NSDictionary dictionaryWithObject:(NSString*)mode
                                       forKey:(NSString*)kTISPropertyInputSourceID];
  NSArray *list = (NSArray*)TISCreateInputSourceList((CFDictionaryRef)filter, NO);
  TISInputSourceRef isr = (TISInputSourceRef)[list objectAtIndex:0];
	
  TISSelectInputSource(isr);
}

@end
