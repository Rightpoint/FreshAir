//
//  RZFRemoteBundleController.m
//  FreshAir
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import Foundation;

#import "RZFBundleResourceRequest.h"
#import "RZFManifest.h"
#import "RZFManifest+Private.h"
#import "RZFManifestEntry.h"
#import "RZFEnvironment.h"

#import "RZFFetchOperation.h"
#import "NSURL+RZFManifest.h"
#import "NSBundle+RZFreshAir.h"
#import "RZFError.h"

NSString *const RZFreshAirRemoteBundleIdPrefix = @"com.raizlabs.freshair.";
NSString *const RZFreshAirLinkSuffix = @"link";

@interface RZFBundleResourceRequest ()

@property (strong, nonatomic) NSBundle *bundle;

@property (strong, nonatomic) NSError *error;
@property (copy, nonatomic, readonly) RZFEnvironment *environment;
@property (copy, nonatomic) RZFBundleUpdateBlock completion;
@property (strong, nonatomic, readonly) NSOperationQueue *backgroundOperations;

@end

@implementation RZFBundleResourceRequest

+ (NSURL *)bundleURLInDirectory:(NSURL *)directory forRemoteURL:(NSURL *)remoteURL error:(NSError **)error
{
    NSParameterAssert(directory);
    NSParameterAssert(remoteURL);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *bundleName = [remoteURL lastPathComponent];
    NSURL *bundleURL = [directory URLByAppendingPathComponent:bundleName];

    if ([fileManager createDirectoryAtURL:bundleURL withIntermediateDirectories:YES attributes:nil error:error] == NO) {
        return nil;
    }

    NSDictionary *infoPlist = @{
                                @"CFBundleIdentifier": [RZFreshAirRemoteBundleIdPrefix stringByAppendingString:bundleName],
                                @"CFBundleName": bundleName,
                                RZFreshAirRemoteURL: [remoteURL absoluteString]
                                };
    if ([infoPlist writeToURL:[bundleURL URLByAppendingPathComponent:@"Info.plist"] atomically:YES] == NO) {
        *error = [NSError errorWithDomain:RZFreshAirErrorDomain code:RZFreshAirErrorCodeFileSaveError userInfo:@{}];
        return nil;
    }

    return bundleURL;
}

+ (NSURL *)linkedDirectoryForBundle:(NSBundle *)bundle error:(NSError **)error
{
    // Return a link to a random UUID. This will bypass any caching
    // performed by NSBundle.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *bundleURL = [bundle bundleURL];
    NSString *linkName = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:RZFreshAirLinkSuffix];
    NSURL *directory = [bundleURL URLByDeletingLastPathComponent];
    NSURL *linkURL = [directory URLByAppendingPathComponent:linkName];

    [fileManager linkItemAtURL:bundleURL
                         toURL:linkURL
                         error:error];
    return linkURL;
}

static NSURL *localURL = nil;

+ (void)load
{
    // Provide a default value for the localURL
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *localURL = [fileManager URLForDirectory:NSDocumentDirectory
                                          inDomain:NSUserDomainMask
                                 appropriateForURL:nil
                                            create:NO
                                             error:nil];

    [self setLocalURL:localURL];
}

+ (NSURL *)localURL;
{
    return localURL;
}

+ (void)setLocalURL:(NSURL *)URL
{
    localURL = URL;
    [self pruneFreshAirLinksInURL:localURL];
}

+ (void)pruneFreshAirLinksInURL:(NSURL *)URL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *contents = [fileManager contentsOfDirectoryAtURL:URL includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:&error];

    for (NSURL *file in contents) {
        if ([[file pathExtension] isEqual:RZFreshAirLinkSuffix]) {
            if ([fileManager removeItemAtURL:file error:&error] == NO) {
                NSLog(@"Error Removing Link: %@", error);
            }
        }
    }
}

- (instancetype)initWithRemoteURL:(NSURL *)remoteURL
                      environment:(RZFEnvironment * __nullable)environment
                       completion:(RZFBundleUpdateBlock)completion
{
    NSAssert([[remoteURL pathExtension] isEqual:@"freshair"], @"Remote URL must point to a .freshair resource");

    self = [super init];
    if (self) {
        _completion = completion ? [completion copy] : [^(NSBundle *b, NSError *e) {} copy];
        _environment = environment ?: [[RZFEnvironment alloc] init];
        _backgroundOperations = [[NSOperationQueue alloc] init];
        _session = [NSURLSession sharedSession];

        // Prepare the bundle
        NSError *error = nil;
        NSURL *bundleURL = [self.class bundleURLInDirectory:[self.class localURL]
                                               forRemoteURL:remoteURL
                                                      error:&error];
        if (bundleURL == nil) {
            [self triggerCompletionWithError:error];
        }
        else {
            _bundle = [[NSBundle alloc] initWithURL:bundleURL];

            [self update];
        }
    }
    return self;
}

- (void)update
{
    NSParameterAssert(self.bundle);
    // Create the manifest
    RZFManifest *manifest = [[RZFManifest alloc] initWithBundle:self.bundle];

    // Always fetch or update the manifest
    RZFFetchOperation *fetch = [[RZFFetchOperation alloc] initWithFilename:[NSURL rzf_manifestFilename]
                                                                       sha:nil
                                                                inManifest:manifest];
    fetch.session = self.session;
    [self dispatchOperations:@[fetch]];
}

- (void)triggerCompletionWithError:(NSError *)error
{
    if (self.completion) {
        self.error = error;
        NSError *linkError = nil;
        NSURL *linkURL = [self.class linkedDirectoryForBundle:self.bundle
                                                        error:&linkError];
        self.bundle = [NSBundle bundleWithURL:linkURL];
        self.completion(self.bundle, error);
        self.completion = nil;
    }
}

- (BOOL)loaded
{
    return [self.environment isRemoteBundleLoaded:self.bundle];
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
        [self triggerCompletionWithError:error];
    }
}

- (void)loadEntriesInManifest:(RZFManifest *)manifest
{
    NSError *error = nil;
    if ([manifest loadEntriesError:&error] == NO) {
        [self triggerCompletionWithError:error];
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
            [self triggerCompletionWithError:fetchOperation.error];
            return;
        }
        RZFManifest *manifest = fetchOperation.manifest;
        NSURL *manifestURL = [manifest.bundle.bundleURL rzf_manifestURL];
        // If the fetch was for this bundle's manifest file, load all of the entries
        // of this manifest
        if ([fetchOperation.destinationURL isEqual:manifestURL]) {
            [self loadEntriesInManifest:manifest];
        }

        // If the manifest is loaded (IE: This is the last downloaded file)
        // notify the delegate
        NSBundle *bundle = manifest.bundle;
        if ([self.environment isRemoteBundleLoaded:bundle]) {
            [self triggerCompletionWithError:nil];
        }
    }
}

@end
