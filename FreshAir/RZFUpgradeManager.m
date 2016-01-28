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
#import "RZFUpdatePromptViewController.h"
#import "RZFUpdateViewModel.h"

@interface UIApplication (RZFPresentation) <RZFUpgradeManagerDelegate>

@end

@implementation UIApplication (RZFPresentation)

- (void)upgradeManager:(RZFUpgradeManager *)upgradeManager presentViewController:(UIViewController *)viewController
{
    [self.delegate.window.rootViewController presentViewController:viewController animated:YES completion:nil];
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

@interface RZFUpgradeManager () <RZFManifestManagerDelegate, RZFUpdatePromptViewControllerDelegate>

@property (strong, nonatomic) RZFManifestManager *upgradeManifestManager;
@property (strong, nonatomic) NSString *currentVersion;

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
        self.delegate = [UIApplication sharedApplication];
    }
    return self;
}

- (void)refreshUpgradeBundle
{
    [self.upgradeManifestManager update];
}

- (void)showUpgradePromptIfDesired
{
    NSBundle *bundle = self.upgradeManifestManager.bundle;
    RZFReleaseNotes *releaseNotes = [bundle rzf_releaseNotes];
    if (releaseNotes) {
        BOOL isForced = [releaseNotes isUpgradeRequiredForVersion:self.currentVersion];
        if ([releaseNotes isUpgradeAvailableForVersion:self.currentVersion] || isForced) {
            RZFUpdateViewModel *updateViewModel = [[RZFUpdateViewModel alloc] init];
            updateViewModel.isForced = isForced;

            RZFUpdatePromptViewController *vc = [[RZFUpdatePromptViewController alloc] initWithUpdateViewModel:updateViewModel upgradeURL:releaseNotes.upgradeURL bundle:bundle];
            vc.delegate = self;
            [self.delegate upgradeManager:self presentViewController:vc];
        }
    }
}

- (void)manifestManager:(RZFManifestManager *)manifestManager didLoadBundle:(NSBundle *)bundle
{
    [self showUpgradePromptIfDesired];
}

- (void)manifestManager:(RZFManifestManager *)manifestManager didEncounterError:(NSError *)error
{
    NSLog(@"Error Loading Manifest: %@", error);
}

- (void)updatePromptViewController:(RZFUpdatePromptViewController *)updatePromptViewController shouldUpgradeWithURL:(NSURL *)url
{
    [self.delegate upgradeManager:self openURL:url];
}

- (void)dismissUpdatePromptViewController:(RZFUpdatePromptViewController *)updatePromptViewController
{
    [self.delegate upgradeManager:self dismissViewController:updatePromptViewController];
}

- (void)showReleaseNotesIfDesired
{

}

- (void)showReleaseNotes
{

}

@end
