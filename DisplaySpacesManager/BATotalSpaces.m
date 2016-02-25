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
#import "BASpacesConfig.h"
#import "private.h"

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

// Regular spaces only, not fullscreen or dashboard
// Each space is an array of [uuid, spaceNumber]
//
NSArray *currentSpaceUUIDs(CGDirectDisplayID displayID)
{
    NSMutableArray *spaces = [NSMutableArray array];
    unsigned int numSpaces = tsapi_numberOfSpacesOnDisplay(displayID);
    for (int i=1; i<= numSpaces; i++) {
        char *spaceUUID = (char *)tsapi_uuidForSpaceNumberOnDisplay(i, displayID);
        NSUInteger type = tsapi_spaceTypeForSpaceNumberOnDisplay(i, displayID);
        if (spaceUUID && type == SpaceTypeDesktop) {
            [spaces addObject:@[[NSString stringWithFormat:@"%s", spaceUUID], @(i)]];
            tsapi_freeString(spaceUUID);
        }
    }
    return spaces;
}

NSDictionary *currentBindings()
{
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *spacesDefaults = [standardDefaults persistentDomainForName:@"com.apple.spaces"];
    // The key is the bundle id, the value is the space uuid
    NSDictionary *bindings = [spacesDefaults objectForKey:@"app-bindings"];
    if (!bindings) bindings = @{};
    return bindings;
}

- (NSDictionary *)currentConfig
{
    if (![self versionCheck]) return nil;
    
    NSArray *displayIDs = [self displayIDs];

    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    for (NSNumber *displayNumber in displayIDs) {
        NSString *displayNumberStr = [NSString stringWithFormat:@"%@", displayNumber];
        
        CGDirectDisplayID displayID = [displayNumber unsignedIntValue];

        NSArray *spaces = currentSpaceUUIDs(displayID);
        
        NSMutableArray *backgrounds = [NSMutableArray array];
        for (NSArray *spaceInfo in spaces) {
            NSString *uuid = spaceInfo[0];
            CFStringRef uuidRef = (__bridge CFStringRef)(uuid);
            
            NSDictionary *info = CFBridgingRelease(DesktopPictureCopyDisplayForSpace(displayID, 0, uuidRef));

            [backgrounds addObject:info];
        }
        
        NSMutableDictionary *names = [NSMutableDictionary dictionary];
        for (NSArray *spaceInfo in spaces) {
            NSString *uuid = spaceInfo[0];
            NSUInteger spaceNum = [spaceInfo[1] unsignedIntegerValue];
            char *name = (char *)tsapi_customNameForSpaceNumberOnDisplay((unsigned)spaceNum, displayID);
            if (name) {
                names[uuid] = [NSString stringWithFormat:@"%s", name];
                tsapi_freeString(name);
            }
        }
        
        unsigned int cols = tsapi_definedColumnsOnDisplay(displayID);
        
        NSDictionary *bindings = currentBindings();
        
        NSMutableArray *spacesArray = [NSMutableArray array];
        for (NSArray *spaceInfo in spaces) {
            [spacesArray addObject:spaceInfo[0]];
        }
        
        NSDictionary *configDict = @{@"spaces" : spacesArray, @"backgrounds" : backgrounds, @"bindings" : bindings, @"names" : names, @"columns" : @(cols)};
        BASpacesConfig *spacesConfig = [[BASpacesConfig alloc] initWithDictionary:configDict];
        if (spacesConfig) config[displayNumberStr] = spacesConfig;
        else return nil;
    }
    
    return config;
}

- (BOOL)configCanBeRestored:(NSDictionary *)config error:(NSError **)error
{
    if (![self versionCheck]) {
        *error = [NSError errorWithDomain:@"com.binaryage.DisplaySpacesManager" code:1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Cannot continue with restore", nil)}];
        return NO;
    }
    
    NSArray *displayIDs = [self displayIDs];
    
    if (displayIDs.count != config.count) {
        *error = [NSError errorWithDomain:@"com.binaryage.DisplaySpacesManager" code:1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"This config has a different number of displays than currently attached", nil)}];
        return NO;
    }
    
    // Check that all the required displays are currently attached
    for (NSString *displayID in config) {
        if ([displayIDs indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return [obj integerValue] == [displayID integerValue];
        }] == NSNotFound) {
            if (error) {
                *error = [NSError errorWithDomain:@"com.binaryage.DisplaySpacesManager" code:1 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Display not found, this config is for different displays", nil)}];
            }
            return NO;
        }
    }

    return YES;
}

