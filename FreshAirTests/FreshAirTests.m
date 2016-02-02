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
@interface FreshAirTests : XCTestCase

@property (strong, nonatomic) RZFEnvironment *environment;

@end

@implementation FreshAirTests

- (void)setUp
{
    [super setUp];

#if (TARGET_IPHONE_SIMULATOR)
    if ([[NSFileManager defaultManager] fileExistsAtPath:[RZFBundleResourceRequest localURL].path]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtURL:[RZFBundleResourceRequest localURL] error:&error];
        XCTAssertNil(error);
    }
#endif

    [[RZFEnvironment defaultVariables] setValue:@"0.9" forKey:RZFEnvironmentAppVersionKey];
    self.environment = [[RZFEnvironment alloc] init];
}

- (void)testBasicManifest
{
    NSURL *url = [BUNDLE URLForResource:@"Examples/TestBasic" withExtension:@"freshair"];
    RZFBundleResourceRequest *mgr = [[RZFBundleResourceRequest alloc] initWithRemoteURL:url
                                                                            environment:self.environment
                                                                             completion:nil];

    while (mgr.loaded == NO && mgr.error == nil) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    XCTAssertNil(mgr.error);
    XCTAssertNotNil(mgr.bundle);
    XCTAssertNil([mgr.bundle URLForResource:@"not_on_ios" withExtension:nil]);
    XCTAssertNil([mgr.bundle URLForResource:@"gt_version_1" withExtension:nil]);
    XCTAssertNotNil([mgr.bundle URLForResource:@"lte_version_1" withExtension:nil]);
}

- (void)testBasicManifestWithOnePointOh
{
    [[RZFEnvironment defaultVariables] setValue:@"1.0" forKey:RZFEnvironmentAppVersionKey];
    self.environment = [[RZFEnvironment alloc] init];

    NSURL *url = [BUNDLE URLForResource:@"Examples/TestBasic" withExtension:@"freshair"];
    RZFBundleResourceRequest *mgr = [[RZFBundleResourceRequest alloc] initWithRemoteURL:url
                                                                            environment:self.environment
                                                                             completion:nil];

    while (mgr.loaded == NO && mgr.error == nil) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    XCTAssertNil(mgr.error);
    XCTAssertNotNil(mgr.bundle);
    XCTAssertNil([mgr.bundle URLForResource:@"not_on_ios" withExtension:nil]);
    XCTAssertNil([mgr.bundle URLForResource:@"gt_version_1" withExtension:nil]);
    XCTAssertNotNil([mgr.bundle URLForResource:@"lte_version_1" withExtension:nil]);
}

- (void)testBasicManifestWithOnePointOne
{
    [[RZFEnvironment defaultVariables] setValue:@"1.1" forKey:RZFEnvironmentAppVersionKey];
    self.environment = [[RZFEnvironment alloc] init];

    NSURL *url = [BUNDLE URLForResource:@"Examples/TestBasic" withExtension:@"freshair"];
    RZFBundleResourceRequest *mgr = [[RZFBundleResourceRequest alloc] initWithRemoteURL:url
                                                                            environment:self.environment
                                                                             completion:nil];

    while (mgr.loaded == NO && mgr.error == nil) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    XCTAssertNil(mgr.error);
    XCTAssertNotNil(mgr.bundle);
    XCTAssertNil([mgr.bundle URLForResource:@"not_on_ios" withExtension:nil]);
    XCTAssertNotNil([mgr.bundle URLForResource:@"gt_version_1" withExtension:nil]);
    XCTAssertNil([mgr.bundle URLForResource:@"lte_version_1" withExtension:nil]);
}

- (void)testFeatureRange
{
    NSURL *url = [BUNDLE URLForResource:@"Examples/TestFeature" withExtension:@"freshair"];
    RZFBundleResourceRequest *mgr = [[RZFBundleResourceRequest alloc] initWithRemoteURL:url
                                                                            environment:self.environment
                                                                             completion:nil];

    while (mgr.loaded == NO && mgr.error == nil) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
    }
    XCTAssertNil(mgr.error);
    XCTAssertNotNil(mgr.bundle);

    RZFReleaseNotes *notes = [mgr.bundle rzf_releaseNotes];
    NSArray *f1_12 = [notes featuresFromVersion:@"1.0" toVersion:@"1.2"];
    NSArray *f12_21 = [notes featuresFromVersion:@"1.2" toVersion:@"2.1"];
    XCTAssert(f1_12.count == 4);
    XCTAssert(f12_21.count == 3);
}


@end
