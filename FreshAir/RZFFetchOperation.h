//
//  RZFResourceLoader.h
//  FreshAir
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import Foundation;

@class RZFManifest;
@class RZFManifestEntry;

NS_ASSUME_NONNULL_BEGIN;

@interface RZFFetchOperation : NSOperation

- (instancetype)initWithFilename:(NSString *)filename
                             sha:(NSString * __nullable)sha
                      inManifest:(RZFManifest *)manifest;

@property (strong, nonatomic) NSURL *fromURL;
@property (strong, nonatomic) NSURL *destinationURL;
@property (copy, nonatomic) NSString * __nullable sha;

@property (strong, nonatomic) RZFManifest *manifest;

@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSURLSession *session;

@property (strong, nonatomic) NSError * __nullable error;

@end

NS_ASSUME_NONNULL_END;

