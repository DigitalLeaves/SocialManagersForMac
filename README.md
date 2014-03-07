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

## Posting messages with location.

# Social Manager Delegate methods


# Post Window

