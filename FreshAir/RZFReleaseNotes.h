//
//  RZFReleaseNotes.h
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN;

@class RZFRelease, RZFCondition;

@interface RZFReleaseNotes : NSObject

@property (strong, nonatomic) NSArray<RZFRelease *> *releases;
@property (strong, nonatomic) NSURL *upgradeURL;
@property (strong, nonatomic) NSString * __nullable minimumVersion;
@property (strong, nonatomic, readonly) NSString *lastVersion;

- (BOOL)isUpgradeAvailableForVersion:(NSString *)version;
- (BOOL)isUpgradeRequiredForVersion:(NSString *)version;

@end

NS_ASSUME_NONNULL_END;