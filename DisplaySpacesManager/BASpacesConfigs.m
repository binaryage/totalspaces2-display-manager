//
//  BASpacesConfigs.m
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 20/04/14.
//  Copyright (c) 2014 Binaryage. All rights reserved.
//

#import "BASpacesConfigs.h"

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
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableConfigs options:NSJSONWritingPrettyPrinted error:&error];
    
    if (!error) {
        [jsonData writeToFile:[BA_CONFIG_FILE stringByExpandingTildeInPath] atomically:YES];
        self.cachedConfigs = mutableConfigs;
    }
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
    id object = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    if (error || ![object isKindOfClass:[NSDictionary class]]) {
        object = [NSDictionary dictionary];
    }
    
    return object;
}

@end
