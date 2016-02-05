//
//  RZFUpdatePromptViewController.h
//  RZFreshAir
//
//  Created by Bradley Smith on 5/26/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

@import UIKit;

#import "RZFViewController.h"

@class RZFUpdatePromptViewController, RZFUpdateViewModel;

@protocol RZFUpdatePromptViewControllerDelegate <NSObject>

- (void)updatePromptViewController:(RZFUpdatePromptViewController *)updatePromptViewController shouldUpgradeWithURL:(NSURL *)url;
- (void)dismissUpdatePromptViewController:(RZFUpdatePromptViewController *)updatePromptViewController;

@end

@interface RZFUpdatePromptViewController : RZFViewController

- (instancetype)initWithUpgradeURL:(NSURL *)upgradeURL version:(NSString *)version isForced:(BOOL)isForced;

@property (strong, nonatomic, readonly) NSURL *upgradeURL;
@property (strong, nonatomic, readonly) NSString *version;
@property (weak, nonatomic, readwrite) id <RZFUpdatePromptViewControllerDelegate> delegate;

@end
