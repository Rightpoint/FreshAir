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
    return self.minimumVersion != nil && [self.minimumVersion compare:version options:NSNumericSearch] == NSOrderedAscending;
}

@end
