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

@implementation NSObject (RZFImport)

+ (id)rzf_importURL:(NSURL *)URL error:(NSError **)error
{
    NSParameterAssert([self conformsToProtocol:@protocol(RZFImporting)]);
    NSData *data = [NSData dataWithContentsOfURL:URL options:kNilOptions error:error];
    if (data == nil) {
        return nil;
    }
    Class<RZFImporting> importClass = (id)self;

    NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
    if (JSON == nil) {
        return nil;
    }
    else if ([JSON isKindOfClass:[NSArray class]]) {
        NSMutableArray *results = [NSMutableArray array];
        for (NSDictionary *jsonObject in JSON) {
            id object = [importClass instanceFromJSON:jsonObject];
            [results addObject:object];
        }
        return results;
    }
    else {
        return [importClass instanceFromJSON:JSON];
    }
}

@end

@implementation RZFReleaseNotes (RZFImport)

+ (instancetype)instanceFromJSON:(id)value
{
    NSParameterAssert([value isKindOfClass:[NSDictionary class]]);
    NSArray *releasesJSON = value[RZF_KP(RZFReleaseNotes, releases)] ?: @[];
    NSArray *forceUpgradeJSON = value[RZF_KP(RZFReleaseNotes, forceUpgradeConditions)] ?: @[];
    RZFReleaseNotes *releaseNotes = [[RZFReleaseNotes alloc] init];
    releaseNotes.upgradeURL = [NSURL URLWithString:value[RZF_KP(RZFReleaseNotes, upgradeURL)]];
    releaseNotes.releases = [releasesJSON map:^id(id value) {
        return [RZFRelease instanceFromJSON:value];
    }];
    releaseNotes.forceUpgradeConditions = [forceUpgradeJSON map:^id(id value) {
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

    NSArray *conditions = self.forceUpgradeConditions;
    if (conditions.count > 0) {
        representation[RZF_KP(RZFReleaseNotes, forceUpgradeConditions)] = [conditions valueForKey:RZF_KP(RZFCondition, jsonRepresentation)];
    }
    return [representation copy];
}

@end

@implementation RZFRelease (RZFImport)

+ (instancetype)instanceFromJSON:(id)value
{
    NSParameterAssert([value isKindOfClass:[NSDictionary class]]);
    NSArray *conditionsJSON = value[RZF_KP(RZFRelease, conditions)] ?: @[];

    RZFRelease *release = [[RZFRelease alloc] init];
    release.version = value[RZF_KP(RZFRelease, version)];
    release.features = [value[RZF_KP(RZFRelease, features)] map:^id(id value) {
        return [RZFFeature instanceFromJSON:value];
    }];
    release.conditions = [conditionsJSON map:^id(id value) {
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
    if (conditions.count > 0) {
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
    NSArray *conditionsJSON = value[RZF_KP(RZFManifestEntry, conditions)] ?: @[];

    RZFManifestEntry *manifestEntry = [[RZFManifestEntry alloc] init];
    manifestEntry.filename = value[RZF_KP(RZFManifestEntry, filename)];
    manifestEntry.conditions = [conditionsJSON map:^id(id value) {
        return [RZFCondition instanceFromJSON:value];
    }];
    manifestEntry.sha = value[RZF_KP(RZFManifestEntry, sha)];
    return manifestEntry;
}

- (id)jsonRepresentation
{
    NSMutableDictionary *representation = [@{
                                             RZF_KP(RZFManifestEntry, filename): self.filename,
                                             } mutableCopy];
    if (self.conditions.count > 0) {
        NSArray *jsonConditions = [self.conditions valueForKey:RZF_KP(RZFCondition, jsonRepresentation)];
        representation[RZF_KP(RZFRelease, conditions)] = jsonConditions;
    }
    if (self.sha) {
        representation[RZF_KP(RZFManifestEntry, sha)] = self.sha;
    }
    return [representation copy];
}

@end

