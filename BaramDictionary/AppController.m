//
//  AppController.m
//  BaramDictionary
//
//  Created by Ha-young Jeong on 08. 05. 20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "../FilenameFormatter/FilenameFormatter.h"
#import "../common/BIMConstants.h"
#import "../libhangul/hangul.h"

extern const NSString *readDictionaryAtStartupKey;
extern const NSString *defaultDictionaryKey;
extern const NSString *dictionaryListKey;
extern const NSString *recentlySavedDictionaryKey;

@implementation AppController
@synthesize originalPath;

- (id)init
{
  if (self = [super init]) {
    // register notification
    NSDistributedNotificationCenter *nc = 
      [NSDistributedNotificationCenter defaultCenter];
    [nc addObserver:self 
	selector:@selector(registerNewWordNotification:) 
	name:kBaramDictionaryAddNewWordNotification
	object:nil 
	suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
  }
	
  return self;
}

- (void)dealloc
{
  NSDistributedNotificationCenter *dnc =
    [NSDistributedNotificationCenter defaultCenter];
  [dnc removeObserver:self
       name:kBaramDictionaryAddNewWordNotification
       object:nil];

  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc removeObserver:self 
      name:NSTableViewSelectionDidChangeNotification
      object:dictionaryTableView];

  [nc removeObserver:self 
      name:NSControlTextDidChangeNotification
      object:contentTableView];

  [super dealloc];
}

- (void)windowWillClose:(NSNotification *)notification
{
  [[NSApplication sharedApplication] terminate:self];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)app
{
  if ([self askToSave])
    return NSTerminateNow;
  else 
    return NSTerminateCancel; 
}

- (void)awakeFromNib
{
  // dictionary array
  NSMutableArray *files = [[NSMutableArray alloc] init];
  NSInteger tag = 0;

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
      if ([[file pathExtension] isEqualToString: @"all"] ||
	  [[file pathExtension] isEqualToString: @"hangul"] ||
	  [[file pathExtension] isEqualToString: @"roman"] ||
	  [[file pathExtension] isEqualToString: @"japanese"]) {
	[files addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[dictionaryPath stringByAppendingPathComponent:file], @"filename", 
					      [NSNumber numberWithBool:YES], @"readOnly", 
					      [NSNumber numberWithInteger:tag], @"tag", nil]];
	tag++;
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
      if ([[file pathExtension] isEqualToString: @"all"] ||
	  [[file pathExtension] isEqualToString: @"hangul"] ||
	  [[file pathExtension] isEqualToString: @"roman"] ||
	  [[file pathExtension] isEqualToString: @"japanese"]) {
	[files addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[dictionaryPath stringByAppendingPathComponent:file], @"filename", 
					      [NSNumber numberWithBool:NO], @"readOnly", 
					      [NSNumber numberWithBool:YES], @"lock",
					      [NSNumber numberWithInteger:tag], @"tag", nil]];
	tag++;
      }
    }
  }

  [dictionaryArrayController addObjects:files];

  // create readDictionaryFiles thread
  [NSThread detachNewThreadSelector:@selector(readDictionaryFiles)
	    toTarget:dictionaryManager
	    withObject:nil];

  // NSTableViewSelectionDidChangeNotification
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self 
      selector:@selector(dictionaryTableViewSelectionDidChange:) 
      name:NSTableViewSelectionDidChangeNotification
      object:dictionaryTableView];

  [nc addObserver:self 
      selector:@selector(contentTableViewTextDidChange:) 
      name:NSControlTextDidChangeNotification
      object:contentTableView];

  // filename formatter
  [[[[dictionaryTableView tableColumns] objectAtIndex:0] dataCell] 
    setFormatter:[[FilenameFormatter alloc] init]];

  // dictionary list update
  for (id file in files) {
    if (![[file objectForKey:@"readOnly"] boolValue]) {
      NSString *filename = [[NSFileManager defaultManager]
			     displayNameAtPath:[file objectForKey:@"filename"]];
      NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:filename
						action:nil
						keyEquivalent:@""];
      [newItem setTag:[[file objectForKey:@"tag"] integerValue]];
      [[registerDictionary menu] addItem:newItem];
      [newItem release];
    }
  }

  [contentArrayController setSelectsInsertedObjects:YES];

  [files release];

  [dictionaryTableView setDelegate:self];
  [contentTableView setDelegate:self];
}

