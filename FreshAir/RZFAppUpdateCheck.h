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

@property (strong, nonatomic) NSURLSession *session;

@property (strong, nonatomic) RZFEnvironment *environment;

- (void)checkAppStoreID:(NSString *)appStoreID
             completion:(RZFAppUpdateCheckCompletion)completion;

- (void)checkReleaseNotesURL:(NSURL *)URL
                  completion:(RZFAppUpdateCheckCompletion)completion;

@end
