//
//  RZFCondition.m
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFCondition.h"

@implementation RZFCondition

+ (NSPredicate *)predicateForConditions:(NSArray *)conditions
{
    if (conditions) {
        NSArray *conditionParts = [conditions valueForKey:@"predicate"];
        return [NSCompoundPredicate andPredicateWithSubpredicates:conditionParts];
    }
    else {
        return [NSPredicate predicateWithValue:YES];
    }
}

- (NSString *)predicateComparison
{
    if ([self.comparison isEqual:@"eq"]) {
        return @"==";
    }
    else if ([self.comparison isEqual:@"gt"]) {
        return @">";
    }
    else if ([self.comparison isEqual:@"gte"]) {
        return @">=";
    }
    else if ([self.comparison isEqual:@"lt"]) {
        return @"<";
    }
    else if ([self.comparison isEqual:@"lte"]) {
        return @"<=";
    }
    [NSException raise:NSInvalidArgumentException format:@"Unsupported comparison: %@", self.comparison];
    return nil;
}

- (NSPredicate *)predicate
{
    NSString *predicateString = [NSString stringWithFormat:@"%@ %@ '%@'", self.key, self.predicateComparison, self.value];
    return [NSPredicate predicateWithFormat:predicateString];
}

@end
