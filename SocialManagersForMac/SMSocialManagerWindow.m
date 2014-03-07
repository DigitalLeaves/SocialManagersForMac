//
//  SMSocialManagerWindow.m
//  The Pillow Book for Mac
//
//  Created by Nacho on 04/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import "SMSocialManagerWindow.h"

@implementation SMSocialManagerWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:bufferingType defer:flag];
    
    if ( self )
    {
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setMovableByWindowBackground:TRUE];
        [self setStyleMask:NSBorderlessWindowMask];
        [self setHasShadow:YES];
    }
    
    return self;
}

- (void) setContentView:(NSView *)aView
{
    aView.wantsLayer            = YES;
    aView.layer.frame           = aView.frame;
    aView.layer.cornerRadius    = 10.0;
    aView.layer.masksToBounds   = YES;
    
    [super setContentView:aView];
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

@end
