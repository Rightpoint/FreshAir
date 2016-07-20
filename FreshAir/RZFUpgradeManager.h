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
 *  The bundle that contains the release_notes.json file and all of the assets to present the release notes
 *  UI. The default value is [NSBundle mainBundle].
 */
@property (strong, nonatomic) NSBundle *releaseNoteBundle;

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
 * This should be called when the app finishes launching. If the app is being launched
 * for the first time, the release notes will not be displayed. When this method is called,
 * the current app version will be saved to the user defaults.
 *
 * @see showNewReleaseNotes:
 */
- (void)showNewReleaseNotes;

/**
 * Present the release notes if there are features that the current user has not seen.
 * This should be called when the app finishes launching. When this method is called,
 * the current app version will be saved to the user defaults.
 *
 * The default behavior is to display release notes if the last saved version is
 * less than the current version. If this method has never been called, there will be no
 * saved version, and the release notes will not be displayed. This behavior can be
 * changed to display the release notes if there is no saved version by setting
 * forceInitialDisplay to YES.
 *
 * @param forceInitialDisplay YES if the release notes should be displayed on initial launch
 */
- (void)showNewReleaseNotes:(BOOL)forceInitialDisplay;

/**
 *  Reset any saved keys in the user defaults.
 *
 */
- (void)resetViewedState;

#pragma mark - Styling

/**
 *  Accent color for release notes view, default if nil
 */
@property (strong, nonatomic, nullable) UIColor *releaseNotesAccentColor;

/**
 *  If YES will present the release notes in full screen, defaults to NO.
 */
@property (assign, nonatomic) BOOL fullScreenReleaseNotes;

/**
 *  The font to use for the title on release notes cells, default if nil.
 */
@property (strong, nonatomic, nullable) UIFont *releaseNotesTitleFont;

/**
 *  Title to show on done button, default if nil.
 */
@property (strong, nonatomic, nullable) NSString *releaseNotesDoneTitle;

/**
 *  Font for done button title, default if nil.
 */
@property (strong, nonatomic, nullable) UIFont *releaseNotesDoneFont;

/**
 *  Background color for done button, default if nil.
 */
@property (strong, nonatomic, nullable) UIColor *releaseNotesDoneBackgroundColor;

/**
 *  Corner radius for done button, 0.0 if nil
 */
@property (assign, nonatomic) CGFloat releaseNotesDoneCornerRadius;

/**
 *  Alpha value to apply to done button to indicate highlight. Defaults to 1.0
 */
@property (assign, nonatomic) CGFloat releaseNotesDoneHighlightAlpha;


@end
