//
//  UIFont+RZFStyle.m
//  RZFreshAir
//
//  Created by Bradley Smith on 5/26/15.
//  Copyright (c) 2015 Raizlabs. All rights reserved.
//

#import "UIFont+RZFStyle.h"

static NSString * const kRZFDefaultPromptTitleFontName = @"HelveticaNeue-Medium";
static NSString * const kRZFDefaultPromptMessageFontName = @"HelveticaNeue-Light";
static NSString * const kRZFDefaultPromptButtonFont = @"HelveticaNeue-Medium";

static NSString * const kRZFDefaultReleaseNoteTitleFont = @"HelveticaNeue-Medium";
static NSString * const kRZFDefaultReleaseNoteMessageFont = @"HelveticaNeue-Light";
static NSString * const kRZFDefaultReleaseNoteButtonFont = @"HelveticaNeue-Medium";

static const CGFloat kRZFDefaultPromptTitleFontSize = 20.0f;
static const CGFloat kRZFDefaultPromptMessageFontSize = 18.0f;
static const CGFloat kRZFDefaultPromptButtonFontSize = 20.0f;

static const CGFloat kRZFDefaultReleaseNoteTitleFontSize = 20.0f;
static const CGFloat kRZFDefaultReleaseNoteMessageFontSize = 18.0f;
static const CGFloat kRZFDefaultReleaseNoteButtonFontSize = 20.0f;

@implementation UIFont (RZFStyle)

+ (UIFont *)rzf_defaultPromptTitleFont
{
    return [UIFont fontWithName:kRZFDefaultPromptTitleFontName size:kRZFDefaultPromptTitleFontSize];
}

+ (UIFont *)rzf_defaultPromptMessageFont
{
    return [UIFont fontWithName:kRZFDefaultPromptMessageFontName size:kRZFDefaultPromptMessageFontSize];
}

+ (UIFont *)rzf_defaultPromptButtonFont
{
    return [UIFont fontWithName:kRZFDefaultPromptButtonFont size:kRZFDefaultPromptButtonFontSize];
}

+ (UIFont *)rzf_defaultReleaseNoteTitleFont
{
    return [UIFont fontWithName:kRZFDefaultReleaseNoteTitleFont size:kRZFDefaultReleaseNoteTitleFontSize];
}

+ (UIFont *)rzf_defaultReleaseNoteMessageFont
{
    return [UIFont fontWithName:kRZFDefaultReleaseNoteMessageFont size:kRZFDefaultReleaseNoteMessageFontSize];
}

+ (UIFont *)rzf_defaultReleaseNoteButtonFont
{
    return [UIFont fontWithName:kRZFDefaultReleaseNoteButtonFont size:kRZFDefaultReleaseNoteButtonFontSize];
}

@end
