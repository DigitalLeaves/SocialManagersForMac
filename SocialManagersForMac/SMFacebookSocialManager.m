//
//  SMFacebookSocialManager.m
//  The Pillow Book for Mac
//
//  Created by Nacho on 03/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import "SMFacebookSocialManager.h"

#define kTSMFacebookDefaultMaxDataSize  1048576     // 1 MB
#define kTSMFacebookPostName            @"message"
#define kTSMFacebookAppID               @"ENTERYOURAPPIDHERE"
#define kTSMFacebookImageName           @"picture"

#define kTSMFacebookViewControllerNibName   @"SMFacebookPostViewController"

@interface SMFacebookSocialManager ()

@property (nonatomic, strong) ACAccountType * facebookAccountType;
@property (nonatomic, strong) ACAccount * facebookAccount;

/** Window and view of the Post Dialog */
@property (nonatomic, strong) SMFacebookPostViewController * facebookPostVC;
@property (nonatomic, strong) SMSocialManagerWindow * facebookPostWindow;


@end

@implementation SMFacebookSocialManager

+ (SMFacebookSocialManager *) sharedInstance
{
    static dispatch_once_t once;
    static SMFacebookSocialManager * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init {
    self = [super init];
    if (self) {
        self.state = SMSocialManagerStateNotLogged;
        self.facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
        self.audience = ACFacebookAudienceEveryone;
        
        // request access to Facebook accounts:
        NSDictionary *options = @{ ACFacebookAppIdKey: kTSMFacebookAppID,ACFacebookPermissionsKey: @[@"email", @"read_stream"],ACFacebookAudienceKey: self.audience };

        [self.accountStore
         requestAccessToAccountsWithType:self.facebookAccountType
         options:options
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 self.state = SMSocialManagerStateLoggedIn;
                 NSArray *accounts = [self.accountStore accountsWithAccountType:self.facebookAccountType];
                 self.facebookAccount = [accounts lastObject];
                 //NSLog(@"Facebook account: %@", self.facebookAccount.username);
             } else {
                 self.state = SMSocialManagerStateLoginRefused;
                 //NSLog(@"Error login to Facebook: %@", error);
             }
         }];

    }
    return self;
}


- (ACAccountType *) facebookAccountType {
    if (!_facebookAccountType) {
        _facebookAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierFacebook];
    }
    return _facebookAccountType;
}
- (ACAccount *) accountForUsername: (NSString *) username {
    NSArray *accounts = [self.accountStore accountsWithAccountType:[self facebookAccountType]];
    if (accounts) {
        for (ACAccount * account in accounts) {
            if ([account.username isEqualToString:username]) return account;
        }
    }
    return nil;
}

- (NSArray *) accounts {
    return [self.accountStore accountsWithAccountType:[self facebookAccountType]];
}

- (ACAccountType *) accountType {
    return self.facebookAccountType;
}

- (NSString *) currentAccountUsername {
    if (self.facebookAccount) {
        return self.facebookAccount.username;
    }
    return nil;
}

- (NSUInteger) maxSizeForAdditionalMedia {
    return kTSMFacebookDefaultMaxDataSize;
}

- (SMAdditionalMultipartData *) multipartDataForImage: (NSImage *) image {
    NSData * validMedia = [self validMediaFromImage:image];
    return [[SMAdditionalMultipartData alloc] initWithData:validMedia name:kTSMFacebookImageName type:[self imageMimeForType:NSJPEGFileType] andFilename:[self imageFileNameForType:NSJPEGFileType]];
}

- (NSURL *) urlForRequest: (SMRequestType) requestType {
    
    switch (requestType) {
        case SMRequestTypeReadConfiguration:
            return nil;
            break;
        case SMRequestTypePost:
        case SMRequestTypePostWithLocation:
            return [NSURL URLWithString:@"https://graph.facebook.com/me/feed"];
            break;
        case SMRequestTypePostWithMedia:
        case SMRequestTypePostWithMediaAndLocation:
            return [NSURL URLWithString:@"https://graph.facebook.com/me/photos"];
            break;
        case SMRequestTypeFetchTimeLine:
            return [NSURL URLWithString:@"https://graph.facebook.com/me/home"];
            break;
        default:
            break;
    }
    return nil;
}

- (SLRequestMethod) requestMethodForRequest:(SMRequestType)requestType {
    switch (requestType) {
        case SMRequestTypeReadConfiguration:
            return SLRequestMethodGET;
            break;
        case SMRequestTypePost:
        case SMRequestTypePostWithLocation:
            return SLRequestMethodPOST;
            break;
        case SMRequestTypePostWithMedia:
        case SMRequestTypePostWithMediaAndLocation:
            return SLRequestMethodPOST;
            break;
        case SMRequestTypeFetchTimeLine:
            return SLRequestMethodGET;
            break;
        default:
            break;
    }
    return SLRequestMethodGET;
}

