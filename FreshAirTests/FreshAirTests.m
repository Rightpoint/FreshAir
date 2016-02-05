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

@end

@implementation FreshAirTests

- (void)testFeatureRange
{
    NSURL *releaseURL = [BUNDLE URLForResource:@"release_notes" withExtension:@"json"];
    RZFReleaseNotes *releaseNotes = [RZFReleaseNotes releaseNotesWithURL:releaseURL error:nil];

    NSArray *f1_12 = [releaseNotes featuresFromVersion:@"1.0" toVersion:@"1.2"];
    NSArray *f12_21 = [releaseNotes featuresFromVersion:@"1.2" toVersion:@"2.1"];
    XCTAssert(f1_12.count == 1);
    XCTAssert(f12_21.count == 3);
}

@end
