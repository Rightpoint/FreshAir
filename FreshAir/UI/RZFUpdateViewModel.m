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
    NSString *value = [[NSBundle mainBundle] localizedStringForKey:fullKey value:nil table:@"FreshAirUpdate"];
    if ([value isEqual:fullKey]) {
        value = [[NSBundle mainBundle] localizedStringForKey:fullKey value:nil table:nil];
    }
    if ([value isEqual:fullKey]) {
        value = [bundle localizedStringForKey:fullKey value:nil table:@"FreshAirUpdate"];
    }
    return value;
}

@implementation RZFUpdateViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSBundle *fallbackBundle = [NSBundle bundleForClass:self.class];
        self.image = [UIImage imageNamed:@"freshair_update" inBundle:fallbackBundle compatibleWithTraitCollection:nil];
        if (self.image == nil) {
            self.image = [UIImage imageNamed:@"freshair_update"];
        }
        self.localizedTitle = RZFLocalizedValue(fallbackBundle, @"title");
        self.localizedDescription = RZFLocalizedValue(fallbackBundle, @"description");
        self.localizedDismiss = RZFLocalizedValue(fallbackBundle, @"dismiss");
        self.localizedConfirmation = RZFLocalizedValue(fallbackBundle, @"confirm");
    }
   
    return self;
}

@end
