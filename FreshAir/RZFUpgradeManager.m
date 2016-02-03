//
//  RZFUpgradeManager.m
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFUpgradeManager.h"
#import "RZFBundleResourceRequest.h"
#import "RZFEnvironment.h"

#import "NSURL+RZFManifest.h"
#import "NSBundle+RZFreshAir.h"
#import "NSObject+RZFImport.h"
#import "UIApplication+RZFInteractionDelegate.h"
#import "RZFUpdateViewModel.h"
#import "RZFAppUpdateCheck.h"

#import "RZFUpdatePromptViewController.h"
#import "RZFReleaseNotesViewController.h"

@interface RZFUpgradeManager ()
<RZFUpdatePromptViewControllerDelegate, RZFReleaseNotesViewControllerDelegate>

@property (assign, nonatomic) BOOL shouldShowUpgradePrompt;
@property (strong, nonatomic) RZFEnvironment *environment;
@property (strong, nonatomic) NSBundle *updateBundle;

@end

@implementation RZFUpgradeManager

+ (NSDictionary *)environmentVariables
{
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *scaleString = [@([[UIScreen mainScreen] scale]) stringValue];
    NSDictionary *infoDictionary = [[NSBundle rzf_appBundle] infoDictionary];
    NSString *appVersion = infoDictionary[@"CFBundleShortVersionString"];
    return @{
             RZFEnvironmentPlatformKey: @"iOS",
             RZFEnvironmentSystemVersionKey: systemVersion,
             RZFEnvironmentDisplayScaleKey: scaleString,
             RZFEnvironmentAppVersionKey: appVersion,
             };
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.environment = [[RZFEnvironment alloc] initWithVariables:[self.class environmentVariables]];
        self.delegate = [UIApplication sharedApplication];
        self.updateBundle = [NSBundle bundleForClass:self.class];
    }
    return self;
}

- (void)setBundle:(NSBundle *)bundle
{
    _bundle = bundle;
    if ([bundle URLForResource:@"FreshAirUpdate" withExtension:@"strings"]) {
        self.updateBundle = bundle;
    }
}

- (void)showUpgradePromptIfDesired
{
    RZFAppUpdateCheck *check = nil;
    if (self.appStoreID) {
        check = [[RZFAppUpdateCheck alloc] initWithAppStoreID:self.appStoreID
                                                  environment:self.environment];
    }
    else {
        check = [[RZFAppUpdateCheck alloc] initWithReleaseNoteURL:self.releaseNoteURL
                                                      environment:self.environment];
    }
    [check performCheckWithCompletion:^(RZFAppUpdateStatus status, NSString *version, NSURL *upgradeURL) {
        BOOL newVersion = (status == RZFAppUpdateStatusNewVersion);
        BOOL isForced = (status == RZFAppUpdateStatusNewVersionForced);
        if (newVersion || isForced) {
            RZFUpdatePromptViewController *vc = nil;
            vc = [[RZFUpdatePromptViewController alloc] initWithUpgradeURL:upgradeURL
                                                                   version:version
                                                                  isForced:isForced
                                                                    bundle:self.updateBundle];
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
    [self.environment userDidViewUpdatePromptForVersion:updatePromptViewController.version];

    [self.delegate rzf_interationDelegate:self dismissViewController:updatePromptViewController];
}

- (void)showReleaseNotesIfDesired
{
    NSBundle *bundle = self.bundle;
    if (bundle == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Must configure the bundle"];
    }
    NSURL *releaseURL = [bundle.bundleURL rzf_releaseURL];
    NSError *error = nil;
    RZFReleaseNotes *releaseNotes = [RZFReleaseNotes releaseNotesWithURL:releaseURL error:&error];
    if (error) {
        NSLog(@"Error Loading release Notes: %@", error);
    }

    if ([self.environment shouldUserSeeReleaseNotes:releaseNotes]) {
        NSArray *features = [self.environment unviewedFeaturesForReleaseNotes:releaseNotes];
        RZFReleaseNotesViewController *vc = [[RZFReleaseNotesViewController alloc] initWithFeatures:features bundle:bundle];
        vc.delegate = self;
        [self.delegate rzf_interationDelegate:self presentViewController:vc];
    }
}

- (void)didSelectDoneForReleaseNotesViewController:(RZFReleaseNotesViewController *)releaseNotesViewController
{
    [self.environment userDidViewContentOfReleaseNotesForCurrentVersion];
    [self.delegate rzf_interationDelegate:self dismissViewController:releaseNotesViewController];
}

- (void)resetViewedState
{
    [self.environment.userDefaults removeObjectForKey:RZFLastVersionPromptedKey];
    [self.environment.userDefaults removeObjectForKey:RZFLastVersionOfReleaseNotesDisplayedKey];
}

@end
