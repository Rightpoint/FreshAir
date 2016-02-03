//
//  RZFAppUpdateCheck.h
//  FreshAir
//
//  Created by Brian King on 2/1/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RZFEnvironment;

typedef NS_ENUM(NSUInteger, RZFAppUpdateStatus) {
    RZFAppUpdateStatusNoUpdate,
    RZFAppUpdateStatusNewVersion,
    RZFAppUpdateStatusNewVersionForced,
    RZFAppUpdateStatusNewVersionUnsupportedOnDevice
};

typedef void(^RZFAppUpdateCheckCompletion)(RZFAppUpdateStatus status, NSString *newVersion, NSURL *upgradeURL);

@interface RZFAppUpdateCheck : NSObject

- (instancetype)initWithReleaseNoteURL:(NSURL *)releaseNoteURL environment:(RZFEnvironment *)environment;
- (instancetype)initWithAppStoreID:(NSString *)appStoreID environment:(RZFEnvironment *)environment;

@property (strong, nonatomic) NSURLSession *session;

@property (strong, nonatomic, readonly) RZFEnvironment *environment;
@property (copy, nonatomic, readonly) NSString *appStoreID;
@property (strong, nonatomic, readonly) NSURL *releaseNoteURL;

- (void)performCheckWithCompletion:(RZFAppUpdateCheckCompletion)completion;

@end
