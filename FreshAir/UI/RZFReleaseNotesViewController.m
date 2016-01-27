//
//  RZFReleaseNotesViewController.m
//  RZFreshAir
//
//  Created by Bradley Smith on 6/5/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZFReleaseNotesViewController.h"
#import "RZFReleaseNotesView.h"
#import "UIView+RZFAutoLayout.h"
#import "NSObject+RZFUtility.h"
#import "RZFFeatureViewModel.h"

static const CGFloat kRZFReleaseNotesViewHorizontalPadding = 20.0f;

@interface RZFViewController ()

@property (strong, nonatomic, readwrite) UIView *tintView;
@property (strong, nonatomic, readwrite) RZFSlideAnimationController *slideAnimationController;

@end

@interface RZFReleaseNotesViewController () <RZFReleaseNotesViewDelegate>

@property (strong, nonatomic, readwrite) RZFReleaseNotesView *releaseNotesView;
@property (strong, nonatomic) NSArray<RZFFeature *> *features;

@end

@implementation RZFReleaseNotesViewController

# pragma mark - Lifecycle

- (instancetype)initWithFeatures:(NSArray<RZFFeature *> *)features bundle:(NSBundle *)bundle;
{
    self = [super initWithNibName:nil bundle:bundle];
    
    if ( self ) {
        self.features = features;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self setupReleaseNotesView];
}

# pragma mark - Setup

- (void)setupReleaseNotesView
{
    NSArray *featureViewModels = [self.features map:^RZFFeatureViewModel *(RZFFeature *feature) {
        return [[RZFFeatureViewModel alloc] initWithFeature:feature bundle:self.nibBundle];
    }];
    self.releaseNotesView = [[RZFReleaseNotesView alloc] initWithFeatures:featureViewModels];
    self.releaseNotesView.delegate = self;
    [self.view addSubview:self.releaseNotesView];
    self.contentView = self.releaseNotesView;
    
    CGFloat padding;
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
        padding = CGRectGetWidth([UIScreen mainScreen].bounds) / 5.0f;
    }
    else {
        padding = kRZFReleaseNotesViewHorizontalPadding;
    }
    
    [self.releaseNotesView rzf_fillContainerHorizontallyWithPadding:padding];
    [self.releaseNotesView rzf_centerVerticallyInContainer];
}

# pragma mark - Release Notes View Delegate

- (void)didSelectDoneForReleaseNotesView:(RZFReleaseNotesView *)releaseNotesView
{
    if ( [self.delegate respondsToSelector:@selector(didSelectDoneForReleaseNotesViewController:)] ) {
        [self.delegate didSelectDoneForReleaseNotesViewController:self];
    }
}

@end
