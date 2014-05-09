//
//  BALogView.h
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 09/05/14.
//  Copyright (c) 2014 Binaryage. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BALogView : NSScrollView

- (void)addMessage:(NSString *)message;

@end
