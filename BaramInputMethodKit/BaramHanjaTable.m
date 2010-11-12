//
//  HanjaTable.m
//  Baram
//
//  Created by Ha-young Jeong on 08. 06. 27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BaramHanjaTable.h"


@implementation BaramHanjaTable

- (id)init
{
	return [super init];
}

- (void)dealloc
{
	if (table != nil) {
		hanja_table_delete(table);
	}
	
	[super dealloc];
}

- (void)loadTable:(NSString*)filename
{
	char *cFileName = (char *)[filename UTF8String];
	
	table = hanja_table_load(cFileName);
	
	if (table == nil)
		NSLog(@"Baram: Cannot load dictionary file %@", filename);
}

- (HanjaTable*)table
{
	return table;
}

@end
