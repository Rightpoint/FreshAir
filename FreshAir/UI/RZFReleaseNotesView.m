//
//  RZFReleaseNotesView.m
//  RZFreshAir
//
//  Created by Bradley Smith on 6/5/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "RZFReleaseNotesView.h"
#import "RZFReleaseNoteCollectionViewCell.h"
#import "UIView+RZFAutoLayout.h"
#import "UIColor+RZFStyle.h"
#import "UIFont+RZFStyle.h"
#import "RZFFeatureViewModel.h"
#import "RZFReleaseNotes.h"
#import "RZFUpgradeManager-Private.h"

static NSString * const kRZFDefaultDoneButtonTitle = @"Check it out";

static const CGFloat kRZFReleaseNotesViewCornerRadius = 5.0f;

static const CGFloat kRZFFeatureCollectionViewHorizontalPadding = 0.0f;
static const CGFloat kRZFFeatureCollectionViewTopPadding = 0.0f;

static const CGFloat kRZFFeaturePageControlTopPadding = 255.0f;

static const CGFloat kRZFDoneButtonHorizontalPadding = 0.0f;
static const CGFloat kRZFDoneButtonBottomPadding = 0.0f;
static const CGFloat kRZFDoneButtonTopPadding = 0.0f;
static const CGFloat kRZFDoneButtonHeight = 64.0f;

static const CGFloat kRZFDoneButtonFullScreenHorizontalPadding = 6.0f;
static const CGFloat kRZFDoneButtonFullScreenBottomPadding = 6.0f;
static const CGFloat kRZFDoneButtonFullScreenHeight = 54.0f;
static const CGFloat kRZFDoneButtonFullScreenTopPadding = 6.0f;

@interface RZFReleaseNotesView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *featureCollectionView;
@property (strong, nonatomic) UIPageControl *featurePageControl;
@property (strong, nonatomic) UIButton *doneButton;
@property (strong, nonatomic) NSArray<RZFFeatureViewModel *> *features;

@property (strong, nonatomic) RZFReleaseNotes *releaseNotes;

@property (strong, nonatomic) UIColor *accentColor;

@end

@implementation RZFReleaseNotesView

# pragma mark - Lifecycle

- (instancetype)initWithFeatures:(NSArray<RZFFeatureViewModel *> *)features releaseNotes:(RZFReleaseNotes *)releaseNotes
{
    self = [self init];
    
    if ( self ) {
        self.features = features;
        self.releaseNotes = releaseNotes;

        self.translatesAutoresizingMaskIntoConstraints = NO;
        if ( RZFUpgradeManager.sharedInstance.releaseNotesAccentColor ) {
            self.accentColor = RZFUpgradeManager.sharedInstance.releaseNotesAccentColor;
        }
        else {
            self.accentColor = [UIColor whiteColor];
        }
        self.backgroundColor = self.accentColor;
        if ( !RZFUpgradeManager.sharedInstance.fullScreenReleaseNotes ) {
            self.layer.cornerRadius = kRZFReleaseNotesViewCornerRadius;
        }
        self.clipsToBounds = YES;
        
        [self setupFeatureCollectionView];
        [self setupFeaturePageControl];
        [self setupDoneButton];
        self.featurePageControl.numberOfPages = [features count];
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.featureCollectionView.collectionViewLayout;
    if ( RZFUpgradeManager.sharedInstance.fullScreenReleaseNotes ) {
        flowLayout.itemSize = self.featureCollectionView.frame.size;
    }
    else {
        flowLayout.itemSize = [RZFReleaseNoteCollectionViewCell rzf_sizeWithWidth:CGRectGetWidth(self.featureCollectionView.frame)];
    }
    [self.featureCollectionView rzf_pinHeightTo:flowLayout.itemSize.height];
    [self.featureCollectionView reloadData];
}

# pragma mark - Setup

- (void)setupFeatureCollectionView
{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsZero;
    flowLayout.minimumInteritemSpacing = 0.0f;
    flowLayout.minimumLineSpacing = 0.0f;
    
    self.featureCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.featureCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.featureCollectionView];
    
    [self.featureCollectionView rzf_fillContainerHorizontallyWithPadding:kRZFFeatureCollectionViewHorizontalPadding];
    [self.featureCollectionView rzf_pinTopSpaceToSuperviewWithPadding:kRZFFeatureCollectionViewTopPadding];
    if ( RZFUpgradeManager.sharedInstance.releaseNotesAccentColor ) {
        self.featureCollectionView.backgroundColor = RZFUpgradeManager.sharedInstance.releaseNotesAccentColor;
    }
    else {
        self.featureCollectionView.backgroundColor = [UIColor rzf_defaultReleaseNoteTintColor];
    }
    self.featureCollectionView.delegate = self;
    self.featureCollectionView.dataSource = self;
    self.featureCollectionView.pagingEnabled = YES;
    self.featureCollectionView.showsHorizontalScrollIndicator = NO;
    [self.featureCollectionView registerClass:[RZFReleaseNoteCollectionViewCell class]
                   forCellWithReuseIdentifier:[RZFReleaseNoteCollectionViewCell rzf_reuseIdentifierFullScreen:YES]];
    [self.featureCollectionView registerClass:[RZFReleaseNoteCollectionViewCell class]
                   forCellWithReuseIdentifier:[RZFReleaseNoteCollectionViewCell rzf_reuseIdentifierFullScreen:NO]];
}

