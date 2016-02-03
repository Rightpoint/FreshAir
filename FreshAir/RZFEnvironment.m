//
//  RZFEnvironment.m
//  FreshAir
//
//  Created by Brian King on 1/29/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFEnvironment.h"
#import "RZFReleaseNotes.h"
#import "RZFCondition.h"
#import "RZFRelease.h"

#import "NSBundle+RZFreshAir.h"
#import "NSURL+RZFManifest.h"
#import "RZFManifest+Private.h"

// Keys in the environment variables
NSString *const RZFEnvironmentPlatformKey = @"platform";
NSString *const RZFEnvironmentSystemVersionKey = @"systemVersion";
NSString *const RZFEnvironmentDisplayScaleKey = @"displayScale";
NSString *const RZFEnvironmentAppVersionKey = @"appVersion";

// Keys for tracking state in NSUserDefaults
NSString *const RZFLastVersionPromptedKey = @"RZFLastVersionPromptedKey";
NSString *const RZFLastVersionOfReleaseNotesDisplayedKey = @"RZFLastVersionOfReleaseNotesDisplayedKey";

@implementation RZFEnvironment

- (instancetype)initWithVariables:(NSDictionary *)variables
{
    self = [super init];
    if (self) {
        self.variables = variables;
        self.userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (NSString *)currentVersion
{
    return self.variables[RZFEnvironmentAppVersionKey];
}

- (BOOL)isUpgradeAvailableForVersion:(NSString *)version
{
    return [version compare:self.currentVersion options:NSNumericSearch] != NSOrderedSame;
}

- (BOOL)shouldDisplayUpgradePromptForVersion:(NSString *)version;
{
    NSString *lastVersionPrompted = [self.userDefaults stringForKey:RZFLastVersionPromptedKey];
    BOOL shouldDisplay = ([self isUpgradeAvailableForVersion:version] &&
                          [lastVersionPrompted isEqual:version] == NO);
    return shouldDisplay;
}

- (BOOL)isUpgradeForced:(RZFReleaseNotes *)releaseNotes;
{
    return [releaseNotes isUpgradeRequiredForVersion:self.currentVersion];
}

- (BOOL)isSystemVersionSupported:(NSString *)systemVersion
{
    NSString *currentSystemVersion = self.variables[RZFEnvironmentSystemVersionKey];

    BOOL osSupported = [systemVersion compare:currentSystemVersion options:NSNumericSearch] == NSOrderedAscending;
    return osSupported;
}

- (BOOL)shouldUserSeeReleaseNotes:(RZFReleaseNotes *)releaseNotes
{
    NSString *lastVersion = [self.userDefaults stringForKey:RZFLastVersionOfReleaseNotesDisplayedKey];
    // If this is the first time the app has run, nothing should be displayed (IE: First install)
    if (lastVersion == nil) {
        [self.userDefaults setValue:self.currentVersion forKey:RZFLastVersionOfReleaseNotesDisplayedKey];
    }
    // If the last version displayed is not equal to this version, display release notes
    else if ([lastVersion compare:self.currentVersion options:NSNumericSearch] != NSOrderedSame) {
        return YES;
    }
    return NO;
}

- (NSArray<RZFFeature *> *)unviewedFeaturesForReleaseNotes:(RZFReleaseNotes *)releaseNotes
{
    NSString *lastVersion = [self.userDefaults stringForKey:RZFLastVersionOfReleaseNotesDisplayedKey];

    NSArray *features = [releaseNotes featuresFromVersion:lastVersion toVersion:self.currentVersion];
    return features;
}

- (NSArray<RZFRelease *> *)supportedReleasesInReleaseNotes:(RZFReleaseNotes *)releaseNotes
{
    NSMutableArray *results = [NSMutableArray array];
    for (RZFRelease *release in releaseNotes.releases) {
        NSPredicate *check = [RZFCondition predicateForConditions:release.conditions];
        if ([check evaluateWithObject:self.variables]) {
            [results addObject:release];
        }
    }
    return [results copy];
}

- (void)userDidViewUpdatePromptForVersion:(NSString *)version
{
    [self.userDefaults setValue:version forKey:RZFLastVersionPromptedKey];
}

- (void)userDidViewContentOfReleaseNotesForCurrentVersion
{
    [self.userDefaults setValue:self.currentVersion
                         forKey:RZFLastVersionPromptedKey];
}

- (BOOL)isRemoteBundleLoaded:(NSBundle *)bundle
{
    RZFManifest *manifest = [[RZFManifest alloc] initWithBundle:bundle];
    BOOL result = NO;
    if ([manifest isManifestLoaded]) {
        result = [manifest loadEntriesError:nil];
        for (RZFManifestEntry *entry in manifest.entries) {
            if ([entry isApplicableInEnvironment:self.variables] &&
                [entry isLoadedInBundle:bundle] == NO) {
                result = NO;
                break;
            }
        }
    }
    return result;
}

@end
