//
//  BPController.m
//  BaramPreference
//
//  Created by Ha-young Jeong on 08. 05. 10.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BPController.h"
#import "ShortcutRecorder.h"
#import "../common/BIMConstants.h"
#import "../FilenameFormatter/FilenameFormatter.h"

#define MyPrivateTableViewDataType @"DictionaryDataType"

@implementation BPController

- (id)initWithWindowNibName:(NSString *)windowNibName
{
  if (self = [super initWithWindowNibName:windowNibName]) {
    _defaults = [[BIMUserDefaults alloc] init];
  }
  
  return self;
}

- (void)dealloc
{
  [_defaults release];

  [super dealloc];
}

- (void)awakeFromNib
{
  [[self window] setDelegate:self];

  // filename formatter
  [[[[_appsTableView tableColumns] objectAtIndex:1] dataCell] setFormatter:[[FilenameFormatter alloc] init]];
  [[[[_dictionaryTableView tableColumns] objectAtIndex:1] dataCell] setFormatter:[[FilenameFormatter alloc] init]];

  [self update];
}

- (void)setupToolbar
{
  [self addView:_generalPrefsView
        label:NSLocalizedString(@"General", @"General")
        image:[NSImage imageNamed:@"General"]];
  [self addView:_advancedPrefsView
        label:NSLocalizedString(@"Advanced", @"Advanced")
        image:[NSImage imageNamed:@"Advanced"]];
  [self addView:_shortcutsPrefsView
        label:NSLocalizedString(@"Shortcuts", @"Shortcuts")
        image:[NSImage imageNamed:@"Shortcuts"]];
  [self addView:_dictionaryPrefsView
        label:NSLocalizedString(@"Dictionary", @"Dictionary")
        image:[NSImage imageNamed:@"Dictionary"]];
  [self addView:_triggerPrefsView
        label:NSLocalizedString(@"Trigger", @"Trigger")
        image:[NSImage imageNamed:@"Trigger"]];
  [self addView:_appsPrefsView
        label:NSLocalizedString(@"Application", @"Application")
        image:[NSImage imageNamed:@"Application"]];
  [self addView:_updatePrefsView
        label:NSLocalizedString(@"Update", @"Update")
        image:[NSImage imageNamed:@"Update"]];
}

- (void)windowWillClose:(NSNotification *)notification
{
  [[NSApplication sharedApplication] terminate:self];
}

// advanced
- (IBAction)restartRemapper:(id)sender
{
  NSLog(@"kill remapper");

  [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall"
	  arguments:[NSArray arrayWithObjects:@"-9", @"BaramRemapper", nil]];
}

// shorcut property
- (IBAction)insertShortcut:(id)sender
{
  NSInteger add;

  [_shortcutEditorOK setTitle:@"Add"];

  [NSApp beginSheet:_shortcutEditorWindow
	 modalForWindow:[self window]
	 modalDelegate:self
	 didEndSelector:nil
	 contextInfo:nil];

  add = [NSApp runModalForWindow:_shortcutEditorWindow];
  
  if (add)
    [_shortcutsArrayController addObject:[self dictionaryForShortcutEditor]];

  [NSApp endSheet:_shortcutEditorWindow];
  [_shortcutEditorWindow orderOut:self];
}

- (IBAction)modifyShortcut:(id)sender
{
  NSInteger modify;
  NSUInteger index = [_shortcutsArrayController selectionIndex];
  NSMutableDictionary *shortcut = [[_shortcutsArrayController selectedObjects] objectAtIndex:0];
  [self shortcutEditorForDictionary:shortcut];

  [_shortcutEditorOK setTitle:@"Modify"];

  [NSApp beginSheet:_shortcutEditorWindow
	 modalForWindow:[self window]
	 modalDelegate:self
	 didEndSelector:nil
	 contextInfo:nil];

  modify = [NSApp runModalForWindow:_shortcutEditorWindow];
  
  if (modify) {
    [_shortcutsArrayController removeObject:shortcut];
    [_shortcutsArrayController insertObject:[self dictionaryForShortcutEditor]
			       atArrangedObjectIndex:index];
  }

  [NSApp endSheet:_shortcutEditorWindow];
  [_shortcutEditorWindow orderOut:self];
}

