//
//  RZFViewController.m
//  RZFreshAir
//
//  Created by Bradley Smith on 6/5/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZFViewController.h"
#import "RZFSlideAnimationController.h"
#import "UIView+RZFAutoLayout.h"

static const CGFloat kRZFTintViewAlpha = 0.7f;

@interface RZFViewController () <UIViewControllerTransitioningDelegate>

@property (strong, nonatomic, readwrite) UIView *tintView;
@property (strong, nonatomic, readwrite) RZFSlideAnimationController *slideAnimationController;

@end

@implementation RZFViewController

# pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    
    if ( self ) {
        self.slideAnimationController = [[RZFSlideAnimationController alloc] init];
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.transitioningDelegate = self;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupTintView];
}

# pragma mark - Setup

- (void)setupTintView
{
    self.tintView = [[UIView alloc] init];
    self.tintView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tintView];
    
    [self.tintView rzf_fillContainerWithInsets:UIEdgeInsetsZero];
    
    self.tintView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kRZFTintViewAlpha];
}

# pragma mark - View Controller Transitioning Delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    self.slideAnimationController.isPresenting = YES;
    
    return self.slideAnimationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.slideAnimationController.isPresenting = NO;
    
    return self.slideAnimationController;
}

@end