//
//  RZFUpdatePromptView.h
//  RZFreshAir
//
//  Created by Bradley Smith on 5/26/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

@import UIKit;

@class RZFUpdatePromptView, RZFUpdateViewModel;

@protocol RZFUpdatePromptViewDelegate <NSObject>

- (void)didSelectDeclineForUpdatePromptView:(RZFUpdatePromptView *)updatePromptView;
- (void)didSelectConfirmForUpdatePromptView:(RZFUpdatePromptView *)updatePromptView;

@end

@interface RZFUpdatePromptView : UIView

- (instancetype)initWithViewModel:(RZFUpdateViewModel *)viewModel;

@property (weak, nonatomic, readwrite) id <RZFUpdatePromptViewDelegate> delegate;

@end
