//
//  RZFReleaseNotes.m
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFReleaseNotes.h"
#import "RZFRelease.h"
#import "RZFDefines.h"
#import "RZFFeature.h"
#import "NSObject+RZFImport.h"

@implementation RZFReleaseNotes

+ (instancetype)releaseNotesWithURL:(NSURL *)URL error:(NSError **)error
{
    return [self rzf_importURL:URL error:error];
}

+ (instancetype)releaseNotesWithData:(NSData *)data error:(NSError **)error
{
    return [self rzf_importData:data error:error];
}

- (BOOL)isUpgradeRequiredForVersion:(NSString *)version
{
    return (self.minimumVersion != nil &&
            [self.minimumVersion compare:version options:NSNumericSearch] == NSOrderedDescending);
}

- (NSArray *)features
{
    NSMutableArray *features = [NSMutableArray array];
    for (RZFRelease *release in self.releases) {
        [features addObjectsFromArray:release.features];
    }
    return [features copy];
}

- (NSArray<RZFFeature *> *)featuresFromVersion:(NSString *)lastVersion toVersion:(NSString *)currentVersion;
{
    NSMutableArray *features = [NSMutableArray array];
    for (RZFRelease *release in self.releases) {
        NSString *version = release.version;
        NSComparisonResult compareLast = [version compare:lastVersion options:NSNumericSearch];
        NSComparisonResult compareCurrent = [version compare:currentVersion options:NSNumericSearch];
        if (compareLast == NSOrderedDescending && compareCurrent != NSOrderedDescending) {
            [features addObjectsFromArray:release.features];
        }
    }

    return [features copy];
}

@end
