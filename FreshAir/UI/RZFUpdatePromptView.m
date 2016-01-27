//
//  RZFUpdatePromptView.m
//  RZFreshAir
//
//  Created by Bradley Smith on 5/26/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZFUpdatePromptView.h"
#import "UIView+RZFAutoLayout.h"
#import "UIColor+RZFStyle.h"
#import "UIFont+RZFStyle.h"

#import "RZFUpdateViewModel.h"

static const CGFloat kRZFUpdatePromptViewCornerRadius = 5.0f;

static const CGFloat kRZFAppIconImageViewTopPadding = 40.0f;
static const CGFloat kRZFAppIconImageViewHeight = 100.0f;
static const CGFloat kRZFAppIconImageViewWidth = 100.0f;

static const CGFloat kRZFPromptTitleLabelTopPadding = 30.0f;

static const CGFloat kRZFPromptMessageLabelHorizontalPadding = 30.0f;
static const CGFloat kRZFPromptMessageLabelTopPadding = 20.0f;

static const CGFloat kRZFPromptButtonsContainerViewHorizontalPadding = 0.0f;
static const CGFloat kRZFPromptButtonsContainerViewTopPadding = 30.0f;
static const CGFloat kRZFPromptButtonsContainerViewBottomPadding = 0.0f;
static const CGFloat kRZFPromptButtonsContainerViewHeight = 60.0f;

static const CGFloat kRZFDeclineButtonVerticalPadding = 0.0f;
static const CGFloat kRZFDeclineButtonHorizontalPadding = 0.0f;

static const CGFloat kRZFPromptButtonsSeparatorViewVerticalPadding = 20.0f;
static const CGFloat kRZFPromptButtonsSeparatorViewHorizontalPadding = 0.0f;
static const CGFloat kRZFPromptButtonsSeparatorViewWidth = 1.0f;

static const CGFloat kRZFConfirmButtonVerticalPadding = 0.0f;
static const CGFloat kRZFConfirmButtonHorizontalPadding = 0.0f;

static const CGFloat kRZFForceUpdateButtonContainerViewHorizontalPadding = 0.0f;
static const CGFloat kRZFForceUpdateButtonContainerViewTopPadding = 30.0f;
static const CGFloat kRZFForceUpdateButtonContainerViewBottomPadding = 0.0f;

static const NSInteger kRZFPromptTitleLabelNumberOfLines = 1;
static const NSInteger kRZFPromptMessageLabelNumberOfLines = 0;

@interface RZFUpdatePromptView ()

@property (strong, nonatomic) UIImageView *appIconImageView;
@property (strong, nonatomic) UILabel *promptTitleLabel;
@property (strong, nonatomic) UILabel *promptMessageLabel;
@property (strong, nonatomic) UIView *promptButtonsContainerView;
@property (strong, nonatomic) UIButton *declineButton;
@property (strong, nonatomic) UIView *promptButtonsSeparatorView;
@property (strong, nonatomic) UIButton *confirmButton;
@property (strong, nonatomic) UIView *forceUpdateButtonContainerView;
@property (strong, nonatomic) UIButton *forceUpdateButton;

@end

@implementation RZFUpdatePromptView

# pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    
    if ( self ) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = kRZFUpdatePromptViewCornerRadius;
        self.clipsToBounds = YES;
        
        [self setupAppIconImageView];
        [self setupPromptTitleLabel];
        [self setupPromptMessageLabel];
        [self setupPromptButtonsContainerView];
        [self setupForceUpdateButtonContainerView];
    }
    
    return self;
}

- (instancetype)initWithViewModel:(RZFUpdateViewModel *)viewModel
{
    self = [self init];
    
    if ( self ) {
        [self setupWithViewModel:viewModel];
    }
    
    return self;
}

# pragma mark - Setup

- (void)setupWithViewModel:(RZFUpdateViewModel *)viewModel
{    
    self.appIconImageView.image = viewModel.image;


    self.promptTitleLabel.text = viewModel.localizedTitle;
    self.promptMessageLabel.text = viewModel.localizedDescription;
    
    self.forceUpdateButtonContainerView.hidden = !viewModel.isForced;
    self.promptButtonsContainerView.hidden = viewModel.isForced;
    [self.declineButton setTitle:viewModel.localizedDismiss forState:UIControlStateNormal];
    [self.confirmButton setTitle:viewModel.localizedConfirmation forState:UIControlStateNormal];
    [self.forceUpdateButton setTitle:viewModel.localizedConfirmation forState:UIControlStateNormal];
}