- (IBAction)shortcutEditorCancel:(id)sender
{
  [NSApp stopModalWithCode:NO];
}

- (IBAction)shortcutEditorOK:(id)sender
{
  [NSApp stopModalWithCode:YES];
}

- (IBAction)installDictionary:(id)sender
{
  NSArray *fileTypes = [[NSArray alloc] initWithObjects:@"all", @"hangul", @"english", @"japanese", nil];
	
  _dictionaryPanel = [NSOpenPanel openPanel];
		
  [_dictionaryPanel setCanChooseDirectories:NO];
  [_dictionaryPanel setCanChooseFiles:YES];
  [_dictionaryPanel setCanCreateDirectories:YES];
  [_dictionaryPanel setAllowsMultipleSelection:NO];
	
  [_dictionaryPanel beginSheetForDirectory:nil file:nil types:fileTypes modalForWindow:[super window] modalDelegate:self didEndSelector:@selector(filePanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
  [fileTypes release];
}

- (IBAction)uninstallDictionary:(id)sender
{
  for (id dictionary in [_dictionaryArrayController selectedObjects]) {
    if ([[dictionary objectForKey:@"defaults"] boolValue]) {
      [dictionary setObject:[NSNumber numberWithBool:NO]
		  forKey:@"defaults"];
      continue;
    }

    NSString *filename = [dictionary objectForKey:@"filename"];
    [[NSFileManager defaultManager] removeItemAtPath:filename
				    error:nil];
  }

  [self update];
}

- (IBAction)openUserDictionaryFolder:(id)sender
{
  NSString *dictionaryPath = [NSString stringWithFormat:@"%@/Library/Dictionaries/Baram", NSHomeDirectory(), nil];

  [[NSWorkspace sharedWorkspace] openFile:dictionaryPath];
}

- (IBAction)insertTrigger:(id)sender
{
  NSMutableDictionary* newObject = [[NSMutableDictionary alloc] init];
  [newObject setObject:@"" forKey:@"triggerString"];

  NSUInteger index = [_triggerArrayController selectionIndex];
    
  if (index == NSNotFound) {
    index = [[_triggerArrayController content] count];
  }
	
  [_triggerArrayController setSelectsInsertedObjects:YES];
  [_triggerArrayController insertObject:newObject atArrangedObjectIndex:index];
  [_triggerTableView editColumn:0 row:index withEvent:nil select:YES];
	
  [newObject release];
}

- (IBAction)insertApp:(id)sender
{
  NSArray *fileTypes = [[NSArray alloc] initWithObjects:@"app", nil];
	
  _appsPanel = [NSOpenPanel openPanel];
		
  [_appsPanel setCanChooseDirectories:NO];
  [_appsPanel setCanChooseFiles:YES];
  [_appsPanel setCanCreateDirectories:YES];
  [_appsPanel setAllowsMultipleSelection:NO];
	
  [_appsPanel beginSheetForDirectory:@"/Applications" 
              file:nil 
              types:fileTypes 
              modalForWindow:[super window] 
              modalDelegate:self 
              didEndSelector:@selector(filePanelDidEnd:returnCode:contextInfo:) 
              contextInfo:nil];
  [fileTypes release];
}

- (IBAction)updateCheckNow:(id)sender
{
  NSLog(@"Baram: updateCheckNow %@", sender);
  NSDate *currentDate = [[NSDate alloc] init];

  [[NSWorkspace sharedWorkspace] launchApplication:@"BaramUpdater.app"];
	
  [self setLastCheckDate:currentDate];
	
  [currentDate release];
}

- (IBAction)cancel:(id)sender
{
  [[self window] close];
}

- (IBAction)save:(id)sender
{
  // general properties
  [_defaults setInteger:[[_romanKeyboardLayout selectedItem] tag] 
	     forKey:kBIMEnglishKeyboardKey];
  [_defaults setInteger:[[_hangulKeyboardLayout selectedItem] tag]
	     forKey:kBIMHangulKeyboardKey];
  [_defaults setBool:[_hangulOrderCorrection state] 
	     forKey:kBIMHangulOrderCorrectionKey];
  [_defaults setBool:[[_inputBySyllable selectedItem] tag]
	     forKey:kBIMHangulCommitByWordKey];
  [_defaults setBool:[_bypassWithOption state]
	     forKey:kBIMEnglishBypassWithOptionKey];

  // shortcuts properties
  [_defaults setObject:[_shortcutsArrayController content]
	     forKey:kBIMShortcutsKey];

  // advanced properties
  [_defaults setInteger:[[_hanjaInputStyle selectedItem] tag]
	     forKey:kBIMHanjaParenStyleKey];
  NSDictionary *candidatesProperties = 
    [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:[[_candidatesPanelType selectedItem] tag]],
		  kBIMCandidatesPanelTypeKey,
		  [NSNumber numberWithInteger:[[_candidatesFontSize selectedItem] tag]],
		  kBIMCandidatesFontSizeKey, nil];
  [_defaults setObject:candidatesProperties
            forKey:kBIMCandidatesPanelPropertiesKey];

  // mode indicator properties
  NSDictionary *indicatorProperties =
    [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:[_indicatorEnable state]], kBIMIndicatorEnableKey, nil];
  [_defaults setObject:indicatorProperties
	     forKey:kBIMIndicatorPropertiesKey];

  [_defaults setObject:[NSNumber numberWithBool:[_viMode state]]
	     forKey:kBIMVIModeKey];
		  
  // dictionary properties
  NSMutableArray *disabledDictionaries = [[NSMutableArray alloc] init];
  for (id dictionary in [_dictionaryArrayController content]) {
    if (![[dictionary objectForKey:kBIMDictionaryEnabledKey] boolValue]) 
      [disabledDictionaries addObject:[dictionary objectForKey:kBIMDictionaryFilenameKey]];
  }
  [_defaults setObject:disabledDictionaries
	    forKey:kBIMDisabledDictionariesKey];
  [disabledDictionaries release];

  // trigger properties
  [_defaults setObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:[_enableTrigger state]], kBIMTriggerEnableKey,
				     [NSNumber numberWithBool:[_alertTrigger state]], kBIMTriggerAlertKey,
				     [_triggerArrayController content], kBIMTriggerArrayKey, nil]
	     forKey:kBIMTriggerPropertiesKey];

  // application properties
  [_defaults setObject:[_appsArrayController content]
	     forKey:kBIMAppSpecificSetupKey];

  // update properties
  [_defaults setInteger:[[_updatePeriod selectedItem] tag]
	     forKey:kBIMUpdateCheckPeriodKey];
  
  [_defaults synchronize];

  [[NSDistributedNotificationCenter defaultCenter]
    postNotificationName:kBIMUserDefaultsDidChangeNotification
		  object:nil
		userInfo:nil
      deliverImmediately:YES];

  [[self window] close];
}

