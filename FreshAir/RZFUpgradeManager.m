//
//  RZFUpgradeManager.m
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFUpgradeManager.h"

#import "NSObject+RZFImport.h"
#import "UIApplication+RZFInteractionDelegate.h"
#import "RZFUpdateViewModel.h"
#import "RZFReleaseNotesCheck.h"
#import "RZFAppStoreUpdateCheck.h"

#import "RZFUpdatePromptViewController.h"
#import "RZFReleaseNotesViewController.h"

// Keys for tracking state in NSUserDefaults
static NSString *const RZFLastVersionPromptedKey = @"RZFLastVersionPromptedKey";
static NSString *const RZFLastVersionOfReleaseNotesDisplayedKey = @"RZFLastVersionOfReleaseNotesDisplayedKey";
static NSString *const RZFReleaseNotesResourceName = @"release_notes";
static NSString *const RZFReleaseNotesResourceExtension = @"json";

@interface RZFUpgradeManager () <RZFUpdatePromptViewControllerDelegate, RZFReleaseNotesViewControllerDelegate>

@property (strong, nonatomic, readonly) NSURL *releaseNoteURL;
@property (strong, nonatomic, readonly) NSString *appStoreID;
@property (assign, nonatomic, readonly) NSString *appVersion;
@property (assign, nonatomic, readonly) NSString *systemVersion;
@property (weak, nonatomic) UIViewController *presentedViewController;

@property (strong, nonatomic) NSUserDefaults *userDefaults;

@end

@implementation RZFUpgradeManager

- (instancetype)initWithReleaseNoteURL:(NSURL *)releaseNoteURL;
{
    self = [self.class sharedInstance];
    if (self) {
        _releaseNoteURL = releaseNoteURL;
    }
    return self;
}

- (instancetype)initWithAppStoreID:(NSString *)appStoreID
{
    self = [self.class sharedInstance];
    if (self) {
        _appStoreID = appStoreID;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegate = [UIApplication sharedApplication];
        _systemVersion = [[UIDevice currentDevice] systemVersion];
        id appObject = [[UIApplication sharedApplication] delegate];
        _appVersion = [NSBundle bundleForClass:[appObject class]].infoDictionary[@"CFBundleShortVersionString"];
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _releaseNoteBundle = [NSBundle mainBundle];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static RZFUpgradeManager *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[RZFUpgradeManager alloc] init];
    });
    return s_manager;
}

- (void)checkForNewUpdate
{
    RZFReleaseNotesCheck *check;

    if (self.appStoreID) {
        // RZFAppStoreUpdateCheck has the same contract as RZFAppUpdateCheck.
        // RZFAppStoreUpdateCheck was written to be isolated from the rest of the
        // implementation details in FreshAir.
        //
        // Casting here is cleaner than creating a shared protocol and compliance.
        check = (id)[[RZFAppStoreUpdateCheck alloc] initWithAppStoreID:self.appStoreID];
    }
    else {
        check = [[RZFReleaseNotesCheck alloc] initWithReleaseNoteURL:self.releaseNoteURL
                                                          appVersion:self.appVersion
                                                       systemVersion:self.systemVersion];
    }

    [check performCheckWithCompletion:^(RZFAppUpdateStatus status, NSString *version, NSURL *upgradeURL) {
        BOOL newVersion = (status == RZFAppUpdateStatusNewVersion);
        BOOL isForced = (status == RZFAppUpdateStatusNewVersionForced);
        NSString *lastDisplayed = [self.userDefaults stringForKey:RZFLastVersionPromptedKey];
        BOOL newUnseenVersion = ((lastDisplayed == nil) || ([self.appVersion compare:lastDisplayed options:NSNumericSearch] == NSOrderedAscending));
        BOOL shouldDisplay = ((newVersion && newUnseenVersion) || isForced);

        // The handling of the RZFAppUpdateStatusNewVersionUnsupportedOnDevice state is implicit here.
        // If the update is forced, we show the user the forced update screen no matter what (ignoring
        // if the device is supported or not). If there is an update, but it's not supported, we ignore
        // state and just don't show the user anything.
        if (shouldDisplay) {
            // Check to see if something other than the update prompt is being presented at the moment.
            // This introduces some oddities into the RZFInteractionDelegate contract which needs to be
            // resolved at some point in the future. This logic should be moved into the default
            // implementation and not exist here in case the consumer's delegate wants a differing
            // presentation method.
            if ([self.presentedViewController isKindOfClass:[RZFUpdatePromptViewController class]]) {
                // If we are already showing an update prompt, bail. There's nothing left to do.
                return;
            }
            else if (self.presentedViewController) {
                // If any other view controller is being presented (at this moment, only
                // other option is the release notes), kill it and continue on!
                [self dismissViewController:self.presentedViewController];
            }

            RZFUpdatePromptViewController *vc = nil;
            vc = [[RZFUpdatePromptViewController alloc] initWithUpgradeURL:upgradeURL
                                                                   version:version
                                                                  isForced:isForced];
            vc.delegate = self;
            [self presentViewController:vc];

            [self.userDefaults setObject:self.appVersion forKey:RZFLastVersionPromptedKey];
        }
    }];
}