- (void)restoreConfig:(NSDictionary *)config error:(NSError **)error
{
    if (![self configCanBeRestored:config error:error]) return;
    
    NSArray *displayIDs = [self displayIDs];

    // Move our own window to space 1
    tsapi_freeWindowList(tsapi_windowList()); // Don't need the result of this, but TS has to believe we got the windowID from it
    NSArray *windows = [[NSApplication sharedApplication] windows];
    NSWindow *window = [windows count] > 0 ? windows[0] : nil;
    tsapi_moveWindowToSpaceOnDisplay((unsigned)window.windowNumber, 1, [displayIDs[0] intValue]);

    // move to space 1 on each display
    for (NSString *displayID in config) {
        tsapi_moveToSpaceOnDisplay(1, [displayID intValue]);
    }
    
    // Configure the displays with the right number of spaces
    for (NSString *displayID in config) {
        BASpacesConfig *spacesConfig = config[displayID];
        CGDirectDisplayID targetDisplayID = [displayID intValue];
        // first set the columns
        tsapi_setDefinedColumnsOnDisplay((unsigned)spacesConfig.columns, targetDisplayID);
        
        NSUInteger numSpaces = [currentSpaceUUIDs(targetDisplayID) count];
        NSUInteger requiredSpaces = [spacesConfig.spaces count];
        if (numSpaces < requiredSpaces) { // add
            tsapi_addDesktopsOnDisplay((unsigned)(requiredSpaces - numSpaces), targetDisplayID);
        } else if (numSpaces > requiredSpaces) { // remove
            tsapi_removeDesktopsOnDisplay((unsigned)(numSpaces - requiredSpaces), targetDisplayID);
        }
    }

    for (NSString *displayID in config) {
        CGDirectDisplayID targetDisplayID = [displayID intValue];
        BASpacesConfig *spacesConfig = config[displayID];
        NSArray *originalSpaces = spacesConfig.spaces;
        NSArray *newSpaces = currentSpaceUUIDs(targetDisplayID);
        
        if ([originalSpaces count] != [newSpaces count]) {
            [BAMainViewController logMessage:[NSString stringWithFormat:@"Spaces were not created correctly, should have %ld but have %ld", [originalSpaces count], [newSpaces count]]];
            return;
        }
        
        NSDictionary *bindings = currentBindings();
        // Add the backgrounds and apply the names
        int i = 0;
        for (NSString *originalUUID in originalSpaces) {
            NSString *newSpaceUUID = newSpaces[i][0];
            NSUInteger newSpaceNum = [newSpaces[i][1] unsignedIntegerValue];
            
            // set the new background properties
            if ([spacesConfig.backgrounds count] <= i) break;
            NSDictionary *background = spacesConfig.backgrounds[i];
            DesktopPictureSetDisplayForSpace(targetDisplayID, (__bridge CFDictionaryRef)(background), 0, 0, (__bridge CFStringRef)(newSpaceUUID));
            
            // set the name
            NSString *name = spacesConfig.names[originalUUID];
            
            if (name) {
                tsapi_setNameForSpaceOnDisplay((unsigned)newSpaceNum, (char *)[name UTF8String], targetDisplayID);
            } else {
                tsapi_setNameForSpaceOnDisplay((unsigned)newSpaceNum, NULL, targetDisplayID);
            }
            
            // set the app bindings
            for (NSString *originalBundleID in spacesConfig.bindings) {
                NSString *originalBindingUUID = spacesConfig.bindings[originalBundleID];
                if ([originalBindingUUID isEqualToString:originalUUID]) {
                    BOOL found = NO;
                    for (NSString *curBundleID in bindings) {
                        if ([curBundleID isEqualToString:originalBundleID]) {
                            found = YES;
                            if ([bindings[curBundleID] isEqualToString:spacesConfig.bindings[originalBundleID]]) {
                                // nothing to do
                            } else {
                                // assign new desktop uuid
                                tsapi_bindAppToSpace((char *)[[curBundleID lowercaseString] UTF8String], (char *)[newSpaceUUID UTF8String]);
                            }
                        }
                    }
                    
                    // if not found in the current bindings, add it
                    if (!found) {
                        tsapi_bindAppToSpace((char *)[[originalBundleID lowercaseString] UTF8String], (char *)[newSpaceUUID UTF8String]);
                    }
                }
            }
            
            // extra bindings in the current setup are not removed
            i++;
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

#define TS_MIN_API_VERSION @"2.1"

- (BOOL)versionCheck
{
    char *apiVersion = (char *)tsapi_apiVersion();
    NSString *apiVersionString = [NSString stringWithFormat:@"%s", apiVersion];
    tsapi_freeString(apiVersion);

    BOOL result = NO;
    
    if ([TS_MIN_API_VERSION compare:apiVersionString options:NSNumericSearch] == NSOrderedAscending) result = YES;
    
    if (!result) [BAMainViewController logMessage:@"Library failed version check, please upgrade TotalSpaces2"];
    
    return result;
}

@end
