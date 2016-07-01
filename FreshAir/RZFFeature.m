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

- (NSString *)localizedAttributedDescriptionPrefixKey
{
    return [self.key stringByAppendingString:@".attributedDescription"];
}

- (NSString *)localizedFontNamePrefixKey
{
    return [self.key stringByAppendingString:@".fontName"];
}

- (NSString *)localizedFontSizePrefixKey
{
    return [self.key stringByAppendingString:@".fontSize"];
}

- (NSString *)localizedImageKey
{
    return self.key;
}

@end
