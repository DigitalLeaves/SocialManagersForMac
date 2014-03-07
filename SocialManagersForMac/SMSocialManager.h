//
//  SMSocialManager.h
//  Ignacio Nieto Carvajal
//
//  Created by Nacho on 03/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <CoreLocation/CoreLocation.h>
#import "SMAdditionalMultipartData.h"
#import "SMSocialManagerDelegate.h"

#define kAdditionalMediaData        @"additionalMediaData"
#define kAdditionalMediaName        @"additionalMediaName"
#define kAdditionalMediaType        @"additionalMediaType"
#define kAdditionalMediaFileName    @"additionalMediaFileName"

#define kSMRequestParameterUsername     @"username"
#define kSMRequestParameterLatitude     @"latitude"
#define kSMRequestParameterLongitude    @"longitude"
#define kSMRequestParameterMessage      @"message"
#define kSMRequestParameterNumOfPosts   @"numOfPosts"

typedef enum {
    SMSocialManagerStateUndefined = 0,
    SMSocialManagerStateNotLogged,
    SMSocialManagerStateLoggedIn,
    SMSocialManagerStateLoginRefused
} SMSocialManagerState;

@interface SMSocialManager: NSObject

/** The delegate of this social manager */
@property (nonatomic, strong) id <SMSocialManagerDelegate> delegate;

/** The state of the social manager */
@property (nonatomic) SMSocialManagerState state;

/** The account store representing the user's social account */
@property (nonatomic) ACAccountStore *accountStore;

/** Returns a NSArray with the list of ACAccount valid accounts for this Social Manager in this device. */
- (NSArray *) accounts;

/** Request the configuration of the user */
- (void) requestConfigurationForUser: (NSString *) username;

/** fetch numPosts posts of the user's timeline */
- (void)fetchTimelinePosts: (NSUInteger) numPosts forUser:(NSString *)username;

/** Post a message without images or links */
- (void) postMessage: (NSString *) message forUser: (NSString *) username;

/** Post a message with an image */
- (void) postMessage: (NSString *) message forUser: (NSString *) username withImage: (NSImage *) image;

/** Post a message with an image */
- (void) postMessage: (NSString *) message forUser: (NSString *) username withLocation: (CLLocationCoordinate2D) location;

/** Post a message with an image and location data */
- (void) postMessage:(NSString *)message forUser:(NSString *)username withImage: (NSImage *) image andLocation:(CLLocationCoordinate2D)location;

/** Returns the MIME type for a image file type, ready for sending it in the additional media field of a request */
- (NSString *) imageMimeForType: (NSBitmapImageFileType) imageType;

/** Generates a filename for uploading additional media in a request */
- (NSString *) imageFileNameForType: (NSBitmapImageFileType) imageType;

/** Generates a valid media to be attached to a request, i.e: restricting max file size for an image. */
- (NSData *) validMediaFromImage: (NSImage *) image;

#pragma mark to be overriden by subclasses

/** Returns YES if this manager allows this specific request, NO otherwise. Must be overriden by subclasses */
- (BOOL) requestAllowed: (SMRequestType) requestType;

/** Returns the account type for this social manager. To be overriden by subclasses */
- (ACAccountType *) accountType;

/** Returns the account associated with a concrete identifier (username). Must be overriden by subclasses */
- (ACAccount *) accountForUsername: (NSString *) username;

/** Returns the URL associated with a given request. To be overriden by subclasses */
- (NSURL *) urlForRequest: (SMRequestType) requestType;

/** Returns the params associated with a given request. To be overriden by subclasses. */
- (NSDictionary *) parametersForRequest: (SMRequestType) requestType withValues: (NSDictionary *) values;

/** Returns the max allowed size of additional media (i.e: images) */
- (NSUInteger) maxSizeForAdditionalMedia;

/** Returns a SMAdditioanlMultipartData to be included with the request. To be overriden by subclasses. The default behaviour is add a NSImage it as a base64 codified image */
- (SMAdditionalMultipartData *) multipartDataForImage: (NSImage *) image;

/** returns the request method used for a concrete request (GET, PUT, DELETE...). Default is always GET. Must be overriden by implementing classes. */
- (SLRequestMethod) requestMethodForRequest: (SMRequestType) requestType;

/** Returns the Service Type for this social manager, i.e: SLServiceTypeTwitter, SLServiceTypeFacebook... */
- (NSString *) serviceTypeForThisSocialManager;
@end
