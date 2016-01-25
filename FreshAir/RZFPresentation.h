//
//  RZFPresentation.h
//  FreshAir
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import Foundation;
@class UIViewController;

@interface RZFPresentation : NSObject

+ (instancetype)presentationFromBundle:(NSBundle *)bundle;

@property (strong, nonatomic, readonly) UIViewController *viewController;

@end
