//
//  RZFReleaseNotes.h
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RZFReleaseNotes : NSObject

@property (strong, nonatomic) NSArray *releases;
@property (strong, nonatomic) NSURL *upgradeURL;
@property (strong, nonatomic) NSArray *forceUpgradeConditions;

@end
