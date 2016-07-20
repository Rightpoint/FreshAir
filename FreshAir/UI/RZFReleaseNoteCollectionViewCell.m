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
#import "RZFReleaseNotes.h"
#import "RZFUpgradeManager-Private.h"

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

static const CGFloat kRZFScreenshotImageViewFullScreenHorizontalPadding = 10.0f;
static const CGFloat kRZFScreenshotImageViewFullScreenTopPadding = 10.0f;
static const CGFloat kRZFScreenshotImageViewFullScreenAspectRatio = 355.0f/365.0f;

static const CGFloat kRZFReleaseNoteTitleLabelFullScreenHorizontalPadding = 15.0f;
static const CGFloat kRZFReleaseNoteTitleLabelFullScreenTopPadding = -12.0f;

static const CGFloat kRZFReleaseNoteMessageLabelFullScreenHorizontalPadding = 15.0f;
static const CGFloat kRZFReleaseNoteMessageLabelFullScreenTopPadding = 4.0f;
static const CGFloat kRZFReleaseNoteMessageLabelHeight = 140.0f;

static const NSInteger kRZFReleaseNoteMessageLabelFullScreenNumberOfLines = 0;

@interface RZFReleaseNoteCollectionViewCell ()

@property (strong, nonatomic) UIImageView *screenshotImageView;
@property (strong, nonatomic) UIView *infoContainerView;
@property (strong, nonatomic) UILabel *releaseNoteTitleLabel;
@property (strong, nonatomic) UILabel *releaseNoteMessageLabel;
@property (strong, nonatomic) UIView *notesContainer;
@property (strong, nonatomic) NSLayoutConstraint *releaseNoteMessageHeightConstraint;
@property (strong, nonatomic) RZFReleaseNotes *releaseNotes;
@property (strong, nonatomic) UIColor *accentColor;

@end

@implementation RZFReleaseNoteCollectionViewCell

# pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if ( self ) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

# pragma mark - Setup

- (void)prepareForReuse {
    [self.releaseNoteTitleLabel removeConstraints:self.releaseNoteTitleLabel.constraints];
    [self.releaseNoteTitleLabel removeFromSuperview];
    self.releaseNoteTitleLabel = nil;
    [self.releaseNoteMessageLabel removeConstraints:self.releaseNoteMessageLabel.constraints];
    [self.releaseNoteMessageLabel removeFromSuperview];
    self.releaseNoteMessageLabel = nil;
    [self.infoContainerView removeConstraints:self.infoContainerView.constraints];
    [self.infoContainerView removeFromSuperview];
    self.infoContainerView = nil;
    [self.screenshotImageView removeConstraints:self.screenshotImageView.constraints];
    [self.screenshotImageView removeFromSuperview];
    self.screenshotImageView = nil;
}

