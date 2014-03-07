//
//  NSColorView.m
//  The Pillow Book for Mac
//
//  Created by Nacho on 24/01/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import "NSColorView.h"

@implementation NSColorView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = YES;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [NSColor whiteColor];
        self.borderColor = [NSColor clearColor];
        self.borderWidth = 0;
        self.cornerRadius = 1.0;
    }
    return self;
}

- (id) initWithFrame:(NSRect)frameRect andBackgroundColor:(NSColor *)color {
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code here.
        self.wantsLayer = YES;
        self.layer.masksToBounds = YES;
        self.backgroundColor = color;
        self.borderColor = [NSColor blackColor];
        self.borderWidth = 1;
        self.cornerRadius = 1.0;
    }
    return self;
}

- (id) initWithFrame:(NSRect)frameRect borderColor:(NSColor *)borderColor borderWidth:(CGFloat)borderWidth andBackgroundColor:(NSColor *)color {
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code here.
        self.wantsLayer = YES;
        self.layer.masksToBounds = YES;
        self.backgroundColor = color;
        self.borderColor = borderColor;
        self.borderWidth = borderWidth;
        self.cornerRadius = 1.0;
    }
    return self;
}

- (id) initWithFrame:(NSRect)frameRect borderColor:(NSColor *)borderColor borderWidth:(CGFloat)borderWidth backgroundColor:(NSColor *)color andCornerRadius: (CGFloat) cornerRadius {
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code here.
        self.wantsLayer = YES;
        self.layer.masksToBounds = YES;
        self.backgroundColor = color;
        self.borderColor = borderColor;
        self.borderWidth = borderWidth;
        self.cornerRadius = cornerRadius;
    }
    return self;
}

- (void) setBorderColor:(NSColor *)borderColor {
    _borderColor = borderColor;
    if (_borderWidth <= 0) _borderWidth = 1.0;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self.backgroundColor setFill];
    [NSBezierPath fillRect:dirtyRect];
    
    if (self.borderWidth > 0.0) {
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSInsetRect(dirtyRect, 0.5 * self.borderWidth, 0.5 * self.borderWidth)];
        [path setLineWidth:self.borderWidth];
        [self.borderColor setStroke];
        [path stroke];
    }
	[super drawRect:dirtyRect];
    
}


@end
