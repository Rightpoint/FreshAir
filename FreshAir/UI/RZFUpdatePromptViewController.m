//
//  RZFUpdatePromptViewController.m
//  RZFreshAir
//
//  Created by Bradley Smith on 5/26/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZFUpdatePromptViewController.h"
#import "UIView+RZFAutoLayout.h"
#import "RZFUpdatePromptView.h"
#import "RZFUpdateViewModel.h"

static const CGFloat kRZFUpdatePromptViewHorizontalPadding = 20.0f;

@interface RZFViewController ()

@property (strong, nonatomic, readwrite) UIView *tintView;
@property (strong, nonatomic, readwrite) RZFSlideAnimationController *slideAnimationController;

@end

@interface RZFUpdatePromptViewController () <RZFUpdatePromptViewDelegate>

@property (strong, nonatomic, readwrite) RZFUpdatePromptView *updatePromptView;
@property (strong, nonatomic) RZFUpdateViewModel *updateViewModel;

@end

@implementation RZFUpdatePromptViewController

# pragma mark - Lifecycle

- (instancetype)initWithUpgradeURL:(NSURL *)upgradeURL
                           version:(NSString *)version
                          isForced:(BOOL)isForced
{
    self = [super initWithNibName:nil bundle:nil];
    
    if ( self ) {
        _upgradeURL = upgradeURL;
        _version = [version copy];
        _updateViewModel = [[RZFUpdateViewModel alloc] init];
        _updateViewModel.isForced = isForced;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self setupUpdatePromptView];
}

- (void)setupUpdatePromptView
{
    self.updatePromptView = [[RZFUpdatePromptView alloc] initWithViewModel:self.updateViewModel];
    self.updatePromptView.delegate = self;
    [self.view addSubview:self.updatePromptView];
    self.contentView = self.updatePromptView;
    
    CGFloat padding;
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
        padding = CGRectGetWidth([UIScreen mainScreen].bounds) / 5.0f;
    }
    else {
        padding = kRZFUpdatePromptViewHorizontalPadding;
    }
    
    [self.updatePromptView rzf_fillContainerHorizontallyWithPadding:padding];
    [self.updatePromptView rzf_centerVerticallyInContainer];
}

# pragma mark - Update Prompt View Delegate

- (void)didSelectDeclineForUpdatePromptView:(RZFUpdatePromptView *)updatePromptView
{
    [self.delegate dismissUpdatePromptViewController:self];
}

- (void)didSelectConfirmForUpdatePromptView:(RZFUpdatePromptView *)updatePromptView
{
    [self.delegate updatePromptViewController:self shouldUpgradeWithURL:self.upgradeURL];
}

@end
