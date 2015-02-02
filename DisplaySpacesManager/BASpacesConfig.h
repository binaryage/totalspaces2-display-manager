//
//  BASpacesConfig.h
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 14/01/15.
//  Copyright (c) 2015 Binaryage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BASpacesConfig : NSObject

/** Array of space UUIDs */
@property (nonatomic, strong) NSArray *spaces;

/** Configurations of backgrounds */
@property (nonatomic, strong) NSArray *backgrounds;

/** Dictionarys of app bindings */
@property (nonatomic, strong) NSDictionary *bindings;

/** Names of spaces */
@property (nonatomic, strong) NSDictionary *names;

/** Number of columns defined in TS */
@property (nonatomic) NSUInteger columns;

- (instancetype)initWithDictionary:(NSDictionary *)configs;

- (NSDictionary *)jsonDict;

@end
