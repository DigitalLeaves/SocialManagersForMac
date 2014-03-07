//
//  NSImage+NSDataRepresentation.m
//  The Pillow Book for Mac
//
//  Created by Nacho on 03/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import "NSImage+NSDataRepresentation.h"

@implementation NSImage (NSDataRepresentation)

- (NSData* )representationForFileType: (NSBitmapImageFileType) fileType properties: (NSDictionary *) properties
{
	NSData *tiffRep = [self TIFFRepresentation];
	NSBitmapImageRep *bitmap = [NSBitmapImageRep imageRepWithData:tiffRep];
	NSData *imageData = [bitmap representationUsingType:fileType properties:properties];
	return imageData;
}

- (NSData *)JPEGRepresentationWithCompressionFactor: (CGFloat) compressionFactor {
	return [self representationForFileType: NSJPEGFileType properties:
            [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:compressionFactor] forKey:NSImageCompressionFactor]];
}

- (NSData *)JPEGRepresentation
{
    return [self representationForFileType:NSJPEGFileType properties:nil];
}

- (NSData *)PNGRepresentation
{
	return [self representationForFileType: NSPNGFileType properties:nil];
}

- (NSData *)JPEG2000Representation
{
	return [self representationForFileType: NSJPEG2000FileType properties:nil];
}

- (NSData *)GIFRepresentation
{
	return [self representationForFileType: NSGIFFileType properties:nil];
}

- (NSData *)BMPRepresentation
{
	return [self representationForFileType: NSBMPFileType properties:nil];
}

@end
