//
//  RZFRemoteBundleController.m
//  FreshAir
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import Foundation;

#import "RZFManifestManager.h"
#import "RZFManifest.h"
#import "RZFManifestEntry.h"
#import "RZFFetchOperation.h"
#import "NSURL+RZFManifest.h"

NSString *const RZFreshAirErrorDomain = @"com.raizlabs.freshair.error";

@interface RZFManifestManager ()

@property (copy, nonatomic, readonly) NSURL *remoteURL;
@property (copy, nonatomic, readonly) NSURL *containerURL;
@property (copy, nonatomic, readonly) NSDictionary<NSString *, NSString *> *environment;
@property (weak, nonatomic, readonly) id <RZFManifestManagerDelegate> delegate;
@property (strong, nonatomic, readonly) NSOperationQueue *backgroundOperations;
@property (strong, nonatomic) NSArray<NSBundle *> *allBundles;

@end

@implementation RZFManifestManager

+ (NSURL *)defaultLocalURL;
{
    NSURL *URL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                        inDomain:NSUserDomainMask
                                               appropriateForURL:nil
                                                          create:NO
                                                           error:nil];
    return URL;
}

+ (NSMutableDictionary *)defaultEnvironment
{
    NSAssert([NSThread currentThread] == [NSThread mainThread], @"Can only mutate the default environment on the main thread.");
    static NSMutableDictionary *defaultEnvironment = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultEnvironment = [NSMutableDictionary dictionary];
    });
    return defaultEnvironment;
}

- (instancetype)initWithRemoteURL:(NSURL *)remoteURL
                         localURL:(NSURL *)localURL
                      environment:(NSDictionary<NSString *, NSString *> *)environment
                         delegate:(id<RZFManifestManagerDelegate>)delegate
{
    NSAssert([[remoteURL pathExtension] isEqual:@"freshair"], @"Remote URL must point to a .freshair resource");

    self = [super init];
    if (self) {
        _remoteURL = remoteURL;
        _delegate = delegate;
        _containerURL = localURL ?: [self.class defaultLocalURL];
        _environment = [environment copy] ?: [self.class.defaultEnvironment copy];
        _backgroundOperations = [[NSOperationQueue alloc] init];
        _allBundles = @[];

        // Prepare the bundle
        NSString *bundleName = [remoteURL lastPathComponent];
        NSURL *bundleURL = [self.containerURL URLByAppendingPathComponent:bundleName];
        [self ensureLocalDirectory:bundleURL];
        _bundle = [NSBundle bundleWithURL:bundleURL];

        [self syncRemoteURL:remoteURL];
    }
    return self;
}

- (void)syncRemoteURL:(NSURL *)remoteURL
{
    // Create the manifest
    RZFManifest *manifest = [[RZFManifest alloc] initWithRemoteURL:remoteURL
                                                            bundle:_bundle
                                                       environment:self.environment];

    // Always fetch or update the manifest
    NSOperation *fetch = [[RZFFetchOperation alloc] initWithFilename:[NSURL rzf_manifestFilename]
                                                                 sha:nil
                                                          inManifest:manifest];
    [self dispatchOperations:@[fetch]];
    if ([manifest isManifestLoaded]) {
        [self pruneManifest:manifest];
    }
}

- (BOOL)loaded
{
    return self.backgroundOperations.operationCount == 0;
}

- (void)ensureLocalDirectory:(NSURL *)localDirectory
{
    NSError *error = nil;
    if ([[NSFileManager defaultManager] createDirectoryAtURL:localDirectory withIntermediateDirectories:YES attributes:nil error:&error] == NO) {
        [self.delegate manifestManager:self didEncounterError:error];
    }
}

- (void)loadEntriesInManifest:(RZFManifest *)manifest
{
    NSError *error = nil;
    if ([manifest loadEntriesError:&error] == NO) {
        [self.delegate manifestManager:self didEncounterError:error];
        return;
    }
    NSMutableArray *operations = [NSMutableArray array];
    for (RZFManifestEntry *entry in manifest.entries) {
        if ([entry isApplicableInEnvironment:self.environment] &&
            [entry isLoadedInBundle:manifest.bundle] == NO) {
            // Make any intermediary directories that are needed
            if ([entry.filename pathComponents].count > 1) {
                NSMutableArray *components = [[entry.filename pathComponents] mutableCopy];
                // Remove the last one (The file)
                [components removeLastObject];
                // Create a URL for the directory with the rest of the components
                NSURL *localDirectoryURL = manifest.bundle.bundleURL;
                for (NSString *component in components) {
                    localDirectoryURL = [localDirectoryURL URLByAppendingPathComponent:component];
                }
                [self ensureLocalDirectory:localDirectoryURL];
            }
            [operations addObject:[[RZFFetchOperation alloc] initWithFilename:entry.filename
                                                                          sha:entry.sha
                                                                   inManifest:manifest]];
        }
    }
    [self dispatchOperations:operations];
}


- (void)dispatchOperations:(NSArray *)operations
{
    for (NSOperation *operation in operations) {
        __weak NSOperation *weakOperation = operation;
        operation.completionBlock = ^() {
            NSOperation *strongOperation = weakOperation;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reportCompletionOfOperation:strongOperation];
            });
        };
    }
    [self.backgroundOperations addOperations:operations waitUntilFinished:NO];
}

- (void)reportCompletionOfOperation:(NSOperation *)operation
{
    if ([operation isKindOfClass:[RZFFetchOperation class]]) {
        RZFFetchOperation *fetchOperation = (id)operation;
        if (fetchOperation.error) {
            [self.delegate manifestManager:self didEncounterError:fetchOperation.error];
            return;
        }
        RZFManifest *manifest = fetchOperation.manifest;
        NSURL *bundleManifest = [manifest.bundle.bundleURL rzf_manifestURL];
        // If the fetch was for this bundle's manifest file, load all of the entries
        // of this manifest
        if ([fetchOperation.destinationURL isEqual:bundleManifest]) {
            [self loadEntriesInManifest:manifest];
        }
        // If this is a child manifest, create a new manifest object
        // and load all entries of the child manifest
        else if ([fetchOperation.destinationURL rzf_isManifestURL]) {
            NSURL *remoteURL = [fetchOperation.fromURL URLByDeletingLastPathComponent];
            NSURL *bundleURL = [fetchOperation.destinationURL URLByDeletingLastPathComponent];
            NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
            RZFManifest *childManifest = [[RZFManifest alloc] initWithRemoteURL:remoteURL
                                                                         bundle:bundle
                                                                    environment:self.environment];

            [self loadEntriesInManifest:childManifest];
        }
        // If the manifest is loaded (IE: This is the last downloaded file)
        // notify the delegate
        NSBundle *bundle = manifest.bundle;
        if ([manifest isLoaded] && [self.allBundles containsObject:bundle] == NO) {
            self.allBundles = [self.allBundles arrayByAddingObject:bundle];
            [self.delegate manifestManager:self didLoadBundle:bundle];
        }
    }
}

- (void)pruneManifest:(RZFManifest *)manifest
{
    // Match the current directory list to the entries, minus the files with sha mismatches.
    for (RZFManifestEntry *entry in manifest.entries) {
        if ([entry isApplicableInEnvironment:self.environment] &&
            [entry isLoadedInBundle:manifest.bundle] == NO) {
        }
    }
}

@end
