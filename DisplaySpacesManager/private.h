//
//  private.h
//  DisplaySpacesManager
//
//  Created by Stephen Sykes on 12/01/15.
//  Copyright (c) 2015 Binaryage. All rights reserved.
//

#ifndef DisplaySpacesManager_private_h
#define DisplaySpacesManager_private_h

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

/*
 Returns a dictionary containing some of these:
 
 ImageFilePath (string)
 LastName (string)
 ChangeTime (int)
 ChangePath (string)
 NewChangePath (string)
 NewImageFilePath (string)
 NoImage (bool)
 BackgroundColor (array containing rgb floats)
 Change (string, can be "TimeInterval")
 Random (bool)
 Placement (string, can be "SizeToFit", "FillScreen", "Centered", "Tiled")
 */
CFDictionaryRef DesktopPictureCopyDisplayForSpace(CGDirectDisplayID display, int unused, CFStringRef spaceUUID);

/*
 If you pass a string for keys ImageFilePath, ChangePath or ChooseFolderPath,
 it will have tilde substitution done, and be placed in NewImageFilePath, NewChangePath
 or NewChooseFolderPath.
 */
void DesktopPictureSetDisplayForSpace(CGDirectDisplayID display, CFDictionaryRef settings, int unused1, int unused2, CFStringRef spaceUUID);

#endif
