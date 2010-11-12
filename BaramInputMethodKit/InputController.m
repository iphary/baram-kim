//
//  InputController.m
//  Baram
//
//  Created by Ha-young Jeong on 08. 04. 30.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "InputController.h"
#import "ApplicationDelegate.h"
#import "BaramHangul.h"
#import "BIMServer.h"
#import "DictionaryEngine.h"
#import "BIMModeIndicator.h"
#import "BIMTrigger.h"
#import "JapaneseEngine.h"
#import "../common/BIMConstants.h"
#import "../common/utf32.h"

// private function
@interface InputController (private)
- (void)setInitialMode;
- (void)overrideKeyboardLayout;
- (BOOL)commitByWord;

- (void)readProperties:(NSNotification *)note;

- (void)launchSharedApplication:(NSString *)appName
	       withNotification:(NSDictionary *)notification;

- (void)sharedApplicationDidLaunch;

- (BOOL)TSMDocumentAccessTest;

- (void)showIndicator:(id)sender;
- (NSDictionary *)attributes;
- (NSString *)stringWithCandidate:(NSString *)candidate;
@end

@implementation InputController
@synthesize currentClient;
@synthesize activated;
@synthesize eventHandled;
@synthesize remapperEnabled;
@synthesize viMode;
@synthesize bypassWithOption;
@synthesize indicator;
@synthesize trigger;
@synthesize shortcuts;
@synthesize parenStyle;
@synthesize parenEnabled;
@synthesize hangulCommitByWord;

@synthesize attributedStringEnabled;
@synthesize fontsAttributes;
@synthesize selectedString;

- (id)initWithServer:(IMKServer *)_server delegate:(id)delegate client:(id)inputClient {	
  DLOG(@"- initWithServer:%08x delegate:%08x client:%08x failed", _server, delegate, inputClient);

  if ((self = [super initWithServer:_server delegate:delegate client:inputClient])) {		
    hic = [[BaramHangul alloc] init];

    [server remapperRegisterClient:self];

    self.trigger = nil;
    self.indicator = nil;

    [[NSNotificationCenter defaultCenter]
      addObserver:self
	 selector:@selector(readProperties:)
	     name:NSUserDefaultsDidChangeNotification
	   object:nil];

    [[NSDistributedNotificationCenter defaultCenter]
      addObserver:self
	 selector:@selector(readProperties:)
	     name:kBIMUserDefaultsDidChangeNotification
	   object:nil];

    [self readProperties:nil];

    return self;
  }
	
  return nil;
}

- (void)dealloc {
  DLOG(@"dealloc");

  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];

  // delete hangul input context
  [hic release];

  [server remapperUnregisterClient:self];

  [self.trigger release];
  [self.indicator release];

  // composed buffer release
  [[self composedStringBuffer] release];
	
  [super dealloc];
}

#pragma mark -
#pragma mark IMKStateSetting Protocol

- (void)activateServer:(id)sender {
  DLOG(@"- activateServer:%08x", sender);

  self.activated = YES;
  self.currentClient = sender;
  
  [self setInitialMode];
  [self showIndicator:nil];

  [server remapperActivateClient:self];
}

- (void)deactivateServer:(id)sender {
  DLOG(@"- deactivateServer:%08x", sender);
  self.activated = NO;

  [self commitComposition:sender];
}

- (void)showPreferences:(id)sender
{
  [self launchSharedApplication:@"BaramPreferences.app"
	       withNotification:nil];
}

- (NSUInteger)recognizedEvents:(id)sender
{
  if (_showCandidates)
    return NSKeyDownMask; 
  else 
    return (NSKeyDownMask | NSFlagsChangedMask);
}

- (NSDictionary*)modes:(id)sender {
  return [super modes:sender];
}

- (id)valueForTag:(long)tag client:(id)sender {
  return [super valueForTag:tag client:sender];
}

- (void)setValue:(id)value forTag:(long)tag client:(id)sender {	
  if (tag != kTextServiceInputModePropertyTag)
    return;

  NSString *newInputMode = (NSString *)value;

  if (![[self inputMode] isEqual:newInputMode] && newInputMode != nil) {
    [self commitComposition:sender];
    [self setInputMode:newInputMode];
  }
}

