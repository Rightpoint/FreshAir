//
//  RZFRelease.h
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RZFRelease : NSObject

@property (copy, nonatomic) NSString *version;
@property (copy, nonatomic) NSString *condition;
@property (strong, nonatomic) NSArray *features;

- (NSString *)conditionWithVersionComparison;

@end
