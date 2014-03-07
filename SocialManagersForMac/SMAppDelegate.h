//
//  SMAppDelegate.h
//  SocialManagersForMac
//
//  Created by Nacho on 25/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SMTwitterSocialManager.h"
#import "SMFacebookSocialManager.h"

@interface SMAppDelegate : NSObject <NSApplicationDelegate, SMSocialManagerDelegate, SMSocialManagerPostWindowDelegate>

@property (assign) IBOutlet NSWindow *window;

@end
