//
//  RZFManifestManager+UIKit.m
//  FreshAir
//
//  Created by Brian King on 1/24/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFManifestManager+UIKit.h"
@import UIKit;

@implementation RZFManifestManager (UIKit)

+ (void)load
{
    [[self defaultEnvironment] setValue:@"iOS" forKey:@"platform"];
    [[self defaultEnvironment] setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forKey:@"appVersion"];
    [[self defaultEnvironment] setValue:[[UIDevice currentDevice] systemVersion] forKey:@"systemVersion"];
    [[self defaultEnvironment] setValue:@([[UIScreen mainScreen] scale]) forKey:@"displayScale"];
    [[self defaultEnvironment] setValue:[NSUserDefaults standardUserDefaults] forKey:@"defaults"];
}

@end
