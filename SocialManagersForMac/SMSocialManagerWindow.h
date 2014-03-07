//
//  SMSocialManagerWindow.h
//  The Pillow Book for Mac
//
//  Created by Nacho on 04/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SMSocialManagerWindow : NSWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;
- (void) setContentView:(NSView *)aView;

@end
