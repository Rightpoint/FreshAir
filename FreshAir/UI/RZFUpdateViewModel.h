//
//  RZFUpdateViewModel.h
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import UIKit;

@class RZFReleaseNotes;

@interface RZFUpdateViewModel : NSObject

- (instancetype)init;

@property (copy, nonatomic) NSString *localizedTitle;
@property (copy, nonatomic) NSString *localizedDescription;
@property (strong, nonatomic) UIImage *image;

@property (copy, nonatomic) NSString *localizedConfirmation;
@property (copy, nonatomic) NSString *localizedDismiss;
@property (assign, nonatomic) BOOL isForced;

@end
