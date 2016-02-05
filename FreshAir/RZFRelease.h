//
//  RZFRelease.h
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RZFFeature, RZFCondition;

@interface RZFRelease : NSObject

@property (copy, nonatomic) NSString *version;
@property (copy, nonatomic) NSString *systemVersion;
@property (strong, nonatomic) NSArray<RZFFeature *> *features;

@end

NS_ASSUME_NONNULL_END
