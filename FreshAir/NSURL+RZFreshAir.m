//
//  NSURL+RZFreshAir.m
//  FreshAir
//
//  Created by Brian King on 1/24/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "NSURL+RZFreshAir.h"

@implementation NSURL (RZFreshAir)

+ (NSString *)rzf_manifestFilename
{
    return @"manifest.json";
}

+ (NSString *)rzf_releaseFilename
{
    return @"release_notes.json";
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
