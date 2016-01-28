//
//  RZFRemoteBundle.m
//  FreshAir
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFManifest.h"
#import "RZFManifestEntry.h"
#import "NSURL+RZFManifest.h"
#import "NSObject+RZFImport.h"
#import "NSBundle+RZFreshAir.h"

@implementation RZFManifest

@synthesize entries = _entries;

- (instancetype)initWithBundle:(NSBundle *)bundle
{
    NSAssert(bundle.infoDictionary[RZFreshAirRemoteURL] != nil, @"Specified bundle is not a freshair bundle");
    self = [super init];
    if (self) {
        _bundle = bundle;
        _entries = @[];
    }
    return self;
}

- (BOOL)loadEntriesError:(NSError **)error
{
    _entries = [RZFManifestEntry rzf_importURL:[self.bundle.bundleURL rzf_manifestURL] error:error];
    return _entries != nil;
}

- (BOOL)isManifestLoaded
{
    NSURL *manifestFile = [self.bundle.bundleURL rzf_manifestURL];
    return [[NSFileManager defaultManager] fileExistsAtPath:manifestFile.path];
}

- (BOOL)isLoadedEnvironment:(NSDictionary *)environment
{
    BOOL result = NO;
    if ([self isManifestLoaded]) {
        result = YES;
        for (RZFManifestEntry *entry in self.entries) {
            if ([entry isApplicableInEnvironment:environment] &&
                [entry isLoadedInBundle:self.bundle] == NO) {
                result = NO;
                break;
            }
        }
    }
    return result;
}

@end
