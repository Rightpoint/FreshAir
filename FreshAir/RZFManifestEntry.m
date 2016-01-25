//
//  RZFManifestEntry.m
//  FreshAir
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFManifestEntry.h"
#import "RZFFileHash.h"

@implementation RZFManifestEntry

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject
{
    self = [super init];
    if (self) {
        _condition = jsonObject[@"condition"];
        _filename = jsonObject[@"filename"];
        _SHA = jsonObject[@"sha"];
    }
    return self;
}

- (BOOL)isApplicableInEnvironment:(NSDictionary *)environment
{
    NSParameterAssert(environment);
    return (self.condition == nil ||
            [[NSPredicate predicateWithFormat:self.condition] evaluateWithObject:environment]);
}

- (BOOL)isLoadedInBundle:(NSBundle *)bundle
{
    NSParameterAssert(bundle);
    NSParameterAssert(self.SHA);
    NSURL *file = [bundle.bundleURL URLByAppendingPathComponent:self.filename];
    return ([[NSFileManager defaultManager] fileExistsAtPath:file.path] &&
            [[RZFFileHash sha1HashOfFileAtPath:file.path] isEqual:self.SHA]);
}

@end