#pragma mark -
#pragma mark handle event

#define KEYCODE_RETURN    0x24
#define KEYCODE_TAB       0x30
#define KEYCODE_SPACE     0x31
#define KEYCODE_BACKSPACE 0x33
#define KEYCODE_ESC       0x35

- (BOOL)commitEvent:(NSEvent *)event {
  NSUInteger modifiers       = [event modifierFlags];
  unsigned short keyCode     = [event keyCode];

  if ((modifiers & NSCommandKeyMask) ||
      (modifiers & NSControlKeyMask) ||
      ((modifiers & NSAlternateKeyMask) && !self.bypassWithOption) ||
      (keyCode == KEYCODE_RETURN) ||
      (keyCode == KEYCODE_TAB) ||
      (keyCode == KEYCODE_SPACE) ||
      (keyCode > KEYCODE_BACKSPACE))
    return YES;
  else
    return NO;
}

- (BOOL)handleRoman:(NSString *)string keyCode:(unsigned short)keyCode modifiers:(NSUInteger)modifiers client:(id)sender {
  BOOL commit;
  BOOL ret = [hic process:string modifierFlags:modifiers commit:&commit];

  if (!ret || commit) 
    [hic reset];

  NSString *romanString = [hic inputString];
  NSString *hangulString = [hic originalString];

  if ([self.trigger replaceInputString:romanString
		       toTriggerString:hangulString]) {
    NSRange range = [sender selectedRange];

    [sender setMarkedText:hangulString
	   selectionRange:NSMakeRange(NSNotFound, NSNotFound)
	 replacementRange:NSMakeRange(range.location - ([romanString length] - 1) , ([romanString length] - 1))];
    [sender insertText:hangulString
      replacementRange:NSMakeRange(range.location - ([romanString length] - 1), [hangulString length])];

    [hic reset];

    [sender selectInputMode:kBIMHangulMode];

    return YES;
  }
			
  return NO;
}

