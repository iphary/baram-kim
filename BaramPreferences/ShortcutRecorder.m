//
//  ShortcutRecorder.m
//  Baram
//
//  Created by Ha-young Jeong on 10/13/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ShortcutRecorder.h"
#import "SRKeyCodeTransformer.h"

@implementation ShortcutRecorder
@synthesize valid;
@synthesize keyCode;
@synthesize modifierFlags;
@synthesize characters;
@synthesize charactersIgnoringModifiers;

- (id)initWithFrame:(NSRect)frame
{
  if (self = [super initWithFrame:frame]) {
    [self drawPageBorderWithSize:NSMakeSize(1, 1)];
  }

  return self;
}

- (BOOL)shouldDrawInsertionPoint
{
  return NO;
}

- (void)update
{
  NSDictionary *attributes = 
    [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:18.0], 
		  NSFontAttributeName, nil];
  NSAttributedString *string = 
    [[NSAttributedString alloc] initWithString:[self description]
				attributes:attributes];
  [[self textStorage] setAttributedString:string];
  [string release];

  [self alignCenter:nil];
}

- (void)keyDown:(NSEvent *)theEvent
{
  [self setValid:YES];
  [self setKeyCode:[theEvent keyCode]];
  [self setModifierFlags:[theEvent modifierFlags]];
  [self setCharacters:[theEvent characters]];
  [self setCharactersIgnoringModifiers:[theEvent charactersIgnoringModifiers]];

  [self update];
}

- (NSString *)description
{
  if (![self valid])
    return nil;

  NSString *string = [self stringForKeyCode];
  if (string == nil)
    string = [[self charactersIgnoringModifiers] uppercaseString];

  return [NSString stringWithFormat:@"%@%@", [self stringForModifierFlags], string, nil];
}

- (NSString *)stringForModifierFlags
{
  NSString *modifierFlagsString = [NSString stringWithFormat:@"%@%@%@%@", 
					    ([self modifierFlags] & NSControlKeyMask ? [NSString stringWithFormat:@"%C", KeyboardControlGlyph] : @"" ),
					    ([self modifierFlags] & NSAlternateKeyMask ? [NSString stringWithFormat:@"%C", KeyboardOptionGlyph] : @"" ),
					    ([self modifierFlags] & NSShiftKeyMask ? [NSString stringWithFormat:@"%C", KeyboardShiftGlyph] : @"" ),
					    ([self modifierFlags] & NSCommandKeyMask ? [NSString stringWithFormat:@"%C", KeyboardCommandGlyph] : @"" )];
  
  return modifierFlagsString;
}

- (NSString *)stringForKeyCode
{
  static SRKeyCodeTransformer *keyCodeTransformer = nil;
  if ( !keyCodeTransformer )
    keyCodeTransformer = [[SRKeyCodeTransformer alloc] init];
  return [keyCodeTransformer transformedValue:[NSNumber numberWithUnsignedInteger:[self keyCode]]];
}

@end