-(void)update
{
  [_defaults synchronize];

  // general properties
  [_romanKeyboardLayout selectItemWithTag:[_defaults integerForKey:kBIMEnglishKeyboardKey]];
  [_hangulKeyboardLayout selectItemWithTag:[_defaults integerForKey:kBIMHangulKeyboardKey]];
  [_hangulOrderCorrection setState:[_defaults boolForKey:kBIMHangulOrderCorrectionKey]];
  [_inputBySyllable selectItemWithTag:[_defaults integerForKey:kBIMHangulCommitByWordKey]];
  [_bypassWithOption setState:[_defaults boolForKey:kBIMEnglishBypassWithOptionKey]];
  
  // shortcuts
  [_shortcutsArrayController setContent:[_defaults arrayForKey:kBIMShortcutsKey]];
  [_shortcutsArrayController setSelectsInsertedObjects:YES];

  // addvanced properties
  [_hanjaInputStyle 
    selectItemWithTag:[_defaults integerForKey:kBIMHanjaParenStyleKey]];
  NSDictionary *candidateProperty = [_defaults objectForKey:kBIMCandidatesPanelPropertiesKey];
  [_candidatesPanelType 
    selectItemWithTag:[[candidateProperty objectForKey:kBIMCandidatesPanelTypeKey] integerValue]];
  [_candidatesFontSize
    selectItemWithTag:[[candidateProperty objectForKey:kBIMCandidatesFontSizeKey] integerValue]];

  NSDictionary *indicatorProperty = [_defaults objectForKey:kBIMIndicatorPropertiesKey];
  [_indicatorEnable
    setState:[[indicatorProperty objectForKey:kBIMIndicatorEnableKey] boolValue]];
  [_viMode setState:[[_defaults objectForKey:kBIMVIModeKey] boolValue]];

  // dictionary properties
  [[_dictionaryArrayController content] removeAllObjects];

  // local domain
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
						       NSLocalDomainMask,
						       YES);
  
  for (id path in paths) {
    // add defaults dictionary
    NSString *file;
    NSString *dictionaryPath = [[path stringByAppendingPathComponent:@"Dictionaries"] 
				 stringByAppendingPathComponent:@"Baram"];
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:dictionaryPath];
    
    while (file = [dirEnum nextObject]) {
      NSInteger mode;

      if ([[file pathExtension] isEqualToString: @"all"])
	mode = kBIMDictionaryForAllMode;
      else if ([[file pathExtension] isEqualToString: @"hangul"])
	mode = kBIMDictionaryForHangulMode;
      else if ([[file pathExtension] isEqualToString: @"roman"])
	mode = kBIMDictionaryForRomanMode;
      else if ([[file pathExtension] isEqualToString: @"japanese"])
	mode = kBIMDictionaryForJapaneseMode;
      else 
	mode = kBIMDictionaryForNilMode;

      if (mode != kBIMDictionaryForNilMode) {
	NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"default",
							 [NSNumber numberWithBool:YES], @"enable",
							 [dictionaryPath stringByAppendingPathComponent:file], @"filename", 
							 [NSNumber numberWithInteger:mode], @"mode", 
							 [NSNumber numberWithInteger:0], @"domain", nil];
	[_dictionaryArrayController addObject:item];
      }
    }
  }

  // user domain
  paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
					      NSUserDomainMask,
					      YES);
  
  for (id path in paths) {
    // add defaults dictionary
    NSString *file;
    NSString *dictionaryPath = [[path stringByAppendingPathComponent:@"Dictionaries"] 
				 stringByAppendingPathComponent:@"Baram"];
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:dictionaryPath];
    
    while (file = [dirEnum nextObject]) {
      NSInteger mode;

      if ([[file pathExtension] isEqualToString: @"all"])
	mode = kBIMDictionaryForAllMode;
      else if ([[file pathExtension] isEqualToString: @"hangul"])
	mode = kBIMDictionaryForHangulMode;
      else if ([[file pathExtension] isEqualToString: @"roman"])
	mode = kBIMDictionaryForRomanMode;
      else if ([[file pathExtension] isEqualToString: @"japanese"])
	mode = kBIMDictionaryForJapaneseMode;
      else 
	mode = kBIMDictionaryForNilMode;

      if (mode != kBIMDictionaryForNilMode) {
	NSMutableDictionary *item = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"default",
							 [NSNumber numberWithBool:YES], @"enable",
							 [dictionaryPath stringByAppendingPathComponent:file], @"filename", 
							 [NSNumber numberWithInteger:mode], @"mode",
							 [NSNumber numberWithInteger:1], @"domain", nil];
	[_dictionaryArrayController addObject:item];
      }
    }
  }
  
  // disabled dictionary
  for (id disabled in [_defaults objectForKey:kBIMDisabledDictionariesKey]) {
    for (id dictionary in [_dictionaryArrayController content]) {
      if ([[dictionary objectForKey:@"filename"] isEqual:disabled]) {
	[dictionary setObject:[NSNumber numberWithBool:NO]
		    forKey:@"enable"];
      }
    }
  }

  // trigger properties
  NSDictionary *triggerProperty = [_defaults objectForKey:kBIMTriggerPropertiesKey];

  [_enableTrigger 
    setState:[[triggerProperty objectForKey:kBIMTriggerEnableKey] boolValue]];
  [_alertTrigger
    setState:[[triggerProperty objectForKey:kBIMTriggerAlertKey] boolValue]];

  [[_triggerArrayController content] removeAllObjects];
  [_triggerArrayController setSelectsInsertedObjects:NO];
  [_triggerArrayController addObjects:[triggerProperty objectForKey:kBIMTriggerArrayKey]];
  [_triggerArrayController setSelectsInsertedObjects:YES];

  // application properties
  [[_appsArrayController content] removeAllObjects];
  [_appsArrayController setSelectsInsertedObjects:NO];
  [_appsArrayController addObjects:[_defaults arrayForKey:kBIMAppSpecificSetupKey]];

  // update properties
  [_updatePeriod
    selectItemWithTag:[_defaults integerForKey:kBIMUpdateCheckPeriodKey]];
  NSDate *lastCheckDate = [_defaults objectForKey:kBIMUpdateLastCheckKey];
  [self setLastCheckDate:lastCheckDate];
}

