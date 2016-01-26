//
//  FreshAirTests.m
//  FreshAirTests
//
//  Created by Brian King on 1/23/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <FreshAir/FreshAir.h>

#define BUNDLE [NSBundle bundleForClass:self.class]
@interface FreshAirTests : XCTestCase <RZFManifestManagerDelegate>

@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSArray *bundles;

@end

@implementation FreshAirTests

- (void)manifestManager:(RZFManifestManager *)manifestManager didLoadBundle:(NSBundle *)bundle
{
    self.bundles = [self.bundles arrayByAddingObject:bundle];
}

- (void)manifestManager:(RZFManifestManager *)manifestManager didEncounterError:(NSError *)error
{
    self.error = error;
}

- (void)setUp
{
    [super setUp];
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:[RZFManifestManager defaultLocalURL] error:&error];
    XCTAssertNil(error);
    [[RZFManifestManager defaultEnvironment] setValue:@"0.9" forKey:@"appVersion"];
    self.bundles = @[];
}

- (void)testEmbeddedManifest
{
    NSURL *url = [BUNDLE URLForResource:@"Examples/TestEmbeddedManifest" withExtension:@"freshair"];
    RZFManifestManager *mgr = [[RZFManifestManager alloc] initWithRemoteURL:url delegate:self];

    while (mgr.loaded == NO) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
    XCTAssertNil(self.error);
}

@end
