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
NSString *const RZFLastVersionPromptedKey = @"RZFLastVersionPromptedKey";
NSString *const RZFLastVersionOfReleaseNotesDisplayedKey = @"RZFLastVersionOfReleaseNotesDisplayedKey";

@interface RZFUpgradeManager ()
<RZFUpdatePromptViewControllerDelegate, RZFReleaseNotesViewControllerDelegate>

@property (strong, nonatomic, readonly) NSURL *releaseNoteURL;
@property (strong, nonatomic, readonly) NSString *appStoreID;
@property (assign, nonatomic, readonly) NSString *appVersion;
@property (assign, nonatomic, readonly) NSString *systemVersion;

@property (strong, nonatomic) NSUserDefaults *userDefaults;

@end

@implementation RZFUpgradeManager

- (instancetype)initWithReleaseNoteURL:(NSURL *)releaseNoteURL;
{
    self = [self init];
    if (self) {
        _releaseNoteURL = releaseNoteURL;
    }
    return self;
}

- (instancetype)initWithAppStoreID:(NSString *)appStoreID
{
    self = [self init];
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
        _appVersion = [NSBundle bundleForClass:self.delegate.class].infoDictionary[@"CFBundleShortVersionString"];
        _userDefaults = [NSUserDefaults standardUserDefaults];
        _bundle = [NSBundle mainBundle];
    }
    return self;
}

- (BOOL)isNewVersion:(NSString *)newVersion
{
    return [self.appVersion compare:newVersion options:NSNumericSearch] == NSOrderedAscending;
}

- (void)checkForNewUpdate
{
    RZFReleaseNotesCheck *check = nil;
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
    NSBundle *updateBundle = [NSBundle bundleForClass:self.class];
    if ([self.bundle URLForResource:@"FreshAirUpdate" withExtension:@"strings"]) {
        updateBundle = self.bundle;
    }

    [check performCheckWithCompletion:^(RZFAppUpdateStatus status, NSString *version, NSURL *upgradeURL) {
        BOOL newVersion = (status == RZFAppUpdateStatusNewVersion);
        BOOL isForced = (status == RZFAppUpdateStatusNewVersionForced);
        NSString *lastDisplayed = [self.userDefaults stringForKey:RZFLastVersionPromptedKey];
        BOOL newUnseenVersion = [self isNewVersion:lastDisplayed];
        BOOL shouldDisplay = ((newVersion && newUnseenVersion) || isForced);
        if (shouldDisplay) {
            RZFUpdatePromptViewController *vc = nil;
            vc = [[RZFUpdatePromptViewController alloc] initWithUpgradeURL:upgradeURL
                                                                   version:version
                                                                  isForced:isForced
                                                                    bundle:updateBundle];
            vc.delegate = self;
            [self.delegate rzf_interationDelegate:self presentViewController:vc];
        }
    }];
}

- (void)updatePromptViewController:(RZFUpdatePromptViewController *)updatePromptViewController shouldUpgradeWithURL:(NSURL *)url
{
    [self.delegate rzf_interationDelegate:self openURL:url];
}

- (void)dismissUpdatePromptViewController:(RZFUpdatePromptViewController *)updatePromptViewController
{
    [self.userDefaults setObject:self.appVersion forKey:RZFLastVersionPromptedKey];
    [self.delegate rzf_interationDelegate:self dismissViewController:updatePromptViewController];
}

- (void)showNewReleaseNotes
{
    NSURL *releaseURL = [self.bundle.bundleURL URLByAppendingPathComponent:@"release_notes.json"];
    NSError *error = nil;
    RZFReleaseNotes *releaseNotes = [RZFReleaseNotes releaseNotesWithURL:releaseURL error:&error];
    if (error) {
        NSLog(@"Error Loading release Notes: %@", error);
    }
    NSString *lastVersion = [self.userDefaults stringForKey:RZFLastVersionOfReleaseNotesDisplayedKey];
    if (lastVersion != nil && [self isNewVersion:lastVersion]) {
        NSArray *features = [releaseNotes featuresFromVersion:lastVersion toVersion:self.appVersion];
        RZFReleaseNotesViewController *vc = [[RZFReleaseNotesViewController alloc] initWithFeatures:features bundle:self.bundle];
        vc.delegate = self;
       [self.delegate rzf_interationDelegate:self presentViewController:vc];
    }
}

- (void)didSelectDoneForReleaseNotesViewController:(RZFReleaseNotesViewController *)releaseNotesViewController
{
    [self.userDefaults setObject:self.appVersion forKey:RZFLastVersionOfReleaseNotesDisplayedKey];
    [self.delegate rzf_interationDelegate:self dismissViewController:releaseNotesViewController];
}

- (void)resetViewedState
{
    [self.userDefaults removeObjectForKey:RZFLastVersionPromptedKey];
    [self.userDefaults removeObjectForKey:RZFLastVersionOfReleaseNotesDisplayedKey];
}

@end