- (BOOL)handleHangul:(NSString *)string keyCode:(unsigned short)keyCode modifiers:(NSUInteger)modifiers client:(id)sender {
  BOOL commit;
  BOOL ret = [hic process:string modifierFlags:modifiers commit:&commit];

  if (!ret) {
    [self commitComposition:nil];

    return NO;
  }
    
  // event has been processed in hic.
  NSString *commitString = [hic commitString];

  if ([commitString length] > 0) {
    if (![self commitByWord]) {
      [sender insertText:commitString
	replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    }
  }

  DLOG(@"updateComposition");
    
  [self updateComposition];

  // if commit is needed.
  if (commit) {
    [self commitComposition:nil];

    return YES;
  }

  NSString *romanString = [hic inputString];
  NSString *hangulString = [hic originalString];

  if ([self.trigger replaceInputString:hangulString
		       toTriggerString:romanString]) {
    NSRange range = [sender selectedRange];

    [self commitComposition:nil];

    [sender setMarkedText:romanString
	   selectionRange:NSMakeRange(NSNotFound, NSNotFound)
	 replacementRange:NSMakeRange((range.location - [hangulString length]), [hangulString length])];
    [sender insertText:romanString
      replacementRange:NSMakeRange((range.location - [hangulString length]), [romanString length])];

    [sender selectInputMode:kBIMEnglishMode];

    return YES;
  }

  return ret;
}

- (BOOL)handleShortcut:(NSEvent *)event {
  CGEventRef cgevent = [event CGEvent];
  CGKeyCode keycode = (CGKeyCode)CGEventGetIntegerValueField(cgevent, kCGKeyboardEventKeycode);
  CGEventFlags modifiers = CGEventGetFlags(cgevent);
  NSUInteger type = [event type];

  for (id skey in self.shortcuts) {
    NSInteger shortcuttype = [[skey objectForKey:kCGEventTypeKey] integerValue];

    if (!(((type == NSKeyDown) && (shortcuttype == kCGEventKeyDown)) ||
	  ((type == NSFlagsChanged) && (shortcuttype == kCGEventFlagsChanged))))
      continue;

    if ([[skey objectForKey:kCGEventFlagsOptionKey] integerValue])
      continue;

    NSUInteger mask  = [[skey objectForKey:kCGEventFlagsMaskKey] unsignedIntegerValue];

    if ((modifiers & mask) != ([[skey objectForKey:kCGEventFlagsKey] unsignedIntegerValue] & mask))
      continue;

    if (keycode == [[skey objectForKey:kCGEventKeyCodeKey] integerValue]) {
      return [self handleShortcutEvent:[[skey objectForKey:kShortcutTypeKey] integerValue]];
    }
  }

  return NO;
}

- (BOOL)handleEvent:(NSEvent*)event client:(id)sender {
  self.currentClient = sender;

  if ([event type] == NSKeyDown) {
    unsigned short keyCode     = [event keyCode];
    NSUInteger modifiers       = [event modifierFlags];
    NSString *string           = [event characters];
    NSString *stringIgnMod     = [event charactersIgnoringModifiers];
    char ascii_code_wo_mod     = [stringIgnMod characterAtIndex:0];

    DLOG(@"Baram : NSKeyDown KeyCode:%08x", keyCode);

    [self.indicator hide];
	  if ( modifiers ) {
		  if ( [self handleShortcut:event] ) {
			  return YES;  
		  }
	  }
    // handle special event
    if (keyCode == KEYCODE_ESC) {
      if (![[self inputMode] isEqual:kBIMEnglishMode])
	[self cancelComposition];

      if (self.viMode)
	[[self client] selectInputMode:kBIMEnglishMode];

      return NO;
    } else if (keyCode == KEYCODE_BACKSPACE) {
      BOOL ret = [self backspace];

      if ([[self inputMode] isEqual:kBIMEnglishMode])
	return NO;
      else 
	return ret;

    } else if ([self commitEvent:event]) {
      [self commitComposition:sender];
			
      return NO;
    }
    if ([[self inputMode] isEqual:kBIMEnglishMode]) {
      // roman input mode
      return [self handleRoman:string keyCode:keyCode modifiers:modifiers client:sender];
    } else if (self.bypassWithOption && (modifiers & NSAlternateKeyMask)) {
      // commit current composition
      [self commitComposition:sender];

#define KEYCODE_N 0x2d
#define KEYCODE_E 0x0e
#define KEYCODE_U 0x20
#define KEYCODE_I 0x22
      
      // adjust charactor code
      if ((modifiers & NSAlphaShiftKeyMask) || (modifiers & NSShiftKeyMask)) {
        switch(keyCode) {
        case KEYCODE_N: ascii_code_wo_mod = 'N'; break;
        case KEYCODE_E: ascii_code_wo_mod = 'E'; break;
        case KEYCODE_U: ascii_code_wo_mod = 'U'; break;
        case KEYCODE_I: ascii_code_wo_mod = 'I'; break;
        default: ascii_code_wo_mod = toupper(ascii_code_wo_mod); break;
        }
      } else {
        switch(keyCode) {
        case KEYCODE_N: ascii_code_wo_mod = 'n'; break;
        case KEYCODE_E: ascii_code_wo_mod = 'e'; break;
        case KEYCODE_U: ascii_code_wo_mod = 'u'; break;
        case KEYCODE_I: ascii_code_wo_mod = 'i'; break;
        default: break;
        }
      }
			
      NSString* convertedString = [NSString stringWithFormat:@"%c", ascii_code_wo_mod, nil];
				
      DLOG(@"BIM: roman bypass %@", convertedString);

      [sender insertText:convertedString
	      replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
			
      return YES;
    } else {
      // Hangul input process
      return [self handleHangul:string keyCode:keyCode modifiers:modifiers client:sender];
    }
  } else if ([event type] == NSFlagsChanged) {
    NSUInteger modifiers   = [event modifierFlags];

    // ignore if it is a shortcut
    for (id shortcut in self.shortcuts) {
      NSInteger flags = [[shortcut objectForKey:kCGEventFlagsKey] integerValue];
      NSInteger flagsMask = [[shortcut objectForKey:kCGEventFlagsMaskKey] integerValue];
      if ((modifiers & flagsMask) == (flags & flagsMask))
	return NO;	
    }
      
    // process only command, control, option
    if (!((modifiers & NSCommandKeyMask) || 
	  (modifiers & NSControlKeyMask) || 
	  (modifiers & NSAlternateKeyMask)))
      return NO;
		
    [self commitComposition:sender];
		
    return NO;
  } 
	
  DLOG(@"BIM: unknown event %@", event);
  return NO;
}

#pragma mark -
#pragma mark internal buffers

- (NSMutableString *)composedStringBuffer {
  if (!_composedStringBuffer)
    _composedStringBuffer = [[NSMutableString alloc] init];

  return _composedStringBuffer;
}

#pragma mark -
#pragma mark IMKServerInput Protocol

- (NSAttributedString *)originalString:(id)sender {
  NSAttributedString *ret;

  if ([self commitByWord]) {
    NSString *original = [hic originalString];

    if ([original length] > 0)
      ret = [[NSAttributedString alloc] initWithString:original
					    attributes:[self attributes]];
    else
      ret = [[NSAttributedString alloc] initWithString:@""
					    attributes:[self attributes]];
  } else {
    NSString *preedit = [hic preeditString];

    if ([preedit length] > 0)
      ret = [[NSAttributedString alloc] initWithString:preedit
					    attributes:[self attributes]];
    else
      ret = [[NSAttributedString alloc] initWithString:@""
					    attributes:[self attributes]];
  }

  DLOG(@"originalString:%@", ret);

  return [ret autorelease];
}

- (id)composedString:(id)sender {
  NSString *currentInputMode = [self inputMode];
  NSString *result = nil;

  if ([currentInputMode isEqual:kBIMHiraganaMode] ||
      [currentInputMode isEqual:kBIMKatakanaMode]) {
    NSString *string = [[self originalString:sender] string];
    NSString *kana = [japaneseEngine
			 translate:string
			 toKana:currentInputMode
			 range:NSMakeRange(0, [string length])];
    if ([kana length] > 0)
      result = kana;
  } else if ([[self composedStringBuffer] length] > 0) {
    result = [self composedStringBuffer];
  } 

  // make attributed string
  NSAttributedString *ret;

  if (result) 
    ret = [[NSAttributedString alloc] initWithString:result
					  attributes:[self attributes]];
  else
    ret = [[NSAttributedString alloc] initWithString:@""
					  attributes:[self attributes]];

  DLOG(@"composedString:%@", ret);

  return [ret autorelease];
}

- (void)commitComposition:(id)sender {	
  if (![[self inputMode] isEqual:kBIMEnglishMode]) {
    NSString *flushed = [hic flush];
    NSMutableString *commit = [[NSMutableString alloc] init];
    DLOG(@"flushedString:%@", flushed);

    if ([self commitByWord])
      [commit appendString:[hic originalString]];

    if ([flushed length] > 0) 
      [commit appendString:flushed];

    if ([[self composedString:nil] length] > 0) 
      [self.currentClient insertText:[self composedString:nil]
		    replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
    else {
      NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:commit
								       attributes:[self attributes]];
      [attrString autorelease];
    
      [self.currentClient insertText:attrString
		    replacementRange:NSMakeRange(NSNotFound,NSNotFound)];
    }

    [commit release];
    [[self composedStringBuffer] setString:@""];
  } 

  [hic reset];
}

- (void)cancelComposition {
  DLOG(@"BIM: cancelComposition");
  
  [[self composedStringBuffer] setString:@""];
  [super cancelComposition];
  [hic reset];

  _showCandidates = NO;
}

- (void)updateComposition {
  id originalString = [self originalString:nil];
  id composedString = [self composedString:nil];
  id updateString;

  if ([composedString length] > 0)
    updateString = composedString;
  else
    updateString = originalString;

  DLOG(@"originalString:%@ composedString:%@ updateString:%@", originalString, composedString, updateString);

  [[self client] setMarkedText:updateString
   		selectionRange:NSMakeRange(0, [updateString length])
   	      replacementRange:NSMakeRange(NSNotFound,NSNotFound)];

}

/* 
   Candidates processing
*/

- (void)showCandidates {
  if (candidatesEngine) {
    if ([[self candidates:nil] count] == 0) {
      //no candidate
      NSBeep();
      return;
    }

    NSDictionary *attributes;
		
    // default font size
    if (_candidatesFontSize < 12 && _candidatesFontSize > 24)
      attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:12], NSFontAttributeName, nil];
    else
      attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:_candidatesFontSize], NSFontAttributeName, nil];
			
    [candidatesEngine updateCandidates];
    if ((_candidatesPanelType == 1) || 
	(_candidatesPanelType == 2) ||
	(_candidatesPanelType == 3))
      [candidatesEngine setPanelType:_candidatesPanelType];
		
    [candidatesEngine setAttributes:attributes];
    [candidatesEngine show:kIMKLocateCandidatesBelowHint];

    _showCandidates = YES;
  }
}