- (NSDictionary *) parametersForRequest:(SMRequestType)requestType withValues:(NSDictionary *)values {
    NSString * message;
    NSString * longitude, * latitude;
    
    switch (requestType) {
        case SMRequestTypeReadConfiguration:
            return [NSDictionary dictionary];
            break;
        case SMRequestTypePost:
            message = values[kSMRequestParameterMessage]; if (!message) message = @"";
            return @{@"message":message};
            break;
        case SMRequestTypePostWithLocation:
            message = values[kSMRequestParameterMessage]; if (!message) message = @"";
            latitude = values[kSMRequestParameterLatitude]? values[kSMRequestParameterLatitude]:@"0";
            longitude = values[kSMRequestParameterLongitude]? values[kSMRequestParameterLongitude]:@"0";
            return @{@"message":message, @"coordinates":@{@"latitude": latitude, @"longitude":longitude}};
            break;
        case SMRequestTypePostWithMedia:
            message = values[kSMRequestParameterMessage]; if (!message) message = @"";
            return @{@"message": message};
            break;
        case SMRequestTypePostWithMediaAndLocation:
            message = values[kSMRequestParameterMessage]; if (!message) message = @"";
            latitude = values[kSMRequestParameterLatitude]? values[kSMRequestParameterLatitude]:@"0";
            longitude = values[kSMRequestParameterLongitude]? values[kSMRequestParameterLongitude]:@"0";
            return @{@"message":message, @"coordinates":@{@"latitude": latitude, @"longitude":longitude}};
            break;
        case SMRequestTypeFetchTimeLine:
            return [NSDictionary dictionary];
            break;
        default:
            break;
    }
    return [NSDictionary dictionary];
}

- (NSString *) serviceTypeForThisSocialManager {
    return SLServiceTypeFacebook;
}

#pragma mark Social Network methods

- (BOOL) requestAllowed:(SMRequestType)requestType {
    switch (requestType) {
        case SMRequestTypeFetchTimeLine:
        case SMRequestTypePost:
        case SMRequestTypePostWithMedia:
        case SMRequestTypePostWithLocation:
        case SMRequestTypePostWithMediaAndLocation:
            return YES;
            break;
        case SMRequestTypeReadConfiguration:
            return NO;
            break;
        default:
            return NO;
            break;
    }
}

- (void) postMessage:(NSString *)message forUser:(NSString *)username {
    [self postMessage:message forUser:username withLocation:kCLLocationCoordinate2DInvalid];
}

- (void) postMessage:(NSString *)message forUser:(NSString *)username withLocation:(CLLocationCoordinate2D)location {
    // Specify App ID and permissions
    NSDictionary *options = @{ ACFacebookAppIdKey: kTSMFacebookAppID,ACFacebookPermissionsKey: @[@"publish_stream", @"publish_actions"],ACFacebookAudienceKey: self.audience };
    [self.accountStore requestAccessToAccountsWithType:self.facebookAccountType options:options
                                  completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES)
         {
             NSDictionary *parameters = nil;
             
             if (CLLocationCoordinate2DIsValid(location)) {
                 parameters = @{@"message":message};
             } else {
                 parameters = @{@"message":message, @"coordinates":@{@"latitude": [NSString stringWithFormat:@"%f", location.latitude], @"longitude":[NSString stringWithFormat:@"%f", location.longitude]}};
             }

             NSURL *feedURL = [self urlForRequest:SMRequestTypePost];
             
             SLRequest *feedRequest = [SLRequest
                                       requestForServiceType:SLServiceTypeFacebook
                                       requestMethod:SLRequestMethodPOST
                                       URL:feedURL
                                       parameters:parameters];
             
             // Post the request
             [feedRequest setAccount:self.facebookAccount];
             
             // Block handler to manage the response
             [feedRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
              {
                  if (!error) {
                      if (self.delegate) [self.delegate socialManager:self requestSucceedWithReturnCode:urlResponse.statusCode andResult:[NSDictionary dictionary]];
                  } else {
                      if (self.delegate) [self.delegate socialManager:self requestFailedWithReturnCode:urlResponse.statusCode andError:error];
                  }
              }];
         } else {
             if ([self.delegate respondsToSelector:@selector(socialManager:loginRefusedWithError:)]) [self.delegate socialManager:self loginRefusedWithError:[error localizedDescription]];
         }
     }];
}

- (void) postMessage:(NSString *)message forUser:(NSString *)username withImage:(NSImage *)image {
    [self postMessage:message forUser:username withImage:image andLocation:kCLLocationCoordinate2DInvalid];
}

