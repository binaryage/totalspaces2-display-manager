//
//  BASpacesConfigs.m
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 20/04/14.
//  Copyright (c) 2014 Binaryage. All rights reserved.
//

#import "BASpacesConfigs.h"
#import "BASpacesConfig.h"

@interface BASpacesConfigs ()

@property (strong) NSDictionary *cachedConfigs;

@end

@implementation BASpacesConfigs

+ (BASpacesConfigs *)instance
{
    static dispatch_once_t pred;
    static BASpacesConfigs *spacesConfigs;
    
    dispatch_once(&pred, ^{
        spacesConfigs = [[self alloc] init];
    });
	return spacesConfigs;
}

- (void)save:(NSString *)name config:(NSDictionary *)config
{
    if (!name || !config) return;
    
    NSDictionary *configs = [self readConfigs];
    
    NSMutableDictionary *mutableConfigs = [NSMutableDictionary dictionaryWithDictionary:configs];
    mutableConfigs[name] = config;
    
    [self writeConfigs:mutableConfigs];
}

- (void)writeConfigs:(NSDictionary *)configs
{
    NSError *error = nil;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *name in configs) {
        NSDictionary *spacesConfigs = configs[name];
        dict[name] = [NSMutableDictionary dictionary];
        for (NSNumber *display in spacesConfigs) {
            BASpacesConfig *config = spacesConfigs[display];
            dict[name][display] = [config jsonDict];
        }
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    if (!error) {
        [jsonData writeToFile:[BA_CONFIG_FILE stringByExpandingTildeInPath] atomically:YES];
        self.cachedConfigs = configs;
    }
}

- (void)delete:(NSString *)name
{
    if (!name) return;
    
    NSDictionary *configs = [self readConfigs];
    
    NSMutableDictionary *mutableConfigs = [NSMutableDictionary dictionaryWithDictionary:configs];
    [mutableConfigs removeObjectForKey:name];
    
    [self writeConfigs:mutableConfigs];
}

- (NSDictionary *)configWithName:(NSString *)name
{
    if (!name) return nil;
    
    NSDictionary *configs = [self readConfigs];
    
    return configs[name];
}

- (NSArray *)configNames
{
    NSDictionary *configs = [self readConfigs];
    
    NSMutableArray *names = [NSMutableArray array];
    for (NSString *name in configs) {
        [names addObject:name];
    }
    
    return [names sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSDictionary *)readConfigs
{
    if (_cachedConfigs) return _cachedConfigs;

    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:[BA_CONFIG_FILE stringByExpandingTildeInPath]];
    if (!jsonData) jsonData = [NSData dataWithBytes:"{}" length:2];

    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (error || ![jsonDict isKindOfClass:[NSDictionary class]]) {
        jsonDict = [NSDictionary dictionary];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *name in jsonDict) {
        NSDictionary *configDict = jsonDict[name];
        if (configDict && [configDict isKindOfClass:[NSDictionary class]]) {
            dict[name] = [NSMutableDictionary dictionary];
            for (NSString *display in configDict) {
                NSDictionary *spacesDict = configDict[display];
                if (spacesDict && [spacesDict isKindOfClass:[NSDictionary class]]) {
                    BASpacesConfig *config = [[BASpacesConfig alloc] initWithDictionary:spacesDict];
                    if (config) {
                        dict[name][display] = config;
                    }
                }
            }
        }
    }
    
    return dict;
}

@end
