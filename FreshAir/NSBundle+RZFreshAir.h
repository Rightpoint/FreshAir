//
//  NSBundle+RZFreshAir.h
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
OBJC_EXTERN NSString *const RZFreshAirRemoteURL;

@class RZFReleaseNotes, RZFManifest;

@interface NSBundle (RZFreshAir)

/**
 *  NSBundle.mainBundle is not very consistent, depending on the target configuration.
 *  NSBundle.rzf_appBundle returns the bundle that the app delegate is a part of. This
 *  should more consistently point to the application bundle.
 *
 *  @note This returns nil until the UIApplication.delegate is configured. In particular,
 *        this method returns nil durrin +load.
 */
+ (NSBundle *)rzf_appBundle;

/**
 *  Return the remote URL for this bundle. If this is not a freshair bundle
 *  this will raise an exception.
 */
- (NSURL *)rzf_remoteURL;

@end
