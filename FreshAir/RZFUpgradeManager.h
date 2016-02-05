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

/**
 *  RZFUpgradeManager coordinates the remote release check, the presentation
 *  of the upgrade prompt, and persists the state required to not show the same
 *  prompt multiple times.
 *
 *  UI Presentation can be customized via the delegate. To customize the UI completely,
 *  it is recommended to just use RZFAppStoreUpdateCheck or RZFReleaseNotesCheck 
 *  directly
 */
@interface RZFUpgradeManager : NSObject

/**
 *  Initialize the upgrade manager pointing to a remotely hosted release note
 *  file. This file will describe the releases and supported system versions
 *  so the upgrade prompt will not be presented if the new release does not support
 *  the current system version. The release notes also allow an upgrade to be
 *  forced remotely.
 */
- (instancetype)initWithReleaseNoteURL:(NSURL *)releaseNoteURL;

/**
 *  Initialize the upgrade manager pointing to the App Store API. This will support
 *  notification of new versions, but the support for system version compatibility
 *  is not as robust, and an upgrade can not be forced.
 *
 *  The following scenario describes the system compatibility limitations:
 *
 *        Given 3 app versions, 1.0, 1.1, and 2.0, and requiring iOS 8.0, 8.0, and 9.0, respectively.
 *        When a user running 1.0 on iOS 8.0 starts the app.
 *        Then they will not be notified that the 1.1 upgrade is available.
 */
- (instancetype)initWithAppStoreID:(NSString *)appStoreID;

/**
 *  The bundle that contains resources for the release notes. If not set,
 *  NSBundle.mainBundle() will be used.
 */
@property (strong, nonatomic) NSBundle *bundle;

/**
 * Delegate to manage presentation. If not set, the delegate will perform modal
 * presentations on the top-most presented view controller of the UIApplication 
 * delegate window property, and call openURL directly on UIApplication.
 */
@property (weak, nonatomic) id<RZFInteractionDelegate> delegate;

/**
 * Check for a new update and present the update view to the user. This should
 * be called on application resume.
 *
 * Also, if the current version is below the minimum version, display the upgrade
 * prompt and do not allow it to be dismissed.
 */
- (void)checkForNewUpdate;

/**
 * Present the release notes if there are features that the current user has not seen.
 */
- (void)showNewReleaseNotes;

/**
 *  Reset any stored keys in the user defaults.
 */
- (void)resetViewedState;

@end
