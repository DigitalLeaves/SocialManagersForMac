//
//  TwitterSocialManager.h
//  The Pillow Book for Mac
//
//  Created by Nacho on 01/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMSocialManager.h"
#import "SMSocialManagerWindow.h"
#import "SMTwitterPostViewController.h"

#define kTSMTwitterMaxtweetLength                       140         // characters
#define kTSMTwitterDefaultCharactersReservedForMedia    23

@interface SMTwitterSocialManager : SMSocialManager

/** Singleton instance of this social manager. */
+ (SMTwitterSocialManager *) sharedInstance;

- (SMSocialManagerWindow *) postWindowWithMessage: (NSString *) message image:(NSImage *)image andDelegate:(id<SMSocialManagerPostWindowDelegate>)delegate;

@end
