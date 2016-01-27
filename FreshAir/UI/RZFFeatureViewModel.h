//
//  RZFUIFeature.h
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import UIKit;
@class RZFFeature;

@interface RZFFeatureViewModel : NSObject

- (instancetype)initWithFeature:(RZFFeature *)feature bundle:(NSBundle *)bundle;

@property (strong, nonatomic, readonly) NSString *localizedTitle;
@property (strong, nonatomic, readonly) NSString *localizedDescription;
@property (strong, nonatomic, readonly) UIImage *image;

@end
