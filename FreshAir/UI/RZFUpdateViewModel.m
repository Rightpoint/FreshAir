//
//  RZFUpdateViewModel.m
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFUpdateViewModel.h"
#import "RZFReleaseNotes.h"

static NSString *RZFLocalizedValue(NSBundle *bundle, NSString *key) {
    NSString *fullKey = [@"freshair.update." stringByAppendingString:key];
    return [bundle localizedStringForKey:fullKey value:nil table:@"FreshAirUpdate"];
}

@implementation RZFUpdateViewModel

- (instancetype)initWithBundle:(NSBundle *)bundle
{
    self = [super init];
    if (self) {
        self.image = [UIImage imageNamed:@"freshair_update" inBundle:bundle compatibleWithTraitCollection:nil];
        self.localizedTitle = RZFLocalizedValue(bundle, @"title");
        self.localizedDescription = RZFLocalizedValue(bundle, @"description");
        self.localizedDismiss = RZFLocalizedValue(bundle, @"dismiss");
        self.localizedConfirmation = RZFLocalizedValue(bundle, @"confirm");
    }
   
    return self;
}

@end
