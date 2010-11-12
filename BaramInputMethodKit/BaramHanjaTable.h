//
//  HanjaTable.h
//  Baram
//
//  Created by Ha-young Jeong on 08. 06. 27.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "../libhangul/hangul.h"

@interface BaramHanjaTable : NSObject {
	HanjaTable *table;
}

- (void)loadTable:(NSString*)filename;
- (HanjaTable*)table;

@end
