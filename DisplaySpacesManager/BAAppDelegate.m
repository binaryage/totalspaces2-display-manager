//
//  BAAppDelegate.m
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 19/04/14.
//  Copyright (c) 2014 Binaryage. All rights reserved.
//

#import "BAAppDelegate.h"

@implementation BAAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [[self window] makeKeyAndOrderFront:self];
    
    return NO;
}


@end
