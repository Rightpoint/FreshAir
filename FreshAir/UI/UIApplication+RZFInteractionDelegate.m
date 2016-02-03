//
//  UIApplication+RZFInteractionDelegate.m
//  FreshAir
//
//  Created by Brian King on 1/28/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "UIApplication+RZFInteractionDelegate.h"


@implementation UIApplication (RZFInteractionDelegate)

- (void)rzf_interationDelegate:(id)initiator presentViewController:(UIViewController *)viewController
{
    UIViewController *topViewController = self.delegate.window.rootViewController;
    while (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    [topViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)rzf_interationDelegate:(id)initiator dismissViewController:(UIViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)rzf_interationDelegate:(id)initiator openURL:(NSURL *)upgradeURL
{
    [self openURL:upgradeURL];
}

@end
