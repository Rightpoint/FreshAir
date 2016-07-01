//
//  NSObject+RZFImport.m
//  FreshAir
//
//  Created by Brian King on 1/26/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

#import "NSObject+RZFImport.h"

#define RZF_KP(Classname, keypath) ({\
Classname *_rzf_keypath_obj; \
__unused __typeof(_rzf_keypath_obj.keypath) _rzf_keypath_prop; \
@#keypath; \
})

@implementation NSArray (RZFUtility)

- (NSArray *)map:(id(^)(id))transform
{
    NSMutableArray *result = [NSMutableArray array];
    for (id obj in self) {
        [result addObject:transform(obj)];
    }
    return [result copy];
}

@end


@implementation NSObject (RZFImport)

+ (id)rzf_importData:(NSData *)data error:(NSError **)error
{
    Class<RZFImporting> importClass = (id)self;

    NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
    if (JSON == nil) {
        return nil;
    }
    else if ([JSON isKindOfClass:[NSArray class]]) {
        NSMutableArray *results = [NSMutableArray array];
        for (NSDictionary *jsonObject in JSON) {
            id object = [importClass instanceFromJSON:jsonObject];
            [results addObject:object];
        }
        return results;
    }
    else {
        return [importClass instanceFromJSON:JSON];
    }
}

+ (id)rzf_importURL:(NSURL *)URL error:(NSError **)error
{
    NSParameterAssert([self conformsToProtocol:@protocol(RZFImporting)]);
    NSData *data = [NSData dataWithContentsOfURL:URL options:kNilOptions error:error];
    if (data == nil) {
        return nil;
    }
    return [self rzf_importData:data error:error];
}

@end

@implementation RZFReleaseNotes (RZFImport)

+ (instancetype)instanceFromJSON:(id)value
{
    NSParameterAssert([value isKindOfClass:[NSDictionary class]]);
    NSArray *releasesJSON = value[RZF_KP(RZFReleaseNotes, releases)] ?: @[];
    RZFReleaseNotes *releaseNotes = [[RZFReleaseNotes alloc] init];
    releaseNotes.upgradeURL = [NSURL URLWithString:value[RZF_KP(RZFReleaseNotes, upgradeURL)]];
    releaseNotes.minimumVersion = value[RZF_KP(RZFReleaseNotes, minimumVersion)];
    releaseNotes.releases = [releasesJSON map:^id(id value) {
        return [RZFRelease instanceFromJSON:value];
    }];


    NSDictionary *styling = value[@"style"];
    releaseNotes.fullScreen = [styling[RZF_KP(RZFReleaseNotes, fullScreen)] boolValue];
    releaseNotes.titleFontName = styling[RZF_KP(RZFReleaseNotes, titleFontName)];
    releaseNotes.titleFontSize = styling[RZF_KP(RZFReleaseNotes, titleFontSize)];

    NSDictionary *doneConfigurationJSON = styling[RZF_KP(RZFReleaseNotes, doneConfiguration)] ?: @{};
    if ( doneConfigurationJSON ) {
        releaseNotes.doneConfiguration = [RZFDoneButtonConfiguration instanceFromJSON: doneConfigurationJSON];
    }

    NSDictionary *accentColor = styling[RZF_KP(RZFReleaseNotes, accentColor)];
    if ( accentColor ) {
        releaseNotes.accentColor = [RZFAlphaColor instanceFromJSON:accentColor];
    }
    return releaseNotes;
}

- (id)jsonRepresentation
{
    // Schema ensures upgradeURL and releases are non-nil
    NSMutableDictionary *representation = [@{
             RZF_KP(RZFReleaseNotes, upgradeURL): self.upgradeURL.path,
             RZF_KP(RZFReleaseNotes, releases): [self.releases valueForKey:RZF_KP(RZFRelease, jsonRepresentation)],
             } mutableCopy];

    if (self.minimumVersion) {
        representation[RZF_KP(RZFReleaseNotes, minimumVersion)] = self.minimumVersion;
    }
    return [representation copy];
}

@end

@implementation RZFAlphaColor (RZFImport)

