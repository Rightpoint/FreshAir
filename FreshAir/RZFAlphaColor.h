//
//  RZFAlphaColor.h
//  FreshAir
//
//  Created by Adam Howitt on 7/1/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RZFAlphaColor : NSObject

@property (copy, nonatomic, nonnull) NSString *key;

@property (strong, nonatomic, nullable) NSString *red;
@property (strong, nonatomic, nullable) NSString *green;
@property (strong, nonatomic, nullable) NSString *blue;
@property (strong, nonatomic, nullable) NSString *alpha;

@end