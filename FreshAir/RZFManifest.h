//
//  RZFRemoteBundle.h
//  FreshAir
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import Foundation;

@class RZFManifestEntry;

NS_ASSUME_NONNULL_BEGIN;

@interface RZFManifest : NSObject

- (instancetype)initWithBundle:(NSBundle *)bundle;

@property (strong, nonatomic, readonly) NSBundle *bundle;

- (BOOL)isManifestLoaded;
- (BOOL)isLoadedEnvironment:(NSDictionary *)environment;

@end

NS_ASSUME_NONNULL_END;