- (void)updateCandidates {
  if (candidatesEngine && _showCandidates)
    [candidatesEngine updateCandidates];
}

//- (NSString *)selectedString {
//  NSRange range = [self.currentClient markedRange];
//  return [[self.currentClient attributedSubstringFromRange:range] string];
//}

- (NSArray *)candidates:(id)sender {
  NSString *word = self.selectedString;

  if (![word length])
    word = [hic originalString];
 
  DLOG(@"search dictionary for %@", word);

  NSArray *array = [dictionaryEngine dictionarySearch:word
						 mode:[self inputMode]];

  DLOG(@"candidates = %@", array);
  return array;
} 

- (void)candidateSelectionChanged:(NSAttributedString*)candidateString
{
  NSDictionary *attributes;
  if (_candidatesFontSize < 12 && _candidatesFontSize > 24)
    attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:12], NSFontAttributeName, nil];
  else
    attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:_candidatesFontSize], NSFontAttributeName, nil];

  // show annotation
  NSString *string = [dictionaryEngine anotationForCandidate:[candidateString string]];

  if ([string length] > 0) {
    NSAttributedString *annotation = [[NSAttributedString alloc] initWithString:string attributes:attributes];

    [candidatesEngine showAnnotation:(NSAttributedString*)annotation];
    [annotation release];
  }

  // update composedString
  [[self composedStringBuffer] setString:[self stringWithCandidate:[candidateString string]]];
  [self updateComposition];
}

