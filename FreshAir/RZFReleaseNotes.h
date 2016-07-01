//
//  RZFReleaseNotes.h
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RZFRelease, RZFFeature, RZFDoneButtonConfiguration, RZFAlphaColor;

@interface RZFReleaseNotes : NSObject

+ (instancetype)releaseNotesWithURL:(NSURL *)URL error:(NSError **)error;
+ (instancetype)releaseNotesWithData:(NSData *)data error:(NSError **)error;

@property (strong, nonatomic) NSArray<RZFRelease *> *releases;
@property (strong, nonatomic) NSURL *upgradeURL;
@property (strong, nonatomic, nullable) NSString *minimumVersion;
@property (strong, nonatomic, readonly) NSArray<RZFFeature *> *features;

@property (assign, nonatomic) BOOL fullScreen;
@property (strong, nonatomic) RZFAlphaColor *accentColor;
@property (strong, nonatomic, nullable) RZFDoneButtonConfiguration *doneConfiguration;

@property (strong, nonatomic, nullable) NSString *titleFontName;
@property (strong, nonatomic, nullable) NSString *titleFontSize;

- (BOOL)isUpgradeRequiredForVersion:(NSString *)version;

- (NSArray<RZFRelease *> *)releasesSupportingSystemVersion:(NSString *)systemVersion;
- (NSArray<RZFFeature *> *)featuresFromVersion:(NSString *)lastVersion toVersion:(NSString *)currentVersion;

@end

NS_ASSUME_NONNULL_END