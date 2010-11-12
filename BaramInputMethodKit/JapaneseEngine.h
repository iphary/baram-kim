//
//  JapaneseEngine.h
//  JapaneseEngine
//
//  Created by Ha-young Jeong on 08. 11. 11.
//  Copyright 2008 연세대 프로세서 연구실. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface JapaneseEngine : NSObject {
}

- (NSDictionary *)hepburnTable;
- (NSDictionary *)hiraganaTable;
- (NSDictionary *)katakanaTable;
- (NSDictionary *)synonymTable;

- (NSString *)kanaForKey:(NSString *)key
		    mode:(NSString *)mode;

- (NSString *)kanaForHangul:(NSString *)hangul
		       mode:(NSString *)mode;

- (NSString *)translate:(NSString *)hangul
		 toKana:(NSString *)mode
		  range:(NSRange)range;

- (NSArray *)kanaKanjiConversion:(NSString *)kana;

@end