- (void)setupScreenshotImageView
{
    self.screenshotImageView = [[UIImageView alloc] init];
    self.screenshotImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.screenshotImageView];

    if ( RZFUpgradeManager.sharedInstance.fullScreenReleaseNotes ) {
        [self.screenshotImageView rzf_fillContainerHorizontallyWithPadding:kRZFScreenshotImageViewFullScreenHorizontalPadding withRelation:NSLayoutRelationLessThanOrEqual priority:UILayoutPriorityDefaultHigh];
        [self.screenshotImageView rzf_centerHorizontallyInContainer];
        [self.screenshotImageView rzf_pinAspectRatio:kRZFScreenshotImageViewFullScreenAspectRatio];
        [self.screenshotImageView rzf_pinTopSpaceToSuperviewWithPadding:kRZFScreenshotImageViewFullScreenTopPadding];


        self.screenshotImageView.backgroundColor = [UIColor clearColor];
        self.screenshotImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    else {
        [self.screenshotImageView rzf_fillContainerHorizontallyWithPadding:kRZFScreenshotImageViewHorizontalPadding];
        [self.screenshotImageView rzf_pinTopSpaceToSuperviewWithPadding:kRZFScreenshotImageViewTopPadding];
        [self.screenshotImageView rzf_pinHeightTo:kRZFScreenshotImageViewHeight];

        self.screenshotImageView.backgroundColor = [UIColor whiteColor];
        self.screenshotImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
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

    if ( RZFUpgradeManager.sharedInstance.releaseNotesAccentColor ) {
        self.infoContainerView.backgroundColor = RZFUpgradeManager.sharedInstance.releaseNotesAccentColor;
    }
    else {
        self.infoContainerView.backgroundColor = [UIColor rzf_defaultReleaseNoteTintColor];
    }

    [self setupReleaseNoteTitleLabel];
    [self setupReleaseNoteMessageLabel];
}

- (void)setupReleaseNoteTitleLabel
{
    self.releaseNoteTitleLabel = [[UILabel alloc] init];
    self.releaseNoteTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.infoContainerView addSubview:self.releaseNoteTitleLabel];

    if ( RZFUpgradeManager.sharedInstance.fullScreenReleaseNotes ) {
        [self.releaseNoteTitleLabel rzf_fillContainerHorizontallyWithPadding:kRZFReleaseNoteTitleLabelFullScreenHorizontalPadding];
    }
    else {
        [self.releaseNoteTitleLabel rzf_fillContainerHorizontallyWithPadding:kRZFReleaseNoteTitleLabelHorizontalPadding];
    }

    self.releaseNoteTitleLabel.backgroundColor = [UIColor clearColor];
    self.releaseNoteTitleLabel.textColor = [UIColor rzf_defaultReleaseNoteTitleColor];
    self.releaseNoteTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.releaseNoteTitleLabel.numberOfLines = kRZFReleaseNoteTitleLabelNumberOfLines;
    self.releaseNoteTitleLabel.adjustsFontSizeToFitWidth = YES;

    if ( RZFUpgradeManager.sharedInstance.fullScreenReleaseNotes ) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.screenshotImageView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.releaseNoteTitleLabel
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0f
                                                          constant:kRZFReleaseNoteTitleLabelFullScreenTopPadding]];


        self.releaseNoteTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    else {
        [self.releaseNoteTitleLabel rzf_pinTopSpaceToSuperviewWithPadding:kRZFReleaseNoteTitleLabelTopPadding];
        self.releaseNoteTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }


    if ( RZFUpgradeManager.sharedInstance.releaseNotesTitleFont ) {
        self.releaseNoteTitleLabel.font = RZFUpgradeManager.sharedInstance.releaseNotesTitleFont;
    }
    else {
        self.releaseNoteTitleLabel.font = [UIFont rzf_defaultReleaseNoteTitleFont];
    }


    CGFloat height = ceil(self.releaseNoteTitleLabel.font.lineHeight * self.releaseNoteTitleLabel.numberOfLines);
    [self.releaseNoteTitleLabel rzf_pinHeightTo:height];
}

