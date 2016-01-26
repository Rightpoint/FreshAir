//
//  RZFFeature.m
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFFeature.h"

@implementation RZFFeature

- (NSString *)localizedTitleKey
{
    return [self.key stringByAppendingString:@".title"];
}

- (NSString *)localizedDescriptionKey
{
    return [self.key stringByAppendingString:@".description"];
}

- (NSString *)localizedImageKey
{
    return self.key;
}

@end
