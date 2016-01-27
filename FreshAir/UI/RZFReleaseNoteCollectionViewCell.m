//
//  RZFReleaseNoteCollectionViewCell.m
//  RZFreshAir
//
//  Created by Bradley Smith on 6/5/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZFReleaseNoteCollectionViewCell.h"
#import "RZFFeature.h"
#import "UIView+RZFAutoLayout.h"
#import "UIColor+RZFStyle.h"
#import "UIFont+RZFStyle.h"
#import "RZFFeatureViewModel.h"

static const CGFloat kRZFScreenshotImageViewHorizontalPadding = 0.0f;
static const CGFloat kRZFScreenshotImageViewTopPadding = 0.0f;
static const CGFloat kRZFScreenshotImageViewHeight = 250.0f;

static const CGFloat kRZFInfoContainerViewHorizontalPadding = 0.0f;
static const CGFloat kRZFInfoContainerViewBottomPadding = 0.0f;
static const CGFloat kRZFInfoContainerViewTopPadding = 40.0f;

static const CGFloat kRZFReleaseNoteTitleLabelHorizontalPadding = 0.0f;
static const CGFloat kRZFReleaseNoteTitleLabelTopPadding = 0.0f;

static const CGFloat kRZFReleaseNoteMessageLabelHorizontalPadding = 0.0f;
static const CGFloat kRZFReleaseNoteMessageLabelBottomPadding = 0.0f;
static const CGFloat kRZFReleaseNoteMessageLabelTopPadding = 10.0f;

static const NSInteger kRZFReleaseNoteTitleLabelNumberOfLines = 1;
static const NSInteger kRZFReleaseNoteMessageLabelNumberOfLines = 3;

@interface RZFReleaseNoteCollectionViewCell ()

@property (strong, nonatomic) UIImageView *screenshotImageView;
@property (strong, nonatomic) UIView *infoContainerView;
@property (strong, nonatomic) UILabel *releaseNoteTitleLabel;
@property (strong, nonatomic) UILabel *releaseNoteMessageLabel;

@end

@implementation RZFReleaseNoteCollectionViewCell

# pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if ( self ) {
        self.backgroundColor = [UIColor clearColor];
        
        [self setupScreenshotImageView];
        [self setupInfoContainerView];
    }
    
    return self;
}

# pragma mark - Setup

- (void)setupScreenshotImageView
{
    self.screenshotImageView = [[UIImageView alloc] init];
    self.screenshotImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.screenshotImageView];
    
    [self.screenshotImageView rzf_fillContainerHorizontallyWithPadding:kRZFScreenshotImageViewHorizontalPadding];
    [self.screenshotImageView rzf_pinTopSpaceToSuperviewWithPadding:kRZFScreenshotImageViewTopPadding];
    [self.screenshotImageView rzf_pinHeightTo:kRZFScreenshotImageViewHeight];
    
    self.screenshotImageView.backgroundColor = [UIColor whiteColor];
    self.screenshotImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.screenshotImageView.clipsToBounds = YES;
}

- (void)setupInfoContainerView
{
    self.infoContainerView = [[UIView alloc] init];
    self.infoContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.infoContainerView];
    
    [self.infoContainerView rzf_fillContainerHorizontallyWithPadding:kRZFInfoContainerViewHorizontalPadding];
    [self.infoContainerView rzf_pinBottomSpaceToSuperviewWithPadding:kRZFInfoContainerViewBottomPadding];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.infoContainerView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.screenshotImageView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:kRZFInfoContainerViewTopPadding]];
    
    self.infoContainerView.backgroundColor = [UIColor rzf_defaultReleaseNoteTintColor];
    
    [self setupReleaseNoteTitleLabel];
    [self setupReleaseNoteMessageLabel];
}

- (void)setupReleaseNoteTitleLabel
{
    self.releaseNoteTitleLabel = [[UILabel alloc] init];
    self.releaseNoteTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.infoContainerView addSubview:self.releaseNoteTitleLabel];
    
    [self.releaseNoteTitleLabel rzf_fillContainerHorizontallyWithPadding:kRZFReleaseNoteTitleLabelHorizontalPadding];
    [self.releaseNoteTitleLabel rzf_pinTopSpaceToSuperviewWithPadding:kRZFReleaseNoteTitleLabelTopPadding];
    
    self.releaseNoteTitleLabel.backgroundColor = [UIColor clearColor];
    self.releaseNoteTitleLabel.font = [UIFont rzf_defaultReleaseNoteTitleFont];
    self.releaseNoteTitleLabel.textColor = [UIColor rzf_defaultReleaseNoteTitleColor];
    self.releaseNoteTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.releaseNoteTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.releaseNoteTitleLabel.numberOfLines = kRZFReleaseNoteTitleLabelNumberOfLines;
    
    CGFloat height = ceil(self.releaseNoteTitleLabel.font.lineHeight * self.releaseNoteTitleLabel.numberOfLines);
    [self.releaseNoteTitleLabel rzf_pinHeightTo:height];
}

- (void)setupReleaseNoteMessageLabel
{
    self.releaseNoteMessageLabel = [[UILabel alloc] init];
    self.releaseNoteMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.infoContainerView addSubview:self.releaseNoteMessageLabel];
    
    [self.releaseNoteMessageLabel rzf_fillContainerHorizontallyWithPadding:kRZFReleaseNoteMessageLabelHorizontalPadding];
    [self.releaseNoteMessageLabel rzf_pinBottomSpaceToSuperviewWithPadding:kRZFReleaseNoteMessageLabelBottomPadding];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.releaseNoteMessageLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.releaseNoteTitleLabel
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0f
                                                      constant:kRZFReleaseNoteMessageLabelTopPadding]];
    
    self.releaseNoteMessageLabel.backgroundColor = [UIColor clearColor];
    self.releaseNoteMessageLabel.font = [UIFont rzf_defaultReleaseNoteMessageFont];
    self.releaseNoteMessageLabel.textColor = [UIColor rzf_defaultReleaseNoteMessageColor];
    self.releaseNoteMessageLabel.textAlignment = NSTextAlignmentCenter;
    self.releaseNoteMessageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.releaseNoteMessageLabel.numberOfLines = kRZFReleaseNoteMessageLabelNumberOfLines;
    
    CGFloat height = ceil(self.releaseNoteMessageLabel.font.lineHeight * self.releaseNoteMessageLabel.numberOfLines);
    [self.releaseNoteMessageLabel rzf_pinHeightTo:height];
}

- (void)setupWithFeature:(RZFFeatureViewModel *)feature
{
    self.screenshotImageView.image = feature.image;

    self.releaseNoteTitleLabel.text = feature.localizedTitle;
    self.releaseNoteMessageLabel.text = feature.localizedDescription;
}

# pragma mark - Class Methods

+ (NSString *)rzf_resuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (CGSize)rzf_sizeWithWidth:(CGFloat)width
{
    CGFloat titleHeight = ceil([UIFont rzf_defaultReleaseNoteTitleFont].lineHeight * kRZFReleaseNoteTitleLabelNumberOfLines);
    CGFloat messageHeight = ceil([UIFont rzf_defaultReleaseNoteMessageFont].lineHeight * kRZFReleaseNoteMessageLabelNumberOfLines);
    CGFloat height = kRZFScreenshotImageViewHeight + kRZFInfoContainerViewTopPadding + kRZFReleaseNoteTitleLabelTopPadding + titleHeight + kRZFReleaseNoteMessageLabelTopPadding + messageHeight + kRZFReleaseNoteMessageLabelBottomPadding;
        
    return CGSizeMake(width, height);
}

@end
