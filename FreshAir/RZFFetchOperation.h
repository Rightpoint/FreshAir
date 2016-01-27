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

@interface RZFFetchOperation : NSOperation

- (instancetype)initWithFilename:(NSString *)filename
                             sha:(NSString *)sha
                      inManifest:(RZFManifest *)manifest;

@property (strong, nonatomic) NSURL *fromURL;
@property (strong, nonatomic) NSURL *destinationURL;
@property (copy, nonatomic) NSString *sha;

@property (strong, nonatomic) RZFManifest *manifest;

@property (strong, nonatomic) NSFileManager *fileManager;
@property (strong, nonatomic) NSURLSession *session;

@property (strong, nonatomic) NSError *error;

@end
