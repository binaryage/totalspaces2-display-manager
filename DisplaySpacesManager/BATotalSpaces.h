//
//  BATotalSpaces.h
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 20/04/14.
//  Copyright (c) 2014 Binaryage. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BATotalSpaces : NSViewController

+ (BATotalSpaces *)instance;

- (NSDictionary *)currentConfig;

- (BOOL)configCanBeRestored:(NSDictionary *)config error:(NSError **)error;

- (void)restoreConfig:(NSDictionary *)config error:(NSError **)error;

@end
