//
//  AppController.h
//  BaramDictionary
//
//  Created by Ha-young Jeong on 08. 05. 20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DictionaryManager.h"
//#import "PreferenceController.h"

@interface AppController : NSWindowController {
  IBOutlet NSArrayController *dictionaryArrayController;
  IBOutlet NSTableView       *dictionaryTableView;

  IBOutlet NSArrayController *contentArrayController;
  IBOutlet NSTableView       *contentTableView;

  IBOutlet NSWindow          *registerNewWordWindow;
  IBOutlet NSTextField       *registerWord;
  IBOutlet NSTextField       *registerValue;
  IBOutlet NSTextField       *registerComment;
  IBOutlet NSPopUpButton     *registerDictionary;

  IBOutlet NSSearchField     *searchField;

  IBOutlet DictionaryManager *dictionaryManager;
  
  NSMutableDictionary        *currentDictionary;

  NSString                   *originalPath;
}

@property (retain) NSString *originalPath;

- (IBAction)showPreferences:(id)sender;
- (IBAction)insertItem:(id)sender;
- (IBAction)removeItem:(id)sender;
- (IBAction)updateFilter:(id)sender;

- (IBAction)registerNewWordOK:(id)sender;
- (IBAction)registerNewWordCancel:(id)sender;

- (IBAction)newDictionary:(id)sender;
- (IBAction)removeDictionary:(id)sender;
- (IBAction)saveDictionary:(id)sender;

- (void)saveDictionaryWithTag:(NSInteger)tag;

- (void)registerNewWordNotification:(NSNotification *)notification;
- (void)registerNewWord:(NSString *)word
		  value:(NSString *)value
		comment:(NSString *)comment
    toDictionaryWithTag:(NSInteger)tag;

- (void)currentDictionaryModified;

- (BOOL)askToSave;
- (NSString *)untitledDictionaryFilename;

// delegate functions
- (void)contentTableViewTextDidChange:(NSNotification *)aNotification;

@end