- (void)dictionaryTableViewSelectionDidChange:(NSNotification *)notification
{
  currentDictionary = [[dictionaryArrayController selectedObjects] 
			objectAtIndex:0];
  [contentArrayController setContent:[currentDictionary objectForKey:@"content"]];
}

- (IBAction)showPreferences:(id)sender
{
  //[[DictionaryPreferenceController sharedPrefsWindowController] showWindow:nil];
}

- (void)registerNewWordNotification:(NSNotification *)notification
{
  NSString *word;
  
  if (notification) {
    NSDictionary *userInfo = [notification userInfo];
    word = [userInfo objectForKey:@"Word"];
  } else {
    word = @"";
  }
	
  //if ([word length] > 0) {
  NSLog(@"BaramDictionary : recieve notification %@", word);

  [registerWord setStringValue:word];
    
  [NSApp beginSheet:registerNewWordWindow
	 modalForWindow:[self window]
	 modalDelegate:self
	 didEndSelector:nil
	 contextInfo:nil];
      
  NSInteger add = [NSApp runModalForWindow:registerNewWordWindow];
    
  if (add) {
    NSInteger selectedTag = [[registerDictionary selectedItem] tag];
    if (!selectedTag) {
      // create new dictionary
      [self newDictionary:nil];
      NSInteger count = [[dictionaryArrayController content] count];
      selectedTag = [[[[dictionaryArrayController content] 
			objectAtIndex:(count-1)]
		       objectForKey:@"tag"] integerValue];

    } 
    
    [self registerNewWord:[registerWord stringValue]
	  value:[registerValue stringValue]
	  comment:[registerComment stringValue]
	  toDictionaryWithTag:selectedTag];
  }

  [NSApp endSheet:registerNewWordWindow];
  [registerNewWordWindow orderOut:self];
  //  }
}

- (IBAction)registerNewWordOK:(id)sender
{
  [NSApp stopModalWithCode:YES];  
}

- (IBAction)registerNewWordCancel:(id)sender
{
  [NSApp stopModalWithCode:NO];
}

 - (void)registerNewWord:(NSString *)word
		   value:(NSString *)value
		 comment:(NSString *)comment
     toDictionaryWithTag:(NSInteger)tag
{
  NSMutableDictionary *selectedDictionary = nil;
  for (id dictionary in [dictionaryArrayController arrangedObjects]) {
    if ([[dictionary objectForKey:@"tag"] integerValue] == tag)
      selectedDictionary = dictionary;
  }
      
  if (selectedDictionary) {
    [dictionaryArrayController 
      setSelectedObjects:[NSArray arrayWithObjects:selectedDictionary, nil]];
    NSMutableDictionary *newObject = [[NSMutableDictionary alloc] init];
    
    [newObject setObject:word forKey:@"key"];
    [newObject setObject:value forKey:@"value"];
    [newObject setObject:comment forKey:@"comment"];
    
    [contentArrayController insertObject:newObject 
			    atArrangedObjectIndex:0];
    
    [selectedDictionary setObject:[NSImage imageNamed:@"yellow"]
			forKey:@"status"];
    [selectedDictionary setObject:[NSNumber numberWithBool:YES]
			forKey:@"modified"];
    [newObject release];
  }
}

- (IBAction)insertItem:(id)sender
{
  if (![[dictionaryArrayController selectedObjects] count]) {
    [self registerNewWordNotification:nil];
    return;
  } else if ([[currentDictionary objectForKey:@"readOnly"] boolValue]) {
    NSBeep();
    return;
  }

  NSMutableDictionary *newObject = [[NSMutableDictionary alloc] init];
  NSUInteger index = [contentArrayController selectionIndex];
	
  if (index == NSNotFound) {
    index = 0;
  }
  
  [newObject setObject:@"" forKey:@"key"];
  [newObject setObject:@"" forKey:@"value"];
  [newObject setObject:@"" forKey:@"comment"];

  [contentArrayController insertObject:newObject 
			  atArrangedObjectIndex:index];
  [contentTableView editColumn:0
		    row:index
		    withEvent:nil
		    select:YES];

  [newObject release];

  [self currentDictionaryModified];
}

