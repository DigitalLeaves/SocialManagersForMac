//
//  SMSocialManager.m
//  The Pillow Book for Mac
//
//  Created by Nacho on 03/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import "SMSocialManager.h"
#import "NSImage+ResizeAndCrop.h"
#import "NSImage+NSDataRepresentation.h"

#define kSMDefaultMaxSizeForAdditionalMedia     1048576

@implementation SMSocialManager

- (id)init
{
    self = [super init];
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
        self.state = SMSocialManagerStateUndefined;
    }
    return self;
}

- (ACAccountType *) accountType {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSArray *) accounts {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (ACAccount *) accountForUsername:(NSString *)username {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSUInteger) maxSizeForAdditionalMedia {
    return kSMDefaultMaxSizeForAdditionalMedia;
}

#pragma mark social account operations

- (NSURL *) urlForRequest:(SMRequestType)requestType {
    // to be overriden by subclasses.
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSDictionary *) parametersForRequest: (SMRequestType) requestType withValues: (NSDictionary *) values {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (BOOL) requestAllowed:(SMRequestType)requestType {
    // to be overriden by subclasses
    return NO;
}

- (NSString *) serviceTypeForThisSocialManager {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void) performRequest: (NSURL *) requestURL ofType: (SLRequestMethod) requestMethod forUser: (NSString *) username withParams: (NSDictionary *) params andAdditionalData: (NSArray *) additionalMedia {
        
    //  Step 1:  Obtain access to the user's accounts
    [self.accountStore
     requestAccessToAccountsWithType:[self accountType]
     options:NULL
     completion:^(BOOL granted, NSError *error) {
         if (granted) {
             //  Step 2:  Create a request
             SLRequest *request =
             [SLRequest requestForServiceType:[self serviceTypeForThisSocialManager]
                                requestMethod:requestMethod
                                          URL:requestURL
                                   parameters:params];
             
             // add multipart additional media (if any)
             if (additionalMedia && additionalMedia.count > 0) {
                 for (SMAdditionalMultipartData * media in additionalMedia) {
                     [request addMultipartData:media.data withName:media.name type:media.type filename:media.filename];
                 }
             }
             
             //  Attach an account to the request
             [request setAccount:[self accountForUsername:username]];
             
             //  Step 3:  Execute the request
             [request performRequestWithHandler:^(NSData *responseData,
                                                  NSHTTPURLResponse *urlResponse,
                                                  NSError *error) {
                 if (responseData) {
                     if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                         NSError *jsonError;
                         NSDictionary *result =
                         [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:NSJSONReadingAllowFragments error:&jsonError];
                         
                         if (result) {
                             if (self.delegate) [self.delegate socialManager: self requestSucceedWithReturnCode:urlResponse.statusCode andResult:result];
                         }
                         else {
                             // Our JSON deserialization went awry
                             if (self.delegate) [self.delegate socialManager: self requestFailedWithReturnCode:urlResponse.statusCode andError:jsonError];
                         }
                     }
                     else {
                         // The server did not respond successfully... were we rate-limited?
                         if (self.delegate) [self.delegate socialManager: self requestFailedWithReturnCode:urlResponse.statusCode andError:nil];
                     }
                 }
             }];
         }
         else {
             // Access was not granted, or an error occurred
             if (self.delegate) [self.delegate socialManager: self requestFailedWithReturnCode:0 andError:error];
         }
     }];
}

- (void) requestConfigurationForUser: (NSString *) username {
    SMRequestType requestType = SMRequestTypeReadConfiguration;

    // First we must check if our social manager allows this operation
    if (![self requestAllowed:requestType]) {
        if (self.delegate) [self.delegate socialManager: self operationNotPermitted:requestType];
        return;
    } else { // request allowed
        NSURL * requestURL = [self urlForRequest:requestType];
        SLRequestMethod reqMethod = [self requestMethodForRequest:requestType];
        NSDictionary * requestNames = [NSDictionary dictionaryWithObjectsAndKeys: username, kSMRequestParameterUsername, nil];
        NSDictionary * params = [self parametersForRequest:requestType withValues:requestNames];
        
        [self performRequest:requestURL ofType:reqMethod forUser:username withParams:params andAdditionalData:nil];
    }
}

/** Post a message without link or images */
- (void) postMessage: (NSString *) message forUser: (NSString *) username {
    SMRequestType requestType = SMRequestTypePost;
    
    // First we must check if our social manager allows this operation
    if (![self requestAllowed:requestType]) {
        if (self.delegate) [self.delegate socialManager: self operationNotPermitted:requestType];
        return;
    } else { // request allowed
        NSURL * requestURL = [self urlForRequest:requestType];
        SLRequestMethod reqMethod = [self requestMethodForRequest:requestType];
        NSDictionary * requestNames = [NSDictionary dictionaryWithObjectsAndKeys:
                                       username, kSMRequestParameterUsername,
                                       message, kSMRequestParameterMessage,
                                       nil];
        NSDictionary *params = [self parametersForRequest:requestType withValues:requestNames];

        [self performRequest:requestURL ofType:reqMethod forUser:username withParams:params andAdditionalData:nil];
    }
}


- (void) postMessage: (NSString *) message forUser: (NSString *) username withImage: (NSImage *) image {
    
    SMRequestType requestType = SMRequestTypePostWithMedia;

    // First we must check if our social manager allows this operation
    if (![self requestAllowed:requestType]) {
        if (self.delegate) [self.delegate socialManager: self operationNotPermitted:requestType];
        return;
    } else { // request allowed
        NSURL * requestURL = [self urlForRequest:requestType];
        SLRequestMethod reqMethod = [self requestMethodForRequest:requestType];
        NSDictionary * requestNames = [NSDictionary dictionaryWithObjectsAndKeys:
                                       username, kSMRequestParameterUsername,
                                       message, kSMRequestParameterMessage,
                                       nil];
        NSDictionary *params = [self parametersForRequest:requestType withValues:requestNames];
        SMAdditionalMultipartData * ampd = [self multipartDataForImage:image];
        [self performRequest:requestURL ofType: reqMethod forUser:username withParams:params andAdditionalData:@[ampd]];
    }
}

- (void) postMessage:(NSString *)message forUser:(NSString *)username withImage: (NSImage *) image andLocation:(CLLocationCoordinate2D)location {
    SMRequestType requestType = SMRequestTypePostWithMediaAndLocation;
    
    // First we must check if our social manager allows this operation
    if (![self requestAllowed:requestType]) {
        if (self.delegate) [self.delegate socialManager: self operationNotPermitted:requestType];
        return;
    } else { // request allowed
        NSURL * requestURL = [self urlForRequest:requestType];
        SLRequestMethod reqMethod = [self requestMethodForRequest:requestType];
        NSDictionary * requestNames = [NSDictionary dictionaryWithObjectsAndKeys:
                                       username, kSMRequestParameterUsername,
                                       message, kSMRequestParameterMessage,
                                       [NSString stringWithFormat:@"%f", location.longitude], kSMRequestParameterLongitude,
                                       [NSString stringWithFormat:@"%f", location.latitude], kSMRequestParameterLatitude,
                                       nil];
        NSDictionary *params = [self parametersForRequest:requestType withValues:requestNames];
        SMAdditionalMultipartData * ampd = [self multipartDataForImage:image];
        [self performRequest:requestURL ofType: reqMethod forUser:username withParams:params andAdditionalData:@[ampd]];
    }
}

- (void) postMessage: (NSString *) message forUser: (NSString *) username withLocation: (CLLocationCoordinate2D) location {
    SMRequestType requestType = SMRequestTypePostWithLocation;
    
    // First we must check if our social manager allows this operation
    if (![self requestAllowed:requestType]) {
        if (self.delegate) [self.delegate socialManager: self operationNotPermitted:requestType];
        return;
    } else { // request allowed
        NSURL * requestURL = [self urlForRequest:requestType];
        SLRequestMethod reqMethod = [self requestMethodForRequest:requestType];
        NSDictionary * requestNames = [NSDictionary dictionaryWithObjectsAndKeys:
                                       username, kSMRequestParameterUsername,
                                       message, kSMRequestParameterMessage,
                                       [NSString stringWithFormat:@"%f", location.longitude], kSMRequestParameterLongitude,
                                       [NSString stringWithFormat:@"%f", location.latitude], kSMRequestParameterLatitude,
                                       nil];
        NSDictionary *params = [self parametersForRequest:requestType withValues:requestNames];
        
        [self performRequest:requestURL ofType:reqMethod forUser:username withParams:params andAdditionalData:nil];
    }
}

- (void)fetchTimelinePosts: (NSUInteger) numPosts forUser:(NSString *)username
{
    SMRequestType requestType = SMRequestTypeFetchTimeLine;

    // First we must check if our social manager allows this operation
    if (![self requestAllowed:requestType]) {
        if (self.delegate) [self.delegate socialManager: self operationNotPermitted:requestType];
        return;
    } else { // request allowed
        NSURL * requestURL = [self urlForRequest:requestType];
        SLRequestMethod reqMethod = [self requestMethodForRequest:requestType];
        NSDictionary * requestNames = [NSDictionary dictionaryWithObjectsAndKeys:
                                       username, kSMRequestParameterUsername,
                                       [NSString stringWithFormat:@"%ld", numPosts], kSMRequestParameterNumOfPosts,
                                       nil];
        NSDictionary *params = [self parametersForRequest:requestType withValues:requestNames];
        [self performRequest:requestURL ofType: reqMethod forUser:username withParams:params andAdditionalData:nil];
    }
}

#pragma mark media and image manipulation methods

- (NSData *) validMediaFromImage: (NSImage *) image {
    NSData * imageData = [image JPEGRepresentation];
    NSUInteger maxSize = [self maxSizeForAdditionalMedia];
    while (imageData.length > maxSize) {
        NSImage * image = [[NSImage alloc] initWithData:imageData];
        CGFloat newWidth = image.size.width / 2.0;
        CGFloat newHeight = image.size.height / 2.0;
        image = [image imageScaledToFitSize:NSMakeSize(newWidth, newHeight)];
        imageData = [image JPEGRepresentation];
    }
    
    return imageData;
}

- (NSString *) imageMimeForType: (NSBitmapImageFileType) imageType {
    switch (imageType) {
        case NSJPEGFileType:
            return @"image/jpeg";
            break;
        case NSGIFFileType:
            return @"image/gif";
        case NSPNGFileType:
            return @"image/png";
        default:
            return @"image";
            break;
    }
}

- (NSString *) imageFileNameForType: (NSBitmapImageFileType) imageType {
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd-HHmmss"];
    NSString * extension;
    
    switch (imageType) {
        case NSJPEGFileType:
            extension = @"jpg";
            break;
        case NSGIFFileType:
            extension = @"gif";
        case NSPNGFileType:
            extension = @"png";
        default:
            extension = @"img";
            break;
    }
    return [NSString stringWithFormat:@"photo-%@.%@", [formatter stringFromDate:[NSDate date]], extension];
}

- (SMAdditionalMultipartData *) multipartDataForImage: (NSImage *) image {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (SLRequestMethod) requestMethodForRequest: (SMRequestType) requestType {
    [self doesNotRecognizeSelector:_cmd];
    return SLRequestMethodGET;
}

@end



















