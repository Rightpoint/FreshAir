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

@protocol RZFReleaseNotesViewControllerDelegate <NSObject>

- (void)didSelectDoneForReleaseNotesViewController:(RZFReleaseNotesViewController *)ReleaseNotesViewController;

@end

@interface RZFReleaseNotesViewController : RZFViewController

- (instancetype)initWithFeatures:(NSArray<RZFFeature *> *)features bundle:(NSBundle *)bundle;

@property (weak, nonatomic, readwrite) id <RZFReleaseNotesViewControllerDelegate> delegate;

@end