- (void) postMessage:(NSString *)message forUser:(NSString *)username withImage:(NSImage *)image andLocation:(CLLocationCoordinate2D)location {
    
    // Specify App ID and permissions
    NSDictionary *options = @{ ACFacebookAppIdKey: kTSMFacebookAppID,ACFacebookPermissionsKey: @[@"publish_stream", @"publish_actions"],ACFacebookAudienceKey: self.audience };
    [self.accountStore requestAccessToAccountsWithType:self.facebookAccountType options:options
                                            completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES)
         {
             NSDictionary *parameters = nil;
             
             if (CLLocationCoordinate2DIsValid(location)) {
                 parameters = @{@"message":message};
             } else {
                 parameters = @{@"message":message, @"coordinates":@{@"latitude": [NSString stringWithFormat:@"%f", location.latitude], @"longitude":[NSString stringWithFormat:@"%f", location.longitude]}};
             }
             
             NSURL *feedURL = [self urlForRequest:SMRequestTypePostWithMedia];
             
             SLRequest *feedRequest = [SLRequest
                                       requestForServiceType:SLServiceTypeFacebook
                                       requestMethod:SLRequestMethodPOST
                                       URL:feedURL
                                       parameters:parameters];
             
             // Post the request
             [feedRequest setAccount:self.facebookAccount];
             SMAdditionalMultipartData * additionalData = [self multipartDataForImage:image];
             [feedRequest addMultipartData:additionalData.data withName:additionalData.name type:additionalData.type filename:additionalData.filename];
             
             // Block handler to manage the response
             [feedRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
              {
                  if (!error) {
                      if (self.delegate) [self.delegate socialManager:self requestSucceedWithReturnCode:urlResponse.statusCode andResult:[NSDictionary dictionary]];
                  } else {
                      if (self.delegate) [self.delegate socialManager:self requestFailedWithReturnCode:urlResponse.statusCode andError:error];
                  }
              }];
         } else {
             if ([self.delegate respondsToSelector:@selector(socialManager:loginRefusedWithError:)]) [self.delegate socialManager:self loginRefusedWithError:[error localizedDescription]];
         }
     }];
}

- (void) requestConfigurationForUser:(NSString *)username {
    if (self.delegate) [self.delegate socialManager:self operationNotPermitted:SMRequestTypeReadConfiguration];
}

- (void) fetchTimelinePosts:(NSUInteger)numPosts forUser:(NSString *)username {
    // Specify App ID and permissions
    NSDictionary *options = @{ ACFacebookAppIdKey: kTSMFacebookAppID,ACFacebookPermissionsKey: @[@"email", @"read_stream"],ACFacebookAudienceKey: self.audience };
    [self.accountStore requestAccessToAccountsWithType:self.facebookAccountType options:options
                                            completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES)
         {
             NSURL *feedURL = [self urlForRequest:SMRequestTypeFetchTimeLine];
             
             SLRequest *feedRequest = [SLRequest
                                       requestForServiceType:SLServiceTypeFacebook
                                       requestMethod:SLRequestMethodGET
                                       URL:feedURL
                                       parameters:[NSDictionary dictionary]];
             
             // Post the request
             [feedRequest setAccount:self.facebookAccount];
             
             // Block handler to manage the response
             [feedRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
              {
                  if (!error) {
                      NSError *jsonError = nil;
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
                  } else {
                      if (self.delegate) [self.delegate socialManager:self requestFailedWithReturnCode:urlResponse.statusCode andError:error];
                  }
              }];
         } else {
             if ([self.delegate respondsToSelector:@selector(socialManager:loginRefusedWithError:)]) [self.delegate socialManager:self loginRefusedWithError:[error localizedDescription]];
         }
     }];
}


#pragma mark create a window for sharing


- (SMSocialManagerWindow *) postWindowWithMessage: (NSString *) message image:(NSImage *)image andDelegate:(id<SMSocialManagerPostWindowDelegate>)delegate {
    NSMutableArray * accountNames = [NSMutableArray array];
    for (ACAccount * acc in [[SMFacebookSocialManager sharedInstance] accounts]) {
        if ([acc.accountType.identifier isEqualToString:ACAccountTypeIdentifierFacebook]) [accountNames addObject:acc.username];
    }
    self.facebookPostVC = [[SMFacebookPostViewController alloc] initWithNibName:kTSMFacebookViewControllerNibName bundle:nil text:message andImage:image];
    self.facebookPostVC.delegate = delegate;
    self.facebookPostWindow = [[SMSocialManagerWindow alloc] initWithContentRect:self.facebookPostVC.view.frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
    [self.facebookPostWindow setContentView:self.facebookPostVC.view];
    [self.facebookPostWindow center];
    return self.facebookPostWindow;
}

@end
