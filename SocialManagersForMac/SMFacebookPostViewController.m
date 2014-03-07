//
//  SMFacebookPostViewController.m
//  SocialManagersForMac
//
//  Created by Nacho on 26/02/14.
//  Copyright (c) 2014 Ignacio Nieto Carvajal. All rights reserved.
//

#import "SMFacebookPostViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSColorView.h"
#import "SMFacebookSocialManager.h"


#define kSMFacebookClearBackgroundColor      [NSColor colorWithRed:1 green:1 blue:1 alpha:0.98]
#define kSMFacebookDarkGrayColor             [NSColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]
#define kSMFacebookBlueColor                 [NSColor colorWithRed:0.1 green: 0.5 blue: 1.0 alpha: 1]
#define kSMFacebookNotLoggedInMessage        @"It seems that you are not logged into Facebook. Maybe the application does not have permission for accessing your Facebook account."

@interface SMFacebookPostViewController ()
// outlets
@property (weak) IBOutlet NSColorView *topLine;
@property (weak) IBOutlet NSColorView *middleLine;
@property (weak) IBOutlet NSColorView *bottomLine;
@property (weak) IBOutlet NSColorView *backgroundView;
@property (weak) IBOutlet NSImageView *imageView;
@property (unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSView *headerView;
@property (weak) IBOutlet NSView *mainContentView;
@property (weak) IBOutlet NSProgressIndicator *locationProgressIndicator;
@property (weak) IBOutlet NSTextField *titleLabel;

// Facebook accounts
@property (weak) IBOutlet NSView *facebookAudiencesView;
@property (nonatomic, strong) NSArray * facebookAudiences;
@property (nonatomic, strong) NSString * currentFacebookAudience;
@property (weak) IBOutlet NSTableView *audiencesTableView;

// location
@property (nonatomic) BOOL locatingUser;
@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) CLGeocoder * geoCoder;
@property (nonatomic, strong) CLLocation * userLocation;
@property (nonatomic, strong) NSString * userLocationCity;

// others
@property (nonatomic, strong) NSImage * postImage;
@property (nonatomic) BOOL showingAudiences;

// buttons
@property (weak) IBOutlet NSButton *cancelButton;
@property (weak) IBOutlet NSButton *postButton;
@property (weak) IBOutlet NSButton *audienceButton1;
@property (weak) IBOutlet NSButton *audienceButton2;
@property (weak) IBOutlet NSButton *locationButton1;
@property (weak) IBOutlet NSButton *locationButton2;


@end

@implementation SMFacebookPostViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil text: (NSString *) text andImage: (NSImage *) image {
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if ([[SMFacebookSocialManager sharedInstance] state] == SMSocialManagerStateLoggedIn) {
            self.textView.string = text;
            if (image) {
                self.imageView.image = image;
                self.postImage = image;
            } else {
                self.postImage = nil;
                self.imageView.image = [NSImage imageNamed:@"SMdefaultImage"];
            }
        } else {
            self.imageView.image = [NSImage imageNamed:@"SMdefaultImage"];
            self.textView.string = NSLocalizedString(kSMFacebookNotLoggedInMessage, kSMFacebookNotLoggedInMessage);
            [self.postButton setEnabled:NO];
        }
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.view.wantsLayer = YES;
        self.facebookAudiencesView.wantsLayer = YES;
        self.mainContentView.wantsLayer = YES;
        self.view.layer.cornerRadius = 12.0f;
        self.view.layer.borderColor = [kSMFacebookDarkGrayColor CGColor];
        self.view.layer.borderWidth = 1.0f;
        self.backgroundView.backgroundColor = kSMFacebookClearBackgroundColor;
        self.topLine.backgroundColor = kSMFacebookDarkGrayColor;
        self.bottomLine.backgroundColor = kSMFacebookDarkGrayColor;
        self.middleLine.backgroundColor = kSMFacebookDarkGrayColor;
        [self setButton:self.cancelButton textColor:kSMFacebookBlueColor size:20 alignment:NSCenterTextAlignment andBold:NO];
        [self setButton:self.postButton textColor:kSMFacebookBlueColor size:20 alignment:NSCenterTextAlignment andBold:YES];
        self.showingAudiences = NO;
        if ([[SMFacebookSocialManager sharedInstance] state] == SMSocialManagerStateLoggedIn) {
            self.textView.delegate = self;
            [self.textView setEditable:YES];
            [[self.textView textStorage] setFont:[NSFont fontWithName:@"Helvetica Neue" size:20]];
            self.currentFacebookAudience = ACFacebookAudienceFriends;
        } else {
            self.textView.string = kSMFacebookNotLoggedInMessage;
        }
        
    }
    return self;
}

