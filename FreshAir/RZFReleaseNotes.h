//
//  RZFReleaseNotes.h
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RZFRelease, RZFCondition, RZFFeature;

@interface RZFReleaseNotes : NSObject

+ (instancetype)releaseNotesWithURL:(NSURL *)URL error:(NSError **)error;
+ (instancetype)releaseNotesWithData:(NSData *)data error:(NSError **)error;

@property (strong, nonatomic) NSArray<RZFRelease *> *releases;
@property (strong, nonatomic) NSURL *upgradeURL;
@property (strong, nonatomic) NSString * __nullable minimumVersion;

- (BOOL)isUpgradeRequiredForVersion:(NSString *)version;

- (NSArray<RZFFeature *> *)featuresFromVersion:(NSString *)lastVersion toVersion:(NSString *)currentVersion;

@end

NS_ASSUME_NONNULL_END