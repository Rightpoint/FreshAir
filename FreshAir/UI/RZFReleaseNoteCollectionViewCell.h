//
//  RZFReleaseNoteCollectionViewCell.h
//  RZFreshAir
//
//  Created by Bradley Smith on 6/5/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

@import UIKit;

@class RZFFeatureViewModel, RZFReleaseNotes;

@interface RZFReleaseNoteCollectionViewCell : UICollectionViewCell

+ (NSString *)rzf_reuseIdentifierFullScreen:(BOOL)fullscreen;
+ (CGSize)rzf_sizeWithWidth:(CGFloat)width;

- (void)setupWithFeature:(RZFFeatureViewModel *)feature releaseNotes:(RZFReleaseNotes *)releaseNotes;

@end
