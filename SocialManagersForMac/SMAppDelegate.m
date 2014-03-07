//
//  SMAppDelegate.m
//  SocialManagersForMac
//
//  Created by Nacho on 25/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import "SMAppDelegate.h"

@interface SMAppDelegate ()

@property (weak) IBOutlet NSImageView *imageView;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSTextField *messageLabel;
@property (nonatomic, strong) NSImage * imageToPost;

@end

@implementation SMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [[SMTwitterSocialManager sharedInstance] setDelegate:self];
    [[SMFacebookSocialManager sharedInstance] setDelegate:self];
}

#pragma mark button actions

- (IBAction)changeImage:(id)sender {
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    
    NSArray* imageTypes = [NSImage imageTypes];
    [panel setAllowedFileTypes:imageTypes];
    
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            // Open the image.
            self.imageToPost = [[NSImage alloc] initWithContentsOfURL:[panel URL]];
            [self.imageView setImage: self.imageToPost];
        }
        
    }];
}

- (IBAction)shareInFacebook:(id)sender {
    [[SMTwitterSocialManager sharedInstance] setDelegate:self];
    SMSocialManagerWindow * dialog = [[SMFacebookSocialManager sharedInstance] postWindowWithMessage:self.textView.string image:self.imageToPost andDelegate:self];
    [dialog makeKeyAndOrderFront:sender];
}

- (IBAction)shareInTwitter:(id)sender {
    [[SMFacebookSocialManager sharedInstance] setDelegate:self];
    SMSocialManagerWindow * dialog = [[SMTwitterSocialManager sharedInstance] postWindowWithMessage:self.textView.string image:self.imageToPost andDelegate:self];
    [dialog makeKeyAndOrderFront:sender];
}

#pragma mark SMSocialManagerPostWindow methods

- (void) postWindowForSocialManagerCancelledByUser:(SMSocialManager *)socialManager {
    [self.messageLabel setHidden:YES];
}

- (void) postWindowForSocialManager:(SMSocialManager *)socialManager isPostingMessage:(NSString *)message toAccountName:(NSString *)accountName {
    [self.messageLabel setStringValue:[NSString stringWithFormat:@"Sending message to account %@...", accountName]];
    [self.messageLabel setHidden:NO];
}

#pragma mark SMSocialManagerDelegate methods

/**
 * @brief Informs the delegate that the last operation was successful.
 * @param returnCode The HTTP return code returned by the server.
 * @param result a NSDictionary with the results of the operation, extracted in JSON format.
 */
- (void) socialManager: (SMSocialManager *) socialManager requestSucceedWithReturnCode: (NSUInteger) returnCode andResult: (NSDictionary *) result {
    [self.messageLabel setStringValue:@"Request succeed"];
    NSLog(@"Request succeed. Response was: %@", result);
    [self.messageLabel setHidden:NO];
}

/**
 * @brief Informs the delegate that the last operation failed.
 * @param returnCode The HTTP return code returned by the server.
 * @param error The NSError if any. This field would be empty in the case of a valid request that returned an error code by the server (i.e: if trying to post an image with a size bigger than allowed). In that case the returnCode must be examined in order to determine the error.
 */
- (void) socialManager: (SMSocialManager *) socialManager requestFailedWithReturnCode: (NSUInteger) returnCode andError: (NSError *) error {
    [self.messageLabel setStringValue:@"Request failed."];
    NSLog(@"Request failed. Error was: %@", error);
    [self.messageLabel setHidden:NO];
}

/**
 * @brief the requested operation is not allowed by this Social Manager.
 * The SocialManager will invoke this method on its delegate to inform it that the requested operation is not supported by this concrete Social Manager.
 */
- (void) socialManager: (SMSocialManager *) socialManager operationNotPermitted: (SMRequestType) operationType {
    [self.messageLabel setStringValue:@"Operation not permited."];
    NSLog(@"Operation %d not permitted.", operationType);
    [self.messageLabel setHidden:NO];
}

/**
 * @brief informs the delegate that the login was refused for this social network
 */
- (void) socialManager: (SMSocialManager *) socialManager loginRefusedWithError: (NSString *) error {
    [self.messageLabel setStringValue:@"Login refused."];
    NSLog(@"Login refused. Error was: %@", error);
    [self.messageLabel setHidden:NO];
}


@end
