//
//  SMFacebookPostViewController.h
//  SocialManagersForMac
//
//  Created by Nacho on 26/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreLocation/CoreLocation.h>
#import <Accounts/Accounts.h>
#import "SMSocialManagerPostWindowDelegate.h"

@interface SMFacebookPostViewController : NSViewController <CLLocationManagerDelegate, NSTextViewDelegate>

@property (nonatomic, strong) id <SMSocialManagerPostWindowDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil text: (NSString *) text andImage: (NSImage *) image;

@end
