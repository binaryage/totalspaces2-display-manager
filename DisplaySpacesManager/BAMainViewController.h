//
//  BAMainViewController.h
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 19/04/14.
//  Copyright (c) 2014 Binaryage. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BALogView;

@interface BAMainViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSButtonCell *saveButton;
@property (weak) IBOutlet NSTableView *configsTable;
@property (weak) IBOutlet NSTableColumn *rightColumn;
@property (weak) IBOutlet NSTableColumn *midColumn;
@property (weak) IBOutlet BALogView *logView;

+ (void)logMessage:(NSString *)message;

@end
