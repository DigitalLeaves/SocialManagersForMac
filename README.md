SocialManagersForMac
====================

**Edit**: With the new Yosemite OS X release, Apple has changed the look and feel of the sharing dialogs to look closer to iOS, making this project not that essential for a modern look in your sharing dialogs. Still, I like these dialogs better, because they are (in my opinion) more modern looking and polished than the Apple counterparts (i.e: compare the black raw lines of the new Yosemite sharing dialogs with the subtly grey lines of "Social Managers for Mac". Still, you may want to stick to the standard sharing dialogs for your Yosemite Apps.

Social Managers for Mac is an attempt to build a collection of Social Managers for Mac including iOS7 like post dialogs. For those who want more control over the sharing funcionality of Mac than the one provided by the NSSharingServicePicker class, including iOS7 like dialogs for sharing for a more modern look in your apps.

![](http://digitalleaves.com/blog/wp-content/uploads/2014/03/socialManagersForMac.jpg)

Currently Twitter and Facebook are supported. The Social Managers for Mac framework includes post dialogs for every supported social network for posting a message with image and location, with the additional needed parameters (like audience for Facebook or account for twitter). 

# Requisites

* Xcode 5
* OS X Mountain Lion or better (10.8+).
* Frameworks: Social, Accounts, CoreLocation, QuartzCore.

# Integration

Integration is really simple, you just have to download the zip and include everything in the *SocialManagersForMac* group folder in your project (that's all source code except for SMAppDelegate.m/.h and MainMenu.xib, that are the example application files.

You also need to add the following frameworks to your project: Social.framework, Accounts.framework, CoreLocation.framework and QuartzCore.framework.

## Facebook Integration

Facebook integration is a little bit more tricky (as everything with Facebook). In order for it to work with facebook, you need to register for a Facebook Developer's account, and create a new Facebook App, follow the instructions of this page: https://developers.facebook.com/docs/web/tutorials/scrumptious/register-facebook-application/. You may need to specify the exact same bundleID of this application, and you are free to modify it to suit your needs.

After you create you application, in the "Configuration" section, you need to specify the "iOS" platform (even thought this is for OS X cocoa) in the basic information area, and then in "advanced options", select the "Native or desktop app" option. Finally, in the "Status & Review" section, make your application public. Get your AppID and put it in the SMFacebookSocialManager.m file in the line:

```
#define kTSMFacebookAppID               @"ENTERYOURAPPIDHERE"
```

# Usage

The project contains several social managers. All of them inherit from SMSocialManager, which defines the methods for dealing with all of them. SMSocialManager is an abstract class, not intended to be instanciated. Currently, there are two social managers ready:

* SMTwitterSocialManager: for Twitter.
* SMFacebookSocialManager: for Facebook.

The managers follow the Singleton design pattern, so they are accessed through a shared instance:

```
SMTwitterSocialManager * twitterSM = [SMTwitterSocialManager sharedInstance];
```

Every social manager has a delegate, that will receive the results of the requests sent to the social manager. You must set the delegate right after getting the shared instance.

```
twitterSM.delegate = self;
```

and declare your class as implementing the *SMSocialManagerDelegate* protocol.

You can use the following methods to interact with the social managers:

## Requesting user information

You can ask for the user information using the method *requestConfigurationForUser:*. It will return the information related to the user account.

```
SMTwitterSocialManager * twitterSM = [SMTwitterSocialManager sharedInstance];
twitterSM.delegate = self;
[twitterSM requestConfigurationForUser:username];
```

where username is the username of the account to use. You can get a list of accounts with the method *accounts*, that would return a *NSArray* of *ACAccount* objects, so you can just get the *username* of the account you are interested in.

The result will be returned in the delegate's method *socialManager:requestSucceedWithReturnCode:andResult:* in a JSON compliant NSDictionary.

## Fetching the user's timeline

You can fetch the timeline of the user by using the method *fetchTimelinePosts:forUser:*, where you select a username and a number of posts to be retrieved.

```
SMTwitterSocialManager * twitterSM = [SMTwitterSocialManager sharedInstance];
twitterSM.delegate = self;
[twitterSM fetchTimelinePosts: 10 forUser:username];
```

The result will be returned in the delegate's method *socialManager:requestSucceedWithReturnCode:andResult:* in a JSON compliant NSDictionary.

## Posting messages

There are several methods for posting messages. For posting just a simple message, without images or location information, you use the method *postMessage:forUser:*.

```
SMFacebookSocialManager * facebookSM = [SMFacebookSocialManager sharedInstance];
facebookSM.delegate = self;
facebookSM.audience = ACFacebookAudienceFriends;
[facebookSM postMessage: @"Hello, this is a message" forUser:username];
```

Note that the SMFacebookSocialManager has an 'audience' property that allows it to set the target audience for posts, either *ACFacebookAudienceFriends*, *ACFacebookAudienceOnlyMe* or *ACFacebookAudienceEveryone*.

## Posting messages with images

For posting messages with images, you can use the method *postMessage:forUser:withImage:* like this:

```
SMTwitterSocialManager * twitterSM = [SMTwitterSocialManager sharedInstance];
twitterSM.delegate = self;
[twitterSM postMessage: message message forUser: username withImage: image];
```

where image is a *NSImage*.

## Posting messages with location.

For posting with location data, you have two methods: *postMessage:forUser:withLocation:* for just a text post and *postMessage:forUser:withImage:andLocation:* for including an image. Both methods use a CLLocationCoordinate2D for sending the user's location (basically a longitude and a latitude).

```
SMFacebookSocialManager * facebookSM = [SMFacebookSocialManager sharedInstance];
facebookSM.delegate = self;
facebookSM.audience = ACFacebookAudienceOnlyMe;
[facebookSM postMessage: @"Hello, this is a message" forUser:username withLocation:location];
```

# Social Manager Delegate methods

The Social Manager Delegate will have to implement the following methods:

* **socialManager:requestSucceedWithReturnCode:andResult:** this method will be invoked if the request was successful, and the returning JSON information will be returned in a NSDictionary.


* **socialManager:requestFailedWithReturnCode:andError:** this method indicates that the request failed, and an return code and related error are returned.

* **socialManager:operationNotPermitted:** the SocialManager will invoke this method on its delegate to inform it that the requested operation is not supported by this concrete Social Manager. You can check if a concrete operation is supported by a SMSocialManager subclass by invoking the method *requestAllowed:* prior to triggering the request.

* **socialManager:loginRefusedWithError:** an optional method, required by some social managers (like Facebook SM) that is invoked to inform that the login was refused in the current device, so no requests are available. The login status of a SMSocialManager subclass can be checked by the property *state*.


# Post Window

For convenience, Social Managers for Mac includes a post window dialog for every SMSocialManager subclass that returns a iOS7 like window to post a message with or without images. This windows have been designed to resemble as closely as possible to the share dialogs from iOS 7. In order to use the window, you have to call the SMSocialManager subclass's method *postWindowWithMessage:image:andDelegate:*.

```
self.facebookSM = [SMFacebookSocialManager sharedInstance];
self.facebookSM.delegate = self;
self.facebookSM.audience = ACFacebookAudienceFriends;
[self.facebookSM postWindowWithMessage: message image:image andDelegate:self];
```

The delegate is optional, and will be sent messages when the user clicks the "post" (*postWindowForSocialManager:isPostingMessage:toAccountName:*) or "cancel" (*postWindowForSocialManagerCancelledByUser:*) buttons, so you can update your UI accordingly.

# Internationalization

Social Managers for Mac is ready to be included in your internationalized project. You just have to define the following strings in your Localized.string:

* @"Cancel": cancel button.
* @"Accept": accept button.
* @"Back": button for going back.
* @"None": for when there are no options.
* @"Audience": the audience property for Facebook's posts.
* @"Unable to get location": if the user's location can not be retrieved.
* @"Facebook": in case you need/want to change this in your language.
* @"Twitter": in case you need/want to change this in your language.
* @"It seems that you are not logged into Facebook. Maybe the application does not have permission for accessing your Facebook account.": self explanatory.
* @"It seems that you are not logged into Twitter. Maybe the application does not have permission for ussing your Twitter accounts.": self explanatory.
 
# License

This code is licensed under the MIT license. You are free to use this code, expand on it, share it, and include it on your commercial or non-commercial projects, but if you do, and find it useful, please consider to send me a message, I would like to hear from you.

Copyright (c) 2014 Ignacio Nieto Carvajal

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
