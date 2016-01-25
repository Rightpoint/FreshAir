//
//  RZFRemoteBundleController.h
//  FreshAir
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import Foundation;

OBJC_EXTERN NSString *const RZFreshAirErrorDomain;
typedef NS_ENUM(NSUInteger, RZFreshAirErrorCode) {
    RZFreshAirErrorCodeSHAMismatch
};

@protocol RZFManifestManagerDelegate;

@interface RZFManifestManager : NSObject

/**
 *  The environment that the manifest conditions are evaluated against. By default, this dictionary
 *  contains:
 *
 *          platform:      iOS
 *          systemVersion: The value of UIDevice.currentDevice.systemVersion
 *          displayScale:  The value of UIScreen.mainScreen.scale
 *          appVersion:    The value of NSBundle.mainBundle.userInfo.CFBundleShortVersionString
 *          defaults:      The value of NSUserDefaults.standardUserDefaults
 */
+ (NSMutableDictionary *)defaultEnvironment;

/**
 *  The default local URL to download the manifest bundles too.
 */
+ (NSURL *)defaultLocalURL;

/**
 *  Create a new manifest manager that will obtain the manifest at the remote URL and store it in the localURL directory
 *
 *  @param remoteURL The remote URL to load. This should refer to the .freshair file, not the manifest file.
 *  @param localURL The local path to store the root bundle. A directory will be appended to this URL to contain the root bundle.
 *
 *
 *  @param delegate The delegate to be informed when a bundle is loaded.
 */
- (instancetype)initWithRemoteURL:(NSURL *)remoteURL
                         delegate:(id<RZFManifestManagerDelegate>)delegate;


@property (strong, nonatomic, readonly) NSArray* bundles;
@property (assign, nonatomic, readonly) BOOL loaded;


@end

@protocol RZFManifestManagerDelegate <NSObject>

- (void)manifestManager:(RZFManifestManager *)manifestManager didLoadBundle:(NSBundle *)bundle;
- (void)manifestManager:(RZFManifestManager *)manifestManager didEncounterError:(NSError *)error;

@end