- (IBAction)removeItem:(id)sender
{
  if ([[currentDictionary objectForKey:@"readOnly"] boolValue]) {
    NSBeep();
    return;
  }
    
  NSUInteger index = [contentArrayController selectionIndex];
	
  if (index != NSNotFound) {
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert addButtonWithTitle:NSLocalizedString(@"Delete", @"Delete")];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel")];
    [alert setMessageText:NSLocalizedString(@"Do you want to delete selected items?", @"Do you want to delete selected items?")];
    [alert setAlertStyle:NSWarningAlertStyle];
  
    int choice = [alert runModal];
    [alert release];
  
    if (choice == NSAlertFirstButtonReturn) {
      [contentArrayController removeObjectAtArrangedObjectIndex:index];
    }
  }

  [self currentDictionaryModified];
}

- (IBAction)newDictionary:(id)sender
{
  NSMutableDictionary *newDictionary =
    [[NSMutableDictionary alloc] init];

  NSInteger count = [[dictionaryArrayController content] count];
  NSInteger tag = [[[[dictionaryArrayController content] 
		      objectAtIndex:(count-1)]
		     objectForKey:@"tag"] integerValue] + 1;
  NSString *filename = [self untitledDictionaryFilename];

  [newDictionary setObject:filename
		 forKey:@"filename"];
  [newDictionary setObject:[NSImage imageNamed:@"yellow"]
		 forKey:@"status"];
  [newDictionary setObject:[NSNumber numberWithBool:NO]
		 forKey:@"modified"];
  [newDictionary setObject:[NSMutableArray array]
		 forKey:@"content"];
  [newDictionary setObject:[NSNumber numberWithInteger:tag]
		 forKey:@"tag"];

  [dictionaryArrayController addObject:newDictionary];
  [newDictionary release];

  // add new dictionary into register new word window
  NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:[[NSFileManager defaultManager]
							    displayNameAtPath:filename]
					    action:nil
					    keyEquivalent:@""];
  [newItem setTag:tag];
  [[registerDictionary menu] addItem:newItem];
  [newItem release];
}

- (IBAction)saveDictionary:(id)sender
{
  [NSThread detachNewThreadSelector:@selector(saveDictionaryFiles)
	    toTarget:dictionaryManager
	    withObject:nil];
}

- (void)saveDictionaryWithTag:(NSInteger)tag
{
  NSInteger index = 0;

  for (id dictionary in [dictionaryArrayController content]) {
    if ([[dictionary objectForKey:@"tag"] integerValue] == tag) {
      [dictionaryManager saveDictionary:dictionary index:index];

      NSDistributedNotificationCenter *nc = [NSDistributedNotificationCenter defaultCenter];
      [nc postNotificationName:kBaramDictionaryDidChangeNotification
	  object:nil 
	  userInfo:nil
	  deliverImmediately:NO];

      break;
    }

    index++;
  }						    
}

- (IBAction)removeDictionary:(id)sender
{
  for (id dictionary in [dictionaryArrayController selectedObjects]) {
    if ([[dictionary objectForKey:@"readOnly"] boolValue]) {
      NSBeep();
      continue;
    }

    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Do you want to delete this dictionary?", @"Do you want to delete this dictionary?")
			      defaultButton:NSLocalizedString(@"No", @"No")
			      alternateButton:NSLocalizedString(@"Yes", @"Yes")
			      otherButton:NSLocalizedString(@"Cancel", @"Cancel")
			      informativeTextWithFormat:@"%@", [dictionary objectForKey:@"filename"]];
      
    NSInteger select = [alert runModal];
    
    if (select == NSAlertDefaultReturn)
      continue;
    else if (select == NSAlertAlternateReturn) {
      NSError *error = nil;
      BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[dictionary objectForKey:@"filename"]
						     error:&error];
      if (!success) {
	[NSApp presentError:error];
	return;
      }
      [dictionaryArrayController removeObject:dictionary];
    } else // if (select == NSAlertOtherReturn)
      return;
  }
}

- (IBAction)updateFilter:(id)sender
{
  if ([[searchField stringValue] length] > 0) {
    NSString *filterString = [[NSString alloc] initWithFormat:@"key contains '%@'", [searchField stringValue], nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:filterString];
    [contentArrayController setFilterPredicate:predicate];
    [filterString release];
  } else {
    [contentArrayController setFilterPredicate:nil];
  }
}

- (void)currentDictionaryModified
{
  [currentDictionary setObject:[NSNumber numberWithBool:YES]
		     forKey:@"modified"];
  [currentDictionary setObject:[NSImage imageNamed:@"yellow"]
		     forKey:@"status"];
}

