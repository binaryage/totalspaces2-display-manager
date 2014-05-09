//
//  BALogView.m
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 09/05/14.
//  Copyright (c) 2014 Binaryage. All rights reserved.
//

#import "BALogView.h"

@implementation BALogView

- (void)addMessage:(NSString *)message
{
    NSString *date = [[NSDate  date] descriptionWithCalendarFormat:@"%H:%M:%S.%F" timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]];
    NSString *text = [NSString stringWithFormat:@"[%@] %@\n", date, message];

    [self.documentView setEditable:true];
    [self.documentView insertText:text];
    [self.documentView setSelectable:false];
}

- (void)awakeFromNib
{
    [self.documentView setSelectable:false];
}

@end
