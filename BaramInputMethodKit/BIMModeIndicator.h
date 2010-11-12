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

#import <Cocoa/Cocoa.h>
#import <BIMConstants.h>
#import <QuartzCore/QuartzCore.h>

@interface BIMModeIndicator : NSObject {
  NSWindow         *_window;
  NSString         *_inputMode;
  NSDictionary     *_modeIcons;
  CALayer          *_rootLayer;
  CABasicAnimation *_animation;
}

- (void)setModeIcons:(NSDictionary *)icons;
- (void)changeMode:(NSString *)mode;
- (NSString *)currentInputMode;
- (void)show:(NSPoint)topleft level:(int)level;
- (void)hide;

// private methods
- (void)prepareLayer;
- (void)prepareAnimation;
- (void)updateFrame;
- (void)setImage:(id)image;

@end

