//
//  UIColor+RZFStyle.m
//  RZFreshAir
//
//  Created by Bradley Smith on 5/26/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "UIColor+RZFStyle.h"

static NSString * const kRZFDefaultPromptTintColor = @"9B9B9B";
static NSString * const kRZFDefaultPromptTitleColorHexString = @"000000";
static NSString * const kRZFDefaultPromptMessageColorHexString = @"9B9B9B";
static NSString * const kRZFDefaultPromptButtonTitleColorNormalHexString = @"FFFFFF";
static NSString * const kRZFDefaultPromptButtonTitleColorPressedHexString = @"E1E1E1";

static NSString * const kRZFDefaultReleaseNoteTintColorHexString = @"9B9B9B";
static NSString * const kRZFDefaultReleaseNoteTitleColorHexString = @"FFFFFF";
static NSString * const kRZFDefaultReleaseNoteMessageColorHexString = @"FFFFFF";
static NSString * const kRZFDefaultReleaseNoteButtonTitleColorNormalHexString = @"FFFFFF";
static NSString * const kRZFDefaultReleaseNoteButtonTitleColorPressedHexString = @"E1E1E1";

@implementation UIColor (RZFStyle)

# pragma mark - Private

+ (UIColor *)rzf_colorFromHexString:(NSString *)string
{
    NSParameterAssert(string);
    if ( string == nil ) {
        return nil;
    }
    
    unsigned int hexInteger = 0;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"x#"]];
    [scanner scanHexInt:&hexInteger];
    
    return [self rzf_colorFromHex:hexInteger];
}

+ (UIColor *)rzf_colorFromHex:(uint32_t)hexLiteral
{
    uint8_t r = (uint8_t)(hexLiteral >> 16);
    uint8_t g = (uint8_t)(hexLiteral >> 8);
    uint8_t b = (uint8_t)hexLiteral;
    
    return [self rzf_colorFrom8BitRed:r green:g blue:b];
}

+ (UIColor *)rzf_colorFrom8BitRed:(uint8_t)r green:(uint8_t)g blue:(uint8_t)b
{
    return [self rzf_colorFrom8BitRed:r green:g blue:b alpha:255];
}

+ (UIColor *)rzf_colorFrom8BitRed:(uint8_t)r green:(uint8_t)g blue:(uint8_t)b alpha:(uint8_t)a
{
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0];
}

# pragma mark - Public

+ (UIColor *)rzf_defaultPromptTintColor {
    return [UIColor rzf_colorFromHexString:kRZFDefaultPromptTintColor];
}

+ (UIColor *)rzf_defaultPromptTitleColor
{
    return [UIColor rzf_colorFromHexString:kRZFDefaultPromptTitleColorHexString];
}

+ (UIColor *)rzf_defaultPromptMessageColor
{
    return [UIColor rzf_colorFromHexString:kRZFDefaultPromptMessageColorHexString];
}

+ (UIColor *)rzf_defaultPromptButtonTitleColorNormal
{
    return [UIColor rzf_colorFromHexString:kRZFDefaultPromptButtonTitleColorNormalHexString];
}

+ (UIColor *)rzf_defaultPromptButtonTitleColorPressed
{
    return [UIColor rzf_colorFromHexString:kRZFDefaultPromptButtonTitleColorPressedHexString];
}

+ (UIColor *)rzf_defaultReleaseNoteTintColor
{
    return [UIColor rzf_colorFromHexString:kRZFDefaultReleaseNoteTintColorHexString];
}

+ (UIColor *)rzf_defaultReleaseNoteTitleColor
{
    return [UIColor rzf_colorFromHexString:kRZFDefaultReleaseNoteTitleColorHexString];
}

+ (UIColor *)rzf_defaultReleaseNoteMessageColor
{
    return [UIColor rzf_colorFromHexString:kRZFDefaultReleaseNoteMessageColorHexString];
}

+ (UIColor *)rzf_defaultReleaseNoteButtonTitleColorNormal
{
    return [UIColor rzf_colorFromHexString:kRZFDefaultReleaseNoteButtonTitleColorNormalHexString];
}

+ (UIColor *)rzf_defaultReleaseNoteButtonTitleColorPressed
{
    return [UIColor rzf_colorFromHexString:kRZFDefaultReleaseNoteButtonTitleColorPressedHexString];
}

@end
