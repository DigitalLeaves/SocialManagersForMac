SocialManagersForMac
====================

Social Managers for Mac is an attempt to build a collection of Social Managers for Mac including iOS7 like post dialogs. For those who want more control over the sharing funcionality of Mac than the one provided by the NSSharingServicePicker class, including iOS7 like dialogs for sharing for a more modern look in your apps.



Currently Twitter and Facebook are supported. The Social Managers for Mac framework includes post dialogs for every supported social network for posting a message with image and location, with the additional needed parameters (like audience for Facebook or account for twitter). 

# Integrating Social Managers for Mac in your project

Integration is really simple, you just have to download the zip and include everything in the *SocialManagersForMac* group folder in your project (that's all source code except for SMAppDelegate.m/.h and MainMenu.xib, that are the example application files.

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

@optional

/** 
 * @brief informs the delegate that the login was refused for this social network
 */
* **socialManager:loginRefusedWithError:** an optional method, required by some social managers (like Facebook SM) that is invoked to 


# Post Window

