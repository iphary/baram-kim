// -*- mode:objc -*-
//
//  InputController.h
//  Baram
//
//  Created by Ha-young Jeong on 08. 04. 30.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

@class BaramHangul;
@class BIMServer;
@class BIMModeIndicator;
@class DictionaryEngine;
@class JapaneseEngine;
@class BIMTrigger;

extern BIMServer        *server;
extern IMKCandidates    *candidatesEngine;
extern DictionaryEngine *dictionaryEngine;
extern JapaneseEngine   *japaneseEngine;
extern BIMTrigger       *triggerEngine;

@interface InputController : IMKInputController <IMKStateSetting> {
  // Hangul Input Context
  BaramHangul         *hic;

  id <IMKTextInput, NSObject> currentClient;

  NSMutableString     *_inputMode;
  NSMutableString     *_prevInputMode;

  BOOL                activated;
  BOOL                eventHandled;
  NSArray             *shortcuts;

  // fonts attributes
  BOOL                attributedStringEnabled;
  NSDictionary        *fontsAttributes;

  NSPoint             _previousMouseLocation;
	
  // candidates list
  BOOL                _showCandidates;
  NSInteger           _candidatesPanelType;
  NSInteger           _candidatesFontSize;
	
  BOOL                hangulCommitByWord;

  // Buffers
  NSMutableString*    _composedStringBuffer; // final composed string
	
  // for dictionary search
  NSString            *selectedString;

  id                  remapper;
  BIMTrigger          *trigger;

  BOOL                remapperEnabled;
  NSDictionary        *_sharedApplicationNotification;

  BIMModeIndicator    *indicator;

  // option
  BOOL                viMode;
  BOOL                bypassWithOption;
  BOOL                parenEnabled;
  NSInteger           parenStyle;
}

@property (nonatomic, assign) id <IMKTextInput, NSObject> currentClient;

@property (nonatomic, assign) BOOL     activated;
@property (nonatomic, assign) BOOL     eventHandled;
@property (nonatomic, assign) BOOL     remapperEnabled;

@property (nonatomic, retain) BIMModeIndicator *indicator;
@property (nonatomic, retain) BIMTrigger *trigger;

@property (nonatomic, retain) NSArray  *shortcuts;
@property (nonatomic, retain) NSString *selectedString;

// optional
@property (nonatomic, assign) BOOL viMode;
@property (nonatomic, assign) BOOL bypassWithOption;
@property (nonatomic, assign) BOOL parenEnabled;
@property (nonatomic, assign) NSInteger parenStyle;
@property (nonatomic, assign) BOOL hangulCommitByWord;
@property (nonatomic, assign) BOOL         attributedStringEnabled;
@property (nonatomic, retain) NSDictionary *fontsAttributes;

// input mode control
- (NSMutableString *)inputMode;
- (void)setInputMode:(NSString *)mode;
- (NSMutableString *)prevInputMode;
- (void)setPrevInputMode:(NSString *)mode;

// composed buffers
- (NSMutableString *)composedStringBuffer;

// handle event
- (BOOL)handleRoman:(NSString *)string keyCode:(unsigned short)keyCode modifiers:(NSUInteger)modifiers client:(id)sender;
- (BOOL)handleHangul:(NSString *)string keyCode:(unsigned short)keyCode modifiers:(NSUInteger)modifiers client:(id)sender;

// Methods
-(void)updateComposition;
-(void)cancelComposition;
-(void)showCandidates;
-(void)updateCandidates;

// menu selector
-(void)showAboutPanel:(id)sender;
-(void)showDictionary:(id)sender;
-(void)showPreferences:(id)sender;
-(void)reloadDictionary:(id)sender;
-(void)checkUpdates:(id)sender;

// Hangul Input Context Processing
-(BOOL)backspace;

// shortcut handle interface
- (BOOL)handleShortcutEvent:(NSInteger)type;
- (void)hangulKey:(id)sender;
- (void)hanjaKey:(id)sender;
- (void)japaneseKey:(id)sender;

@end
