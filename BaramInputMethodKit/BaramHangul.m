//
//  BaramHangul.m
//  Baram
//
//  Created by Hayoung Jeong on 7/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BaramHangul.h"
#import "../common/BIMConstants.h"

@implementation BaramHangul

- (id)init {
  if (self = [super init]) {
    hic = hangul_ic_new("2");
    hangul_ic_connect_callback(hic,
			       "transition", 
			       callback_on_transition,
			       self);
    if (!hic) {
      NSLog(@"BaramHangul: hangul_ic_new is failed");
      return nil;
    }

    inputStringBuffer = [[NSMutableString alloc] init];
    originalStringBuffer = [[NSMutableString alloc] init];
  }

  return self;
}

- (void)dealloc {
  hangul_ic_delete(hic);

  [inputStringBuffer release];
  [originalStringBuffer release];

  [super dealloc];
}

- (void)reset {
  [inputStringBuffer setString:@""];
  [originalStringBuffer setString:@""];

  hangul_ic_reset(hic);
}

- (NSString *)flush {
  ucschar  *flushed   = (ucschar *)hangul_ic_flush(hic);
  return UTF32toNSString(flushed);
}

- (BaramHangulKeyboardType)hangulKeyboard {
  return hangulKeyboard;
}

- (void)setHangulKeyboard:(BaramHangulKeyboardType)keyboard {
  hangulKeyboard = keyboard;

  switch (hangulKeyboard) {
  case BaramHangulKeyboardType2:
    hangul_ic_select_keyboard(hic,"2");
    break;
  case BaramHangulKeyboardType32:
    hangul_ic_select_keyboard(hic,"32");
    break;
  case BaramHangulKeyboardType390:
    hangul_ic_select_keyboard(hic,"39");
    break;
  case BaramHangulKeyboardType3Final:
    hangul_ic_select_keyboard(hic,"3f");
    break;
  case BaramHangulKeyboardType3Sun:
    hangul_ic_select_keyboard(hic,"3s");
    break;
  case BaramHangulKeyboardType3Yet:
    hangul_ic_select_keyboard(hic,"3y");
    break;
  case BaramHangulKeyboardTypeRomaja:
    hangul_ic_select_keyboard(hic,"ro");
    break;
  case BaramHangulKeyboardTypeAn:
    hangul_ic_select_keyboard(hic,"an");
    break;
  default:
    NSLog(@"BaramHangul : unknown hangul keyboard type = %d", hangulKeyboard);
    break;
  }
}

- (BaramRomanKeyboardType)romanKeyboard {
  return romanKeyboard;
}

- (void)setRomanKeyboard:(BaramRomanKeyboardType)keyboard {
  romanKeyboard = keyboard;
}

- (BOOL)commitByWord {
  return commitByWord;
}

- (void)setCommitByWord:(BOOL)mode {
  commitByWord = mode;
}

- (BOOL)orderCorrection {
  return orderCorrection;
}

- (void)setOrderCorrection:(BOOL)correct {
  orderCorrection = correct;
}

- (BOOL)process:(NSString *)string modifierFlags:(NSUInteger)modifiers commit:(BOOL*)commit {
  char ascii;
  char adjustedAscii;
  BOOL ret;
	
  // Adjust english keyboard layout
  ascii = [string characterAtIndex:0];
  adjustedAscii = [self adjustKeyboardLayout:ascii];
	
  // Adjust Capslock flag
  if (modifiers & NSAlphaShiftKeyMask) {
    if (!(modifiers & NSShiftKeyMask) && isalpha(adjustedAscii))
      adjustedAscii = tolower(adjustedAscii);
  }
		
  // libhangul process
  ret = hangul_ic_process(hic, adjustedAscii);
  *commit = NO;

  if (ret) {
    [inputStringBuffer appendString:string];
    
    NSString *commitString = [self commitString];

    if ([commitString length]) 
      [originalStringBuffer appendString:commitString];
  }

  ucschar *buf = (ucschar *)hangul_ic_get_preedit_string(hic);

  // if there is non hangul character in internal buffer, set commit.
  for (; *buf != nil; buf++) {
    if (!(hangul_is_jamo(*buf) ||
	  hangul_is_cjamo(*buf) || 
	  hangul_is_syllable(*buf))) {
      *commit = YES;
      return ret;
    }
  }

  buf = (ucschar *)hangul_ic_get_commit_string(hic);

  // if there is non hangul character in internal buffer, set commit.
  for (; *buf != nil; buf++) {
    if (!(hangul_is_jamo(*buf) ||
	  hangul_is_cjamo(*buf) || 
	  hangul_is_syllable(*buf))) {
      *commit = YES;
      return ret;
    }
  }

  return ret;
}

- (BOOL)backspace {
  if ([inputStringBuffer length])
    [inputStringBuffer deleteCharactersInRange:NSMakeRange([inputStringBuffer length]-1, 1)];

  if ([[self preeditString] length] > 0) {
    hangul_ic_backspace(hic);

    return YES;
  } else {
    if ([originalStringBuffer length] > 0) {
      [originalStringBuffer deleteCharactersInRange:NSMakeRange([originalStringBuffer length]-1, 1)];

      if (commitByWord)
	return YES;
    }

    return NO;
  }
}

- (NSString *)preeditString {
  ucschar  *preedit = (ucschar *)hangul_ic_get_preedit_string(hic);
  return UTF32toNSString(preedit);
}

- (NSString *)commitString {
  ucschar  *commit = (ucschar *)hangul_ic_get_commit_string(hic);
  return UTF32toNSString(commit);
}

- (NSString *)originalString {
  NSString *string = [NSString stringWithFormat:@"%@%@", originalStringBuffer, [self preeditString]];

  return string;
}

- (NSString *)inputString {
  NSString *string = [NSString stringWithString:inputStringBuffer];

  return string;
}

- (char)adjustKeyboardLayout:(char)ascii {
  switch (romanKeyboard) {
  case BaramRomanKeyboardTypeUS:
    return ascii;
  case BaramRomanKeyboardTypeDvorak:
  case BaramRomanKeyboardTypeDvorakQwerty:
    return hangul_ic_dvorak_to_qwerty(ascii);
  case BaramRomanKeyboardTypeGerman:
    return [self adjustQwertzKeyboardLayout:ascii];
  default:
    NSLog(@"BaramHangul: unknown roman keyboard layout = %d", romanKeyboard);
    return ascii;
  }
}

- (char)adjustQwertzKeyboardLayout:(char)ascii {
  if (ascii == 'y')
    return 'z';
  else if (ascii == 'Y')
    return 'Z';
  else if (ascii == 'z')
    return 'y';
  else if (ascii == 'Z')
    return 'Y';
  else 
    return ascii;
}


bool callback_on_transition(HangulInputContext* hic, ucschar c, const ucschar* preedit, void* data) {
  BOOL orderCorrection = objc_msgSend(data, @selector(orderCorrection));

  if (!orderCorrection) {
    if (hangul_is_choseong(c)) {
      if (hangul_ic_has_jungseong(hic) || hangul_ic_has_jongseong(hic)) {
        return NO;
      }
    }

    if (hangul_is_jungseong(c)) {
      if (hangul_ic_has_jongseong(hic)) {
        return NO;
      }
    }
  }

  return YES;
}

@end