+ (instancetype)instanceFromJSON:(id)value
{
    NSParameterAssert([value isKindOfClass:[NSDictionary class]]);
    RZFAlphaColor *color = [[RZFAlphaColor alloc] init];
    color.red = value[RZF_KP(RZFAlphaColor, red)] ?: @"255.0";
    color.green = value[RZF_KP(RZFAlphaColor, green)] ?: @"255.0";
    color.blue = value[RZF_KP(RZFAlphaColor, blue)] ?: @"255.0";
    color.alpha = value[RZF_KP(RZFAlphaColor, alpha)] ?: @"255.0";
    return color;
}

- (id)jsonRepresentation
{
    NSMutableDictionary *representation = [@{
                                             RZF_KP(RZFAlphaColor, red): self.red,
                                             RZF_KP(RZFAlphaColor, green): self.green,
                                             RZF_KP(RZFAlphaColor, blue): self.blue,
                                             RZF_KP(RZFAlphaColor, alpha): self.alpha,
                                             } mutableCopy];
    return [representation copy];
}
@end

@implementation RZFDoneButtonConfiguration (RZFImport)

+ (instancetype)instanceFromJSON:(id)value
{
    NSParameterAssert([value isKindOfClass:[NSDictionary class]]);
    RZFDoneButtonConfiguration *doneConfiguration = [[RZFDoneButtonConfiguration alloc] init];
    doneConfiguration = [[RZFDoneButtonConfiguration alloc] init];
    doneConfiguration.title = value[RZF_KP(RZFDoneButtonConfiguration, title)];
    doneConfiguration.fontName = value[RZF_KP(RZFDoneButtonConfiguration, fontName)];
    doneConfiguration.fontSize = value[RZF_KP(RZFDoneButtonConfiguration, fontSize)];
    doneConfiguration.cornerRadius = value[RZF_KP(RZFDoneButtonConfiguration, cornerRadius)];
    doneConfiguration.highlightAlpha = value[RZF_KP(RZFDoneButtonConfiguration, highlightAlpha)];
    NSDictionary *backgroundColor = value[RZF_KP(RZFDoneButtonConfiguration, backgroundColor)];
    if ( backgroundColor ) {
        doneConfiguration.backgroundColor = [RZFAlphaColor instanceFromJSON:backgroundColor];
    }
    return doneConfiguration;
}

- (id)jsonRepresentation
{
    NSMutableDictionary *representation = [@{
                                             RZF_KP(RZFDoneButtonConfiguration, title): self.title,
                                             RZF_KP(RZFDoneButtonConfiguration, fontName): self.fontName,
                                             RZF_KP(RZFDoneButtonConfiguration, fontSize): self.fontSize,
                                             RZF_KP(RZFDoneButtonConfiguration, cornerRadius): self.cornerRadius,
                                             RZF_KP(RZFDoneButtonConfiguration, highlightAlpha): self.highlightAlpha
                                             } mutableCopy];
    return [representation copy];
}
@end

@implementation RZFRelease (RZFImport)

+ (instancetype)instanceFromJSON:(id)value
{
    NSParameterAssert([value isKindOfClass:[NSDictionary class]]);
    RZFRelease *release = [[RZFRelease alloc] init];
    release.version = value[RZF_KP(RZFRelease, version)];
    release.systemVersion = value[RZF_KP(RZFRelease, systemVersion)];
    release.features = [value[RZF_KP(RZFRelease, features)] map:^id(id value) {
        return [RZFFeature instanceFromJSON:value];
    }];
    return release;

}

- (id)jsonRepresentation
{
    NSMutableDictionary *representation = [@{
             RZF_KP(RZFRelease, version): self.version,
             RZF_KP(RZFRelease, systemVersion): self.systemVersion,
             RZF_KP(RZFRelease, features): [self.features valueForKey:RZF_KP(RZFFeature, jsonRepresentation)],
             } mutableCopy];
    return [representation copy];
}

@end

@implementation RZFFeature (RZFImport)

+ (instancetype)instanceFromJSON:(id)value
{
    NSParameterAssert([value isKindOfClass:[NSString class]]);
    RZFFeature *feature = [[RZFFeature alloc] init];
    feature.key = value;
    return feature;
}

- (id)jsonRepresentation
{
    return self.key;
}

@end
