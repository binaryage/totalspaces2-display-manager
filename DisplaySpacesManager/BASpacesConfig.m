//
//  BASpacesConfig.m
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 14/01/15.
//  Copyright (c) 2015 Binaryage. All rights reserved.
//

#import "BASpacesConfig.h"

@implementation BASpacesConfig

- (instancetype)initWithDictionary:(NSDictionary *)configs
{
    self = [super init];
    if (self) {
        BOOL success = [self loadDictionary:configs];
        if (!success) return nil;
    }
    return self;
}

- (BOOL)loadDictionary:(NSDictionary *)configs
{
    if (![configs isKindOfClass:[NSDictionary class]]) return NO;
    self.spaces = configs[@"spaces"];
    if (![_spaces isKindOfClass:[NSArray class]]) return NO;
    self.backgrounds = configs[@"backgrounds"];
    if (![_backgrounds isKindOfClass:[NSArray class]]) return NO;
    self.bindings = configs[@"bindings"];
    if (![_bindings isKindOfClass:[NSDictionary class]]) return NO;
    self.names = configs[@"names"];
    if (![_names isKindOfClass:[NSDictionary class]]) return NO;
    self.columns = [configs[@"columns"] unsignedIntegerValue];
    if (_columns < 1 || _columns > 16) return NO;
    return YES;
}

- (NSDictionary *)jsonDict
{
    return @{@"spaces" : _spaces, @"backgrounds" : _backgrounds, @"bindings" : _bindings, @"names" : _names, @"columns" : @(_columns)};
}

@end
