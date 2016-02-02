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

@end

@implementation RZFUpgradeManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.environment = [[RZFEnvironment alloc] init];
        self.delegate = [UIApplication sharedApplication];
    }
    return self;
}

- (void)showUpgradePromptIfDesired
{
    RZFAppUpdateCheck *check = [[RZFAppUpdateCheck alloc] init];
    check.environment = self.environment;
    [check checkAppStoreID:self.appStoreID completion:^(RZFAppUpdateStatus status, NSString *version, NSURL *upgradeURL) {
        BOOL newVersion = (status == RZFAppUpdateStatusNewVersion);
        BOOL isForced = (status == RZFAppUpdateStatusNewVersionForced);
        if (newVersion || isForced) {
            RZFUpdatePromptViewController *vc = [[RZFUpdatePromptViewController alloc] initWithUpgradeURL:upgradeURL version:version isForced:isForced bundle:nil];
            vc.delegate = self;
            [self.delegate rzf_intitiator:self presentViewController:vc];
        }
    }];
}

- (void)updatePromptViewController:(RZFUpdatePromptViewController *)updatePromptViewController shouldUpgradeWithURL:(NSURL *)url
{
    [self.delegate rzf_intitiator:self openURL:url];
}

- (void)dismissUpdatePromptViewController:(RZFUpdatePromptViewController *)updatePromptViewController
{
    [self.environment userDidViewUpdatePromptForVersion:updatePromptViewController.version];

    [self.delegate rzf_intitiator:self dismissViewController:updatePromptViewController];
}

- (void)showReleaseNotesIfDesired
{
    NSBundle *bundle = self.releaseNoteBundle;
    RZFReleaseNotes *releaseNotes = [bundle rzf_releaseNotes];
    if ([self.environment shouldUserSeeReleaseNotes:releaseNotes]) {
        NSArray *features = [self.environment unviewedFeaturesForReleaseNotes:releaseNotes];
        RZFReleaseNotesViewController *vc = [[RZFReleaseNotesViewController alloc] initWithFeatures:features bundle:bundle];
        vc.delegate = self;
        [self.delegate rzf_intitiator:self presentViewController:vc];
    }
}

- (void)didSelectDoneForReleaseNotesViewController:(RZFReleaseNotesViewController *)releaseNotesViewController
{
    [self.environment userDidViewContentOfReleaseNotesForCurrentVersion];
    [self.delegate rzf_intitiator:self dismissViewController:releaseNotesViewController];
}

@end