- (void)updatePromptViewController:(RZFUpdatePromptViewController *)updatePromptViewController shouldUpgradeWithURL:(NSURL *)url
{
    [self.delegate rzf_interationDelegate:self openURL:url];
}

- (void)dismissUpdatePromptViewController:(RZFUpdatePromptViewController *)updatePromptViewController
{
    [self dismissViewController:updatePromptViewController];
}

- (void)showNewReleaseNotes
{
    [self showNewReleaseNotes:NO];
}

- (void)showNewReleaseNotes:(BOOL)forceInitialDisplay
{
    // If something is already being presented it is either a set of release notes,
    // or an update notification. In either case, bail and don't do anything.
    if (self.presentedViewController) {
        return;
    }

    NSURL *releaseURL = [self.releaseNoteBundle URLForResource:RZFReleaseNotesResourceName withExtension:RZFReleaseNotesResourceExtension];
    if (!releaseURL) {
        NSLog(@"failed to load '%@.%@' from bundle %@", RZFReleaseNotesResourceName, RZFReleaseNotesResourceExtension, self.releaseNoteBundle.bundleIdentifier);
        return;
    }

    NSError *error;
    RZFReleaseNotes *releaseNotes = [RZFReleaseNotes releaseNotesWithURL:releaseURL error:&error];
    if (!releaseNotes) {
        NSLog(@"Error Loading release Notes: %@", error);
        return;
    }

    NSString *lastVersion = [self.userDefaults stringForKey:RZFLastVersionOfReleaseNotesDisplayedKey];
    if (forceInitialDisplay && (lastVersion == nil)) {
        lastVersion = releaseNotes.releases.firstObject.version;
    }

    if ((lastVersion != nil) && ([self.appVersion compare:lastVersion options:NSNumericSearch] == NSOrderedDescending)) {
        NSArray *features = [releaseNotes featuresFromVersion:lastVersion toVersion:self.appVersion];

        if (features.count > 0) {
            RZFReleaseNotesViewController *vc = [[RZFReleaseNotesViewController alloc] initWithFeatures:features releaseNotes:releaseNotes];
            vc.delegate = self;
            [self presentViewController:vc];
        }
    }

    [self.userDefaults setObject:self.appVersion forKey:RZFLastVersionOfReleaseNotesDisplayedKey];
}

- (void)didSelectDoneForReleaseNotesViewController:(RZFReleaseNotesViewController *)releaseNotesViewController
{
    [self dismissViewController:releaseNotesViewController];
}

- (void)resetViewedState
{
    [self.userDefaults removeObjectForKey:RZFLastVersionPromptedKey];
    [self.userDefaults removeObjectForKey:RZFLastVersionOfReleaseNotesDisplayedKey];
}

#pragma mark - Delegation Helpers

- (void)presentViewController:(nonnull UIViewController *)viewControllerToPresent
{
    // Sanity check the parameter to make sure we aren't being fed with a nil
    NSParameterAssert(viewControllerToPresent);

    // Ensure the same thing isn't being re-presented.
    // This may need a check at some point to make sure the `presentedViewController`
    // was actually presented but, for the moment, assume a perfect world
    // and it was.
    if (self.presentedViewController == viewControllerToPresent) {
        return;
    }

    // If a VC is already being presented, get rid of it. Let
    // the caller figure out if they should be presenting something or not,
    // that's not a decision we should be making here
    if (self.presentedViewController != nil) {
        [self dismissViewController:self.presentedViewController];
    }

    // Store the new presented VC then tell our delegate to do it's thing
    self.presentedViewController = viewControllerToPresent;
    [self.delegate rzf_interationDelegate:self presentViewController:viewControllerToPresent];
}

- (void)dismissViewController:(nonnull UIViewController *)viewControllerToDismiss
{
    NSParameterAssert(viewControllerToDismiss);
    NSAssert(self.presentedViewController == viewControllerToDismiss, @"attempting to dismiss view controller %@, but presented view controller is %@", viewControllerToDismiss, self.presentedViewController);

    [self.delegate rzf_interationDelegate:self dismissViewController:viewControllerToDismiss];
    self.presentedViewController = nil;
}

@end
