//
//  RZFResourceLoader.m
//  FreshAir
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFFetchOperation.h"
#import "RZFManifestManager.h"
#import "RZFManifest.h"
#import "RZFManifestEntry.h"
#import "RZFFileHash.h"
#import "RZFError.h"
#import "NSBundle+RZFreshAir.h"

@implementation RZFFetchOperation

- (instancetype)initWithFilename:(NSString *)filename
                             sha:(NSString *)sha
                      inManifest:(RZFManifest *)manifest;
{
    self = [super init];
    if (self) {
        self.manifest = manifest;
        self.sha = sha;
        self.fromURL = [manifest.bundle.rzf_remoteURL URLByAppendingPathComponent:filename];
        self.destinationURL = [manifest.bundle.bundleURL URLByAppendingPathComponent:filename];
        
        self.session = [NSURLSession sharedSession];
        self.fileManager = [NSFileManager defaultManager];
    }
    return self;
}

- (void)main
{
    if ([self.fromURL.scheme isEqual:@"file"]) {
        [self performCopyFromURL:self.fromURL];
    }
    else {
        [self performDownload];
    }
    [self confirmSHA];
}

- (void)confirmSHA
{
    if (self.sha && self.error == nil) {
        NSString *sha = [RZFFileHash sha1HashOfFileAtPath:self.destinationURL.path];
        if ([self.sha isEqual:sha] == NO) {
            NSString *message = [NSString stringWithFormat:@"SHA Does Not Match:\n%@: %@\n%@: %@",
                                 self.fromURL.path, self.sha,
                                 self.destinationURL.path, sha];
            self.error = [NSError errorWithDomain:RZFreshAirErrorDomain
                                             code:RZFreshAirErrorCodeSHAMismatch
                                         userInfo:@{NSLocalizedDescriptionKey: message}];
        }
    }
}

- (void)performCopyFromURL:(NSURL *)fromURL
{
    NSError *error = nil;
    if ([self.fileManager fileExistsAtPath:self.destinationURL.path] &&
        [self.fileManager removeItemAtPath:self.destinationURL.path error:&error] == NO) {
        self.error = error;
    }
    else if ([self.fileManager copyItemAtURL:fromURL toURL:self.destinationURL error:&error] == NO) {
        self.error = error;
    }
}

- (void)performDownload
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.session downloadTaskWithURL:self.fromURL completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSUInteger responseCode = ((NSHTTPURLResponse *)response).statusCode;
        if ( responseCode == 200 ) {
            [self performCopyFromURL:location];
        }
        else if (responseCode == 304) {
            // No change
        }
        else {
            self.error = error;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

}

@end