- (void)setupReleaseNoteMessageLabel
{
    self.releaseNoteMessageLabel = [[UILabel alloc] init];
    self.releaseNoteMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;

    if ( RZFUpgradeManager.sharedInstance.fullScreenReleaseNotes ) {
        self.notesContainer = [[UIView alloc] init];
        self.notesContainer.translatesAutoresizingMaskIntoConstraints = NO;

        [self.infoContainerView addSubview:self.notesContainer];

        [self.notesContainer rzf_fillContainerHorizontallyWithPadding:kRZFReleaseNoteMessageLabelFullScreenHorizontalPadding];
        [self.notesContainer rzf_pinBottomSpaceToSuperviewWithPadding:kRZFReleaseNoteMessageLabelBottomPadding];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.notesContainer
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.releaseNoteTitleLabel
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0f
                                                          constant:kRZFReleaseNoteMessageLabelFullScreenTopPadding]];


        [self.notesContainer addSubview:self.releaseNoteMessageLabel];

        [self.releaseNoteMessageLabel rzf_pinTopSpaceToSuperviewWithPadding:0.0f];
        [self.releaseNoteMessageLabel rzf_fillContainerHorizontallyWithPadding:0.0f];

        [self.infoContainerView addConstraint:[NSLayoutConstraint
                                               constraintWithItem:self.notesContainer
                                               attribute:NSLayoutAttributeBottom
                                               relatedBy:NSLayoutRelationGreaterThanOrEqual
                                               toItem:self.releaseNoteMessageLabel
                                               attribute:NSLayoutAttributeBottom
                                               multiplier:1.0f
                                               constant:0.0f]];
    }
    else {
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
        

    }

    self.releaseNoteMessageLabel.backgroundColor = [UIColor clearColor];
    if ( RZFUpgradeManager.sharedInstance.releaseNotesTitleFont ) {
        self.releaseNoteMessageLabel.font = RZFUpgradeManager.sharedInstance.releaseNotesTitleFont;
    }
    else {
        self.releaseNoteMessageLabel.font = [UIFont rzf_defaultReleaseNoteMessageFont];
    }
    self.releaseNoteMessageLabel.textColor = [UIColor rzf_defaultReleaseNoteMessageColor];
    self.releaseNoteMessageLabel.textAlignment = NSTextAlignmentCenter;
    self.releaseNoteMessageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.releaseNoteMessageLabel.numberOfLines = (RZFUpgradeManager.sharedInstance.fullScreenReleaseNotes ? kRZFReleaseNoteMessageLabelFullScreenNumberOfLines : kRZFReleaseNoteMessageLabelNumberOfLines);

    if ( RZFUpgradeManager.sharedInstance.fullScreenReleaseNotes ) {
        self.releaseNoteMessageHeightConstraint = [self.notesContainer rzf_pinHeightTo:kRZFReleaseNoteMessageLabelHeight withRelation:NSLayoutRelationGreaterThanOrEqual];
    }
    else {
        CGFloat height = ceilf((float)self.releaseNoteMessageLabel.font.lineHeight * (float)self.releaseNoteMessageLabel.numberOfLines);
        [self.releaseNoteMessageLabel rzf_pinHeightTo:height];
    }
}

- (void)setupWithFeature:(RZFFeatureViewModel *)feature releaseNotes:(RZFReleaseNotes *)releaseNotes
{
    self.releaseNotes = releaseNotes;
    self.accentColor = [RZFUpgradeManager sharedInstance].releaseNotesAccentColor;
    [self setupScreenshotImageView];
    [self setupInfoContainerView];

    self.screenshotImageView.image = feature.image;

    self.releaseNoteTitleLabel.text = feature.localizedTitle;
    if ( feature.localizedAttributedDescription ) {
        self.releaseNoteMessageLabel.attributedText = feature.localizedAttributedDescription;
    }
    else {
        self.releaseNoteMessageLabel.text = feature.localizedDescription;
    }

}

# pragma mark - Class Methods

+ (NSString *)rzf_reuseIdentifierFullScreen:(BOOL)fullscreen
{
    return [NSString stringWithFormat:@"%@%@",NSStringFromClass([self class]), ( fullscreen ? @"fullscreen": @"")];
}

+ (CGSize)rzf_sizeWithWidth:(CGFloat)width
{
    CGFloat titleHeight = ceil([UIFont rzf_defaultReleaseNoteTitleFont].lineHeight * kRZFReleaseNoteTitleLabelNumberOfLines);
    CGFloat messageHeight = ceil([UIFont rzf_defaultReleaseNoteMessageFont].lineHeight * kRZFReleaseNoteMessageLabelNumberOfLines);
    CGFloat height = kRZFScreenshotImageViewHeight + kRZFInfoContainerViewTopPadding + kRZFReleaseNoteTitleLabelTopPadding + titleHeight + kRZFReleaseNoteMessageLabelTopPadding + messageHeight + kRZFReleaseNoteMessageLabelBottomPadding;
        
    return CGSizeMake(width, height);
}

@end