- (NSString *)stringWithCandidate:(NSString *)candidate {
  NSMutableString *result = [[NSMutableString alloc] initWithString:self.selectedString];

  if ([candidate length] > 0) {
    NSString *selectedKey = [dictionaryEngine keyForCandidate:candidate];
    NSMutableString *paren = [[NSMutableString alloc] init];

    if (self.parenEnabled) {
      switch (self.parenStyle) {
      case 1: 
	[paren appendFormat:@"%@(%@)", candidate, selectedKey]; break;
      case 2:
	[paren appendFormat:@"%@(%@)", selectedKey, candidate]; break;
      default:
	[paren appendString:candidate];
      }
    } else {
	[paren appendString:candidate];
    }

    [result replaceCharactersInRange:[result rangeOfString:selectedKey]
			  withString:paren];

    [paren release];
  }

  NSString *ret = [NSString stringWithString:result];
  [result release];
  return ret;
}

- (void)candidateSelected:(NSAttributedString *)candidateString {
  [[self composedStringBuffer] setString:[self stringWithCandidate:[candidateString string]]];

  [self commitComposition:nil];

  // update candidates selection history
  [dictionaryEngine candidateSelect:[candidateString string]]; 
  [self.selectedString release];
  self.selectedString = nil;
}

/* 
   Menu actions
*/
- (NSMenu*)menu
{
  return [[NSApp delegate] menu];
}

- (void)showAboutPanel:(id)sender
{
  [self launchSharedApplication:@"BaramAbout.app"
	withNotification:nil];
}

- (void)showDictionary:(id)sender
{
  [self launchSharedApplication:@"BaramDictionary.app"
	withNotification:nil];
}

- (void)reloadDictionary:(id)sender
{
  [dictionaryEngine readDictionary];
}

- (void)checkUpdates:(id)sender
{
  [self launchSharedApplication:@"BaramUpdater.app"
	withNotification:nil];
}

- (BOOL)backspace {
  if ([hic backspace] && ![[self inputMode] isEqual:kBIMEnglishMode]) { 
    [self updateComposition];

    return YES;
  }
	
  return NO;
}

#pragma mark -
#pragma mark menu actions

