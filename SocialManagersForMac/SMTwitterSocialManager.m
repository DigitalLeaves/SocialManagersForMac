//
//  TwitterSocialManager.m
//  The Pillow Book for Mac
//
//  Created by Nacho on 01/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import "SMTwitterSocialManager.h"

#define kTSMTwitterDefaultMaxDataSize                   3145728     // 3 Mb
#define kTSMTwitterImagePostName                        @"media[]"

#define kTSMTwitterViewControllerNibName                @"SMTwitterPostViewController"

@interface SMTwitterSocialManager()

/** The account type for twitter accounts */
@property (nonatomic, strong) ACAccountType * twitterAccountType;

/** Characters reserved for media, to be substracted for the max character limit. */
@property (nonatomic) NSUInteger charactersReservedForMedia;

/** Window and view of the Post Dialog */
@property (nonatomic, strong) SMTwitterPostViewController * twitterPostVC;
@property (nonatomic, strong) SMSocialManagerWindow * twitterPostWindow;

@end

@implementation SMTwitterSocialManager

+ (SMTwitterSocialManager *) sharedInstance
{
    static dispatch_once_t once;
    static SMTwitterSocialManager * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init {
    self = [super init];
    if (self) {
        self.state = SMSocialManagerStateNotLogged;
        
        // request access to accounts:
        [self.accountStore
         requestAccessToAccountsWithType:[self accountType]
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 self.state = SMSocialManagerStateLoggedIn;
             } else {
                 self.state = SMSocialManagerStateLoginRefused;
             }
         }];
    }
    return self;
}

- (NSUInteger) charactersReservedForMedia {
    if (!_charactersReservedForMedia) {
        _charactersReservedForMedia = kTSMTwitterDefaultCharactersReservedForMedia;
    }
    return _charactersReservedForMedia;
}

#pragma mark request operations.

- (void) postMessage:(NSString *)message forUser:(NSString *)username {
    NSString * tweet = [self validTweetForMessage:message includesMedia:NO];
    [super postMessage:tweet forUser:username];
    
}

- (void) postMessage:(NSString *)message forUser:(NSString *)username withImage:(NSImage *)image {
    NSString * tweet = [self validTweetForMessage:message includesMedia:YES];
    [super postMessage:tweet forUser:username withImage:image];
}


- (BOOL) requestAllowed:(SMRequestType)requestType {
    switch (requestType) {
        case SMRequestTypeFetchTimeLine:
        case SMRequestTypePost:
        case SMRequestTypePostWithMedia:
        case SMRequestTypePostWithLocation:
        case SMRequestTypePostWithMediaAndLocation:
        case SMRequestTypeReadConfiguration:
            return YES;
            break;
            
        default:
            return NO;
            break;
    }
}

- (NSString *) validTweetForMessage: (NSString *) baseString includesMedia: (BOOL) includesMedia {
    
    NSUInteger maxLength = kTSMTwitterMaxtweetLength;
    if (includesMedia) maxLength = maxLength - self.charactersReservedForMedia;
    NSRange stringRange = {0, MIN([baseString length], maxLength)};
    stringRange = [baseString rangeOfComposedCharacterSequencesForRange:stringRange];
    NSString * trimmedString = [baseString substringWithRange:stringRange];
    return trimmedString;
}

- (ACAccountType *) twitterAccountType {
    if (!_twitterAccountType) {
        _twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier: ACAccountTypeIdentifierTwitter];
    }
    return _twitterAccountType;
}

- (ACAccount *) accountForUsername: (NSString *) username {
    NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:[self twitterAccountType]];
    if (twitterAccounts) {
        for (ACAccount * account in twitterAccounts) {
            if ([account.username isEqualToString:username]) return account;
        }
    }
    return nil;
}

- (NSArray *) accounts {
    return [self.accountStore accountsWithAccountType:[self twitterAccountType]];
}

- (ACAccountType *) accountType {
    return self.twitterAccountType;
}

- (NSUInteger) maxSizeForAdditionalMedia {
    return kTSMTwitterDefaultMaxDataSize;
}

- (SMAdditionalMultipartData *) multipartDataForImage: (NSImage *) image {
    NSData * validMedia = [self validMediaFromImage:image];
    return [[SMAdditionalMultipartData alloc] initWithData:validMedia name:kTSMTwitterImagePostName type:[self imageMimeForType:NSJPEGFileType] andFilename:[self imageFileNameForType:NSJPEGFileType]];
}

