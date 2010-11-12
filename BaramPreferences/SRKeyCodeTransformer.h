//
//  SRKeyCodeTransformer.h
//  ShortcutRecorder
//
//  Copyright 2006-2007 Contributors. All rights reserved.
//
//  License: BSD
//
//  Contributors:
//      David Dauer
//      Jesper
//      Jamie Kirkpatrick

#import <Cocoa/Cocoa.h>

#define SRLoc(key) NSLocalizedString(key, nil)
#define SRInt(x) [NSNumber numberWithInteger:x]
#define SRChar(x) [NSString stringWithFormat: @"%C", x]

@interface SRKeyCodeTransformer : NSValueTransformer 
{
}
 
@end
