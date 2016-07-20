//
//  RZFReleaseNotesView.h
//  RZFreshAir
//
//  Created by Bradley Smith on 6/5/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

@import UIKit;

@class RZFFeatureViewModel, RZFReleaseNotesView, RZFReleaseNotes;

@protocol RZFReleaseNotesViewDelegate <NSObject>

- (void)didSelectDoneForReleaseNotesView:(RZFReleaseNotesView *)releaseNotesView;

@end

@interface RZFReleaseNotesView : UIView

- (instancetype)initWithFeatures:(NSArray<RZFFeatureViewModel *> *)features releaseNotes:(RZFReleaseNotes *)releaseNotes;

@property (weak, nonatomic, readwrite) id <RZFReleaseNotesViewDelegate> delegate;

@end
