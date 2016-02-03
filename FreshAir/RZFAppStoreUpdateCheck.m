//
//  RZFAppStoreUpdateCheck.m
//  FreshAir
//
//  Created by Brian King on 2/3/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFAppStoreUpdateCheck.h"

static NSString *const RZFAppStoreURLFormat = @"http://itunes.apple.com/us/lookup?id=%@";

static NSString *const RZFAppStoreResultsKey = @"results";
static NSString *const RZFAppStoreVersionKey = @"version";
static NSString *const RZFAppStoreMinimumOsVersionKey = @"minimumOsVersion";
static NSString *const RZFAppStoreUpgradeURLKey = @"trackViewUrl";

@implementation RZFAppStoreUpdateCheck

- (instancetype)initWithAppStoreID:(NSString *)appStoreID
{
    self = [super init];
    if (self) {
        _session = [NSURLSession sharedSession];
        _appStoreID = [appStoreID copy];
    }
    return self;
}

- (void)performCheckWithCompletion:(RZFAppUpdateCheckCompletion)completion;
{
    completion = completion ?: ^(RZFAppUpdateStatus status, NSString *version, NSURL *upgradeURL) {};
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:RZFAppStoreURLFormat, self.appStoreID]];

    NSURLSessionDataTask *task = [self.session dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [self triggerData:data completion:completion];
    }];
    [task resume];
}

- (void)triggerData:(NSData *)data completion:(RZFAppUpdateCheckCompletion)completion
{
    RZFAppUpdateStatus status = RZFAppUpdateStatusNoUpdate;
    NSBundle *appBundle = [NSBundle bundleForClass:UIApplication.sharedApplication.delegate.class];
    NSString *appVersion = appBundle.infoDictionary[@"CFBundleShortVersionString"];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *appStoreVersion = nil;
    NSURL *upgradeURL = nil;
    NSDictionary *json = nil;
    if (data) {
        json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    NSArray *results = json[RZFAppStoreResultsKey];
    if (results.count > 0) {
        NSDictionary *appInfo = results[0];
        NSString *appStoreSystemVersion = appInfo[RZFAppStoreMinimumOsVersionKey];
        NSString *upgradeURLString = appInfo[RZFAppStoreUpgradeURLKey];
        appStoreVersion = appInfo[RZFAppStoreVersionKey];
        upgradeURL = [NSURL URLWithString:upgradeURLString];
        BOOL newVersion  = [appVersion compare:appStoreVersion options:NSNumericSearch] == NSOrderedAscending;
        BOOL deviceSupported = [systemVersion compare:appStoreSystemVersion options:NSNumericSearch] != NSOrderedAscending;
        if (newVersion && deviceSupported) {
            status = RZFAppUpdateStatusNewVersion;
        }
        else if (newVersion && deviceSupported == NO) {
            status = RZFAppUpdateStatusNewVersionUnsupportedOnDevice;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(status, appStoreVersion, upgradeURL);
    });
}

@end
