//
//  BAMostRecentAsync.m
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 18/04/15.
//  Copyright (c) 2015 Binaryage. All rights reserved.
//

#import "BAMostRecentAsync.h"

NSString *displayReconfigurationIdentifier = @"displayReconfiguration";

@implementation BAMostRecentAsync

static NSMutableDictionary *counters;

+ (void)executeMostRecentAfter:(NSTimeInterval)delay identifier:(NSString *)identifier block:(void (^)())block
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        counters = [NSMutableDictionary dictionary];
    });
    
    NSString *idString = [identifier copy];
    
    if (!counters[idString]) counters[idString] = @0;
    NSInteger curCounter = [counters[idString] integerValue];
    NSUInteger counterInteger = curCounter + 1;
    NSNumber *nextValue = @(counterInteger);
    counters[idString] = nextValue;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (counterInteger == [counters[idString] integerValue]) {
            block();
        }
    });
}

@end
