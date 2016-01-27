//
//  NSObject+RZFImport.m
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "NSObject+RZFImport.h"
#import "RZFDefines.h"
#import "NSObject+RZFUtility.h"

@implementation RZFReleaseNotes (RZFImport)

+ (instancetype)instanceFromJSON:(id)value
{
    NSParameterAssert([value isKindOfClass:[NSDictionary class]]);
    RZFReleaseNotes *releaseNotes = [[RZFReleaseNotes alloc] init];
    releaseNotes.upgradeURL = [NSURL URLWithString:value[RZF_KP(RZFReleaseNotes, upgradeURL)]];
    releaseNotes.releases = [value[RZF_KP(RZFReleaseNotes, releases)] map:^id(id value) {
        return [RZFRelease instanceFromJSON:value];
    }];
    releaseNotes.forceUpgradeCondition = [value[RZF_KP(RZFReleaseNotes, forceUpgradeCondition)] map:^id(id value) {
        return [RZFCondition instanceFromJSON:value];
    }];
    return releaseNotes;
}

- (id)jsonRepresentation
{
    // Schema ensures upgradeURL and releases are non-nil
    NSMutableDictionary *representation = [@{
             RZF_KP(RZFReleaseNotes, upgradeURL): self.upgradeURL.path,
             RZF_KP(RZFReleaseNotes, releases): [self.releases valueForKey:RZF_KP(RZFRelease, jsonRepresentation)],
             } mutableCopy];

    NSArray *conditions = self.forceUpgradeCondition;
    if (conditions) {
        representation[RZF_KP(RZFReleaseNotes, forceUpgradeCondition)] = [conditions valueForKey:RZF_KP(RZFCondition, jsonRepresentation)];
    }
    return [representation copy];
}

@end

@implementation RZFRelease (RZFImport)

+ (instancetype)instanceFromJSON:(id)value
{
    NSParameterAssert([value isKindOfClass:[NSDictionary class]]);
    RZFRelease *release = [[RZFRelease alloc] init];
    release.version = value[RZF_KP(RZFRelease, version)];
    release.features = [value[RZF_KP(RZFRelease, features)] map:^id(id value) {
        return [RZFFeature instanceFromJSON:value];
    }];
    release.conditions = [value[RZF_KP(RZFRelease, conditions)] map:^id(id value) {
        return [RZFCondition instanceFromJSON:value];
    }];
    return release;

}

- (id)jsonRepresentation
{
    NSMutableDictionary *representation = [@{
             RZF_KP(RZFRelease, version): self.version,
             RZF_KP(RZFRelease, features): [self.features valueForKey:RZF_KP(RZFFeature, jsonRepresentation)],
             } mutableCopy];
    NSArray *conditions = self.conditions;
    if (conditions) {
        representation[RZF_KP(RZFRelease, conditions)] = [conditions valueForKey:RZF_KP(RZFCondition, jsonRepresentation)];
    }
    return [representation copy];

}

@end

@implementation RZFFeature (RZFImport)

+ (instancetype)instanceFromJSON:(id)value
{
    NSParameterAssert([value isKindOfClass:[NSString class]]);
    RZFFeature *feature = [[RZFFeature alloc] init];
    feature.key = value;
    return feature;
}

- (id)jsonRepresentation
{
    return self.key;
}

@end

@implementation RZFCondition (RZFImport)

+ (instancetype)instanceFromJSON:(NSDictionary *)value
{
    NSParameterAssert([value isKindOfClass:[NSDictionary class]]);
    RZFCondition *condition = [[RZFCondition alloc] init];
    condition.key = value[RZF_KP(RZFCondition, key)];
    condition.comparison = value[RZF_KP(RZFCondition, comparison)] ?: @"gte";
    condition.value = value[RZF_KP(RZFCondition, value)];
    return condition;
}

- (id)jsonRepresentation
{
    return @{
             RZF_KP(RZFCondition, key): self.key,
             RZF_KP(RZFCondition, comparison): self.comparison ?: @"gte",
             RZF_KP(RZFCondition, value): self.value
             };
}

@end

@implementation RZFManifestEntry (RZFImport)

+ (instancetype)instanceFromJSON:(NSDictionary *)value
{
    NSParameterAssert([value isKindOfClass:[NSDictionary class]]);
    RZFManifestEntry *manifestEntry = [[RZFManifestEntry alloc] init];
    manifestEntry.filename = value[RZF_KP(RZFManifestEntry, filename)];
    manifestEntry.conditions = [value[RZF_KP(RZFRelease, conditions)] map:^id(id value) {
        return [RZFCondition instanceFromJSON:value];
    }];
    manifestEntry.sha = value[RZF_KP(RZFManifestEntry, sha)];
    return manifestEntry;
}

- (id)jsonRepresentation
{
    NSMutableDictionary *representation = [@{
                                             RZF_KP(RZFManifestEntry, filename): self.filename,
                                             RZF_KP(RZFManifestEntry, sha): self.sha,
                                             } mutableCopy];
    NSArray *conditions = self.conditions;
    if (conditions) {
        representation[RZF_KP(RZFRelease, conditions)] = [conditions valueForKey:RZF_KP(RZFCondition, jsonRepresentation)];
    }
    return [representation copy];
}

@end

