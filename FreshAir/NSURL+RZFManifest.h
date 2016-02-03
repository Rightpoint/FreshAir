//
//  NSURL+RZFManifest.h
//  FreshAir
//
//  Created by Brian King on 1/24/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (RZFManifest)

+ (NSString *)rzf_manifestFilename;

+ (NSString *)rzf_releaseFilename;

+ (NSString *)rzf_freshairExtension;

- (NSURL *)rzf_manifestURL;

- (NSURL *)rzf_releaseURL;

- (BOOL)rzf_isManifestURL;

@end

NS_ASSUME_NONNULL_END
