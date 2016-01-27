//
//  RZFManifestEntry.m
//  FreshAir
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFManifestEntry.h"
#import "RZFFileHash.h"
#import "RZFCondition.h"

@implementation RZFManifestEntry

- (BOOL)isApplicableInEnvironment:(NSDictionary *)environment
{
    NSParameterAssert(environment);
    return [[RZFCondition predicateForConditions:self.conditions] evaluateWithObject:environment];
}

- (BOOL)isLoadedInBundle:(NSBundle *)bundle
{
    NSParameterAssert(bundle);
    NSURL *file = [bundle.bundleURL URLByAppendingPathComponent:self.filename];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:file.path];
    if (self.sha) {
        NSString *computedSha = [RZFFileHash sha1HashOfFileAtPath:file.path];
        return fileExists && [computedSha isEqual:self.sha];
    }
    else {
        return fileExists;
    }
}

@end