- (void)setButton: (NSButton *) button textColor:(NSColor*)color size: (CGFloat) size alignment: (NSTextAlignment) alignment andBold: (BOOL) bold
{
    NSMutableParagraphStyle * style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = alignment;
    NSFont * font = bold? [NSFont fontWithName:@"HelveticaNeue-Bold" size:size]:[NSFont fontWithName:@"Helvetica Neue" size:size];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString: [button title] attributes:
                                            [NSDictionary dictionaryWithObjectsAndKeys:
                                             color, NSForegroundColorAttributeName,
                                             style, NSParagraphStyleAttributeName,
                                             font, NSFontAttributeName,
                                             
                                             nil]];
    
    [button setAttributedTitle: attributedString];
}

- (NSArray *) facebookAudiences {
    if (!_facebookAudiences) {
        _facebookAudiences = @[ACFacebookAudienceEveryone, ACFacebookAudienceFriends, ACFacebookAudienceOnlyMe];
    }
    return _facebookAudiences;
}

#pragma mark button actions

- (IBAction)cancelButtonTouched:(id)sender {
    if (self.showingAudiences) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
            [context setDuration:1.0];
            // move main views
            [self.mainContentView setFrame:NSMakeRect(0, self.mainContentView.frame.origin.y, self.mainContentView.frame.size.width, self.mainContentView.frame.size.height)];
            [self.facebookAudiencesView setFrame:NSMakeRect(self.view.frame.size.width, self.facebookAudiencesView.frame.origin.y, self.facebookAudiencesView.frame.size.width, self.facebookAudiencesView.frame.size.height)];
            // hide "post" button, change "cancel" button and set title to "Accounts"
            self.postButton.alphaValue = 1;
            self.cancelButton.title = NSLocalizedString(@"Cancel", @"Cancel");
            [self setButton:self.cancelButton textColor:kSMFacebookBlueColor size:20 alignment:NSCenterTextAlignment andBold:NO];
            self.titleLabel.stringValue = NSLocalizedString(@"Facebook", @"Facebook");
            
        } completionHandler:^{
            [self.postButton setEnabled:YES];
            self.showingAudiences = NO;
        }];
    } else {
        if (self.delegate) [self.delegate postWindowForSocialManagerCancelledByUser:[SMFacebookSocialManager sharedInstance]];
        [self.view.window orderOut:nil];
    }
}

- (IBAction)postButtonTouched:(id)sender {
    if (self.postImage) { // with image
        if (self.userLocation) { // user location
            [[SMFacebookSocialManager sharedInstance] postMessage:self.textView.string forUser:self.currentFacebookAudience withImage:self.postImage andLocation:self.userLocation.coordinate];
        } else { // no location
            [[SMFacebookSocialManager sharedInstance] postMessage:self.textView.string forUser:self.currentFacebookAudience withImage:self.postImage];
        }
    } else { // no image
        if (self.userLocation) { // user location
            [[SMFacebookSocialManager sharedInstance] postMessage:self.textView.string forUser:self.currentFacebookAudience withLocation:self.userLocation.coordinate];
        } else { // no location
            [[SMFacebookSocialManager sharedInstance] postMessage:self.textView.string forUser:self.currentFacebookAudience];
        }
    }
    if (self.delegate) [self.delegate postWindowForSocialManager:[SMFacebookSocialManager sharedInstance] isPostingMessage:self.textView.string toAccountName:[[SMFacebookSocialManager sharedInstance] currentAccountUsername]];
    [self.view.window orderOut:nil];
}

- (void) setCurrentFacebookAudience:(NSString *)currentFacebookAudience {
    _currentFacebookAudience = currentFacebookAudience;
    [self.audiencesTableView reloadData];
    self.audienceButton2.title = self.currentFacebookAudience;
}