- (void)registerSelectedWord:(id)sender 
{
  BOOL running = NO;
  for (id app in [[NSWorkspace sharedWorkspace] launchedApplications]) {
    if ([[app objectForKey:@"NSApplicationBundleIdentifier"] 
	  isEqual:@"kr.or.baram.BaramDictionary"]) {
      running = YES;
      break;
    }
  }

  NSString *word = [[[self client] attributedSubstringFromRange:[[self client] selectedRange]] string];
  NSDictionary *infoDict;

  if ([word length] > 0) {
    infoDict = [[NSDictionary alloc] initWithObjectsAndKeys:word, @"Word", nil];
  } else {
    NSLog(@"no selected word");
    return;
  }

  // execution dictionary
  if (running) {
    NSDistributedNotificationCenter *nc = [NSDistributedNotificationCenter defaultCenter];
    
    [nc postNotificationName:kBaramDictionaryAddNewWordNotification
	object:nil 
	userInfo:infoDict 
	deliverImmediately:YES];
    NSLog(@"post notification \"BaramDictionaryAddNewWord Notification\" %@", word);

    [infoDict release];
  } else {
    [self launchSharedApplication:@"BaramDictionary.app"
	  withNotification:infoDict];
  }
}

#pragma mark -
#pragma mark shortcut event

- (BOOL)handleShortcutEvent:(NSInteger)type {
  DLOG(@"handleShortcutEvent:%d", type);

  if (!self.remapperEnabled || !self.activated)
    return NO;

  // for VMWare Fusion 3 Unity mode
  if ([[[self client] bundleIdentifier] hasPrefix:@"com.vmware.proxyApp"])
    return NO;

  // if (!self.eventHandled) {
  //   // for content of Safari
  //   NSRect rect;
  //   [[self client] attributesForCharacterIndex:0
  // 			   lineHeightRectangle:&rect];
  //   NSLog(@"length %d, (%f,%f)", 
  // 	  [[self client] length],
  // 	  rect.origin.x,
  // 	  rect.origin.y);

  //   if ((rect.origin.x == 0) && (rect.origin.y == 0)) 
  //     return NO;
  // }

  switch (type) {
  case kBIMSwitchShortcut:
    [self hangulKey:nil];
    break;
  case kBIMHanjaShortcut:
    [self hanjaKey:nil];
    break;
  case kBIMJapaneseShortcut:
    [self japaneseKey:nil];
    break;
  default:
    NSLog(@"BIM:Unrecognized shorcut type:%d", type);
    return NO;
  }

  return YES;
}

- (void)hangulKey:(id)sender {
  DLOG(@"- hangulKey:%08x", sender);
	
  NSString *currentInputMode = [self inputMode];
	
  if ([currentInputMode isEqual:kBIMEnglishMode]) 
    [[self client] selectInputMode:kBIMHangulMode];
  else if ([currentInputMode isEqual:kBIMHangulMode])
    [[self client] selectInputMode:kBIMEnglishMode];
  else 
    [[self client] selectInputMode:(NSString*)[self prevInputMode]];
}

- (void)hanjaKey:(id)sender {
  DLOG(@"BIM: hanjaKey is pushed.");
  [dictionaryEngine setProgressive:NO];

  NSRange selectedRange = [self.currentClient selectedRange];
  NSAttributedString *string = [self.currentClient attributedSubstringFromRange:selectedRange];

  if ([string length]) {
    // make marked region
    [self.currentClient setMarkedText:string
		       selectionRange:NSMakeRange(0, [string length])
		     replacementRange:selectedRange];

    [[self composedStringBuffer] setString:[string string]];
    self.selectedString = [NSString stringWithString:[self composedStringBuffer]];
  } else {
    self.selectedString = [NSString stringWithString:[[self originalString:nil] string]];
  }

  [self showCandidates];
}

- (void)japaneseKey:(id)sender {
  DLOG(@"BIM: japaneseKey is pushed.");

  NSString *currentInputMode = [self inputMode];

  if ([currentInputMode isEqual:kBIMHiraganaMode])
    [[self client] selectInputMode:kBIMKatakanaMode];
  else
    [[self client] selectInputMode:kBIMHiraganaMode];
}

#pragma mark - 
#pragma mark private functions

