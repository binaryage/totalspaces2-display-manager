//
//  BAAppDelegate.m
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 19/04/14.
//  Copyright (c) 2014 Binaryage. All rights reserved.
//

#import "BAAppDelegate.h"
#import "private.h"
#import "BAMostRecentAsync.h"

NSString *const kNotificationDisplayReconfig = @"displayReconfig";

@implementation BAAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver: self
                      selector: @selector(displayReconfiguration:)
                          name: NSApplicationDidChangeScreenParametersNotification
                        object: nil];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [[self window] makeKeyAndOrderFront:self];
    
    return NO;
}

- (void)displayReconfiguration:(NSNotification *)notification
{
    [BAMostRecentAsync executeMostRecentAfter:1 identifier:displayReconfigurationIdentifier block:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDisplayReconfig object:self];
    }];
}

@end
