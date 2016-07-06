//
//  RZFUpgradeManager-Private.h
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import UIKit;

#import "RZFUpgradeManager.h"

@protocol RZFInteractionDelegate;

@interface RZFUpgradeManager (Private)

/**
 *  Provided for RZF to be able to reference configured style items
 *
 *  @return The shared upgrade manager instance
 */
+ (instancetype)sharedInstance;

@end
