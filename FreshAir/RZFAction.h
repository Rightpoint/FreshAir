//
//  RZFAction.h
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RZFAction : NSObject

@property (copy, nonatomic) NSString *key;
@property (copy, nonatomic) NSString *condition;
@property (strong, nonatomic) NSURL *URL;

@end
