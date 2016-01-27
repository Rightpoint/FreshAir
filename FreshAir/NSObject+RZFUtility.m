//
//  NSObject+RZFUtility.m
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "NSObject+RZFUtility.h"

@implementation NSArray (RZFUtility)

- (NSArray *)map:(id(^)(id))transform
{
    NSMutableArray *result = [NSMutableArray array];
    for (id obj in self) {
        [result addObject:transform(obj)];
    }
    return [result copy];
}

@end
