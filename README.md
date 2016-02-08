# Fresh Air
Fresh Air is an application update library. It is designed check a remote location for application updates and if updates are available, prompt the user to upgrade the application. When the new version of the application is started, a dialog can be presented that show case the new features available to the user.

## Update Checks
Fresh Air supports checking iTunes for a new version, or checking a remotely hosted `release_notes.json` file.

```swift
let upgradeManager = RZFUpgradeManager(appStoreID:"ANAPPID")
upgradeManager.checkForNewUpdate()
```

This will check the iTunes for an app with the specified ID, and present a dialog if an update exists. See [RZFUpgradeManager](FreshAir/RZFUpgradeManager.h) for details on the UI presentation

## Release Note Presentation
Fresh Air also supports presenting release notes as a series of paging images with a title and description to introduce users to the new features included in an app update. This is managed by a set of feature keys specified in a `release_notes.json` file that is included in the application bundle. This file resides in a bundle that includes all of the assets needed for presentation. The feature keys are expanded into an image, a title, and a description via `[UIImage imageNamed:$key]`, and the localization keys `$key.title` and `$key.description`. The usual asset lookup rules apply, so if different images are desired on iPhone vs iPad, use the `~iphone` and `~ipad` suffix. If localized images are desired, make sure that the images are only placed in the `.lproj` directories, and not in the top level directory.

## Update Prompt Customization
Fresh Air comes with english localization for the update prompt. This can be customized by adding the localized keys from `FreshAirUpdate.strings` to your application's main bundle's `Localizable.strings` file. To configure an image, add an image named `freshair_update` to the bundle.


## Release Notes
The `release_notes.json` file describes the version history of the application. Every release entry contains any number of 'feature' keys to denote marketing features. There is an [Example](Schema/release_notes.json) of the release note file and a [JSON Schema](Schema/release_notes_schema.json) file that can be used to validate your releases_notes.json file.

## Installation
To install using CocoaPods, include the 'FreshAir' cocoapod.

    pod 'FreshAir'

If you only want the remote app check, use:

    pod 'FreshAir/AppStoreCheck'