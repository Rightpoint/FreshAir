//
//  RZFUpgradeManager.m
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFUpgradeManager.h"
#import "RZFManifestManager.h"

#import "NSBundle+RZFreshAir.h"
#import "NSObject+RZFImport.h"
#import "RZFUpdateViewModel.h"

#import "RZFUpdatePromptViewController.h"
#import "RZFReleaseNotesViewController.h"

NSString *const RZFLastVersionPromptedKey = @"RZFLastVersionPromptedKey";
NSString *const RZFLastVersionOfReleaseNotesDisplayedKey = @"RZFLastVersionOfReleaseNotesDisplayedKey";

@interface UIApplication (RZFPresentation) <RZFUpgradeManagerDelegate>
@end

@implementation UIApplication (RZFPresentation)

- (void)upgradeManager:(RZFUpgradeManager *)upgradeManager presentViewController:(UIViewController *)viewController
{
    UIViewController *topViewController = self.delegate.window.rootViewController;
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    [topViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)upgradeManager:(RZFUpgradeManager *)upgradeManager dismissViewController:(UIViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)upgradeManager:(RZFUpgradeManager *)upgradeManager openURL:(NSURL *)upgradeURL
{
    [self openURL:upgradeURL];
}

@end

@interface RZFUpgradeManager ()
<RZFManifestManagerDelegate, RZFUpdatePromptViewControllerDelegate, RZFReleaseNotesViewControllerDelegate>

@property (strong, nonatomic) RZFManifestManager *upgradeManifestManager;
@property (strong, nonatomic) NSString *currentVersion;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (assign, nonatomic) BOOL shouldShowUpgradePrompt;

@end

@implementation RZFUpgradeManager

+ (void)load
{
    NSMutableDictionary *environment = [RZFManifestManager defaultEnvironment];
    [environment setValue:@"iOS" forKey:@"platform"];
    [environment setValue:[[UIDevice currentDevice] systemVersion] forKey:@"systemVersion"];
    [environment setValue:[@([[UIScreen mainScreen] scale]) stringValue] forKey:@"displayScale"];
}

- (instancetype)initWithRemoteURL:(NSURL *)remoteURL currentVersion:(NSString *)currentVersion
{
    self = [super init];
    if (self) {
        NSMutableDictionary *environment = [RZFManifestManager defaultEnvironment];
        environment[@"version"] = currentVersion;
        self.upgradeManifestManager = [[RZFManifestManager alloc] initWithRemoteURL:remoteURL
                                                                           localURL:nil
                                                                        environment:environment
                                                                           delegate:self];
        self.currentVersion = currentVersion;
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        self.delegate = [UIApplication sharedApplication];
    }
    return self;
}

- (void)refreshUpgradeBundle
{
    [self.upgradeManifestManager update];
}

- (void)manifestManager:(RZFManifestManager *)manifestManager didLoadBundle:(NSBundle *)bundle
{
    if (self.shouldShowUpgradePrompt) {
        [self showUpgradePromptIfDesired];
    }
}

- (void)manifestManager:(RZFManifestManager *)manifestManager didEncounterError:(NSError *)error
{
    NSLog(@"Error Loading Manifest: %@", error);
}

- (void)showUpgradePromptIfDesired
{
    NSBundle *bundle = self.upgradeManifestManager.bundle;
    RZFReleaseNotes *releaseNotes = [bundle rzf_releaseNotes];
    if (releaseNotes && self.upgradeManifestManager.loaded) {
        NSString *lastVersionPrompted = [self.userDefaults stringForKey:RZFLastVersionPromptedKey];
        BOOL isForced = [releaseNotes isUpgradeRequiredForVersion:self.currentVersion];
        BOOL shouldDisplay = ([releaseNotes isUpgradeAvailableForVersion:self.currentVersion] &&
                              [lastVersionPrompted isEqual:releaseNotes.lastVersion] == NO);
        if (shouldDisplay || isForced) {
            RZFUpdateViewModel *updateViewModel = [[RZFUpdateViewModel alloc] init];
            updateViewModel.isForced = isForced;

            RZFUpdatePromptViewController *vc = [[RZFUpdatePromptViewController alloc] initWithUpdateViewModel:updateViewModel upgradeURL:releaseNotes.upgradeURL bundle:bundle];
            vc.delegate = self;
            [self.delegate upgradeManager:self presentViewController:vc];
            self.shouldShowUpgradePrompt = NO;
        }
    }
    else {
        self.shouldShowUpgradePrompt = YES;
    }
}

- (void)updatePromptViewController:(RZFUpdatePromptViewController *)updatePromptViewController shouldUpgradeWithURL:(NSURL *)url
{
    [self.delegate upgradeManager:self openURL:url];
}

- (void)dismissUpdatePromptViewController:(RZFUpdatePromptViewController *)updatePromptViewController
{
    NSBundle *bundle = self.upgradeManifestManager.bundle;
    RZFReleaseNotes *releaseNotes = [bundle rzf_releaseNotes];
    [self.userDefaults setValue:releaseNotes.lastVersion forKey:RZFLastVersionPromptedKey];
    [self.delegate upgradeManager:self dismissViewController:updatePromptViewController];
}

- (void)showReleaseNotesIfDesired
{
    NSString *lastVersion = [self.userDefaults stringForKey:RZFLastVersionOfReleaseNotesDisplayedKey];
    // If this is the first time the app has run, nothing should be displayed (IE: First install)
    if (lastVersion == nil) {
        [self.userDefaults setValue:self.currentVersion forKey:RZFLastVersionOfReleaseNotesDisplayedKey];
    }
    // If the last version displayed is not equal to this version, display release notes
    else if ([lastVersion compare:self.currentVersion options:NSNumericSearch] != NSOrderedSame) {
        [self showReleaseNotes];
    }
}

- (void)showReleaseNotes
{
    NSString *lastVersion = [self.userDefaults stringForKey:RZFLastVersionOfReleaseNotesDisplayedKey];
    NSBundle *bundle = self.upgradeManifestManager.bundle;
    RZFReleaseNotes *releaseNotes = [bundle rzf_releaseNotes];
    NSArray *features = [releaseNotes featuresFromVersion:lastVersion toVersion:self.currentVersion];
    RZFReleaseNotesViewController *vc = [[RZFReleaseNotesViewController alloc] initWithFeatures:features bundle:bundle];
    vc.delegate = self;
    [self.delegate upgradeManager:self presentViewController:vc];
}

- (void)didSelectDoneForReleaseNotesViewController:(RZFReleaseNotesViewController *)releaseNotesViewController
{
    [self.userDefaults setValue:self.currentVersion forKey:RZFLastVersionOfReleaseNotesDisplayedKey];
    [self.delegate upgradeManager:self dismissViewController:releaseNotesViewController];
}


@end