- (IBAction)audienceButtonTouched:(id)sender {
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:1.0];
        // move main views
        [self.mainContentView setFrame:NSMakeRect(- self.view.frame.size.width, self.mainContentView.frame.origin.y, self.mainContentView.frame.size.width, self.mainContentView.frame.size.height)];
        [self.facebookAudiencesView setFrame:NSMakeRect(0, self.facebookAudiencesView.frame.origin.y, self.facebookAudiencesView.frame.size.width, self.facebookAudiencesView.frame.size.height)];
        // hide "post" button, change "cancel" button and set title to "Accounts"
        self.postButton.alphaValue = 0;
        self.cancelButton.title = NSLocalizedString(@"Back", @"Back");
        [self setButton:self.cancelButton textColor:kSMFacebookBlueColor size:20 alignment:NSCenterTextAlignment andBold:NO];
        self.titleLabel.stringValue = NSLocalizedString(@"Audience", @"Audience");
        
    } completionHandler:^{
        [self.postButton setEnabled:NO];
        self.showingAudiences = YES;
        [self.audiencesTableView reloadData];
        self.audienceButton2.title = self.currentFacebookAudience;
    }];
}

- (IBAction)locationButtonTouched:(id)sender {
    if (!self.locatingUser) {
        self.locatingUser = YES;
        [self.locationProgressIndicator setHidden:NO];
        [self.locationProgressIndicator startAnimation:sender];
        [self.locationButton2 setImage:[NSImage imageNamed:@"SMnothing"]];
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark NSTextView delegate methods

- (void) textDidChange:(NSNotification *)notification {
    if (self.textView.string.length == 0) {
        [self.textView setFont:[NSFont fontWithName:@"Helvetica Neue" size:20]];
    }
}


#pragma mark NSTextView delegate methods

// The only essential/required tableview dataSource method
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.facebookAudiences count];
}

// This method is optional if you use bindings to provide the data
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];
    if ([identifier isEqualToString:@"AudienceCell"]) {
        NSString * audience = [self.facebookAudiences objectAtIndex:row];
        // We pass us as the owner so we can setup target/actions into this main controller object
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
        // Then setup properties on the cellView based on the column
        cellView.textField.stringValue = audience;
        cellView.imageView.objectValue = [audience isEqualToString:self.currentFacebookAudience]?[NSImage imageNamed:@"NSMenuOnStateTemplate"]:nil;
        return cellView;
    } else {
        NSAssert1(NO, @"Unhandled table column identifier %@", identifier);
    }
    return nil;
}

- (void) tableViewSelectionDidChange:(NSNotification *)notification {
    NSTableCellView *selectedCell = [self.audiencesTableView viewAtColumn:self.audiencesTableView.selectedColumn row:self.audiencesTableView.selectedRow makeIfNecessary:NO];
    self.currentFacebookAudience = selectedCell.textField.stringValue;
    [[SMFacebookSocialManager sharedInstance] setAudience:self.currentFacebookAudience];
}

#pragma mark location methods

- (CLLocationManager *) locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.distanceFilter = 100; // 100 metres.
    }
    return _locationManager;
}

/** Update location for Mac OS X < 10.9 and iOS < 6 */
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationManager stopUpdatingLocation];

    [self.geoCoder reverseGeocodeLocation: newLocation completionHandler: ^(NSArray *placemarks, NSError *error) {
        //Get nearby address
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        [self updateLocation:newLocation withCity:placemark.locality];
        
    }];
}

/* Update locations for Mac OS X >= 10.9 and iOS >= 6 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    [self.locationManager stopUpdatingLocation];
    if (locations && (locations.count > 0)) {
        CLLocation * lastLocation = [locations lastObject];

        [self.geoCoder reverseGeocodeLocation: lastLocation completionHandler: ^(NSArray *placemarks, NSError *error) {
            //Get nearby address
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            [self updateLocation:lastLocation withCity:placemark.locality];
            
        }];
    } else [self updateLocation:nil withCity:NSLocalizedString(@"None", @"")];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self updateLocation:nil withCity:nil];
}

- (void) updateLocation: (CLLocation *) location withCity: (NSString *) city {
    self.locatingUser = NO;
    [self.locationProgressIndicator stopAnimation:nil];
    [self.locationProgressIndicator setHidden:YES];
    if (location) {
        self.userLocationCity = city;
        self.locationButton2.title = city;
        self.userLocation = location;
    } else {
        self.locationButton2.title = NSLocalizedString(@"Unable to get location", @"");
        self.userLocationCity = nil;
        self.userLocation = nil;
    }
}

- (CLGeocoder *) geoCoder {
    if (!_geoCoder) {
        _geoCoder = [[CLGeocoder alloc] init];
    }
    return _geoCoder;
}

@end
