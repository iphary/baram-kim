// -*- mode:objc -*-
//
//  BaramHangul.h
//  Baram
//
//  Created by Hayoung Jeong on 7/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "../libhangul/hangul.h"
#import "../common/utf32.h"

typedef enum BaramHangulKeyboardType {
  BaramHangulKeyboardType2 = 0,
  BaramHangulKeyboardType32,
  BaramHangulKeyboardType390,
  BaramHangulKeyboardType3Final,
  BaramHangulKeyboardType3Sun,
  BaramHangulKeyboardType3Yet,
  BaramHangulKeyboardTypeRomaja,
  BaramHangulKeyboardTypeAn
} BaramHangulKeyboardType;

typedef enum BaramRomanKeyboardType {
  BaramRomanKeyboardTypeUS = 0,
  BaramRomanKeyboardTypeDvorak,
  BaramRomanKeyboardTypeDvorakQwerty,
  BaramRomanKeyboardTypeGerman  
} BaramRomanKeyboardType;

@interface BaramHangul : NSObject {
  HangulInputContext       *hic;

  NSMutableString          *inputStringBuffer;
  NSMutableString          *originalStringBuffer;

  BaramHangulKeyboardType  hangulKeyboard;
  BaramRomanKeyboardType   romanKeyboard;

  BOOL                     commitByWord;
  BOOL                     orderCorrection;
}

- (void)reset;
- (NSString *)flush;

- (BaramHangulKeyboardType)hangulKeyboard;
- (void)setHangulKeyboard:(BaramHangulKeyboardType)keyboard;
- (BaramRomanKeyboardType)romanKeyboard;
- (void)setRomanKeyboard:(BaramRomanKeyboardType)keyboard;
- (BOOL)commitByWord;
- (void)setCommitByWord:(BOOL)mode;
- (BOOL)orderCorrection;
- (void)setOrderCorrection:(BOOL)correct;

- (BOOL)process:(NSString *)string modifierFlags:(NSUInteger)modifiers commit:(BOOL *)commit;
- (BOOL)backspace;

- (NSString *)preeditString;
- (NSString *)commitString;
- (NSString *)inputString;
- (NSString *)originalString;

// to support multiple keyboard layout
- (char)adjustKeyboardLayout:(char)ascii;
- (char)adjustQwertzKeyboardLayout:(char)ascii;

// libhangul callback function
bool callback_on_transition(HangulInputContext* hic, ucschar c, const ucschar* preedit, void* data);

@end