- (void)shortcutEditorForDictionary:(NSMutableDictionary *)dictionary
{
  [_shortcutEditorType selectItemWithTag:[[dictionary objectForKey:kShortcutTypeKey] integerValue]];
  [_shortcutEditorUserDefined selectItemWithTag:[[dictionary objectForKey:kShortcutUserDefinedKey] integerValue]];
  [_shortcutEditorRecorder setKeyCode:[[dictionary objectForKey:kCGEventKeyCodeKey] integerValue]];
  [_shortcutEditorRecorder setModifierFlags:[[dictionary objectForKey:kCGEventFlagsKey] integerValue]];
  [_shortcutEditorFlagsOption selectItemWithTag:[[dictionary objectForKey:kCGEventFlagsOptionKey] integerValue]];
}

- (NSMutableDictionary *)dictionaryForShortcutEditor
{
  NSInteger type;
  NSInteger keyCode;
  NSInteger flags;
  NSInteger flagsMask;
  NSInteger flagsOption = [[_shortcutEditorFlagsOption selectedItem] tag];

  // predefined shorcut
  switch ([[_shortcutEditorUserDefined selectedItem] tag]) {
  case 1 : /* command */
    flags = NX_COMMANDMASK | NX_DEVICELCMDKEYMASK | NX_DEVICERCMDKEYMASK;
    type = kCGEventFlagsChanged;
    break;
  case 2 : /* control */
    flags = NX_CONTROLMASK | NX_DEVICELCTLKEYMASK | NX_DEVICERCTLKEYMASK;
    type = kCGEventFlagsChanged;
    break;
  case 3 : /* option */
    flags = NX_ALTERNATEMASK | NX_DEVICELALTKEYMASK | NX_DEVICERALTKEYMASK;
    type = kCGEventFlagsChanged;
    break;
  case 4 : /* capslock */
    flags = NX_ALPHASHIFTMASK;
    type = kCGEventFlagsChanged;
    break;
  case 5 : /* right enter */
    keyCode = 0x04c;
    flags = 0x0;
    type = kCGEventKeyDown;
    break;
  case 6 : /* hangul key */
    keyCode = 0x068;
    flags = 0x0;
    type = kCGEventKeyDown;
    break;
  case 7 : /* hanja key */
    keyCode = 0x066;
    flags = 0x0;
    type = kCGEventKeyDown;
    break;

  default : /* user defined */
    type = kCGEventKeyDown;

    keyCode = [_shortcutEditorRecorder keyCode];
    flags   = [_shortcutEditorRecorder modifierFlags];
  }

  if (flags) {
    if (flagsOption == kCGEventFlagsLeft)
      flagsMask = LEFTMODMASK;
    else if (flagsOption == kCGEventFlagsRight)
      flagsMask = RIGHTMODMASK;
    else
      flagsMask = ANYMODMASK;
  }

  // create dictionary object
  NSMutableDictionary *newShortcut = [NSMutableDictionary dictionary];
  [newShortcut setObject:[NSNumber numberWithBool:YES]
	       forKey:kShortcutEnableKey];
  [newShortcut setObject:[NSNumber numberWithInteger:[[_shortcutEditorType selectedItem] tag]]
	       forKey:kShortcutTypeKey];
  [newShortcut setObject:[NSNumber numberWithInteger:[[_shortcutEditorUserDefined selectedItem] tag]]
	       forKey:kShortcutUserDefinedKey];
  [newShortcut setObject:[NSNumber numberWithInteger:type]
	       forKey:kCGEventTypeKey];
  [newShortcut setObject:[NSNumber numberWithInteger:keyCode]
	       forKey:kCGEventKeyCodeKey];
  [newShortcut setObject:[NSNumber numberWithInteger:flags]
	       forKey:kCGEventFlagsKey];
  [newShortcut setObject:[NSNumber numberWithInteger:flagsOption]
	       forKey:kCGEventFlagsOptionKey];
  [newShortcut setObject:[NSNumber numberWithInteger:flagsMask]
	       forKey:kCGEventFlagsMaskKey];
  NSString *string = [_shortcutEditorRecorder description];

  if ([string length] > 0) {
    [newShortcut setObject:string
		 forKey:kShortcutStringKey];
  } else {
    [newShortcut setObject:[self stringForShortcut:newShortcut]
 		 forKey:kShortcutStringKey];
  }

  string = [_shortcutEditorRecorder characters];
  if ([string length] > 0) {
    [newShortcut setObject:string
		 forKey:kShortcutStringIgnoringModifiersKey];
  } 

  return newShortcut;
}

