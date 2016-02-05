//
//  RZFAppUpdateCheck.h
//  FreshAir
//
//  Created by Brian King on 2/1/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZFAppStoreUpdateCheck.h"

/**
 * Check the releaseNoteURL file to see if there is an update available. If this is a remote
 * file it will be downloaded, if it is a local file it will be checked immediately.
 */
@interface RZFAppUpdateCheck : NSObject

- (instancetype)initWithReleaseNoteURL:(NSURL *)releaseNoteURL appVersion:(NSString *)appVersion systemVersion:(NSString *)systemVersion;

/**
 * NSURLSession to make request with. Defaults to +[NSURLSession defaultSession]
 */
@property (strong, nonatomic) NSURLSession *session;

@property (strong, nonatomic, readonly) NSString *appVersion;
@property (strong, nonatomic, readonly) NSString *systemVersion;
@property (strong, nonatomic, readonly) NSURL *releaseNoteURL;

- (void)performCheckWithCompletion:(RZFAppUpdateCheckCompletion)completion;

@end