- (NSURL *) urlForRequest: (SMRequestType) requestType {
    
    switch (requestType) {
        case SMRequestTypeReadConfiguration:
            return [NSURL URLWithString:@"https://api.twitter.com/1.1/help/configuration.json"];
            break;
        case SMRequestTypePost:
        case SMRequestTypePostWithLocation:
            return [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
            break;
        case SMRequestTypePostWithMedia:
        case SMRequestTypePostWithMediaAndLocation:
            return [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
            break;
        case SMRequestTypeFetchTimeLine:
            return [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
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

- (NSDictionary *) parametersForRequest: (SMRequestType) requestType withValues: (NSDictionary *) values {
    
    NSString * username;
    NSString * message;
    NSString * numberOfPosts;
    NSString * latitude, * longitude;
    
    switch (requestType) {
        case SMRequestTypeReadConfiguration:
            return [NSDictionary dictionary];
            break;
        case SMRequestTypePost:
            username = values[kSMRequestParameterUsername]; if (!username) username = @"";
            message = values[kSMRequestParameterMessage]; if (!message) message = @"";
            return @{@"screen_name" : username, @"status": message};
            break;
        case SMRequestTypePostWithMedia:
            username = values[kSMRequestParameterUsername]; if (!username) username = @"";
            message = values[kSMRequestParameterMessage]; if (!message) message = @"";
            return @{@"screen_name" : username, @"status": message};
            break;
        case SMRequestTypeFetchTimeLine:
            username = values[kSMRequestParameterUsername]; if (!username) username = @"";
            numberOfPosts = values[kSMRequestParameterMessage]; if (!numberOfPosts) numberOfPosts = @"1";
            return @{@"screen_name" : username, @"include_rts" : @"0", @"trim_user" : @"1", @"count" : numberOfPosts};
            break;
        case SMRequestTypePostWithLocation:
            username = values[kSMRequestParameterUsername]; if (!username) username = @"";
            message = values[kSMRequestParameterMessage]; if (!message) message = @"";
            latitude = values[kSMRequestParameterLatitude]? values[kSMRequestParameterLatitude]:@"0";
            longitude = values[kSMRequestParameterLongitude]? values[kSMRequestParameterLongitude]:@"0";
            return @{@"screen_name" : username, @"status": message, @"lat": latitude, @"long": longitude };
            break;
        case SMRequestTypePostWithMediaAndLocation:
            username = values[kSMRequestParameterUsername]; if (!username) username = @"";
            message = values[kSMRequestParameterMessage]; if (!message) message = @"";
            latitude = values[kSMRequestParameterLatitude]? values[kSMRequestParameterLatitude]:@"0";
            longitude = values[kSMRequestParameterLongitude]? values[kSMRequestParameterLongitude]:@"0";
            return @{@"screen_name" : username, @"status": message, @"lat": latitude, @"long": longitude };
            break;
        default:
            break;
    }
    return [NSDictionary dictionary];
}


- (NSString *) serviceTypeForThisSocialManager {
    return SLServiceTypeTwitter;
}

#pragma mark create a window for sharing

- (SMSocialManagerWindow *) postWindowWithMessage: (NSString *) message image:(NSImage *)image andDelegate:(id<SMSocialManagerPostWindowDelegate>)delegate {
    NSMutableArray * accountNames = [NSMutableArray array];
    for (ACAccount * acc in [[SMTwitterSocialManager sharedInstance] accounts]) {
        if ([acc.accountType.identifier isEqualToString:ACAccountTypeIdentifierTwitter]) [accountNames addObject:acc.username];
    }
    self.twitterPostVC = [[SMTwitterPostViewController alloc] initWithNibName:kTSMTwitterViewControllerNibName bundle:nil text:message andImage:image];
    self.twitterPostVC.delegate = delegate;
    self.twitterPostWindow = [[SMSocialManagerWindow alloc] initWithContentRect:self.twitterPostVC.view.frame styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];
    [self.twitterPostWindow setContentView:self.twitterPostVC.view];
    [self.twitterPostWindow center];
    return self.twitterPostWindow;
}


@end