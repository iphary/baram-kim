//
//  DictionaryEngine.m
//  Baram
//
//  Created by Ha-young Jeong on 08. 05. 28.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "DictionaryEngine.h"
#import "../common/BIMConstants.h"

@implementation DictionaryEngine

- (id)init
{
  if (self = [super init]) {
    // add observer
    //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    //[nc addObserver:self selector:@selector(configurationChanged:) name:@"NSUserDefaultsDidChangeNotification" object:nil];
	
    NSDistributedNotificationCenter *nc = 
      [NSDistributedNotificationCenter defaultCenter];
    [nc addObserver:self 
	selector:@selector(dictionaryDidChange:) 
	name:kBaramDictionaryDidChangeNotification
	object:nil 
	suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];

    [self readDictionary];
  }
	
  return self;
}

- (void)dealloc
{
  // release hanja tables
  [_userDictionaries release];
  [_candidates release];
  [_currentCandidates release];
  [_candidateHistory release];
  [_candidateHistoryDate release];
	
  // remove observer
  //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  //[nc removeObserver:self];
	
  NSDistributedNotificationCenter *dnc =
    [NSDistributedNotificationCenter defaultCenter];
  [dnc removeObserver:self
       name:kBaramDictionaryDidChangeNotification
       object:nil];
	
  [super dealloc];
}

- (void)dictionaryDidChange:(NSNotification *)note
{
  NSLog(@"DictionaryEngine received dictionaryDidChange notification");
  [self readDictionary];
}

- (NSMutableArray*)userDictionaries
{
  if (_userDictionaries == nil) {
    _userDictionaries = [[NSMutableArray alloc] init];
  }
	
  return _userDictionaries;
}

- (NSMutableArray*)candidates
{
  if (_candidates == nil) {
    _candidates = [[NSMutableArray alloc] init];
  }
	
  return _candidates;
}

- (NSMutableDictionary*)currentCandidates
{
  if (_currentCandidates == nil) {
    _currentCandidates = [[NSMutableDictionary alloc] init];
  }
	
  return _currentCandidates;
}

- (NSMutableDictionary*)candidateHistory
{
  if (_candidateHistory == nil) {
    _candidateHistory = [[NSMutableDictionary alloc] init];
  }
	
  return _candidateHistory;
}

- (NSMutableDictionary*)candidateHistoryDate
{
  if (_candidateHistoryDate == nil) {
    _candidateHistoryDate = [[NSMutableDictionary alloc] init];
  }
	
  return _candidateHistoryDate;
}

- (void)readDictionary
{
  NSMutableArray *dictionaries = [self userDictionaries];
	
  // clean up dictionary array
  [dictionaries removeAllObjects];

  NSMutableArray *files = [[NSMutableArray alloc] init];

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
	[files addObject:[dictionaryPath stringByAppendingPathComponent:file]];
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
	[files addObject:[dictionaryPath stringByAppendingPathComponent:file]];
      }
    }
  }
  
  NSArray *disabledDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kBIMDisabledDictionariesKey];
  for (id disabled in disabledDictionary) {
    [files removeObject:disabled];
  }

  for (id file in files) {
    NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc] init];
    BaramHanjaTable     *newTable      = [[BaramHanjaTable alloc] init];
    [newTable loadTable:file];
		
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

    [newDictionary setObject:newTable forKey:@"table"];
    [newDictionary setObject:[NSNumber numberWithInteger:mode] forKey:@"mode"];
		
    [dictionaries addObject:newDictionary];
		
    [newDictionary release];
    [newTable release];
  }
	
  [files release];
}

NSInteger candidatesSort(id item1, id item2, NSMutableDictionary* history)
{
  // 소팅 우선순위
  // 1. 길이가 긴 candidate가 우선한다 
  if ([item1 length] > [item2 length])
    return NSOrderedAscending;
  else if ([item1 length] < [item2 length])
    return NSOrderedDescending;
		
  int v1 = [[history objectForKey:item1] unsignedIntValue];
  int v2 = [[history objectForKey:item2] unsignedIntValue];
	
  // 2. 길이가 같다면 사용한 빈도가 높은 candidate가 우선한다.
  if (v1 > v2)
    return NSOrderedAscending;
  else if (v1 < v2)
    return NSOrderedDescending;
		
  // 3. 길이도 같고 사용한 빈도도 같으면 일반 정렬
  return [item1 localizedCompare:item2];
}

