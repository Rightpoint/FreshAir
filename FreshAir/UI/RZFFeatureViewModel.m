//
//  RZFUIFeature.m
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFFeatureViewModel.h"
#import "RZFFeature.h"

@implementation RZFFeatureViewModel

- (instancetype)initWithFeature:(RZFFeature *)feature bundle:(NSBundle *)bundle;
{
    self = [super init];
    if (self) {
        _localizedTitle = [bundle localizedStringForKey:feature.localizedTitleKey value:nil table:@"Feature"];
        _localizedDescription = [bundle localizedStringForKey:feature.localizedDescriptionKey value:nil table:@"Feature"];
        _image = [UIImage imageNamed:feature.localizedImageKey inBundle:bundle compatibleWithTraitCollection:nil];
    }
    return self;
}

@end