- (BOOL)askToSave
{
  NSInteger index = 0;

  BOOL sendNotification = NO;
  for (id dictionary in [dictionaryArrayController content]) {
    BOOL modified = [[dictionary objectForKey:@"modified"] boolValue];

    if (modified) {
      NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Do you want to save the changes?", @"Do you want to save the changes?")
				defaultButton:NSLocalizedString(@"Save", @"Save")
				alternateButton:NSLocalizedString(@"Don't Save", @"Don't Save")
				otherButton:NSLocalizedString(@"Cancel", @"Cancel")
				informativeTextWithFormat:@"%@", [dictionary objectForKey:@"filename"]];
      
      NSInteger select = [alert runModal];
		
      if (select == NSAlertDefaultReturn) {
	[dictionaryManager saveDictionary:dictionary index:index];
	sendNotification = YES;
      } else if (select == NSAlertAlternateReturn) 
	continue;
      else {// if (select == NSAlertOtherReturn) 
	if (sendNotification) {
	  NSDistributedNotificationCenter *nc = [NSDistributedNotificationCenter defaultCenter];
	  [nc postNotificationName:kBaramDictionaryDidChangeNotification
	      object:nil 
	      userInfo:nil
	      deliverImmediately:NO];
	}

	return NO;
      }
    } 

    index++;
  }

  if (sendNotification) {
      NSDistributedNotificationCenter *nc = [NSDistributedNotificationCenter defaultCenter];
      [nc postNotificationName:kBaramDictionaryDidChangeNotification
	  object:nil 
	  userInfo:nil
	  deliverImmediately:NO];
  }
  
  return YES;
}

- (NSString *)untitledDictionaryFilename
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
						       NSUserDomainMask,
						       YES);
  NSString *filename = [[[[paths objectAtIndex:0] stringByAppendingPathComponent:@"Dictionaries"] 
			  stringByAppendingPathComponent:@"Baram"]
			 stringByAppendingPathComponent:@"untitled"];
  NSMutableString *newFilename = [[NSMutableString alloc] init];
  NSInteger edition = 0;

  [newFilename appendFormat:@"%@.all", filename, nil];
  for (id dictionary in [dictionaryArrayController content]) {
    if ([[dictionary objectForKey:@"filename"] isEqual:newFilename]) {
      [newFilename setString:@""];
      [newFilename appendFormat:@"%@%d.all", filename, edition++, nil];
      
      continue;
    }
  }

  NSString *ret = [NSString stringWithString:newFilename];
  [newFilename release];

  return ret;
}

// delegate functions
- (void)contentTableViewTextDidChange:(NSNotification *)aNotification
{
  [self currentDictionaryModified];
}

#pragma mark __NSTableView delegate protocol start__

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
  if (aTableView == dictionaryTableView) {
    originalPath = [[aTableColumn dataCellForRow:rowIndex] stringValue];

    return YES;
  }
  return NO;
}

- (BOOL)control:(NSControl *)aControl textShouldEndEditing:(NSText *)textObject
{
  NSString *dstPath = [textObject string];
  NSString *extension = [dstPath pathExtension];
  if (!([extension isEqual:@"all"] ||
	[extension isEqual:@"hangul"] ||
	[extension isEqual:@"english"] ||
	[extension isEqual:@"japanese"])) {
    // default extension
    dstPath = [NSString stringWithFormat:@"%@.all", dstPath];
    [aControl setStringValue:dstPath];
  }

  NSAlert *alert = [NSAlert alertWithMessageText:@"Do you want to rename?"
				   defaultButton:@"OK"
				 alternateButton:@"Cancel"
				     otherButton:nil
		       informativeTextWithFormat:[NSString stringWithFormat:@"\"%@\" to \"%@\"", originalPath, dstPath, nil]];

  NSInteger select = [alert runModal];

  if (select == NSAlertDefaultReturn) {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    BOOL result = [fm moveItemAtPath:[NSString stringWithFormat:@"%@/Library/Dictionaries/Baram/%@", NSHomeDirectory(), originalPath, nil]
			      toPath:[NSString stringWithFormat:@"%@/Library/Dictionaries/Baram/%@", NSHomeDirectory(), dstPath, nil]
			       error:nil];
    
    return result;
  } 
  
  [aControl abortEditing];

  return NO;
}

#pragma mark __NSTableView delegate protocol end__
@end
