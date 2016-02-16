//
//  RZFAppUpdateCheck.m
//  FreshAir
//
//  Created by Brian King on 2/1/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFReleaseNotesCheck.h"
#import "RZFReleaseNotes.h"
#import "RZFRelease.h"

@implementation RZFReleaseNotesCheck

- (instancetype)initWithReleaseNoteURL:(NSURL *)releaseNoteURL appVersion:(NSString *)appVersion systemVersion:(NSString *)systemVersion
{
    self = [super init];
    if (self) {
        _session = [NSURLSession sharedSession];
        _releaseNoteURL = releaseNoteURL;
        _appVersion = appVersion;
        _systemVersion = systemVersion;
    }
    return self;
}

- (void)performCheckWithCompletion:(RZFAppUpdateCheckCompletion)completion;
{
    if ([self.releaseNoteURL isFileURL]) {
        NSError *error = nil;

        RZFReleaseNotes *releaseNotes = [RZFReleaseNotes releaseNotesWithURL:self.releaseNoteURL error:&error];
        if (error) {
            NSLog(@"%@", error);
        }

        [self checkReleaseNotes:releaseNotes completion:completion];
    }
    else {
        NSURLSessionDataTask *task = [self.session dataTaskWithURL:self.releaseNoteURL completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
            NSError *importError;
            RZFReleaseNotes *releaseNotes;

            if (data) {
                releaseNotes = [RZFReleaseNotes releaseNotesWithData:data error:&importError];
            }

            if (importError || !releaseNotes) {
                NSLog(@"request for version history failed: %@", importError ?: error);
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
        NSArray<RZFRelease *> *supportedReleases = [releaseNotes releasesSupportingSystemVersion:self.systemVersion];
        RZFRelease *lastRelease = [supportedReleases lastObject];
        lastVersion = [lastRelease version];
        upgradeURL = releaseNotes.upgradeURL;

        BOOL newVersion = [self.appVersion compare:lastVersion options:NSNumericSearch] == NSOrderedAscending;
        BOOL deviceSupported = lastVersion != nil;
        if (newVersion && deviceSupported) {
            BOOL updateIsForced = [self.appVersion compare:releaseNotes.minimumVersion options:NSNumericSearch] == NSOrderedAscending;
            status = updateIsForced ? RZFAppUpdateStatusNewVersionForced : RZFAppUpdateStatusNewVersion;
        }
        else if (newVersion && deviceSupported == NO) {
            status = RZFAppUpdateStatusNewVersionUnsupportedOnDevice;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(status, lastVersion, upgradeURL);
    });
}

@end
