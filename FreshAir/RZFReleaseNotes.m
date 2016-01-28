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

@implementation RZFReleaseNotes

- (NSString *)lastVersion
{
    NSArray<NSString *> *versions = [self.releases valueForKey:RZF_KP(RZFRelease, version)];
    [versions sortedArrayUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    return versions.lastObject;
}

- (BOOL)isUpgradeAvailableForVersion:(NSString *)version
{
    return [self.lastVersion compare:version options:NSNumericSearch] != NSOrderedSame;
}

- (BOOL)isUpgradeRequiredForVersion:(NSString *)version
{
    return self.minimumVersion != nil && [self.minimumVersion compare:version options:NSNumericSearch] == NSOrderedDescending;
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