- (void)readProperties:(NSNotification *)note {
  DLOG(@"%@", note);

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults synchronize];

  self.hangulCommitByWord = [defaults boolForKey:kBIMHangulCommitByWordKey];
  self.bypassWithOption = [defaults boolForKey:kBIMEnglishBypassWithOptionKey];
  self.parenEnabled = YES;
  self.parenStyle = [defaults integerForKey:kBIMHanjaParenStyleKey];

  // shortcut
  self.shortcuts = [defaults objectForKey:kBIMShortcutsKey];

  if ([triggerEngine enabledForClient:[[self client] bundleIdentifier]] &&
      [self TSMDocumentAccessTest]) {
    if (!self.trigger)
      self.trigger = triggerEngine;
  } else {
    [self.trigger release];
    self.trigger = nil;
  }

  NSDictionary *indicatorProperties = [defaults objectForKey:kBIMIndicatorPropertiesKey];
  if ([[indicatorProperties objectForKey:kBIMIndicatorEnableKey] boolValue]) {
    if (!self.indicator) {
      BIMModeIndicator *_indicator = [[BIMModeIndicator alloc] init];
      self.indicator = _indicator;
      [_indicator release];
    }
  } else {
    [self.indicator release];
    self.indicator = nil;
  }

  self.attributedStringEnabled = [defaults boolForKey:kBIMAttributedStringEnabledKey];
  self.fontsAttributes = [defaults objectForKey:kBIMFontsAttributesKey];

  self.viMode = [[defaults objectForKey:kBIMVIModeKey] boolValue];
  self.remapperEnabled = YES;
  for (id app in [defaults objectForKey:kBIMAppSpecificSetupKey]) {
    if ([[[self client] bundleIdentifier] 
	  isEqual:[app objectForKey:@"bundleIdentifier"]]) {
      self.viMode = [[app objectForKey:@"viMode"] boolValue];
      self.remapperEnabled = [[app objectForKey:@"remapper"] boolValue];
      break;
    }
  }

  [hic setRomanKeyboard:[defaults integerForKey:kBIMEnglishKeyboardKey]];
  [hic setHangulKeyboard:[defaults integerForKey:kBIMHangulKeyboardKey]];
  [hic setCommitByWord:self.hangulCommitByWord];
  [hic setOrderCorrection:[defaults boolForKey:kBIMHangulOrderCorrectionKey]];

  [self overrideKeyboardLayout];

  NSDictionary *candidatesProperties = [defaults objectForKey:kBIMCandidatesPanelPropertiesKey];
  _candidatesPanelType         = [[candidatesProperties objectForKey:kBIMCandidatesPanelTypeKey] integerValue];
  _candidatesFontSize          = [[candidatesProperties objectForKey:kBIMCandidatesFontSizeKey] integerValue];
	
}

- (void)overrideKeyboardLayout {
  BaramRomanKeyboardType romanKeyboard = [hic romanKeyboard];

  switch (romanKeyboard) {
  case BaramRomanKeyboardTypeUS:
    [[self client] overrideKeyboardWithKeyboardNamed:kUSKeylayout];
    break;
  case BaramRomanKeyboardTypeDvorak:
    [[self client] overrideKeyboardWithKeyboardNamed:kDvorakKeylayout];
    break;
  case BaramRomanKeyboardTypeDvorakQwerty:
    [[self client] overrideKeyboardWithKeyboardNamed:kDvorakQwertyKeylayout];
    break;
  case BaramRomanKeyboardTypeGerman:
    [[self client] overrideKeyboardWithKeyboardNamed:kGermanKeylayout];
    break;
  default:
    NSLog(@"BIM: unknown roman keyboard layout = %d", romanKeyboard);
    break;
  }
}

- (void)launchSharedApplication:(NSString *)appName 
	       withNotification:(NSDictionary *)notification {
  DLOG(@"BIM: launchSharedApplication:%@ withNotification:%@", appName, notification);

  if (notification)
    [[[NSWorkspace sharedWorkspace] notificationCenter]
      addObserver:self
	 selector:@selector(sharedApplicationDidLaunch)
	     name:NSWorkspaceDidLaunchApplicationNotification
	   object:nil];

  NSString *application = [[[NSBundle mainBundle] sharedSupportPath]
			    stringByAppendingPathComponent:appName];

  [[NSWorkspace sharedWorkspace] launchApplication:application];

  _sharedApplicationNotification = notification;
}