- (void)setupAppIconImageView
{
    self.appIconImageView = [[UIImageView alloc] init];
    self.appIconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.appIconImageView];
    
    [self.appIconImageView rzf_centerHorizontallyInContainer];
    [self.appIconImageView rzf_pinTopSpaceToSuperviewWithPadding:kRZFAppIconImageViewTopPadding];
    [self.appIconImageView rzf_pinSizeTo:CGSizeMake(kRZFAppIconImageViewWidth, kRZFAppIconImageViewHeight)];
    
    self.appIconImageView.backgroundColor = [UIColor clearColor];
    self.appIconImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.appIconImageView.clipsToBounds = YES;
}

- (void)setupPromptTitleLabel
{
    self.promptTitleLabel = [[UILabel alloc] init];
    self.promptTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.promptTitleLabel];
    
    [self.promptTitleLabel rzf_centerHorizontallyInContainer];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.promptTitleLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.appIconImageView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:kRZFPromptTitleLabelTopPadding]];
    
    self.promptTitleLabel.backgroundColor = [UIColor clearColor];
    self.promptTitleLabel.font = [UIFont rzf_defaultPromptTitleFont];
    self.promptTitleLabel.textColor = [UIColor rzf_defaultPromptTitleColor];
    self.promptTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.promptTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.promptTitleLabel.numberOfLines = kRZFPromptTitleLabelNumberOfLines;
}

- (void)setupPromptMessageLabel
{
    self.promptMessageLabel = [[UILabel alloc] init];
    self.promptMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.promptMessageLabel];
    
    [self.promptMessageLabel rzf_fillContainerHorizontallyWithPadding:kRZFPromptMessageLabelHorizontalPadding];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.promptMessageLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.promptTitleLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:kRZFPromptMessageLabelTopPadding]];
    
    self.promptMessageLabel.backgroundColor = [UIColor clearColor];
    self.promptMessageLabel.font = [UIFont rzf_defaultPromptMessageFont];
    self.promptMessageLabel.textColor = [UIColor rzf_defaultPromptMessageColor];
    self.promptMessageLabel.textAlignment = NSTextAlignmentCenter;
    self.promptMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.promptMessageLabel.numberOfLines = kRZFPromptMessageLabelNumberOfLines;
}

- (void)setupPromptButtonsContainerView
{
    self.promptButtonsContainerView = [[UIView alloc] init];
    self.promptButtonsContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.promptButtonsContainerView];
    
    [self.promptButtonsContainerView rzf_fillContainerHorizontallyWithPadding:kRZFPromptButtonsContainerViewHorizontalPadding];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.promptButtonsContainerView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.promptMessageLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:kRZFPromptButtonsContainerViewTopPadding]];
    [self.promptButtonsContainerView rzf_pinBottomSpaceToSuperviewWithPadding:kRZFPromptButtonsContainerViewBottomPadding];
    [self.promptButtonsContainerView rzf_pinHeightTo:kRZFPromptButtonsContainerViewHeight];
    
    self.promptButtonsContainerView.backgroundColor = [UIColor rzf_defaultPromptTintColor];
    
    [self setupDeclineButton];
    [self setupPromptButtonsSeparatorView];
    [self setupConfirmButton];
}

- (void)setupDeclineButton
{
    self.declineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.declineButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.promptButtonsContainerView addSubview:self.declineButton];
    
    [self.declineButton rzf_fillContainerVerticallyWithPadding:kRZFDeclineButtonVerticalPadding];
    [self.declineButton rzf_pinLeftSpaceToSuperviewWithPadding:kRZFDeclineButtonHorizontalPadding];
    
    self.declineButton.backgroundColor = [UIColor clearColor];
    self.declineButton.titleLabel.font = [UIFont rzf_defaultPromptButtonFont];
    [self.declineButton setTitleColor:[UIColor rzf_defaultPromptButtonTitleColorNormal] forState:UIControlStateNormal];
    [self.declineButton setTitleColor:[UIColor rzf_defaultPromptButtonTitleColorPressed] forState:UIControlStateHighlighted];
    [self.declineButton addTarget:self
                           action:@selector(declineButtonTapped)
                 forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupPromptButtonsSeparatorView
{
    self.promptButtonsSeparatorView = [[UIView alloc] init];
    self.promptButtonsSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.promptButtonsContainerView addSubview:self.promptButtonsSeparatorView];
    
    [self.promptButtonsSeparatorView rzf_fillContainerVerticallyWithPadding:kRZFPromptButtonsSeparatorViewVerticalPadding];
    [self.promptButtonsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.promptButtonsSeparatorView
                                                                                attribute:NSLayoutAttributeLeading
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.declineButton
                                                                                attribute:NSLayoutAttributeTrailing
                                                                               multiplier:1.0f
                                                                                 constant:kRZFPromptButtonsSeparatorViewHorizontalPadding]];
    [self.promptButtonsSeparatorView rzf_pinWidthTo:kRZFPromptButtonsSeparatorViewWidth];
    
    self.promptButtonsSeparatorView.backgroundColor = [UIColor rzf_defaultPromptButtonTitleColorNormal];
}

