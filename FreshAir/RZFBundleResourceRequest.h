//
//  RZFRemoteBundleController.h
//  FreshAir
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol RZFBundleResourceRequestDelegate;
@class RZFEnvironment;

typedef void(^RZFBundleUpdateBlock)(NSBundle *bundle, NSError *error);

@interface RZFBundleResourceRequest : NSObject

/**
 *  The default local URL to download the manifest bundles to.
 */
+ (NSURL *)localURL;

/**
 *  Set the local storage URL. Must be a file URL.
 */
+ (void)setLocalURL:(NSURL *)URL;

/**
 *  Create a new manifest manager that will obtain the manifest at the remote URL and store it in the localURL directory
 *
 *  @param remoteURL The remote URL to load. This should refer to the .freshair file, not the manifest file.
 *  @param environment The environment object to evaluate conditions against.
 *  @param delegate The delegate to be informed when a bundle is loaded.
 */
- (instancetype)initWithRemoteURL:(NSURL *)remoteURL
                      environment:(RZFEnvironment *)environment
                       completion:(RZFBundleUpdateBlock __nullable)completion;

/**
 *  The primary bundle to download
 */
@property (strong, nonatomic, readonly) NSBundle * __nullable bundle;

/**
 *  The error that failed the bundle to load.
 */
@property (strong, nonatomic, readonly) NSError * __nullable error;

/**
 *  This will return YES when the bundle has been loaded.
 */
@property (assign, nonatomic, readonly) BOOL loaded;

/**
 *  The URL Session to perform downloads with. This will default to
 *  NSURLSession.defaultSession if not set
 */
@property (strong, nonatomic) NSURLSession *session;

@end

NS_ASSUME_NONNULL_END

