//
//  NSBundle+RZFreshAir.m
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "NSBundle+RZFreshAir.h"

NSString *const RZFreshAirRemoteURL = @"RZFreshAirRemoteURL";

@implementation NSBundle (RZFreshAir)

+ (NSBundle *)rzf_appBundle
{
    Class UIApplication = NSClassFromString(@"UIApplication");
    id obj = [UIApplication valueForKeyPath:@"sharedApplication.delegate"];
    return obj ? [NSBundle bundleForClass:obj] : nil;
}

- (NSURL *)rzf_remoteURL
{
    NSString *absoluteURL = self.infoDictionary[RZFreshAirRemoteURL];
    NSAssert(absoluteURL != nil, @"rzf_remoteURL is only supported on .freshair bundles");
    return [NSURL URLWithString:absoluteURL];
}

@end
