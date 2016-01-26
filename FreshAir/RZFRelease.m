//
//  RZFRelease.m
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFRelease.h"

@implementation RZFRelease

- (NSString *)conditionWithVersionComparison
{
    NSString *versionCompare = [NSString stringWithFormat:@"appVersion < %@", self.version];
    return self.condition.length > 0 ? [self.condition stringByAppendingString:versionCompare] : versionCompare;
}

@end
