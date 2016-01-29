//
//  RZFEnvironment.m
//  FreshAir
//
//  Created by Brian King on 1/29/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFEnvironment.h"
#import "RZFReleaseNotes.h"
#import "NSBundle+RZFreshAir.h"
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

+ (NSMutableDictionary *)defaultVariables
{
    NSAssert([NSThread currentThread] == [NSThread mainThread], @"Can only mutate the default environment on the main thread.");
    static NSMutableDictionary *defaultVariables = nil;
    if (defaultVariables == nil) {
        defaultVariables = [NSMutableDictionary dictionary];
    }
    return defaultVariables;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.variables = [self.class defaultVariables];
    }
    return self;
}

- (NSString *)currentVersion
{
    return self.variables[RZFEnvironmentAppVersionKey];
}

- (BOOL)shouldDisplayUpgradePrompt:(RZFReleaseNotes *)releaseNotes
{
    NSString *lastVersionPrompted = [self.userDefaults stringForKey:RZFLastVersionPromptedKey];
    BOOL shouldDisplay = ([releaseNotes isUpgradeAvailableForVersion:self.currentVersion] &&
                          [lastVersionPrompted isEqual:releaseNotes.lastVersion] == NO);
    return shouldDisplay || [self isUpgradeForced:releaseNotes];
}

- (BOOL)isUpgradeForced:(RZFReleaseNotes *)releaseNotes;
{
    return [releaseNotes isUpgradeRequiredForVersion:self.currentVersion];
}

- (void)userDidViewUpdatePromptForReleaseNotes:(RZFReleaseNotes *)releaseNotes
{
    [self.userDefaults setValue:releaseNotes.lastVersion forKey:RZFLastVersionPromptedKey];
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

- (void)userDidViewContentOfReleaseNotes:(RZFReleaseNotes *)releaseNotes
{
    [self.userDefaults setValue:releaseNotes.lastVersion forKey:RZFLastVersionPromptedKey];

}

- (BOOL)isBundleLoaded:(NSBundle *)bundle
{
    RZFManifest *manifest = [bundle rzf_manifest];
    BOOL result = NO;
    if ([manifest isManifestLoaded]) {
        result = YES;
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
