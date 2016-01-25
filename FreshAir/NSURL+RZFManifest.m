//
//  NSURL+RZFManifest.m
//  FreshAir
//
//  Created by Brian King on 1/24/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "NSURL+RZFManifest.h"

@implementation NSURL (RZFManifest)

+ (NSString *)rzf_manifestFilename
{
    return @"mansifest.json";
}

+ (NSString *)rzf_presentationFilename
{
    return @"presentation.json";
}

- (NSURL *)rzf_manifestURL
{
    return [self URLByAppendingPathComponent:[NSURL rzf_manifestFilename]];
}

- (BOOL)rzf_isManifestURL
{
    return [self.lastPathComponent isEqual:[NSURL rzf_manifestFilename]];
}

- (NSURL *)rzf_presentationURL
{
    return [self URLByAppendingPathComponent:[NSURL rzf_presentationFilename]];
}

@end
