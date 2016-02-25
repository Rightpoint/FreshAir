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
@property (assign, nonatomic) BOOL isForced;

@property (strong, nonatomic, readonly) UIImage *image;
@property (copy, nonatomic, readonly) NSString *localizedTitle;
@property (copy, nonatomic, readonly) NSString *localizedDescription;
@property (copy, nonatomic, readonly) NSString *localizedConfirmation;
@property (copy, nonatomic, readonly) NSString *localizedDismiss;

@end
