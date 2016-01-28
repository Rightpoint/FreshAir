//
//  NSBundle+RZFreshAir.m
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "NSBundle+RZFreshAir.h"
#import "RZFError.h"
#import "RZFReleaseNotes.h"
#import "RZFManifest.h"
#import "NSObject+RZFImport.h"
#import "NSURL+RZFManifest.h"

NSString *const RZFreshAirRemoteURL = @"RZFreshAirRemoteURL";
NSString *const RZFreshAirRemoteBundleIdPrefix = @"com.raizlabs.freshair.";

@implementation NSBundle (RZFreshAir)

+ (NSURL *)rzf_bundleURLInDirectory:(NSURL *)directory forRemoteURL:(NSURL *)remoteURL error:(NSError **)error
{
    NSParameterAssert(directory);
    NSParameterAssert(remoteURL);

    NSString *bundleName = [remoteURL lastPathComponent];
    NSURL *bundleURL = [directory URLByAppendingPathComponent:bundleName];

    if ([[NSFileManager defaultManager] createDirectoryAtURL:bundleURL withIntermediateDirectories:YES attributes:nil error:error] == NO) {
        return nil;
    }

    NSDictionary *infoPlist = @{
                                @"CFBundleIdentifier": [RZFreshAirRemoteBundleIdPrefix stringByAppendingString:bundleName],
                                @"CFBundleName": bundleName,
                                RZFreshAirRemoteURL: [remoteURL absoluteString]
                                };
    if ([infoPlist writeToURL:[bundleURL URLByAppendingPathComponent:@"Info.plist"] atomically:YES] == NO) {
        *error = [NSError errorWithDomain:RZFreshAirErrorDomain code:RZFreshAirErrorCodeFileSaveError userInfo:@{}];
        return nil;
    }

    return bundleURL;
}

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
    return [[RZFManifest alloc] initWithBundle:self];
}

@end
