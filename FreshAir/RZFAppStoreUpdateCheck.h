//
//  RZFAppStoreUpdateCheck.h
//  FreshAir
//
//  Created by Brian King on 2/3/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSUInteger, RZFAppUpdateStatus) {
    RZFAppUpdateStatusNoUpdate,
    RZFAppUpdateStatusNewVersion,
    RZFAppUpdateStatusNewVersionForced,
    RZFAppUpdateStatusNewVersionUnsupportedOnDevice
};

typedef void(^RZFAppUpdateCheckCompletion)(RZFAppUpdateStatus status, NSString *newVersion, NSURL *upgradeURL);

@interface RZFAppStoreUpdateCheck : NSObject

- (instancetype)initWithAppStoreID:(NSString *)appStoreID;

@property (strong, nonatomic) NSURLSession *session;
@property (copy, nonatomic, readonly) NSString *appStoreID;

- (void)performCheckWithCompletion:(RZFAppUpdateCheckCompletion)completion;

@end
