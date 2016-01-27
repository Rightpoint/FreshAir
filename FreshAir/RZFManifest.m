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

@interface RZFManifest ()

@property (copy, nonatomic) NSDictionary *environment;

@end

@implementation RZFManifest

@synthesize entries = _entries;

- (instancetype)initWithRemoteURL:(NSURL *)remoteURL
                           bundle:(NSBundle *)bundle
                      environment:(NSDictionary *)environment;
{
    self = [super init];
    if (self) {
        _remoteURL = remoteURL;
        _bundle = bundle;
        _environment = environment;
    }
    return self;
}

- (BOOL)loadEntriesError:(NSError **)error
{
    NSData *data = [NSData dataWithContentsOfURL:[self.bundle.bundleURL rzf_manifestURL] options:kNilOptions error:error];
    if (data == nil) {
        return NO;
    }

    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
    if (jsonArray == nil) {
        return NO;
    }

    NSMutableArray *entryArray = [NSMutableArray array];
    for (NSDictionary *jsonObject in jsonArray) {
        RZFManifestEntry *entry = [RZFManifestEntry instanceFromJSON:jsonObject];
        [entryArray addObject:entry];
    }
    _entries = entryArray;
    return YES;
}

- (BOOL)isManifestLoaded
{
    NSURL *manifestFile = [self.bundle.bundleURL rzf_manifestURL];
    return [[NSFileManager defaultManager] fileExistsAtPath:manifestFile.path];
}

- (NSArray *)unloadedFilenames
{
    NSMutableArray *unloadedFiles = [NSMutableArray array];
    for (RZFManifestEntry *entry in self.entries) {
        if ([entry isApplicableInEnvironment:self.environment] &&
            [entry isLoadedInBundle:self.bundle] == NO) {
            [unloadedFiles addObject:entry.filename];
        }
    }
    return [unloadedFiles copy];
}

- (BOOL)isLoaded
{
    return [self isManifestLoaded] && self.unloadedFilenames.count == 0;
}

@end
