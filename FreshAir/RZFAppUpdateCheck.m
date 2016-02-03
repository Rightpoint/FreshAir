//
//  RZFAppUpdateCheck.m
//  FreshAir
//
//  Created by Brian King on 2/1/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFAppUpdateCheck.h"
#import "RZFEnvironment.h"
#import "RZFReleaseNotes.h"
#import "RZFRelease.h"

@implementation RZFAppUpdateCheck

+ (RZFAppUpdateStatus)statusForNewVersion:(BOOL)newVersion deviceSupported:(BOOL)deviceSupported
{
    RZFAppUpdateStatus status = RZFAppUpdateStatusNoUpdate;
    if (newVersion && deviceSupported) {
        status = RZFAppUpdateStatusNewVersion;
    }
    else if (newVersion && deviceSupported == NO) {
        status = RZFAppUpdateStatusNewVersionUnsupportedOnDevice;
    }
    return status;
}
- (instancetype)initWithReleaseNoteURL:(NSURL *)releaseNoteURL environment:(RZFEnvironment *)environment
{
    self = [super init];
    if (self) {
        _session = [NSURLSession sharedSession];
        _releaseNoteURL = releaseNoteURL;
        _environment = environment;
    }
    return self;
}

- (void)performCheckWithCompletion:(RZFAppUpdateCheckCompletion)completion;
{
    if ([self.releaseNoteURL.scheme isEqual:@"file"]) {
        NSError *error = nil;
        RZFReleaseNotes *releaseNotes = [RZFReleaseNotes releaseNotesWithURL:self.releaseNoteURL error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
        [self checkReleaseNotes:releaseNotes completion:completion];
    }
    else {
        NSURLSessionDataTask *task = [self.session dataTaskWithURL:self.releaseNoteURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSError *importError = nil;
            RZFReleaseNotes *releaseNotes = [RZFReleaseNotes releaseNotesWithData:data error:&importError];
            if (importError || error) {
                NSLog(@"%@", importError ?: error);
            }
            [self checkReleaseNotes:releaseNotes completion:completion];
        }];
        [task resume];
    }
}

- (void)checkReleaseNotes:(RZFReleaseNotes *)releaseNotes
               completion:(RZFAppUpdateCheckCompletion)completion
{
    RZFAppUpdateStatus status = RZFAppUpdateStatusNoUpdate;
    NSURL *upgradeURL = nil;
    NSString *lastVersion = nil;
    if (releaseNotes) {
        NSArray<RZFRelease *> *supportedReleases = [self.environment supportedReleasesInReleaseNotes:releaseNotes];
        RZFRelease *lastRelease = [supportedReleases lastObject];
        lastVersion = [lastRelease version];
        upgradeURL = releaseNotes.upgradeURL;

        BOOL newVersion  = [self.environment shouldDisplayUpgradePromptForVersion:lastVersion];
        BOOL deviceSupported = lastRelease == releaseNotes.releases.lastObject;
        status = [self.class statusForNewVersion:newVersion deviceSupported:deviceSupported];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(status, lastVersion, upgradeURL);
    });
}

@end
