//
//  SMAdditionalMultipartData.m
//  The Pillow Book for Mac
//
//  Created by Nacho on 03/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import "SMAdditionalMultipartData.h"

@implementation SMAdditionalMultipartData

- (id) initWithData:(NSData *)data name:(NSString *)name type:(NSString *)type andFilename:(NSString *)filename {
    self = [super init];
    if (self) {
        self.data = data;
        self.name = name;
        self.type = type;
        self.filename = filename; 
    }
    return self;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"Social Manager additional multipart data: data size: %ld, data name: %@, data type:%@, data filename: %@",
            self.data.length, self.name, self.type, self.filename];
}

@end
