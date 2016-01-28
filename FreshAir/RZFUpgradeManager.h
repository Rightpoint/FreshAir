//
//  RZFUpgradeManager.h
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import UIKit;

@class RZFUpgradeManager;

@protocol RZFUpgradeManagerDelegate;

@interface RZFUpgradeManager : NSObject

- (instancetype)initWithRemoteURL:(NSURL *)remoteURL currentVersion:(NSString *)currentVersion;

/**
 * Delegate to present. By default this protocol is implemented by UIApplication and performs a modal presentation
 * on top of the rootViewController.
 */
@property (weak, nonatomic) id<RZFUpgradeManagerDelegate> delegate;

/**
 *  Refresh the bundle
 */
- (void)refreshUpgradeBundle;

/**
 * Show the upgrade prompt if appropriate.
 *
 * If there is a new version that has not been prompted display the upgrade prompt.
 * Also, if the current version is below the minimum version, display the upgrade prompt and do not allow it to be dismissed.
 */
- (void)showUpgradePromptIfDesired;

/**
 * Present the release notes if appropriate.
 *
 * If there are release notes are downloaded that have not been displayed, present them to the user.
 */
- (void)showReleaseNotesIfDesired;

/**
 * Present the release notes
 *
 */
- (void)showReleaseNotes;


@end

@protocol RZFUpgradeManagerDelegate <NSObject>

- (void)upgradeManager:(RZFUpgradeManager *)upgradeManager presentViewController:(UIViewController *)viewController;
- (void)upgradeManager:(RZFUpgradeManager *)upgradeManager dismissViewController:(UIViewController *)viewController;
- (void)upgradeManager:(RZFUpgradeManager *)upgradeManager openURL:(NSURL *)upgradeURL;

@end