-(NSArray*)dictionarySearch:(NSString*)word mode:(NSString*)inputMode
{
  //NSLog(@"Baram: dictionarySearch:%@ mode:%@", word, inputMode);
  NSMutableArray *dictionaries = [self userDictionaries];
  NSMutableArray *theCandidates = [self candidates];
  NSMutableDictionary *candidatesDictionary = [self currentCandidates];
  int i;
	
  // clean up	
  [theCandidates removeAllObjects];
  [candidatesDictionary removeAllObjects];
	
  for (id entry in dictionaries) {
    DLOG(@"Baram: dictionarySearch:%@ mode:%d", word, [[entry objectForKey:@"mode"] intValue]);

    NSInteger mode = [[entry objectForKey:@"mode"] integerValue];
    
    if (((mode == kBIMDictionaryForRomanMode) &&
	 ![inputMode isEqual:kBIMEnglishMode]) ||
	((mode == kBIMDictionaryForHangulMode) &&
	 ![inputMode isEqual:kBIMHangulMode]) ||
	((mode == kBIMDictionaryForJapaneseMode) &&
	 (![inputMode isEqual:kBIMHiraganaMode] ||
	  ![inputMode isEqual:kBIMKatakanaMode])))
      continue;
    
    HanjaTable *hanja_table = (HanjaTable*)[[entry objectForKey:@"table"] table];
		
    if ((word != nil) && ([word length] > 0)) {
      const char *keyword  = [word UTF8String];
      HanjaList  *list     = hanja_table_match_prefix(hanja_table, keyword);
      int        list_size = hanja_list_get_size(list);

      DLOG(@"list_size = %d", list_size);

      //NSLog(@"Baram : candidates: list_size = %d", list_size);
      for(i=0; i<list_size; i++) {
	const Hanja *entry   = hanja_list_get_nth(list, i);
	const char  *key     = hanja_get_key(entry);
	const char  *value   = hanja_get_value(entry);
	const char  *comment = hanja_get_comment(entry);
			
	NSString *converted_key     = [[NSString alloc] initWithUTF8String:key];
	NSString *converted_value   = [[NSString alloc] initWithUTF8String:value];
	NSString *converted_comment = [[NSString alloc] initWithUTF8String:comment];
	NSArray  *object            = [[NSArray alloc] initWithObjects:converted_key, converted_comment, nil];
			
	[theCandidates addObject:converted_value];
			
	[candidatesDictionary setObject:object forKey:converted_value]; 
			
	[converted_key release];
	[converted_value release];
	[converted_comment release];
	[object release];
      }

      hanja_list_delete(list);
    }
  }

  if ([theCandidates count] == 0)
    return nil;

  // selectedList의 count값을 사용하여 자주 사용되는 값이 먼저 오도록 sorting한다.
  [theCandidates sortUsingFunction:(NSInteger (*)(id, id, void *))candidatesSort 
		 context:(void *)[self candidateHistory]];
  return theCandidates;
}

- (void)candidateSelect:(NSString*)word
{
  // candidate가 선택될때 마다 count up을 한다.
  id entry = [[self candidateHistory] objectForKey:word];
  if (entry == nil) {
    NSNumber *count = [[NSNumber alloc] initWithInt:1];
    NSDate   *date  = [[NSDate alloc] init];
    //NSLog(@"Baram:candidate %@ stat %d", [candidateString string], [count unsignedIntValue]);
    [[self candidateHistory] setObject:count forKey:word];
    [[self candidateHistoryDate] setObject:date forKey:word];
    [count release];
    [date release];
  } else {
    int countup = [entry unsignedIntValue] + 1;
    NSNumber *newCount = [[NSNumber alloc] initWithInt:countup];
    NSDate   *date  = [[NSDate alloc] init];
		
    //NSLog(@"Baram:candidate %@ stat %d", [candidateString string], [newCount unsignedIntValue]);
    [[self candidateHistory] setObject:newCount forKey:word];
    [[self candidateHistoryDate] setObject:date forKey:word];
    [newCount release];
    [date release];
  }

  // selectedList의 count를 100개 이하로 유지한다.
  // 만일 100가 넘을 경우 count값으로 sorting하여 최소값을 지운다.
  if ([[self candidateHistory] count] > 100) {
    NSArray* keys = [[self candidateHistory] allKeys];
    NSMutableDictionary* dates = [self candidateHistoryDate];
    NSDate* oldest = nil;
    NSString* oldestKey;
		
    // sort
    for (id key in keys) {
      NSDate *newone = [dates objectForKey:key];
      if ((oldest == nil) || ([(NSDate*)oldest compare:newone] == NSOrderedAscending)) {
	oldest = newone;
	oldestKey = key;
      }
    }
		
    if (oldestKey != nil) {
      NSLog(@"Baram: DictionaryEngine oldest %@ is removed: %@", oldestKey, oldest);
      [[self candidateHistory] removeObjectForKey:oldestKey];
      [[self candidateHistoryDate] removeObjectForKey:oldestKey];
    }
  }
}

- (NSString*)anotationForCandidate:(NSString*)word
{
  NSArray *selectedObject = [[self currentCandidates] objectForKey:word];
	
  if (selectedObject != nil) {
    return [selectedObject objectAtIndex:1]; 
  }
	
  return nil;
}

- (NSString*)keyForCandidate:(NSString*)word
{
  NSArray *selectedObject = [[self currentCandidates] objectForKey:word];
	
  if (selectedObject != nil) {
    return [selectedObject objectAtIndex:0]; 
  }
	
  return nil;
}

- (void)setProgressive:(BOOL)mode
{
  _progressive = mode;
}

@end
