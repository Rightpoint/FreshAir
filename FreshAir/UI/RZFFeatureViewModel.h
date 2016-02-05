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

@property (strong, nonatomic) NSString *localizedTitle;
@property (strong, nonatomic) NSString *localizedDescription;
@property (strong, nonatomic) UIImage *image;

@end
