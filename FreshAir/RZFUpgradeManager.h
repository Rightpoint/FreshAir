//
//  RZFUpgradeManager.h
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import UIKit;

@class RZFUpgradeManager;

@protocol RZFInteractionDelegate;

OBJC_EXTERN NSString *const RZFLastVersionPromptedKey;
OBJC_EXTERN NSString *const RZFLastVersionOfReleaseNotesDisplayedKey;

@interface RZFUpgradeManager : NSObject

- (instancetype)initWithRemoteURL:(NSURL *)remoteURL;

/**
 * Delegate to manage presentation. If not set, the delegate will perform modal
 * presentations on the top-most presented view controller of the UIApplication delegate window property, and call openURL directly on UIApplication.
 */
@property (weak, nonatomic) id<RZFInteractionDelegate> delegate;

/**
 *  Refresh the bundle. This should be called when the network is available.
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
 * If there are release notes for the version running that have not been displayed, display them.
 */
- (void)showReleaseNotesIfDesired;

/**
 * Present the release notes for features that are in the new version of the application.
 */
- (void)showReleaseNotes;


@end

