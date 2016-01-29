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
#import "RZFManifest+Private.h"
#import "RZFManifestEntry.h"
#import "RZFEnvironment.h"

#import "RZFFetchOperation.h"
#import "NSURL+RZFManifest.h"
#import "NSBundle+RZFreshAir.h"
#import "RZFError.h"

@interface RZFManifestManager ()

@property (copy, nonatomic, readonly) NSURL *containerURL;
@property (copy, nonatomic, readonly) RZFEnvironment *environment;
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

- (instancetype)initWithRemoteURL:(NSURL *)remoteURL
                         localURL:(NSURL *)localURL
                      environment:(RZFEnvironment *)environment
                         delegate:(id<RZFManifestManagerDelegate>)delegate
{
    NSAssert([[remoteURL pathExtension] isEqual:@"freshair"], @"Remote URL must point to a .freshair resource");

    self = [super init];
    if (self) {
        _delegate = delegate;
        _containerURL = localURL ?: [self.class defaultLocalURL];
        _environment = environment ?: [[RZFEnvironment alloc] init];
        _backgroundOperations = [[NSOperationQueue alloc] init];
        _allBundles = @[];

        // Prepare the bundle
        NSError *error = nil;
        NSURL *bundleURL = [NSBundle rzf_bundleURLInDirectory:self.containerURL
                                                 forRemoteURL:remoteURL
                                                        error:&error];
        if (bundleURL == nil) {
            [self.delegate manifestManager:self didEncounterError:error];
        }

        _bundle = [NSBundle bundleWithURL:bundleURL];
    }
    return self;
}

- (void)update
{
    NSParameterAssert(self.bundle);
    // Create the manifest
    RZFManifest *manifest = [[RZFManifest alloc] initWithBundle:self.bundle];

    // Always fetch or update the manifest
    NSOperation *fetch = [[RZFFetchOperation alloc] initWithFilename:[NSURL rzf_manifestFilename]
                                                                 sha:nil
                                                          inManifest:manifest];
    [self dispatchOperations:@[fetch]];
}

- (BOOL)loaded
{
    return [self.environment isBundleLoaded:self.bundle];
}

- (void)createDirectoryForManifestEntry:(RZFManifestEntry *)entry inDirectory:(NSURL *)localDirectoryURL
{
    NSMutableArray *components = [[entry.filename pathComponents] mutableCopy];
    // Remove the last one (The file)
    [components removeLastObject];
    // Create a URL for the directory with the rest of the components
    for (NSString *component in components) {
        localDirectoryURL = [localDirectoryURL URLByAppendingPathComponent:component];
    }
    NSError *error = nil;
    if ([[NSFileManager defaultManager] createDirectoryAtURL:localDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error] == NO) {
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
        BOOL applicable = [entry isApplicableInEnvironment:self.environment.variables];
        BOOL loaded = [entry isLoadedInBundle:manifest.bundle];
        if (applicable && loaded == NO) {
            // Make any intermediary directories that are needed
            if ([entry.filename pathComponents].count > 1) {
                [self createDirectoryForManifestEntry:entry
                                          inDirectory:manifest.bundle.bundleURL];
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
        NSURL *manifestURL = [manifest.bundle.bundleURL rzf_manifestURL];
        // If the fetch was for this bundle's manifest file, load all of the entries
        // of this manifest
        if ([fetchOperation.destinationURL isEqual:manifestURL]) {
            [self loadEntriesInManifest:manifest];
        }
        // If this is a child manifest, create a new manifest object
        // and load all entries of the child manifest
        else if ([fetchOperation.destinationURL rzf_isManifestURL]) {
            NSError *error = nil;
            NSURL *remoteURL = [fetchOperation.fromURL URLByDeletingLastPathComponent];
            NSURL *containerURL = [[fetchOperation.destinationURL URLByDeletingLastPathComponent] URLByDeletingLastPathComponent];
            NSURL *bundleURL = [NSBundle rzf_bundleURLInDirectory:containerURL forRemoteURL:remoteURL error:&error];
            if (error == nil) {
                NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
                RZFManifest *childManifest = [[RZFManifest alloc] initWithBundle:bundle];

                [self loadEntriesInManifest:childManifest];
            }
            else {
                [self.delegate manifestManager:self didEncounterError:error];
            }
        }
        // If the manifest is loaded (IE: This is the last downloaded file)
        // notify the delegate
        NSBundle *bundle = manifest.bundle;
        if ([self.environment isBundleLoaded:bundle] &&
            [self.allBundles containsObject:bundle] == NO) {
            self.allBundles = [self.allBundles arrayByAddingObject:bundle];
            [self.delegate manifestManager:self didLoadBundle:bundle];
        }
    }
}

@end
