//
//  NSObject+RZFUtility.h
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (RZFUtility)

- (NSArray *)map:(id(^)(id))transform;

@end

NS_ASSUME_NONNULL_END
