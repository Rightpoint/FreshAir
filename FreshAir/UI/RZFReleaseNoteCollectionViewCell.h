//
//  RZFReleaseNoteCollectionViewCell.h
//  RZFreshAir
//
//  Created by Bradley Smith on 6/5/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

@import UIKit;

@class RZFFeatureViewModel;

@interface RZFReleaseNoteCollectionViewCell : UICollectionViewCell

+ (NSString *)rzf_resuseIdentifier;
+ (CGSize)rzf_sizeWithWidth:(CGFloat)width;

- (void)setupWithFeature:(RZFFeatureViewModel *)feature;

@end
