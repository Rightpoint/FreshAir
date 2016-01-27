//
//  RZFRemoteBundle.h
//  FreshAir
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import Foundation;

@class RZFManifestEntry;

NS_ASSUME_NONNULL_BEGIN;

@interface RZFManifest : NSObject

- (instancetype)initWithRemoteURL:(NSURL *)remoteURL
                           bundle:(NSBundle *)bundle
                      environment:(NSDictionary *)environment;

@property (copy, nonatomic, readonly) NSURL *remoteURL;
@property (strong, nonatomic, readonly) NSBundle *bundle;

@property (copy, nonatomic, readonly) NSArray *entries;

- (BOOL)loadEntriesError:(NSError **)error;
- (BOOL)isManifestLoaded;

- (BOOL)isLoaded;

- (NSArray *)unloadedFilenames;

@end

NS_ASSUME_NONNULL_END;
