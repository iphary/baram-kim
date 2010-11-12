//
//  BIMUserDefaults.m
//  Baram
//
//  Created by Ha-young Jeong on 08. 05. 20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BIMUserDefaults.h"
#import "BIMConstants.h"

@implementation BIMUserDefaults

#define BIMDefaultsValue(key) CFPreferencesCopyAppValue((CFStringRef)key, (CFStringRef)kBIMBundleID);
#define BIMDefaultsSetValue(key, value) CFPreferencesSetAppValue((CFStringRef)key, value, (CFStringRef)kBIMBundleID);

- (void)synchronize
{
  CFPreferencesAppSynchronize((CFStringRef)kBIMBundleID);
}

// getting default values
- (NSArray *)arrayForKey:(NSString *)defaultName
{
  return (NSArray *)BIMDefaultsValue(defaultName);
}

- (BOOL)boolForKey:(NSString *)defaultName
{
  CFNumberRef numberRef = (CFNumberRef)BIMDefaultsValue(defaultName);
  BOOL ret = [(NSNumber *)numberRef boolValue];

  return ret;
}

- (NSData *)dataForKey:(NSString *)defaultName
{
  return (NSData *)BIMDefaultsValue(defaultName);
}

- (NSDictionary *)dictionaryForKey:(NSString *)defaultName
{
  return (NSDictionary *)BIMDefaultsValue(defaultName);
}

- (float)floatForKey:(NSString *)defaultName
{
  CFNumberRef numberRef = (CFNumberRef)BIMDefaultsValue(defaultName);
  float ret = [(NSNumber *)numberRef floatValue];

  return ret;
}

- (NSInteger)integerForKey:(NSString *)defaultName
{
  CFNumberRef numberRef = (CFNumberRef)BIMDefaultsValue(defaultName);
  NSInteger ret = [(NSNumber *)numberRef integerValue];

  return ret;
}

- (id)objectForKey:(NSString *)defaultName
{
  return (id)BIMDefaultsValue(defaultName);
}

- (NSArray *)stringArrayForKey:(NSString *)defaultName
{
  return (NSArray *)BIMDefaultsValue(defaultName);
}

- (NSString *)stringForKey:(NSString *)defaultName
{
  return (NSString *)BIMDefaultsValue(defaultName);
}

- (double)doubleForKey:(NSString *)defaultName
{
  CFNumberRef numberRef = (CFNumberRef)BIMDefaultsValue(defaultName);
  double ret = [(NSNumber *)numberRef doubleValue];

  return ret;
}

- (NSURL *)URLForKey:(NSString *)defaultName
{
  return (NSURL *)BIMDefaultsValue(defaultName);
}

// setting default values
- (void)setBool:(BOOL)value forKey:(NSString *)defaultName
{
  BIMDefaultsSetValue(defaultName, [NSNumber numberWithBool:value]);
}

- (void)setFloat:(float)value forKey:(NSString *)defaultName
{
  BIMDefaultsSetValue(defaultName, [NSNumber numberWithFloat:value]);
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName
{
  BIMDefaultsSetValue(defaultName, [NSNumber numberWithInteger:value]);
}

- (void)setObject:(id)value forKey:(NSString *)defaultName
{
  BIMDefaultsSetValue(defaultName, value);
}

- (void)setDouble:(double)value forKey:(NSString *)defaultName
{
  BIMDefaultsSetValue(defaultName, [NSNumber numberWithDouble:value]);
}

- (void)setURL:(NSURL *)value forKey:(NSString *)defaultName
{
  BIMDefaultsSetValue(defaultName, value);
}

@end
