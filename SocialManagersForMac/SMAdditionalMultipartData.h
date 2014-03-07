//
//  SMAdditionalMultipartData.h
//  The Pillow Book for Mac
//
//  Created by Nacho on 03/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMAdditionalMultipartData : NSObject

- (id) initWithData: (NSData *) data name: (NSString *) name type: (NSString *) type andFilename: (NSString *) filename;

@property (nonatomic, strong) NSData * data;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * filename;

@end
