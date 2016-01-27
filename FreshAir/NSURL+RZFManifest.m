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
    return @"manifest.json";
}

+ (NSString *)rzf_releaseFilename
{
    return @"release.json";
}

+ (NSString *)rzf_freshairExtension
{
    return @"freshair";
}

- (NSURL *)rzf_manifestURL
{

    return [self URLByAppendingPathComponent:[NSURL rzf_manifestFilename]];
}

- (BOOL)rzf_isManifestURL
{
    return [self.lastPathComponent isEqual:[NSURL rzf_manifestFilename]];
}

- (NSURL *)rzf_releaseURL
{
    return [self URLByAppendingPathComponent:[NSURL rzf_releaseFilename]];
}

@end
