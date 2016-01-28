//
//  RZFError.h
//  FreshAir
//
//  Created by Brian King on 1/27/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

OBJC_EXTERN NSString *const RZFreshAirErrorDomain;
typedef NS_ENUM(NSUInteger, RZFreshAirErrorCode) {
    RZFreshAirErrorCodeSHAMismatch,
    RZFreshAirErrorCodeFileSaveError
};