- (NSString *)stringForShortcut:(NSDictionary *)shortcut
{
  NSInteger flags = [[shortcut objectForKey:kCGEventFlagsKey] integerValue];
  NSMutableString *str = [NSMutableString string];

  if (flags & NX_ALPHASHIFTMASK)
    [str appendString:@"⇪"];
  if (flags & NX_SHIFTMASK)
    [str appendString:@"⇧"];
  if (flags & NX_CONTROLMASK)
    [str appendString:@"⌃"];
  if (flags & NX_ALTERNATEMASK)
    [str appendString:@"⌥"];
  if (flags & NX_COMMANDMASK)
    [str appendString:@"⌘"];

  return str;
}

- (void)setLastCheckDate:(NSDate*)date
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
  [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	
  if (date) {
    [_lastCheck setStringValue:[dateFormatter stringFromDate:date]];
  } else {
    [_lastCheck setStringValue:@"N/A"];
  }
	
  [dateFormatter release];
}

// file open sheet delegate function
- (void)filePanelDidEnd:(NSOpenPanel*)sheet
	     returnCode:(int)returnCode
	    contextInfo:(void*)contextInfo
{
  if (returnCode == NSOKButton) {
    if (sheet == _dictionaryPanel) {
      NSString *dictionaryPath = [[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"]
				    stringByAppendingPathComponent:@"Dictionaries"]
				   stringByAppendingPathComponent:@"Baram"];
      [[NSFileManager defaultManager] copyItemAtPath:[_dictionaryPanel filename]
				      toPath:dictionaryPath
				      error:nil];
      [self update];
    } else if (sheet == _appsPanel) {
      NSMutableDictionary *newApp = [[NSMutableDictionary alloc] init];
      NSString *filename = [_appsPanel filename];
     
      [newApp setObject:filename
		 forKey:@"path"];
      [newApp setObject:[[NSBundle bundleWithPath:filename] bundleIdentifier]
		 forKey:@"bundleIdentifier"];
      [newApp setObject:[NSNumber numberWithInt:1]
		 forKey:@"initialMode"];
      [newApp setObject:[NSNumber numberWithBool:NO]
		 forKey:@"viMode"];
			
      [_appsArrayController addObject:newApp];
			
      [newApp release];
    }
  }
}

@end
