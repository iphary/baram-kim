//
//  ShortcutRecorder.h
//  Baram
//
//  Created by Ha-young Jeong on 10/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Unicode values of some keyboard glyphs
enum {
  KeyboardTabRightGlyph       = 0x21E5,
  KeyboardTabLeftGlyph        = 0x21E4,
  KeyboardCommandGlyph        = 0x2318,
  KeyboardOptionGlyph         = 0x2325,
  KeyboardShiftGlyph          = 0x21E7,
  KeyboardControlGlyph        = 0x2303,
  KeyboardReturnGlyph         = 0x2305,
  KeyboardReturnR2LGlyph      = 0x21A9,	
  KeyboardDeleteLeftGlyph     = 0x232B,
  KeyboardDeleteRightGlyph    = 0x2326,	
  KeyboardPadClearGlyph       = 0x2327,
  KeyboardLeftArrowGlyph      = 0x2190,
  KeyboardRightArrowGlyph     = 0x2192,
  KeyboardUpArrowGlyph        = 0x2191,
  KeyboardDownArrowGlyph      = 0x2193,
  KeyboardPageDownGlyph       = 0x21DF,
  KeyboardPageUpGlyph         = 0x21DE,
  KeyboardNorthwestArrowGlyph = 0x2196,
  KeyboardSoutheastArrowGlyph = 0x2198,
  KeyboardEscapeGlyph         = 0x238B,
  KeyboardHelpGlyph           = 0x003F,
  KeyboardUpArrowheadGlyph    = 0x2303,
};

// Special keys
enum {
  kSRKeysF1 = 122,
  kSRKeysF2 = 120,
  kSRKeysF3 = 99,
  kSRKeysF4 = 118,
  kSRKeysF5 = 96,
  kSRKeysF6 = 97,
  kSRKeysF7 = 98,
  kSRKeysF8 = 100,
  kSRKeysF9 = 101,
  kSRKeysF10 = 109,
  kSRKeysF11 = 103,
  kSRKeysF12 = 111,
  kSRKeysF13 = 105,
  kSRKeysF14 = 107,
  kSRKeysF15 = 113,
  kSRKeysF16 = 106,
  kSRKeysF17 = 64,
  kSRKeysF18 = 79,
  kSRKeysF19 = 80,
  kSRKeysSpace = 49,
  kSRKeysDeleteLeft = 51,
  kSRKeysDeleteRight = 117,
  kSRKeysPadClear = 71,
  kSRKeysLeftArrow = 123,
  kSRKeysRightArrow = 124,
  kSRKeysUpArrow = 126,
  kSRKeysDownArrow = 125,
  kSRKeysSoutheastArrow = 119,
  kSRKeysNorthwestArrow = 115,
  kSRKeysEscape = 53,
  kSRKeysPageDown = 121,
  kSRKeysPageUp = 116,
  kSRKeysReturnR2L = 36,
  kSRKeysReturn = 76,
  kSRKeysTabRight = 48,
  kSRKeysHelp = 114
};

@interface ShortcutRecorder : NSTextView {
  BOOL       valid;
  NSUInteger keyCode;
  NSUInteger modifierFlags;
  NSString   *characters;
  NSString   *charactersIgnoringModifiers;
}

@property (assign) BOOL       valid;
@property (assign) NSUInteger keyCode;
@property (assign) NSUInteger modifierFlags;
@property (copy)   NSString   *characters;
@property (copy)   NSString   *charactersIgnoringModifiers;

- (NSString *)stringForModifierFlags;
- (NSString *)stringForKeyCode;

@end
