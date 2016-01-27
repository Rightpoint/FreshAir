//
//  RZFManifestEntry.h
//  FreshAir
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import Foundation;

@interface RZFManifestEntry : NSObject

@property (copy, nonatomic) NSArray *conditions;
@property (copy, nonatomic) NSString *filename;
@property (copy, nonatomic) NSString *sha;

- (BOOL)isApplicableInEnvironment:(NSDictionary *)environment;
- (BOOL)isLoadedInBundle:(NSBundle *)bundle;

@end
