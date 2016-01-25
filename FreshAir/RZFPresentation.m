//
//  RZFPresentation.m
//  FreshAir
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "RZFPresentation.h"
#import "NSURL+RZFManifest.h"

@implementation RZFPresentation

+ (instancetype)presentationFromBundle:(NSBundle *)bundle
{
    NSURL *presentationURL = bundle.bundleURL.rzf_presentationURL;
    if ([[NSFileManager defaultManager] fileExistsAtPath:presentationURL.path]) {
        RZFPresentation *presentation = [[RZFPresentation alloc] initWithLocalURL:presentationURL];
        return presentation;
    }
    return nil;
}

- (instancetype)initWithLocalURL:(NSURL *)localURL
{
    self = [super init];
    if (self) {
        _viewController = nil; // FIXME
    }
    return self;
}

@end
