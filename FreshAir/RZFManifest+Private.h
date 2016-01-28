//
//  RZFManifest+Private.h
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFManifest.h"

@interface RZFManifest (RZFUtility)

@property (copy, nonatomic, readonly) NSArray<RZFManifestEntry *> *entries;

- (BOOL)loadEntriesError:(NSError **)error;

@end
