//
//  RZFUpgradeManager.h
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import UIKit;

@class RZFUpgradeManager;

@protocol RZFUpgradeManagerDelegate <NSObject>

- (void)upgradeManager:(RZFUpgradeManager *)upgradeManager presentViewController:(UIViewController *)viewController;
- (void)upgradeManager:(RZFUpgradeManager *)upgradeManager dismissViewController:(UIViewController *)viewController;
- (void)upgradeManager:(RZFUpgradeManager *)upgradeManager openURL:(NSURL *)upgradeURL;

@end

@interface RZFUpgradeManager : NSObject

- (instancetype)initWithRemoteURL:(NSURL *)remoteURL currentVersion:(NSString *)currentVersion;

/**
 * Delegate to present. By default this protocol is implemented by UIApplication and performs a modal presentation
 * on top of the rootViewController.
 */
@property (weak, nonatomic) id<RZFUpgradeManagerDelegate> delegate;

- (void)attemptManifestRefresh;

/**
 * Show the upgrade prompt if desired. If there are release notes downloaded and the version
 * has not been viewed, or if an update is forced, trigger the delegate to display the upgrade prompt.
 */
- (void)showUpgradePromptIfDesired;

/**
 * Show the upgrade prompt. This can be triggered to force an update.
 */
- (void)showUpgradePrompt;

/**
 */
- (void)showReleaseNotesIfDesired;


@end
