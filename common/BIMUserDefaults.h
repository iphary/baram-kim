//
//  BIMUserDefaults.h
//  Baram
//
//  Created by Ha-young Jeong on 08. 05. 20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BIMUserDefaults : NSObject {
}

- (void)synchronize;

// getting default values
- (NSArray *)arrayForKey:(NSString *)defaultName;
- (BOOL)boolForKey:(NSString *)defaultName;
- (NSData *)dataForKey:(NSString *)defaultName;
- (NSDictionary *)dictionaryForKey:(NSString *)defaultName;
- (float)floatForKey:(NSString *)defaultName;
- (NSInteger)integerForKey:(NSString *)defaultName;
- (id)objectForKey:(NSString *)defaultName;
- (NSArray *)stringArrayForKey:(NSString *)defaultName;
- (NSString *)stringForKey:(NSString *)defaultName;
- (double)doubleForKey:(NSString *)defaultName;
- (NSURL *)URLForKey:(NSString *)defaultName;

// setting default values
- (void)setBool:(BOOL)value forKey:(NSString *)defaultName;
- (void)setFloat:(float)value forKey:(NSString *)defaultName;
- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName;
- (void)setObject:(id)value forKey:(NSString *)defaultName;
- (void)setDouble:(double)value forKey:(NSString *)defaultName;
- (void)setURL:(NSURL *)value forKey:(NSString *)defaultName;

@end
