//
//  NSURL+RZFManifest.h
//  FreshAir
//
//  Created by Brian King on 1/24/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (RZFManifest)

+ (NSString *)rzf_manifestFilename;

+ (NSString *)rzf_presentationFilename;

- (NSURL *)rzf_manifestURL;

- (NSURL *)rzf_presentationURL;

- (BOOL)rzf_isManifestURL;

@end
