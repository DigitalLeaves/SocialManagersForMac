//
//  NSImage+NSDataRepresentation.h
//  The Pillow Book for Mac
//
//  Created by Nacho on 03/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (NSDataRepresentation)

- (NSData* )representationForFileType: (NSBitmapImageFileType) fileType properties: (NSDictionary *) properties;

- (NSData *)JPEGRepresentation;
- (NSData *)JPEGRepresentationWithCompressionFactor: (CGFloat) compressionFactor;
- (NSData *)JPEG2000Representation;
- (NSData *)PNGRepresentation;
- (NSData *)GIFRepresentation;
- (NSData *)BMPRepresentation;

@end
