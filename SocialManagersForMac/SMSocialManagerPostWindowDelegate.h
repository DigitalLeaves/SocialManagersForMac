//
//  SMSocialManagerPostWindowDelegate.h
//  SocialManagersForMac
//
//  Created by Nacho on 07/03/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMSocialManager.h"

@protocol SMSocialManagerPostWindowDelegate <NSObject>

- (void) postWindowForSocialManagerCancelledByUser: (SMSocialManager *) socialManager;

- (void) postWindowForSocialManager: (SMSocialManager *) socialManager isPostingMessage: (NSString *) message toAccountName: (NSString *) accountName;

@end
