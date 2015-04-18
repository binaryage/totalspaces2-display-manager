//
//  BAMostRecentAsync.h
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 18/04/15.
//  Copyright (c) 2015 Binaryage. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *displayReconfigurationIdentifier;

@interface BAMostRecentAsync : NSObject

+ (void)executeMostRecentAfter:(NSTimeInterval)delay identifier:(NSString *)identifier block:(void (^)())block;

@end
