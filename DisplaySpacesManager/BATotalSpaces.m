//
//  BATotalSpaces.m
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 20/04/14.
//  Copyright (c) 2014 Binaryage. All rights reserved.
//

#import "BATotalSpaces.h"
#import "TSLib.h"
#import "BAMainViewController.h"

@implementation BATotalSpaces

+ (BATotalSpaces *)instance
{
    static dispatch_once_t pred;
    static BATotalSpaces *totalSpaces;
    
    dispatch_once(&pred, ^{
        totalSpaces = [[self alloc] init];
    });
	return totalSpaces;
}

- (NSDictionary *)currentConfig
{
    if (![self versionCheck]) return nil;
    
    NSArray *displayIDs = [self displayIDs];

    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    for (NSNumber *displayNumber in displayIDs) {
        NSString *displayNumberStr = [NSString stringWithFormat:@"%@", displayNumber];
        
        NSMutableArray *spaces = [NSMutableArray array];
        CGDirectDisplayID displayID = [displayNumber unsignedIntValue];
        unsigned int numSpaces = tsapi_numberOfSpacesOnDisplay(displayID);
        for (int i=1; i<= numSpaces; i++) {
            char *spaceUUID = (char *)tsapi_uuidForSpaceNumberOnDisplay(i, displayID);
            if (spaceUUID) {
                [spaces addObject:[NSString stringWithFormat:@"%s", spaceUUID]];
                tsapi_freeString(spaceUUID);
            }
        }
        config[displayNumberStr] = spaces;
    }
    
    return config;
}

- (void)restoreConfig:(NSDictionary *)config error:(NSError **)error
{
    if (![self versionCheck]) return;

    NSArray *displayIDs = [self displayIDs];

    // Check that all the required displays are currently attached
    for (NSString *displayID in config) {
        if ([displayIDs indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [obj integerValue] == [displayID integerValue];
        }] == NSNotFound) {
            if (error) {
                *error = [NSError errorWithDomain:@"com.binaryage.DisplaySpacesManager" code:1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Display not found, this config is for different displays", nil)}];
            }
            return;
        }
    }
    

    
    // Move the spaces
    for (NSString *displayID in config) {
        NSArray *spaces = config[displayID];
        CGDirectDisplayID targetDisplayID = [displayID intValue];

        unsigned int targetPosition = 1;

        for (NSString *spaceUUID in spaces) {
            
            NSDictionary *currentConfig = [self currentConfig];
            
            // Prepare a lookup for which display each space is currently on,
            // and which number it is
            NSMutableDictionary *spaceDisplays = [NSMutableDictionary dictionary];
            NSMutableDictionary *spacePositions = [NSMutableDictionary dictionary];
            for (NSString *displayID in currentConfig) {
                NSArray *spaces = currentConfig[displayID];
                
                unsigned int position = 1;
                
                for (NSString *spaceUUID in spaces) {
                    spaceDisplays[spaceUUID] = @([displayID intValue]);
                    spacePositions[spaceUUID] = @(position);
                    position++;
                }
            }
            
            NSNumber *fromDisplayNumber = spaceDisplays[spaceUUID];
            NSNumber *fromPosition = spacePositions[spaceUUID];
            if (!fromDisplayNumber || !fromPosition) {
                [BAMainViewController logMessage:[NSString stringWithFormat:@"Space %@ does not exist", spaceUUID]];
                continue;
            }
            
            CGDirectDisplayID fromDisplayID = [fromDisplayNumber unsignedIntValue];
            if (fromDisplayID != targetDisplayID) {
                unsigned int currentSpace = tsapi_currentSpaceNumberOnDisplay(fromDisplayID);
                if (currentSpace == [fromPosition unsignedIntValue]) {
                    [BAMainViewController logMessage:@"Can't move current space"];
                } else {
                    [BAMainViewController logMessage:[NSString stringWithFormat:@"Moving space %@ from display %d to display %d position %d", spaceUUID, fromDisplayID, targetDisplayID, targetPosition]];
                    BOOL result = tsapi_moveSpaceOnDisplayToPositionOnDisplay([fromPosition unsignedIntValue], fromDisplayID, targetPosition, targetDisplayID);
                    if (!result) [BAMainViewController logMessage:@"Move failed"];
                }
            }
            targetPosition++;
        }
    }
}

- (NSArray *)displayIDs
{
    struct tsapi_displays *displays = tsapi_displayList();
    unsigned int displaysCount = displays->displaysCount;
    NSMutableArray *displayIDs = [NSMutableArray array];
    for (int i=0; i < displaysCount; i++) {
        struct tsapi_display display = displays->displays[i];
        [displayIDs addObject:@(display.displayId)];
    }
    tsapi_freeDisplayList(displays);

    return displayIDs;
}

- (BOOL)versionCheck
{
    char *libVersion = (char *)tsapi_libTotalSpacesVersion();
    
    char *apiVersion = (char *)tsapi_apiVersion();
    
    BOOL result = NO;
    
    // cheap check, ok for versions < 10
    if (*libVersion == *apiVersion) result = YES;
    
    tsapi_freeString(libVersion);
    tsapi_freeString(apiVersion);
    
    if (!result) [BAMainViewController logMessage:@"Library failed version check, please upgrade TotalSpaces2"];
    
    return result;
}

@end
