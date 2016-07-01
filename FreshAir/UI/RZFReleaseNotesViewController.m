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
#import "RZFFeatureViewModel.h"
#import "RZFFeature.h"
#import "RZFReleaseNotes.h"

@interface RZFViewController ()

@property (strong, nonatomic, readwrite) UIView *tintView;
@property (strong, nonatomic, readwrite) RZFSlideAnimationController *slideAnimationController;

@end

@interface RZFReleaseNotesViewController () <RZFReleaseNotesViewDelegate>

@property (strong, nonatomic, readwrite) RZFReleaseNotesView *releaseNotesView;
@property (strong, nonatomic) NSArray<RZFFeature *> *features;
@property (strong, nonatomic) RZFReleaseNotes *releaseNotes;

@end

@implementation RZFReleaseNotesViewController

# pragma mark - Lifecycle

- (instancetype)initWithFeatures:(NSArray<RZFFeature *> *)features releaseNotes:(RZFReleaseNotes *)releaseNotes;
{
    self = [super initWithNibName:nil bundle:nil];
    
    if ( self ) {
        self.features = features;
        self.releaseNotes = releaseNotes;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self setupReleaseNotesView];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

# pragma mark - Setup

- (CGFloat)horizontalPadding {
    if ( self.releaseNotes.fullScreen == YES ) {
        return 0.0f;
    }
    else {
        return 20.0f;
    }
}

- (NSArray *)attributedItemsForPrefix:(NSString *)prefix {
    NSInteger descriptionIndex = 1;

    NSString *currentKeyForIndex;
    NSString *currentValueForIndex;
    NSMutableArray *attributedDescriptions = [NSMutableArray array];

    do {
        currentKeyForIndex = [NSString stringWithFormat:@"%@.%d", prefix, descriptionIndex];

        currentValueForIndex = [self.nibBundle localizedStringForKey:currentKeyForIndex value:nil table:nil];

        if (currentValueForIndex != nil && currentValueForIndex != currentKeyForIndex) {
            [attributedDescriptions addObject:currentValueForIndex];
            descriptionIndex += 1;
        }
    } while (currentValueForIndex != nil && currentValueForIndex != currentKeyForIndex);
    return attributedDescriptions;
}

- (void)setupReleaseNotesView
{
    NSMutableArray *featureViewModels = [NSMutableArray array];
    for (RZFFeature *feature in self.features) {
        RZFFeatureViewModel *featureVM = [[RZFFeatureViewModel alloc] init];
        featureVM.localizedTitle = [self.nibBundle localizedStringForKey:feature.localizedTitleKey value:nil table:nil];
        NSArray *descriptionStrings = [self attributedItemsForPrefix:feature.localizedAttributedDescriptionPrefixKey];
        NSArray *fontNames = [self attributedItemsForPrefix:feature.localizedFontNamePrefixKey];
        NSArray *fontSizes = [self attributedItemsForPrefix:feature.localizedFontSizePrefixKey];
        featureVM.localizedDescription = [descriptionStrings componentsJoinedByString:@"\n\n"];

        if ( descriptionStrings.count > 0 && fontNames.count == descriptionStrings.count && fontSizes.count == descriptionStrings.count ) {

            NSAttributedString *descriptionAttributedString = [self.class attributedStringFromStringArray:descriptionStrings fontArray:fontNames sizeArray:fontSizes];
            featureVM.localizedAttributedDescription = descriptionAttributedString;
        }
        else {
            featureVM.localizedDescription = [self.nibBundle localizedStringForKey:feature.localizedDescriptionKey value:nil table:nil];
        }

        featureVM.image = [UIImage imageNamed:feature.localizedImageKey];

        // Grab the jpg image if there's no PNG with a matching name.
        if (featureVM.image == nil) {
            featureVM.image = [UIImage imageNamed:[feature.localizedImageKey stringByAppendingString:@".jpg"]];
        }
        [featureViewModels addObject:featureVM];
    }
    self.releaseNotesView = [[RZFReleaseNotesView alloc] initWithFeatures:featureViewModels releaseNotes:self.releaseNotes];
    self.releaseNotesView.delegate = self;
    [self.view addSubview:self.releaseNotesView];
    self.contentView = self.releaseNotesView;
    
    CGFloat padding;
    if ( [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ) {
        padding = CGRectGetWidth([UIScreen mainScreen].bounds) / 5.0f;
    }
    else {
        padding = [self horizontalPadding];
    }
    
    [self.releaseNotesView rzf_fillContainerHorizontallyWithPadding:padding];
    [self.releaseNotesView rzf_fillContainerVerticallyWithPadding:padding];

    if ( !self.releaseNotes.fullScreen ) {
        [self.releaseNotesView rzf_centerVerticallyInContainer];
    }
}

# pragma mark - Release Notes View Delegate

- (void)didSelectDoneForReleaseNotesView:(RZFReleaseNotesView *)releaseNotesView
{
    if ( [self.delegate respondsToSelector:@selector(didSelectDoneForReleaseNotesViewController:)] ) {
        [self.delegate didSelectDoneForReleaseNotesViewController:self];
    }
}

+ (NSAttributedString *)attributedStringFromStringArray:(NSArray *)stringArray fontArray:(NSArray *)fontArray sizeArray:(NSArray *)sizeArray {

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];

    for ( int currentStringIndex = 0; currentStringIndex < stringArray.count; currentStringIndex++ ) {
        NSString *currentString = stringArray[currentStringIndex];
        NSString *fontName = fontArray[currentStringIndex];
        NSString *fontSize = sizeArray[currentStringIndex];

        NSString *adjustedString = ( currentStringIndex < stringArray.count -1 ? [NSString stringWithFormat:@"%@\n", currentString ] : currentString );

        NSDictionary *extractedAttributes = @{
                                              NSFontAttributeName: [UIFont fontWithName:fontName size:fontSize.floatValue],
                                              };

        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:adjustedString attributes:extractedAttributes]];
    }
    
    return attributedString;
}

@end
