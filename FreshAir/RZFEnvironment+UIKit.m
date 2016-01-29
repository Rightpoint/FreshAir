//
//  RZFManifestManager+UIKit.m
//  FreshAir
//
//  Created by Brian King on 1/24/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFEnvironment+UIKit.h"
@import UIKit;

@implementation RZFEnvironment (UIKit)

+ (void)load
{
    NSMutableDictionary *environment = [self defaultVariables];
    [environment setValue:@"iOS" forKey:RZFEnvironmentPlatformKey];
    [environment setValue:[[UIDevice currentDevice] systemVersion] forKey:RZFEnvironmentSystemVersionKey];
    [environment setValue:[@([[UIScreen mainScreen] scale]) stringValue] forKey:RZFEnvironmentDisplayScaleKey];

    // NSBundle.mainBundle is un-reliable, Look for an object that is in the application bundle.
    id obj = [[UIApplication sharedApplication] delegate];
    if (obj) {
        NSBundle *appBundle = [NSBundle bundleForClass:obj];
        [environment setValue:appBundle.infoDictionary[@"CFBundleShortVersionString"] forKey:RZFEnvironmentAppVersionKey];
    }
}

@end
