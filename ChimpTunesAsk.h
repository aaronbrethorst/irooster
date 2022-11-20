//
//  ChimpTunesAsk.h
//  iRooster
//
//  Created by Aaron Brethorst on 12/18/04.
//  Copyright 2004 Chimp Software LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ChimpTunesAsk : NSWindowController
{
    IBOutlet NSButton *chkDownloadArt;
    IBOutlet NSButton *chkEnableChimpTunes;
}
- (IBAction)ok:(id)sender;
@end
