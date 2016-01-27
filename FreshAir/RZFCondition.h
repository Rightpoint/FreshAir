//
//  RZFCondition.h
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RZFCondition : NSObject

+ (NSPredicate *)predicateForConditions:(NSArray *)conditions;

@property (copy, nonatomic) NSString *key;
@property (copy, nonatomic) NSString *comparison;
@property (copy, nonatomic) NSString *value;

- (NSPredicate *)predicate;

@end
