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

static NSString *const RZFAppStoreURLFormat = @"http://itunes.apple.com/us/lookup?id=%@";

static NSString *const RZFAppStoreResultsKey = @"results";
static NSString *const RZFAppStoreVersionKey = @"version";
static NSString *const RZFAppStoreMinimumOsVersionKey = @"minimumOsVersion";
static NSString *const RZFAppStoreUpgradeURLKey = @"trackViewUrl";


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

- (instancetype)initWithAppStoreID:(NSString *)appStoreID environment:(RZFEnvironment *)environment
{
    self = [super init];
    if (self) {
        _session = [NSURLSession sharedSession];
        _appStoreID = [appStoreID copy];
        _environment = environment;
    }
    return self;
}

- (void)performCheckWithCompletion:(RZFAppUpdateCheckCompletion)completion;
{
    if (self.appStoreID) {
        [self checkAppStoreID:self.appStoreID completion:completion];
    }
    else if (self.releaseNoteURL) {
        [self checkReleaseNotesURL:self.releaseNoteURL completion:completion];
    }
    else {
        [NSException raise:NSInvalidArgumentException format:@"Must specify an appStoreID or a releaseNoteURL"];
    }
}

- (void)checkAppStoreID:(NSString *)appStoreID
             completion:(RZFAppUpdateCheckCompletion)completion
{
    completion = completion ?: ^(RZFAppUpdateStatus status, NSString *version, NSURL *upgradeURL) {};
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:RZFAppStoreURLFormat, appStoreID]];
    NSURLSessionDataTask *task = [self.session dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        RZFAppUpdateStatus status = RZFAppUpdateStatusNoUpdate;
        NSString *appStoreVersion = nil;
        NSURL *upgradeURL = nil;

        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *results = json[RZFAppStoreResultsKey];
            if (results.count > 0) {
                NSDictionary *appInfo = results[0];
                NSString *systemVersion = appInfo[RZFAppStoreMinimumOsVersionKey];
                NSString *upgradeURLString = appInfo[RZFAppStoreUpgradeURLKey];
                appStoreVersion = appInfo[RZFAppStoreVersionKey];
                NSURLComponents *components = [[NSURLComponents alloc] initWithString:upgradeURLString];
                components.query = nil;
                upgradeURL = [components URL];
                BOOL newVersion  = [self.environment shouldDisplayUpgradePromptForVersion:appStoreVersion];
                BOOL deviceSupported = [self.environment isSystemVersionSupported:systemVersion];
                status = [self.class statusForNewVersion:newVersion deviceSupported:deviceSupported];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(status, appStoreVersion, upgradeURL);
        });
    }];
    [task resume];
}

- (void)checkReleaseNotesURL:(NSURL *)URL
                  completion:(RZFAppUpdateCheckCompletion)completion;
{
    if ([URL.scheme isEqual:@"file"]) {
        NSError *error = nil;
        RZFReleaseNotes *releaseNotes = [RZFReleaseNotes releaseNotesWithURL:URL error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
        [self checkReleaseNotes:releaseNotes completion:completion];
    }
    else {
        NSURLSessionDataTask *task = [self.session dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
