//
//  RZFEnvironment.h
//  FreshAir
//
//  Created by Brian King on 1/29/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXTERN NSString *const RZFEnvironmentPlatformKey;
OBJC_EXTERN NSString *const RZFEnvironmentSystemVersionKey;
OBJC_EXTERN NSString *const RZFEnvironmentDisplayScaleKey;
OBJC_EXTERN NSString *const RZFEnvironmentAppVersionKey;

@class RZFReleaseNotes, RZFFeature;

@interface RZFEnvironment : NSObject

/**
 *  The variables that the conditions are evaluated against. By default, this dictionary
 *  contains:
 *
 *          platform:      iOS
 *          systemVersion: The value of UIDevice.currentDevice.systemVersion
 *          displayScale:  The value of UIScreen.mainScreen.scale
 *          appVersion:    The value of NSBundle.mainBundle.userInfo.CFBundleShortVersionString
 */
+ (NSMutableDictionary<NSString *, NSString *> *)defaultVariables;

/**
 *  A dictionary of all variables configured in the environment.
 */
@property (strong, nonatomic) NSDictionary<NSString *, NSString *> *variables;

/**
 *  The user defaults object to store the state of what the user has viewed. By default
 *  this is [NSUserDefaults standardUserDefaults].
 */
@property (strong, nonatomic) NSUserDefaults *userDefaults;

/**
 *  Return YES if a new release is in the release notes and the latest release
 *  has not been shown.
 */
- (BOOL)shouldDisplayUpgradePrompt:(RZFReleaseNotes *)releaseNotes;

/**
 *  Return YES if the current version is less than the minimum required version.
 */
- (BOOL)isUpgradeForced:(RZFReleaseNotes *)releaseNotes;

/**
 *  Check if the user should see release notes
 */
- (BOOL)shouldUserSeeReleaseNotes:(RZFReleaseNotes *)releaseNotes;

/**
 *  Obtain the unviewed features in the release notes
 */
- (NSArray<RZFFeature *> *)unviewedFeaturesForReleaseNotes:(RZFReleaseNotes *)releaseNotes;

/**
 *  Note that the user has viewed the release notes
 */
- (void)userDidViewContentOfReleaseNotes:(RZFReleaseNotes *)releaseNotes;

/**
 *  Note that the user has viewed the specified version.
 */
- (void)userDidViewUpdatePromptForReleaseNotes:(RZFReleaseNotes *)releaseNotes;

/**
 * Check to see if the bundle is loaded
 */
- (BOOL)isRemoteBundleLoaded:(NSBundle *)bundle;

@end
