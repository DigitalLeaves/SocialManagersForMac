//
//  SMSocialManagerDelegate.h
//  The Pillow Book for Mac
//
//  Created by Nacho on 03/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMSocialManager.h"


typedef enum {
    SMRequestTypeReadConfiguration = 0,
    SMRequestTypePost,
    SMRequestTypePostWithMedia,
    SMRequestTypePostWithLocation,
    SMRequestTypePostWithMediaAndLocation,
    SMRequestTypeFetchTimeLine,
} SMRequestType;

@class SMSocialManager;

@protocol SMSocialManagerDelegate <NSObject>

/** 
 * @brief Informs the delegate that the last operation was successful.
 * @param returnCode The HTTP return code returned by the server.
 * @param result a NSDictionary with the results of the operation, extracted in JSON format.
 */
- (void) socialManager: (SMSocialManager *) socialManager requestSucceedWithReturnCode: (NSUInteger) returnCode andResult: (NSDictionary *) result;

/**
 * @brief Informs the delegate that the last operation failed.
 * @param returnCode The HTTP return code returned by the server.
 * @param error The NSError if any. This field would be empty in the case of a valid request that returned an error code by the server (i.e: if trying to post an image with a size bigger than allowed). In that case the returnCode must be examined in order to determine the error.
 */
- (void) socialManager: (SMSocialManager *) socialManager requestFailedWithReturnCode: (NSUInteger) returnCode andError: (NSError *) error;

/** 
 * @brief the requested operation is not allowed by this Social Manager.
 * The SocialManager will invoke this method on its delegate to inform it that the requested operation is not supported by this concrete Social Manager.
 */
- (void) socialManager: (SMSocialManager *) socialManager operationNotPermitted: (SMRequestType) operationType;

@optional

/** 
 * @brief informs the delegate that the login was refused for this social network
 */
- (void) socialManager: (SMSocialManager *) socialManager loginRefusedWithError: (NSString *) error;

@end
