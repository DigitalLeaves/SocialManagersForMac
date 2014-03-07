//
//  SMFacebookSocialManager.h
//  The Pillow Book for Mac
//
//  Created by Nacho on 03/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import "SMSocialManager.h"
#import "SMFacebookPostViewController.h"
#import "SMSocialManagerWindow.h"
#import "SMSocialManagerPostWindowDelegate.h"

#define kSMFacebookErrorCodeNotLoggedIn     1001
#define kSMFacebookErrorCodeAccessRefused   1002

@interface SMFacebookSocialManager : SMSocialManager

/** Audience for the posts. Must be either ACFacebookAudienceEveryone (default), ACFacebookAudienceOnlyMe or ACFacebookAudienceFriends */
@property (nonatomic) NSString * audience;

/** Singleton instance of this social manager. */
+ (SMFacebookSocialManager *) sharedInstance;

/** Creates a new window that allows the user to share a post with an image. */ 
- (SMSocialManagerWindow *) postWindowWithMessage: (NSString *) message image: (NSImage *) image andDelegate: (id <SMSocialManagerPostWindowDelegate>) delegate;

- (NSString *) currentAccountUsername;

@end
