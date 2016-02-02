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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.session = [NSURLSession sharedSession];
        self.environment = [[RZFEnvironment alloc] init];
    }
    return self;
}

- (void)checkAppStoreID:(NSString *)appStoreID
             completion:(RZFAppUpdateCheckCompletion)completion
{
    completion = completion ?: ^(RZFAppUpdateStatus status, NSString *version, NSURL *upgradeURL) {};
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:RZFAppStoreURLFormat, appStoreID]];
    [self.session dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *results = json[RZFAppStoreResultsKey];
            if (results.count > 0) {
                NSDictionary *appInfo = results[0];
                NSString *appStoreVersion = appInfo[RZFAppStoreVersionKey];
                NSString *systemVersion = appInfo[RZFAppStoreMinimumOsVersionKey];
                NSString *upgradeURLString = appInfo[RZFAppStoreUpgradeURLKey];
                NSURL *upgradeURL = [NSURL URLWithString:upgradeURLString];

                BOOL newVersion  = [self.environment shouldDisplayUpgradePromptForVersion:appStoreVersion];
                BOOL deviceSupported = [self.environment isSystemVersionSupported:systemVersion];
                RZFAppUpdateStatus status = [self.class statusForNewVersion:newVersion deviceSupported:deviceSupported];
                completion(status, appStoreVersion, upgradeURL);
            }
            else {
                completion(RZFAppUpdateStatusNoUpdate, nil, nil);
            }
        } else {
            completion(RZFAppUpdateStatusNoUpdate, nil, nil);
        }
    }];
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
        [self.session dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSError *importError = nil;
            RZFReleaseNotes *releaseNotes = [RZFReleaseNotes releaseNotesWithData:data error:&importError];
            if (importError || error) {
                NSLog(@"%@", importError ?: error);
            }
            [self checkReleaseNotes:releaseNotes completion:completion];
        }];
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
    completion(status, lastVersion, upgradeURL);
}

@end
