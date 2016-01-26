//
//  RZFFeature.h
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RZFFeature : NSObject

@property (copy, nonatomic) NSString *key;
@property (copy, nonatomic) NSString *condition;

- (NSString *)localizedTitleKey;
- (NSString *)localizedDescriptionKey;
- (NSString *)localizedImageKey;

@end
