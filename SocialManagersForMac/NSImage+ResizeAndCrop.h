//
//  NSImage+ResizeAndCrop.h
//  The Pillow Book for Mac
//
//  Created by Nacho on 05/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (ResizeAndCrop)

typedef enum {
    MGImageResizeCrop,
    MGImageResizeCropStart,
    MGImageResizeCropEnd,
    MGImageResizeScale
} MGImageResizingMethod;

- (void)drawInRect:(NSRect)dstRect operation:(NSCompositingOperation)op fraction:(float)delta method:(MGImageResizingMethod)resizeMethod;
- (NSImage *)imageToFitSize:(NSSize)size method:(MGImageResizingMethod)resizeMethod;
- (NSImage *)imageToFitRect:(NSRect)rect method:(MGImageResizingMethod)resizeMethod;
- (NSImage *)imageCroppedToFitSize:(NSSize)size;
- (NSImage *)imageScaledToFitSize:(NSSize)size;
- (NSImage *) imageFromRect: (NSRect) rect;

@end
