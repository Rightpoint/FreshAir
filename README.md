# Fresh Air
Fresh Air is a library designed to publish statically hosted data (ie: Amazon S3) to your mobile application. The library checks a remotly hosted manifest file and downloads all appropriate files to the local device. 


## Manifest File
For every file, the manifest contains the relative file path, the SHA of the file, and a condition to evaluate. This condition is evaluated on the device, and only conditions that evaluate to true are downloaded.

Here is an example of a manifest file. This manifest lists 2 files. The first file is downloaded if the device is iOS and the app version is below 1.0, and the other if the app version is above 1.0.

**App.freshair/manifest.json**
```
[
    {
        "condition": "platform == 'iOS' && systemVersion > 8.4 && appVersion < 1.0"
        "filename": "ForceUpgrade.freshair/manifest.json",
        "sha": "ABCDEF012345"
    },
    {
        "condition": "platform == 'iOS' && systemVersion > 8.4 && appVersion > 1.0"
        "filename": "NotifyUpgrade.freshair/manifest.json",
        "sha": "ABCDEF012345"
    }
]
```

Once downloaded, an NSBundle is created and passed to the application where further action can be taken.

### Child Manifest File
In the case above, 2 child manifest files are listed. A top level manifest can be used to distribute multiple child manifest files. Once the manifest file is downloaded, the child manifest will be downloaded as well. This is useful to manage different toplevel features.
 
**App.freshair/ForceUpgrade.freshair/manifest.json**
```
[
    {
        "filename": "en.lproj/localizable.strings",
        "sha": "ABCDEF012345"
    },
    {
        "filename": "presentation.json",
        "sha": "ABCDEF012345"
    },
    {
        "filename": "raizlabs_logo.png",
        "sha": "ABCDEF012345",
    },
    {
        "filename": "raizlabs_logo@2x.png",
        "sha": "ABCDEF012345",
    },
    {
        "filename": "RZUpgradeViewController.xib",
        "sha": "ABCDEF012345"
    }
]
```


## iOS Presentation File
A `presentation.json` file can be stored in the manifest that informs the application to present a screen. This is a simple container that will use KVC to create and configure a view controller to be presented. The view controller is loaded with the downloaded `.freshair` directory as an `NSBundle`. This allows all of the resources to be modified after deployment. Even The `.xib` or `.storyboard` can be updated and re-deployed.

**App.freshair/ForceUpgrade.freshair/presentation.json**
```
{
    "screen": "ForceUpgrade",
    "viewController": "RZUpgradeViewController",
    "configuration": {
        "releaseNotes" = [
            {
                "image":"raizlabs_logo",
                "title": "Something New",
                "description": "Description"
            }
        ],
        "forceUpgrade": true
    }
}
```

## Condition Evaluation
The condition statements are evaluated against a simple `NSDictionary` that is copied from `+[RZFManifestManager defaultEnvironment]` on instantiation. This dictionary is pre-populated with a set of default values, but can be easily extended. A lot of extensibility can be achieved by using the standard user defaults, which can be accessed using KVC compliant keypaths against the `defaults` key.


# Breeze
Breeze is a command line program to automate some of the tedious tasks involed with creating and managing manifest files. It will automatically update the SHA files in the manifest, as well as generate a manifest file based on a `.xcassets` directory, and create the correct conditions for the various image sizes.