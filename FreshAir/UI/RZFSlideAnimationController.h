//
//  RZFSlideAnimationController.h
//  RZFreshAir
//
//  Created by Bradley Smith on 5/26/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

@import UIKit;

@protocol RZFSlidingViewController <NSObject>

@property (strong, nonatomic, readonly) UIView *tintView;
@property (strong, nonatomic, readonly) UIView *contentView;

@end

@interface RZFSlideAnimationController : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic, readwrite) BOOL isPresenting;

@end
