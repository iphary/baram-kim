//
//  DictionaryManager.h
//  Baram
//
//  Created by Ha-young Jeong on 9/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DictionaryManager : NSObject {
  IBOutlet NSArrayController   *dictionaryArrayController;
  IBOutlet NSTableView         *dictionaryTableView;
  IBOutlet NSProgressIndicator *workingIndicator;
  IBOutlet NSButton            *registerWordOK;
}

- (void)readDictionaryFiles;
- (NSMutableArray *)readDictionary:(NSMutableDictionary *)dictionary 
			     index:(NSInteger)index;

- (void)saveDictionaryFiles;
- (void)saveDictionary:(NSMutableDictionary *)dictionary
		 index:(NSInteger)index;

@end
