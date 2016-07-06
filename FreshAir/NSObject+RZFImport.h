//
//  NSObject+RZFImport.h
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RZFReleaseNotes.h"
#import "RZFRelease.h"
#import "RZFFeature.h"

NS_ASSUME_NONNULL_BEGIN

// One stop shop for the boring JSON mapping.
@protocol RZFImporting <NSObject>

+ (instancetype)instanceFromJSON:(id)value;
- (id)jsonRepresentation;

@end

@interface NSObject (RZFImport)

+ (id __nullable)rzf_importURL:(NSURL *)URL error:(out NSError **)error;
+ (id)rzf_importData:(NSData *)data error:(NSError **)error;

@end

@interface RZFReleaseNotes (RZFImport) <RZFImporting>
@end

@interface RZFRelease (RZFImport) <RZFImporting>
@end

@interface RZFFeature (RZFImport) <RZFImporting>
@end

NS_ASSUME_NONNULL_END