- (void)sharedApplicationDidLaunch {
  DLOG(@"BIM: sharedApplicationDidLaunch");

  [[[NSWorkspace sharedWorkspace] notificationCenter]
    removeObserver:self
    name:NSWorkspaceDidLaunchApplicationNotification
    object:nil];

  if (_sharedApplicationNotification) {
    NSDistributedNotificationCenter *nc = [NSDistributedNotificationCenter defaultCenter];
  
    [nc postNotificationName:kBaramDictionaryAddNewWordNotification
	object:nil 
	userInfo:_sharedApplicationNotification
	deliverImmediately:YES];

    [_sharedApplicationNotification release];
    _sharedApplicationNotification = nil;
  }
}

- (void)showIndicator:(id)sender {
  DLOG(@"BIM: showIndicator");

  NSRect rect;
  
  [self.currentClient attributesForCharacterIndex:0
			 lineHeightRectangle:&rect];
 
  if ((rect.origin.x != 0) && (rect.origin.y != 0)) {
    [self.indicator changeMode:[self inputMode]];
    [self.indicator show:NSMakePoint(rect.origin.x, rect.origin.y + 15)
		   level:[self.currentClient windowLevel]];
  }
}

- (BOOL)TSMDocumentAccessTest {
  //FIXME : use IMKTextInput supportsProperty than selectedRange on Mac OS X 10.6
  //[[self client] supportsProperty:kTSMDocumentSupportDocumentAccessPropertyTag];

  NSRange range = [[self client] selectedRange];
  NSRange notfound = NSMakeRange(NSNotFound, NSNotFound);
	
  if ((range.location == notfound.location) && (range.length == notfound.length))
    return NO;

  // firefox does not support TSM for trigger
  //if ([[[self client] bundleIdentifier] isEqual:@"org.mozilla.firefox"])
  //  return NO;

  return YES;
}

#pragma mark -
#pragma mark getter and setter

- (NSMutableString *)inputMode {
  if (!_inputMode) {
    _inputMode = [[NSMutableString alloc] init];
  }

  return _inputMode;
}

- (void)setInputMode:(NSString *)mode {
  if ([[self inputMode] isEqual:kBIMEnglishMode] || 
      [[self inputMode] isEqual:kBIMHangulMode]) {
    [self setPrevInputMode:[self inputMode]];
  }

  [[self inputMode] setString:mode];
  [self showIndicator:nil];
}

- (NSMutableString *)prevInputMode {
  if (!_prevInputMode) {
    _prevInputMode = [[NSMutableString alloc] init];
  }

  return _prevInputMode;
}

- (void)setPrevInputMode:(NSString *)mode {
  [[self prevInputMode] setString:mode];
}

- (BOOL)commitByWord {
  if ([[self inputMode] isEqual:kBIMEnglishMode]) {
    return NO;
  } else if ([[self inputMode] isEqual:kBIMHangulMode]) {
    return self.hangulCommitByWord;
  } else if ([[self inputMode] isEqual:kBIMHiraganaMode]) {
    return YES;
  } else if ([[self inputMode] isEqual:kBIMKatakanaMode]) {
    return YES;
  } else {
    return NO;
  }
 }

#pragma mark -
#pragma mark private functions

- (void)setInitialMode {
  NSArray *remapperArray = [[NSUserDefaults standardUserDefaults] arrayForKey:kBIMAppSpecificSetupKey];
  ApplicationDelegate *_delegate = [NSApp delegate];

  for (id entry in remapperArray) {
    if ([[[self client] bundleIdentifier]
	  hasPrefix:[entry objectForKey:@"bundleIdentifier"]]) {
      switch ([[entry objectForKey:@"initialMode"] intValue]) {
      case 0 : [_delegate selectInputMode:kBIMEnglishMode];  break;
      case 1 : [_delegate selectInputMode:kBIMHangulMode];   break;
      case 3 : [_delegate selectInputMode:kBIMHiraganaMode]; break;
      case 4 : [_delegate selectInputMode:kBIMKatakanaMode]; break;
      }
    }
  }
}

- (NSDictionary *)attributes {
  if (self.attributedStringEnabled)
    return [self.fontsAttributes objectForKey:[self inputMode]];
  else
    return nil;
}

@end
