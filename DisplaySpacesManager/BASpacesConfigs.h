//
//  BASpacesConfigs.h
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 20/04/14.
//  Copyright (c) 2014 Binaryage. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define BA_CONFIG_FILE @"~/.ts2_spaces_configs"

@interface BASpacesConfigs : NSViewController

+ (BASpacesConfigs *)instance;

- (void)save:(NSString *)name config:(NSDictionary *)config;

- (NSDictionary *)configWithName:(NSString *)name;

- (NSArray *)configNames;

@end