- (void)setupFeaturePageControl
{
    self.featurePageControl = [[UIPageControl alloc] init];
    self.featurePageControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.featurePageControl];
    
    [self.featurePageControl rzf_centerHorizontallyInContainer];

    if ( !RZFUpgradeManager.sharedInstance.fullScreenReleaseNotes ) {
        [self.featurePageControl rzf_pinTopSpaceToSuperviewWithPadding:kRZFFeaturePageControlTopPadding];
    }
    self.featurePageControl.backgroundColor = [UIColor clearColor];
    self.featurePageControl.currentPage = 0;
    self.featurePageControl.hidesForSinglePage = YES;
    self.featurePageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
    self.featurePageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    self.featurePageControl.userInteractionEnabled = NO;
}

- (void)setupDoneButton
{
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.doneButton];

    if ( RZFUpgradeManager.sharedInstance.fullScreenReleaseNotes ) {
        [self.doneButton rzf_fillContainerHorizontallyWithPadding:kRZFDoneButtonFullScreenHorizontalPadding];
        [self.doneButton rzf_pinBottomSpaceToSuperviewWithPadding:kRZFDoneButtonFullScreenBottomPadding];
        [self.doneButton rzf_pinHeightTo:kRZFDoneButtonFullScreenHeight];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.doneButton
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.featureCollectionView
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0f
                                                          constant:kRZFDoneButtonFullScreenTopPadding]];

    }
    else {
        [self.doneButton rzf_fillContainerHorizontallyWithPadding:kRZFDoneButtonHorizontalPadding];
        [self.doneButton rzf_pinBottomSpaceToSuperviewWithPadding:kRZFDoneButtonBottomPadding];
        [self.doneButton rzf_pinHeightTo:kRZFDoneButtonHeight];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.doneButton
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.featureCollectionView
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0f
                                                          constant:kRZFDoneButtonTopPadding]];
    }

    if ( RZFUpgradeManager.sharedInstance.fullScreenReleaseNotes ) {
        [self rzf_spaceSubviews:@[self.featurePageControl,self.doneButton] vertically:YES itemSpacing:-4.0f relation:NSLayoutRelationEqual];
    }



    if ( RZFUpgradeManager.sharedInstance.releaseNotesDoneBackgroundColor ) {
        self.doneButton.backgroundColor = RZFUpgradeManager.sharedInstance.releaseNotesDoneBackgroundColor;
    }
    else {
        self.doneButton.backgroundColor = [UIColor rzf_defaultReleaseNoteTintColor];
    }

    
    if ( RZFUpgradeManager.sharedInstance.releaseNotesDoneFont ) {
        self.doneButton.titleLabel.font = RZFUpgradeManager.sharedInstance.releaseNotesDoneFont;
    }
    else {
        self.doneButton.titleLabel.font = [UIFont rzf_defaultReleaseNoteButtonFont];
    }

    if ( RZFUpgradeManager.sharedInstance.releaseNotesAccentColor ) {
        [self.doneButton setTitleColor:RZFUpgradeManager.sharedInstance.releaseNotesAccentColor forState:UIControlStateNormal];
        [self.doneButton setTitleColor:[RZFUpgradeManager.sharedInstance.releaseNotesAccentColor colorWithAlphaComponent:RZFUpgradeManager.sharedInstance.releaseNotesDoneHighlightAlpha] forState:UIControlStateHighlighted];
    }
    else {
        [self.doneButton setTitleColor:[UIColor rzf_defaultReleaseNoteButtonTitleColorNormal] forState:UIControlStateNormal];
        [self.doneButton setTitleColor:[UIColor rzf_defaultReleaseNoteButtonTitleColorPressed] forState:UIControlStateHighlighted];
    }

    if ( RZFUpgradeManager.sharedInstance.releaseNotesDoneCornerRadius ) {
        self.doneButton.layer.cornerRadius = RZFUpgradeManager.sharedInstance.releaseNotesDoneCornerRadius;
    }

    [self.doneButton setTitle:(RZFUpgradeManager.sharedInstance.releaseNotesDoneTitle ?: kRZFDefaultDoneButtonTitle) forState:UIControlStateNormal];

    [self.doneButton addTarget:self
                        action:@selector(doneButtonTapped)
              forControlEvents:UIControlEventTouchUpInside];
}

# pragma mark - Actions

- (void)doneButtonTapped
{
    if ( [self.delegate respondsToSelector:@selector(didSelectDoneForReleaseNotesView:)] ) {
        [self.delegate didSelectDoneForReleaseNotesView:self];
    }
}

# pragma mark - Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.features count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RZFReleaseNoteCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[RZFReleaseNoteCollectionViewCell rzf_reuseIdentifierFullScreen:RZFUpgradeManager.sharedInstance.fullScreenReleaseNotes]
                                                                                       forIndexPath:indexPath];
    RZFFeatureViewModel *feature = self.features[indexPath.item];
    [cell setupWithFeature:feature releaseNotes:self.releaseNotes];
    if ( RZFUpgradeManager.sharedInstance.releaseNotesAccentColor ) {
        cell.backgroundColor = RZFUpgradeManager.sharedInstance.releaseNotesAccentColor;
    }
    return cell;
}

# pragma mark - Scroll View Delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ( scrollView == self.featureCollectionView ) {
        CGFloat itemWidth = ((UICollectionViewFlowLayout *)self.featureCollectionView.collectionViewLayout).itemSize.width;
        NSInteger page = floor(scrollView.contentOffset.x / itemWidth);
        
        self.featurePageControl.currentPage = page;
    }
}

@end
