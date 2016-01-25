//
//  RZFManifestEntry.h
//  FreshAir
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import Foundation;

@interface RZFManifestEntry : NSObject

- (instancetype)initWithJSONObject:(NSDictionary *)jsonObject;

@property (copy, nonatomic, readonly) NSString *condition;
@property (copy, nonatomic, readonly) NSString *filename;
@property (copy, nonatomic, readonly) NSString *SHA;

- (BOOL)isApplicableInEnvironment:(NSDictionary *)environment;
- (BOOL)isLoadedInBundle:(NSBundle *)bundle;

@end
