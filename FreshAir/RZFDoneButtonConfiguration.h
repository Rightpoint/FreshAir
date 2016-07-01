//
//  RZFDoneButtonConfiguration.h
//  FreshAir
//
//  Created by Adam Howitt on 7/1/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RZFAlphaColor;

@interface RZFDoneButtonConfiguration : NSObject

@property (copy, nonatomic, nonnull) NSString *key;

@property (strong, nonatomic, nullable) NSString *title;
@property (strong, nonatomic, nullable) NSString *fontName;
@property (strong, nonatomic, nullable) NSString *fontSize;
@property (strong, nonatomic, nullable) NSString *cornerRadius;
@property (strong, nonatomic, nullable) NSString *highlightAlpha;
@property (strong, nonatomic, nullable) RZFAlphaColor *backgroundColor;

@end
