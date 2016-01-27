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
#import "RZFCondition.h"
#import "RZFManifest.h"
#import "RZFManifestEntry.h"

// One stop shop for the boring JSON mapping.
@protocol RZFImporting <NSObject>

+ (instancetype)instanceFromJSON:(id)value;
- (id)jsonRepresentation;

@end

@interface RZFReleaseNotes (RZFImport) <RZFImporting>
@end

@interface RZFRelease (RZFImport) <RZFImporting>
@end

@interface RZFFeature (RZFImport) <RZFImporting>
@end

@interface RZFCondition (RZFImport) <RZFImporting>
@end

@interface RZFManifestEntry (RZFImport) <RZFImporting>
@end