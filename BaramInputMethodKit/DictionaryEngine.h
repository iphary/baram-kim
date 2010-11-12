//
//  DictionaryEngine.h
//  Baram
//
//  Created by Ha-young Jeong on 08. 05. 28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaramHanjaTable.h"

@interface DictionaryEngine : NSObject {
	NSMutableArray*         _userDictionaries;
	
	NSMutableArray*         _candidates;
	NSMutableDictionary*	_currentCandidates;
	NSMutableDictionary*	_candidateHistory;
	NSMutableDictionary*    _candidateHistoryDate;
        BOOL                    _progressive;
}

- (void)dictionaryDidChange:(NSNotification *)note;

- (NSMutableArray*)userDictionaries;
- (NSMutableArray*)candidates;
- (NSMutableDictionary*)currentCandidates;
- (NSMutableDictionary*)candidateHistory;
- (NSMutableDictionary*)candidateHistoryDate;

- (void)readDictionary;

- (NSArray*)dictionarySearch:(NSString*)word mode:(NSString*)inputMode;
- (void)candidateSelect:(NSString*)word;
- (NSString*)anotationForCandidate:(NSString*)word;
- (NSString*)keyForCandidate:(NSString*)word;

- (void)setProgressive:(BOOL)mode;

@end
