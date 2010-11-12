/*
  Filename : BIMModeIndicator.h
  This file is a part of Baram Input Method for Mac OS X.

  Copyright (C) 2008 Ha-young Jeong <sixt06@gmail.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/

#import "BIMModeIndicator.h"

@implementation BIMModeIndicator

- (id)init 
{
  if(self = [super init]) {
    _window = [[NSWindow alloc] initWithContentRect:NSZeroRect
				styleMask:NSBorderlessWindowMask
				backing:NSBackingStoreBuffered
				defer:YES];
    [_window setBackgroundColor:[NSColor clearColor]];
    [_window setOpaque:NO];
    [_window setIgnoresMouseEvents:YES];

    _inputMode = kBIMEnglishMode;
    _modeIcons = nil;

    [self setModeIcons:[NSDictionary dictionaryWithObjectsAndKeys:[NSImage imageNamed:@"english"], kBIMEnglishMode,
					      [NSImage imageNamed:@"hangul"], kBIMHangulMode,
					      [NSImage imageNamed:@"hiragana"], kBIMHiraganaMode,
					      [NSImage imageNamed:@"katakana"], kBIMKatakanaMode, nil]];

    [self prepareLayer];
    [self prepareAnimation];
  }

  return self;
}

- (void)dealloc
{
  [_modeIcons release];
  [_animation release];
  [_window release];

  [super dealloc];
}

- (void)setModeIcons:(NSDictionary *)icons
{
  [icons retain];

  if(_modeIcons) {
    [_modeIcons release];
  }

  _modeIcons = icons;
}

- (void)changeMode:(NSString *)mode
{
  _inputMode = mode;

  [self updateFrame];

  NSImage *image = [_modeIcons objectForKey:mode];
  NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]]; 

  [self setImage:(id)[rep CGImage]];
}

- (NSString *)currentInputMode
{
  return _inputMode;
}

- (void)show:(NSPoint)topleft level:(int)level
{
  [self updateFrame];

  [_window setFrameTopLeftPoint:topleft];
  [_window setLevel:level];
  [_window orderFront:nil];

  [_rootLayer addAnimation:_animation forKey:@"fadeOut"];
}

- (void)hide
{
  [_window orderOut:nil];
}

- (void)prepareLayer
{
  _rootLayer = [CALayer layer];
  _rootLayer.opacity = 0.0;

  NSView* view = [_window contentView];

  [view setLayer:_rootLayer];
  [view setWantsLayer:YES];
}

- (void)prepareAnimation
{
  _animation = [[CABasicAnimation animationWithKeyPath:@"opacity"] retain];

  _animation.duration = 2.0;
  _animation.fromValue = [NSNumber numberWithFloat:1.0];
  _animation.toValue = [NSNumber numberWithFloat:0];
  _animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.5 :0.0 :0.5 :0.0];
}

- (void)updateFrame
{
  NSRect rect = [_window frame];
  NSSize iconSize = rect.size;
  NSImage *icon = [_modeIcons objectForKey:_inputMode];
  NSArray *reps = [icon representations];

  if([reps count]) {
    NSImageRep* image = [reps objectAtIndex:0];
    iconSize = NSMakeSize(image.pixelsWide, image.pixelsHigh);
  }

  if(!NSEqualSizes(rect.size, iconSize)) {
    rect.origin.y += rect.size.height - iconSize.height;
    rect.size = iconSize;

    [self setImage:0];

    [_window setFrame:rect display:YES];
  }
}

- (void)setImage:(id)image
{
  [CATransaction begin];
  [CATransaction setValue:[NSNumber numberWithFloat:0.0]
		 forKey:kCATransactionAnimationDuration];

  _rootLayer.contents = image;

  [CATransaction commit];
}

@end
