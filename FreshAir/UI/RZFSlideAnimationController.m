//
//  RZFSlideAnimationController.m
//  RZFreshAir
//
//  Created by Bradley Smith on 5/26/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZFSlideAnimationController.h"
#import "RZFUpdatePromptViewController.h"
#import "RZFReleaseNotesViewController.h"
#import "RZFUpdatePromptView.h"
#import "RZFReleaseNotesView.h"
#import "UIView+RZFAutoLayout.h"

static const CGFloat kRZFSlideAnimationDuration = 0.75f;
static const CGFloat kRZFSlideAnimationDelay = 0.0f;
static const CGFloat kRZFSlideAnimationSpringDamping = 0.75f;
static const CGFloat kRZFSlideAnimationSpringVelocity = 0.0f;

@implementation RZFSlideAnimationController

# pragma mark - View Controller Animated transitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    
    CGFloat startAlpha;
    CGFloat endAlpha;
    CGAffineTransform startTransform;
    CGAffineTransform endTransform;
    
    UIView *tintView;
    UIView *contentView;
    
    if ( self.isPresenting ) {
        [container addSubview:toViewController.view];
        toViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [toViewController.view rzf_fillContainerWithInsets:UIEdgeInsetsZero];
        
        startAlpha = 0.0f;
        endAlpha = 1.0f;
        
        CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        startTransform = CGAffineTransformMakeTranslation(0.0f, screenHeight);
        endTransform = CGAffineTransformIdentity;
        
        if ( [toViewController conformsToProtocol:@protocol(RZFSlidingViewController)] ) {
            UIViewController<RZFSlidingViewController> *viewController = (id)toViewController;
            tintView = viewController.tintView;
            contentView = viewController.contentView;
        }
        else {
            [NSException raise:NSInvalidArgumentException format:@"View Controller must conform to RZFSlidingViewController"];
        }
    }
    else {
        startAlpha = 1.0f;
        endAlpha = 0.0f;
        
        startTransform = CGAffineTransformIdentity;
        CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        endTransform = CGAffineTransformMakeTranslation(0.0f, screenHeight);

        if ( [fromViewController conformsToProtocol:@protocol(RZFSlidingViewController)] ) {
            UIViewController<RZFSlidingViewController> *viewController = (id)fromViewController;
            tintView = viewController.tintView;
            contentView = viewController.contentView;
        }
        else {
            [NSException raise:NSInvalidArgumentException format:@"View Controller must conform to RZFSlidingViewController"];
        }
    }
    
    tintView.alpha = startAlpha;
    contentView.transform = startTransform;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:kRZFSlideAnimationDelay
         usingSpringWithDamping:kRZFSlideAnimationSpringDamping
          initialSpringVelocity:kRZFSlideAnimationSpringVelocity
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         tintView.alpha = endAlpha;
                         contentView.transform = endTransform;
                     }
                     completion:^(BOOL finished) {
                         [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                     }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return kRZFSlideAnimationDuration;
}

@end
