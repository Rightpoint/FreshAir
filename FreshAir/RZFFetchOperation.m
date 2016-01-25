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

@implementation RZFFetchOperation

- (instancetype)initWithFilename:(NSString *)filename
                             SHA:(NSString *)SHA
                      inManifest:(RZFManifest *)manifest;
{
    self = [super init];
    if (self) {
        self.manifest = manifest;
        self.SHA = SHA;
        self.fromURL = [manifest.remoteURL URLByAppendingPathComponent:filename];
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
    if (self.SHA) {
        NSString *SHA = [RZFFileHash sha1HashOfFileAtPath:self.destinationURL.path];
        if ([self.SHA isEqual:SHA] == NO) {
            NSString *message = [NSString stringWithFormat:@"SHA Does Not Match:\n%@: %@\n%@: %@",
                                 self.fromURL.path, self.SHA,
                                 self.destinationURL.path, SHA];
            self.error = [NSError errorWithDomain:RZFreshAirErrorDomain
                                             code:RZFreshAirErrorCodeSHAMismatch
                                         userInfo:@{NSLocalizedDescriptionKey: message}];
        }
    }
}

- (void)performCopyFromURL:(NSURL *)fromURL
{
    NSError *error = nil;
    if ([self.fileManager copyItemAtURL:fromURL toURL:self.manifest.bundle.bundleURL error:&error] == NO) {
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
