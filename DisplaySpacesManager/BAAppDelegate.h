//
//  BAAppDelegate.h
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 19/04/14.
//  Copyright (c) 2014 Binaryage. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *const kNotificationDisplayReconfig;

@interface BAAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@end
