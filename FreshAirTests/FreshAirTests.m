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
@property (strong, nonatomic) RZFEnvironment *environment;

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
    if ([[NSFileManager defaultManager] fileExistsAtPath:[RZFManifestManager defaultLocalURL].path]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:[RZFManifestManager defaultLocalURL] error:&error];
        XCTAssertNil(error);
    }
    [[RZFEnvironment defaultVariables] setValue:@"0.9" forKey:RZFEnvironmentAppVersionKey];
    self.environment = [[RZFEnvironment alloc] init];
    self.bundles = @[];
}

- (void)testEmbeddedManifest
{
    NSURL *url = [BUNDLE URLForResource:@"Examples/TestEmbeddedManifest" withExtension:@"freshair"];
    RZFManifestManager *mgr = [[RZFManifestManager alloc] initWithRemoteURL:url
                                                                   localURL:nil
                                                                environment:self.environment
                                                                   delegate:self];
    [mgr update];

    while (mgr.loaded == NO) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    XCTAssertNil(self.error);
    XCTAssertEqual(self.bundles.count, 2);
}

- (void)testFeatureRange
{
    NSURL *url = [BUNDLE URLForResource:@"Examples/TestFeature" withExtension:@"freshair"];
    RZFManifestManager *mgr = [[RZFManifestManager alloc] initWithRemoteURL:url
                                                                   localURL:nil
                                                                environment:self.environment
                                                                   delegate:self];
    [mgr update];

    while (mgr.loaded == NO) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
    XCTAssertNil(self.error);
    XCTAssert(self.bundles.count == 1);

    RZFReleaseNotes *notes = [mgr.bundle rzf_releaseNotes];
    NSArray *f1_12 = [notes featuresFromVersion:@"1.0" toVersion:@"1.2"];
    NSArray *f12_21 = [notes featuresFromVersion:@"1.2" toVersion:@"2.1"];
    XCTAssert(f1_12.count == 4);
    XCTAssert(f12_21.count == 3);
}


@end
