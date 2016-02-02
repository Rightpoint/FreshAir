//
//  NSBundle+RZFreshAir.m
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "NSBundle+RZFreshAir.h"
#import "RZFManifest+Private.h"
#import "RZFError.h"
#import "RZFReleaseNotes.h"
#import "RZFManifest.h"
#import "NSObject+RZFImport.h"
#import "NSURL+RZFManifest.h"

NSString *const RZFreshAirRemoteURL = @"RZFreshAirRemoteURL";

@implementation NSBundle (RZFreshAir)

- (NSURL *)rzf_remoteURL
{
    NSString *absoluteURL = self.infoDictionary[RZFreshAirRemoteURL];
    NSAssert(absoluteURL != nil, @"rzf_remoteURL is only supported on .freshair bundles");
    return [NSURL URLWithString:absoluteURL];
}

- (RZFReleaseNotes *)rzf_releaseNotes
{
    NSURL *releaseURL = [self.bundleURL rzf_releaseURL];
    NSError *error = nil;
    RZFReleaseNotes *releaseNotes = [RZFReleaseNotes rzf_importURL:releaseURL error:&error];
    if (error) {
        NSLog(@"Error Loading release Notes: %@", error);
    }
    return releaseNotes;
}

- (RZFManifest *)rzf_manifest
{
    RZFManifest *manifest = [[RZFManifest alloc] initWithBundle:self];
    if ([manifest isManifestLoaded]) {
        [manifest loadEntriesError:nil];
    }
    return manifest;
}

@end
