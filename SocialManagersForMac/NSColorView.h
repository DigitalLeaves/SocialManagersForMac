//
//  NSColorView.h
//  The Pillow Book for Mac
//
//  Created by Nacho on 24/01/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColorView : NSView

@property (nonatomic, strong) NSColor * backgroundColor;
@property (nonatomic, strong) NSColor * borderColor;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat cornerRadius;

- (id) initWithFrame:(NSRect)frameRect andBackgroundColor: (NSColor *) color;

- (id) initWithFrame:(NSRect)frameRect borderColor: (NSColor *) borderColor borderWidth: (CGFloat) borderWidth andBackgroundColor:(NSColor *)color;

- (id) initWithFrame:(NSRect)frameRect borderColor:(NSColor *)borderColor borderWidth:(CGFloat)borderWidth backgroundColor:(NSColor *)color andCornerRadius: (CGFloat) cornerRadius;

@end
