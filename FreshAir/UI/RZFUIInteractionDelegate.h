//
//  RZFUIInteraction.h
//  FreshAir
//
//  Created by Brian King on 1/28/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import UIKit;

@protocol RZFInteractionDelegate <NSObject>

- (void)rzf_intitiator:(id)initiator presentViewController:(UIViewController *)viewController;
- (void)rzf_intitiator:(id)initiator dismissViewController:(UIViewController *)viewController;
- (void)rzf_intitiator:(id)initiator openURL:(NSURL *)upgradeURL;

@end

