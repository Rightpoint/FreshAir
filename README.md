# Fresh Air
Fresh Air is an application update library. It is designed check a remote location for application updates and if updates are available, prompt the user to upgrade the application. When the new version of the application is started, a dialog can be presented that show case the new features available to the user.

## Update Checks
Fresh Air supports checking iTunes for a new version, and checking a remotely hosted `release_notes.json` file.

    let upgradeManager = RZFUpgradeManager(appStoreID:"ANAPPID")
    upgradeManager.checkForNewUpdate()

This will check the iTunes for an app with the specified ID, and present a dialog if an update exists. See [RZFUpgradeManager](FreshAir/RZFUpgradeManager.h) for how to manage the Presentation UI.

## Release Note Presentation
Fresh Air also supports presenting release notes as a series of paging images with a title and description. This can be used to introduce users to the new features in the app. This is managed by a set of feature keys specified in `release_notes.json` which are used to expanded into an image, a title, and a description. This is supported via `[UIImage imageNamed:$key]`, and the localization keys `$key.title` and `$key.description`. The usual asset lookup rules apply, so if different images are desired on iPhone vs iPad, use the `~iphone` and `~ipad` suffix and if localized images are desired, make sure that the images are only placed in the `.lproj` directories, and not in the top level directory.

## Update Prompt Customization
Fresh Air comes with english localization for the update prompt. This can be customized by adding the localized keys from `FreshAirUpdate.strings` to your application's main bundle's `Localized.strings` file. To configure an image, add an image named `freshair_update` to the bundle.


## Release Notes
The `release_notes.json` file is included that describe the version history of the application. Every release entry contains any number of keys to denote marketing features. There are [Examples](Schema/Examples/Test.releaseNotes/release_notes.json) of the manifest file and a [JSON Schema](Schema/release_notes_schema.json) file is included to validate your releases_notes.json file.

