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
 *  Return the remote URL for this bundle. If this is not a freshair bundle
 *  this will raise an exception.
 */
- (NSURL *)rzf_remoteURL;

/**
 *  Return a release notes object for the `release_notes.json` 
 *  file contained in this bundle. If the file does not exist, nil will be
 *  returned.
 */
- (RZFReleaseNotes *)rzf_releaseNotes;

/**
 *  Return the manifest object for the `manifest.json` file contained in
 *  the bundle. If the file does not exist, nil will be returned.
 */
- (RZFManifest *)rzf_manifest;

@end
