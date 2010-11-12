//
//  DictionaryManager.m
//  Baram
//
//  Created by Ha-young Jeong on 9/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DictionaryManager.h"
#import "../common/BIMConstants.h"

@interface NSMutableDictionary (BDSort)
- (NSComparisonResult)BDCompare:(NSMutableDictionary *)aDictionary;
@end

@implementation NSMutableDictionary (BDSort)
- (NSComparisonResult)BDCompare:(NSMutableDictionary *)aDictionary
{
  return [[self objectForKey:@"key"] 
	   localizedCompare:[aDictionary objectForKey:@"key"]];
}
@end

@implementation DictionaryManager

- (void)readDictionaryFiles
{
  NSAutoreleasePool* myAutoreleasePool = [[NSAutoreleasePool alloc] init];

  [workingIndicator setUsesThreadedAnimation:YES];
  [workingIndicator startAnimation:nil];
  [registerWordOK setEnabled:NO];

  NSInteger index = 0;
  for (id dictionary in [dictionaryArrayController arrangedObjects]) {
    NSString *filename = [dictionary objectForKey:@"filename"];

    if ([filename length] > 0) {
      NSLog(@"read %@", filename);

      NSMutableArray *content = [self readDictionary:dictionary index:index++];
      if ([content count] > 0) 
	[dictionary setObject:content forKey:@"content"];
      
      [dictionary setObject:[NSNumber numberWithBool:NO]
		     forKey:@"lock"];
      [content release];
    }
  }

  [workingIndicator stopAnimation:nil];
  [registerWordOK setEnabled:YES];

  [myAutoreleasePool release];
  [NSThread exit];
}

- (NSMutableArray *)readDictionary:(NSMutableDictionary *)dictionary index:(NSInteger)index
{
  FILE *fp;

  if (!(fp = fopen([[dictionary objectForKey:@"filename"] UTF8String], "rt")))
    return nil;

  char buf[1024];
  char *key;
  char *value;
  char *comment;
  
  char *save_ptr = NULL;
  NSMutableArray *array = [[NSMutableArray alloc] init];

  fseek(fp, 0, SEEK_END);
  NSInteger size = ftell(fp);
  fseek(fp, 0, SEEK_SET);

  NSProgressIndicator *progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 16, 16)];
  [progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
  [progressIndicator setIndeterminate:NO];
  [progressIndicator setMaxValue:(double)size];

  // add subview
  NSView *view = [[dictionaryTableView preparedCellAtColumn:1 row:index] controlView];
  NSRect frame = [dictionaryTableView frameOfCellAtColumn:1 row:index];
  frame.origin.x += 10;
  [view addSubview:progressIndicator];
  [progressIndicator setFrame:frame];

  while(fgets(buf, sizeof(buf), fp) != NULL) {
    NSInteger pos = ftell(fp);

    /* skip comments and empty lines */
    if (buf[0] == '#' || buf[0] == '\r' || buf[0] == '\n' || buf[0] == '\0')
      continue;

    save_ptr = NULL;
    key = strtok_r(buf, ":", &save_ptr);
    value = strtok_r(NULL, ":", &save_ptr);
    comment = strtok_r(NULL, "\r\n", &save_ptr);
    
    if (key == NULL || strlen(key) == 0)
      continue;
    
    if (value == NULL || strlen(value) == 0)
      continue;
    
    if (comment == NULL)
      comment = "";

    [array addObject:
	     [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:key], @"key",
				  [NSString stringWithUTF8String:value], @"value",
				  [NSString stringWithUTF8String:comment], @"comment", nil]];

    if (!(pos % 2000))
      [progressIndicator setDoubleValue:(double)pos];
  }

  [progressIndicator removeFromSuperview];
  [progressIndicator release];

  fclose(fp);

  if ([[dictionary objectForKey:@"readOnly"] boolValue])
    [dictionary setObject:[NSImage imageNamed:@"Locked"] forKey:@"status"];
  else
    [dictionary setObject:[NSImage imageNamed:@"green"] forKey:@"status"];

  return array;
}

- (void)saveDictionaryFiles
{
  NSAutoreleasePool* myAutoreleasePool = [[NSAutoreleasePool alloc] init];

  NSInteger index = 0;
  BOOL sendNotification = NO;
  for (id dictionary in [dictionaryArrayController content]) {
    BOOL modified = [[dictionary objectForKey:@"modified"] boolValue];

    if (modified) {
      [self saveDictionary:dictionary index:index++];
      sendNotification = YES;
    } 
  }

  if (sendNotification) {
      NSDistributedNotificationCenter *nc = [NSDistributedNotificationCenter defaultCenter];
      [nc postNotificationName:kBaramDictionaryDidChangeNotification
	  object:nil 
	  userInfo:nil
	  deliverImmediately:NO];
  }

  [myAutoreleasePool release];
  [NSThread exit];
}

- (void)saveDictionary:(NSMutableDictionary *)dictionary
		 index:(NSInteger)index
{
  NSArray *sortedContent = [[dictionary objectForKey:@"content"]
			     sortedArrayUsingSelector:@selector(BDCompare:)];

  char *cFileName;
  NSInteger count = 0;

  NSLog(@"saveDictionary:%@", [dictionary objectForKey:@"filename"]);

  cFileName = (char*)[[dictionary objectForKey:@"filename"] UTF8String];

  FILE *fp = fopen(cFileName, "wt");

  fseek(fp, 0, SEEK_END);
  NSInteger size = [dictionary count];
  fseek(fp, 0, SEEK_SET);

  NSProgressIndicator *progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, 0, 16, 16)];
  [progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
  [progressIndicator setIndeterminate:NO];
  [progressIndicator setMaxValue:(double)size];

  // add subview
  NSView *view = [[dictionaryTableView preparedCellAtColumn:1 row:index] controlView];
  NSRect frame = [dictionaryTableView frameOfCellAtColumn:1 row:index];
  frame.origin.x += 10;
  [view addSubview:progressIndicator];
  [progressIndicator setFrame:frame];
	
  // data dump
  for (id entry in sortedContent) {
    NSString *key = [entry objectForKey:@"key"];
    if (key == nil) 
      continue;
    
    NSString *value = [entry objectForKey:@"value"];
    if (value == nil) 
      continue;
			
    NSString *comment = [entry objectForKey:@"comment"];
    if (comment == nil)
      comment = @"";
		
    NSString *line = [[NSString alloc] initWithFormat:@"%@:%@:%@\n", key, value, comment];
    char *cLine = (char*)[line UTF8String];
    fputs(cLine, fp);

    if (!(count % 500))
      [progressIndicator setDoubleValue:(double)count];

    count++;
  }

  [progressIndicator removeFromSuperview];
  [progressIndicator release];

  fclose(fp);

  [dictionary setObject:[NSNumber numberWithBool:NO]
	      forKey:@"modified"];
  [dictionary setObject:[NSImage imageNamed:@"green"]
	      forKey:@"status"];
}

@end
