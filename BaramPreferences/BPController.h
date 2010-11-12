//
//  BPController.h
//  BaramPreference
//
//  $Id$
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "../common/BIMUserDefaults.h"
#import "../DBPrefs/DBPrefsWindowController.h"

@class ShortcutRecorder;

@interface BPController : DBPrefsWindowController {
  IBOutlet NSView            *_generalPrefsView;
  IBOutlet NSView            *_shortcutsPrefsView;
  IBOutlet NSView            *_advancedPrefsView;
  IBOutlet NSView            *_dictionaryPrefsView;
  IBOutlet NSView            *_triggerPrefsView;
  IBOutlet NSView            *_appsPrefsView;
  IBOutlet NSView            *_updatePrefsView;

  // general properties
  IBOutlet NSPopUpButton     *_romanKeyboardLayout;
  IBOutlet NSPopUpButton     *_hangulKeyboardLayout;
  IBOutlet NSButton          *_hangulOrderCorrection;
  IBOutlet NSButton          *_bypassWithOption;
  IBOutlet NSPopUpButton     *_inputBySyllable;

  // shortcuts properties
  IBOutlet NSArrayController *_shortcutsArrayController;
  IBOutlet NSTableView       *_shortcutsTableView;

  // shortcutEditor window
  IBOutlet NSWindow          *_shortcutEditorWindow;
  IBOutlet NSButton          *_shortcutEditorOK;
  IBOutlet NSPopUpButton     *_shortcutEditorType;
  IBOutlet NSPopUpButton     *_shortcutEditorUserDefined;
  IBOutlet ShortcutRecorder  *_shortcutEditorRecorder;
  IBOutlet NSPopUpButton     *_shortcutEditorFlagsOption;

  // advanced properties
  IBOutlet NSPopUpButton     *_hanjaInputStyle;
  IBOutlet NSPopUpButton     *_candidatesPanelType;
  IBOutlet NSPopUpButton     *_candidatesFontSize;
  IBOutlet NSButton          *_indicatorEnable;
  IBOutlet NSButton          *_viMode;

  // dictionary properties
  IBOutlet NSArrayController *_dictionaryArrayController;
  IBOutlet NSTableView       *_dictionaryTableView;

  // trigger properties
  IBOutlet NSButton          *_enableTrigger;
  IBOutlet NSButton          *_alertTrigger;
  IBOutlet NSArrayController *_triggerArrayController;
  IBOutlet NSTableView       *_triggerTableView;

  // application properties
  IBOutlet NSArrayController *_appsArrayController;
  IBOutlet NSTableView       *_appsTableView;

  // update properties
  IBOutlet NSPopUpButton     *_updatePeriod;
  IBOutlet NSTextField       *_lastCheck;

  NSOpenPanel                *_dictionaryPanel;
  NSOpenPanel                *_appsPanel;

  BIMUserDefaults            *_defaults;
}

// advanced
- (IBAction)restartRemapper:(id)sender;

// shortcuts
- (IBAction)insertShortcut:(id)sender;
- (IBAction)shortcutEditorCancel:(id)sender;
- (IBAction)shortcutEditorOK:(id)sender;

// dictionary
- (IBAction)installDictionary:(id)sender;
- (IBAction)uninstallDictionary:(id)sender;
- (IBAction)openUserDictionaryFolder:(id)sender;

// trigger
- (IBAction)insertTrigger:(id)sender;

// applications
- (IBAction)insertApp:(id)sender;

// update
- (IBAction)updateCheckNow:(id)sender;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

// functions
- (void)update;
- (void)shortcutEditorForDictionary:(NSMutableDictionary *)dictionary;
- (NSMutableDictionary *)dictionaryForShortcutEditor;
- (NSString *)stringForShortcut:(NSDictionary *)shortcut;
- (void)setLastCheckDate:(NSDate*)date;

// delegate function
- (void)filePanelDidEnd:(NSOpenPanel*)sheet
	     returnCode:(int)returnCode contextInfo:(void*)contextInfo;

@end
