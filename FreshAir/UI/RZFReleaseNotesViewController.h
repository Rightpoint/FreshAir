//
//  RZFReleaseNotesViewController.h
//  RZFreshAir
//
//  Created by Bradley Smith on 6/5/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

@import UIKit;

#import "RZFViewController.h"

@class RZFReleaseNotesViewController;
@class RZFFeature;
@class RZFReleaseNotes;

@protocol RZFReleaseNotesViewControllerDelegate <NSObject>

- (void)didSelectDoneForReleaseNotesViewController:(RZFReleaseNotesViewController *)releaseNotesViewController;

@end

@interface RZFReleaseNotesViewController : RZFViewController

- (instancetype)initWithFeatures:(NSArray<RZFFeature *> *)features releaseNotes:(RZFReleaseNotes *)releaseNotes;

@property (weak, nonatomic, readwrite) id <RZFReleaseNotesViewControllerDelegate> delegate;

@end
