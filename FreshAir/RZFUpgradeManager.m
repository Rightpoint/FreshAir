//
//  RZFUpgradeManager.m
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFUpgradeManager.h"
#import "RZFManifestManager.h"
#import "RZFEnvironment.h"

#import "NSBundle+RZFreshAir.h"
#import "NSObject+RZFImport.h"
#import "UIApplication+RZFInteractionDelegate.h"
#import "RZFUpdateViewModel.h"

#import "RZFUpdatePromptViewController.h"
#import "RZFReleaseNotesViewController.h"

@interface RZFUpgradeManager ()
<RZFManifestManagerDelegate, RZFUpdatePromptViewControllerDelegate, RZFReleaseNotesViewControllerDelegate>

@property (strong, nonatomic) RZFManifestManager *upgradeManifestManager;
@property (assign, nonatomic) BOOL shouldShowUpgradePrompt;
@property (strong, nonatomic) RZFEnvironment *environment;

@end

@implementation RZFUpgradeManager


- (instancetype)initWithRemoteURL:(NSURL *)remoteURL
{
    self = [super init];
    if (self) {
        self.environment = [[RZFEnvironment alloc] init];
        self.upgradeManifestManager = [[RZFManifestManager alloc] initWithRemoteURL:remoteURL
                                                                           localURL:nil
                                                                        environment:self.environment
                                                                           delegate:self];
        self.delegate = [UIApplication sharedApplication];
    }
    return self;
}

- (RZFReleaseNotes *)releaseNotes
{
    NSBundle *bundle = self.upgradeManifestManager.bundle;
    RZFReleaseNotes *releaseNotes = [bundle rzf_releaseNotes];
    return releaseNotes;
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
    BOOL showUpgrade = [self.environment shouldDisplayUpgradePrompt:releaseNotes];

    if (showUpgrade && self.upgradeManifestManager.loaded) {
        RZFUpdateViewModel *updateViewModel = [[RZFUpdateViewModel alloc] init];
        updateViewModel.isForced = [self.environment isUpgradeForced:releaseNotes];

        RZFUpdatePromptViewController *vc = [[RZFUpdatePromptViewController alloc] initWithUpdateViewModel:updateViewModel upgradeURL:releaseNotes.upgradeURL bundle:bundle];
        vc.delegate = self;
        [self.delegate rzf_intitiator:self presentViewController:vc];
        self.shouldShowUpgradePrompt = NO;
    }
    else {
        self.shouldShowUpgradePrompt = YES;
    }
}

- (void)updatePromptViewController:(RZFUpdatePromptViewController *)updatePromptViewController shouldUpgradeWithURL:(NSURL *)url
{
    [self.delegate rzf_intitiator:self openURL:url];
}

- (void)dismissUpdatePromptViewController:(RZFUpdatePromptViewController *)updatePromptViewController
{
    [self.environment userDidViewUpdatePromptForReleaseNotes:self.releaseNotes];

    [self.delegate rzf_intitiator:self dismissViewController:updatePromptViewController];
}

- (void)showReleaseNotesIfDesired
{
    if ([self.environment shouldUserSeeReleaseNotes:self.releaseNotes]) {
        [self showReleaseNotes];
    }
}

- (void)showReleaseNotes
{
    NSBundle *bundle = self.upgradeManifestManager.bundle;
    RZFReleaseNotes *releaseNotes = [bundle rzf_releaseNotes];
    NSArray *features = [self.environment unviewedFeaturesForReleaseNotes:releaseNotes];
    RZFReleaseNotesViewController *vc = [[RZFReleaseNotesViewController alloc] initWithFeatures:features bundle:bundle];
    vc.delegate = self;
    [self.delegate rzf_intitiator:self presentViewController:vc];
}

- (void)didSelectDoneForReleaseNotesViewController:(RZFReleaseNotesViewController *)releaseNotesViewController
{
    [self.environment userDidViewContentOfReleaseNotes:self.releaseNotes];
    [self.delegate rzf_intitiator:self dismissViewController:releaseNotesViewController];
}

@end
