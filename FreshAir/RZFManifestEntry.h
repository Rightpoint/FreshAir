//
//  RZFManifestEntry.h
//  FreshAir
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN;

@interface RZFManifestEntry : NSObject

@property (copy, nonatomic) NSArray *conditions;
@property (copy, nonatomic) NSString *filename;
@property (copy, nonatomic) NSString * __nullable sha;

- (BOOL)isApplicableInEnvironment:(NSDictionary *)environment;
- (BOOL)isLoadedInBundle:(NSBundle *)bundle;
- (NSString * __nullable)shaInBundle:(NSBundle *)bundle;

@end

NS_ASSUME_NONNULL_END;
