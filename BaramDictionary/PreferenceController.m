//
//  PreferenceController.m
//  Baram
//
//  Created by Ha-young Jeong on 08. 09. 30.
//  Copyright 2008 연세대 프로세서 연구실. All rights reserved.
//

#import "PreferenceController.h"

@implementation DictionaryPreferenceController

- (void)setupToolbar
{
  NSLog(@"BaramDictionary:setupToolbar");
}

+ (NSString*)nibName;
{
  NSLog(@"BaramDictionary:nibName");
	
  return @"preferences";
}

@end
