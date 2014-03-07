SocialManagersForMac
====================

Social Managers for Mac is an attempt to build a collection of Social Managers for Mac including iOS7 like post dialogs. For those who want more control over the sharing funcionality of Mac than the one provided by the NSSharingServicePicker class, including iOS7 like dialogs for sharing for a more modern look in your apps.



Currently Twitter and Facebook are supported. The Social Managers for Mac framework includes post dialogs for every supported social network for posting a message with image and location, with the additional needed parameters (like audience for Facebook or account for twitter). 

# Integrating Social Managers for Mac in your project

Integration is really simple, you just have to download the zip and include everything in the *SocialManagersForMac* group folder in your project (that's all source code except for SMAppDelegate.m/.h and MainMenu.xib, that are the example application files.

# Usage

The project contains several social managers. All of them inherit from SMSocialManager, which defines the methods for dealing with all of them. SMSocialManager is an abstract class, not intended to be instanciated. Currently, there are two social managers ready:

* SMTwitterSocialManager: for Twitter.
 

