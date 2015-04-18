//
//  BAMainViewController.m
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 19/04/14.
//  Copyright (c) 2014 Binaryage. All rights reserved.
//

#import "BAMainViewController.h"
#import "BAAppDelegate.h"
#import "BASpacesConfigs.h"
#import "BASpacesConfig.h"
#import "BATotalSpaces.h"
#import "BALogView.h"

NSString *const kPreferenceRestoreAutomaticallyOnDisplayChange = @"restoreAutomaticallyOnDisplayChange";

@implementation BAMainViewController

static BAMainViewController *mainController;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        mainController = self;
        
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(displaysChanged) name:kNotificationDisplayReconfig object:nil];
    }
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    NSArray *names = [[BASpacesConfigs instance] configNames];
    return [names count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if (aTableColumn == self.rightColumn || aTableColumn == self.farRightColumn) return @"";

    NSArray *names = [[BASpacesConfigs instance] configNames];
    if (rowIndex >= [names count]) return @"??";
    NSDictionary *config = [[BASpacesConfigs instance] configWithName:names[rowIndex]];

    if (aTableColumn == self.midColumn) {
        NSUInteger displays = [config count];
        return [NSString stringWithFormat:@"%ld", displays];
    } else {
        return [NSString stringWithFormat:@"%@", names[rowIndex]];
    }
}


- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (!tableColumn) return nil;
    if (tableColumn == self.rightColumn) {
        NSButtonCell *buttonCell = [[NSButtonCell alloc] init];
        [buttonCell setButtonType:NSMomentaryPushInButton];
        [buttonCell setBezelStyle:NSRoundedBezelStyle];
        [buttonCell setControlSize:NSSmallControlSize];
        [buttonCell setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
        [buttonCell setTitle:@"Restore"];
        [buttonCell setTarget:self];
        [buttonCell setAction:@selector(restoreButtonPushed:)];
        buttonCell.tag = row;
        
        return buttonCell;
    } else if (tableColumn == self.farRightColumn) {
        NSButtonCell *buttonCell = [[NSButtonCell alloc] init];
        [buttonCell setButtonType:NSMomentaryPushInButton];
        [buttonCell setBezelStyle:NSRoundedBezelStyle];
        [buttonCell setControlSize:NSSmallControlSize];
        [buttonCell setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSSmallControlSize]]];
        [buttonCell setTitle:@"Delete"];
        [buttonCell setTarget:self];
        [buttonCell setAction:@selector(deleteButtonPushed:)];
        buttonCell.tag = row;
        
        return buttonCell;
    } else {
        return [[NSTextFieldCell alloc] init];
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldTrackCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([cell isKindOfClass:[NSButtonCell class]]) return YES;
    return NO;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    return NO;
}

- (void)restoreButtonPushed:(NSTableView *)tableView
{
    NSUInteger row = tableView.selectedTag;
    NSArray *names = [[BASpacesConfigs instance] configNames];
    if (row >= [names count]) return;
    NSString *name = names[row];
    NSDictionary *selectedConfig = [[BASpacesConfigs instance] configWithName:name];

    NSError *error = nil;
    [[BATotalSpaces instance] restoreConfig:selectedConfig error:&error];
    
    if (error) {
        [self.logView addMessage:[error localizedDescription]];
    } else {
        [BAMainViewController logMessage:@"Restored"];
    }
}

- (void)deleteButtonPushed:(NSTableView *)tableView
{
    NSUInteger row = tableView.selectedTag;
    NSArray *names = [[BASpacesConfigs instance] configNames];
    if (row >= [names count]) return;
    NSString *name = names[row];
    NSDictionary *selectedConfig = [[BASpacesConfigs instance] configWithName:name];
    
    if (selectedConfig) {
        [[BASpacesConfigs instance] delete:name];
        [self.configsTable reloadData];
        [BAMainViewController logMessage:@"Deleted"];
    }
}

// see http://stackoverflow.com/questions/7387341/how-to-create-and-get-return-value-from-cocoa-dialog
//
- (NSString *)getName: (NSString *)prompt defaultValue: (NSString *)defaultValue {
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        return nil;
    }
}

- (IBAction)saveButtonPressed:(NSButton *)button
{
    NSString *name = @"";
    NSArray *existingNames = [[BASpacesConfigs instance] configNames];
    while ([name isEqualToString:@""] || [existingNames containsObject:name]) {
        name = [self getName:@"Setting name" defaultValue:name];
    }
    if (name) {
        NSDictionary *currentConfig = [[BATotalSpaces instance] currentConfig];
        if (!currentConfig) [BAMainViewController logMessage:@"Error reading current config"];
        else {
            [[BASpacesConfigs instance] save:name config:currentConfig];
            [BAMainViewController logMessage:@"Saved"];
        }
    }
    
    [self.configsTable reloadData];
}

- (BOOL)restoreAutomaticallyOnDisplayChange
{
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    NSUserDefaults *defaults = [defaultsController defaults];
    return [defaults boolForKey:kPreferenceRestoreAutomaticallyOnDisplayChange];
}

- (void)displaysChanged
{
    if (![self restoreAutomaticallyOnDisplayChange]) return;
    
    [self.class logMessage:@"Displays changed"];
    NSArray *names = [[BASpacesConfigs instance] configNames];
    for (NSString *name in names) {
        NSDictionary *selectedConfig = [[BASpacesConfigs instance] configWithName:name];

        NSError *error = nil;
        
        if (![[BATotalSpaces instance] configCanBeRestored:selectedConfig error:&error]) continue;
        
        [self.class logMessage:[NSString stringWithFormat:@"Config %@ matches displays, restoring it", name]];
        
        [[BATotalSpaces instance] restoreConfig:selectedConfig error:&error];
    
        if (error) {
            [self.logView addMessage:[error localizedDescription]];
        } else {
            [BAMainViewController logMessage:@"Restored"];
            break;
        }
    }
}

+ (void)logMessage:(NSString *)message
{
    [mainController.logView addMessage:message];
}

@end
