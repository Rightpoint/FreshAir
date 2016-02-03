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

- (instancetype)init;

/**
 *  App Store ID to check for updates using the iTunes API.
 */
@property (strong, nonatomic) NSString *appStoreID;

/**
 *  URL pointing to release_notes.json to use to check for updates.
 */
@property (strong, nonatomic) NSURL *releaseNoteURL;

/**
 *  The bundle that contains resources for the release notes. If this bundle contains
 *  a FreshAirUpdate.strings file, the bundle will also be used for the upgrade prompt.
 */
@property (strong, nonatomic) NSBundle *bundle;

/**
 * Delegate to manage presentation. If not set, the delegate will perform modal
 * presentations on the top-most presented view controller of the UIApplication 
 * delegate window property, and call openURL directly on UIApplication.
 */
@property (weak, nonatomic) id<RZFInteractionDelegate> delegate;

/**
 * Show the upgrade prompt if appropriate.
 *
 *  If there is a new version that has not been prompted display the upgrade prompt.
 *  Also, if the current version is below the minimum version, display the upgrade 
 *  prompt and do not allow it to be dismissed.
 */
- (void)showUpgradePromptIfDesired;

/**
 * Present the release notes if appropriate.
 *
 * If there are release notes for the version running that have not been displayed, display them.
 */
- (void)showReleaseNotesIfDesired;

/**
 *  Reset any stored keys in the user defaults.
 */
- (void)resetViewedState;

@end
