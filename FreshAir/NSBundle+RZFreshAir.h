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

+ (NSURL *)rzf_bundleURLInDirectory:(NSURL *)directory forRemoteURL:(NSURL *)remoteURL error:(NSError **)error;

- (NSURL *)rzf_remoteURL;

- (RZFReleaseNotes *)rzf_releaseNotes;

- (RZFManifest *)rzf_manifest;

@end
