//
//  RZFViewController.h
//  RZFreshAir
//
//  Created by Bradley Smith on 6/5/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

@import UIKit;
#import "RZFSlideAnimationController.h"

@interface RZFViewController : UIViewController <RZFSlidingViewController>

@property (strong, nonatomic, readonly) UIView *tintView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic, readonly) RZFSlideAnimationController *slideAnimationController;

@end