- (void)setupConfirmButton
{
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.promptButtonsContainerView addSubview:self.confirmButton];
    
    [self.confirmButton rzf_fillContainerVerticallyWithPadding:kRZFConfirmButtonVerticalPadding];
    [self.confirmButton rzf_pinRightSpaceToSuperviewWithPadding:kRZFConfirmButtonHorizontalPadding];
    [self.promptButtonsContainerView addConstraint:[NSLayoutConstraint constraintWithItem:self.confirmButton
                                                                                attribute:NSLayoutAttributeLeading
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.promptButtonsSeparatorView
                                                                                attribute:NSLayoutAttributeTrailing
                                                                               multiplier:1.0f
                                                                                 constant:kRZFConfirmButtonHorizontalPadding]];
    [self.confirmButton rzf_pinWidthToView:self.declineButton];
    
    self.confirmButton.backgroundColor = [UIColor clearColor];
    self.confirmButton.titleLabel.font = [UIFont rzf_defaultPromptButtonFont];
    [self.confirmButton setTitleColor:[UIColor rzf_defaultPromptButtonTitleColorNormal] forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[UIColor rzf_defaultPromptButtonTitleColorPressed] forState:UIControlStateHighlighted];
    [self.confirmButton addTarget:self
                           action:@selector(confirmButtonTapped)
                 forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupForceUpdateButtonContainerView
{
    self.forceUpdateButtonContainerView = [[UIView alloc] init];
    self.forceUpdateButtonContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.forceUpdateButtonContainerView];
    
    [self.forceUpdateButtonContainerView rzf_fillContainerHorizontallyWithPadding:kRZFForceUpdateButtonContainerViewHorizontalPadding];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.forceUpdateButtonContainerView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.promptMessageLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:kRZFForceUpdateButtonContainerViewTopPadding]];
    [self.forceUpdateButtonContainerView rzf_pinBottomSpaceToSuperviewWithPadding:kRZFForceUpdateButtonContainerViewBottomPadding];
    [self.forceUpdateButtonContainerView rzf_pinHeightToView:self.promptButtonsContainerView];
    
    self.forceUpdateButtonContainerView.backgroundColor = [UIColor rzf_defaultPromptTintColor];
    
    [self setupForceUpdateButton];    
}

- (void)setupForceUpdateButton
{
    self.forceUpdateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.forceUpdateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.forceUpdateButtonContainerView addSubview:self.forceUpdateButton];
    
    [self.forceUpdateButton rzf_fillContainerWithInsets:UIEdgeInsetsZero];
    
    self.forceUpdateButton.backgroundColor = [UIColor clearColor];
    self.forceUpdateButton.titleLabel.font = [UIFont rzf_defaultPromptButtonFont];
    [self.forceUpdateButton setTitleColor:[UIColor rzf_defaultPromptButtonTitleColorNormal] forState:UIControlStateNormal];
    [self.forceUpdateButton setTitleColor:[UIColor rzf_defaultPromptButtonTitleColorPressed] forState:UIControlStateHighlighted];
    [self.forceUpdateButton addTarget:self
                               action:@selector(confirmButtonTapped)
                     forControlEvents:UIControlEventTouchUpInside];
}

# pragma mark - Actions

- (void)declineButtonTapped
{
    if ( [self.delegate respondsToSelector:@selector(didSelectDeclineForUpdatePromptView:)] ) {
        [self.delegate didSelectDeclineForUpdatePromptView:self];
    }
}

- (void)confirmButtonTapped
{
    if ( [self.delegate respondsToSelector:@selector(didSelectConfirmForUpdatePromptView:)] ) {
        [self.delegate didSelectConfirmForUpdatePromptView:self];
    }
}

@end
