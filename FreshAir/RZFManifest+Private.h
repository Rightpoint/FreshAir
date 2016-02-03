//
//  RZFManifest+Private.h
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFManifest.h"
#import "RZFManifestEntry.h"

NS_ASSUME_NONNULL_BEGIN

@interface RZFManifest (RZFUtility)

@property (copy, nonatomic, readonly) NSArray<RZFManifestEntry *> * __nullable entries;

- (BOOL)loadEntriesError:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
