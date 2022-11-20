//
//  ActivationController.h
//  iRooster
//
//  Created by Aaron Brethorst on Tue Aug 12 2003.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface ActivationController : NSWindowController {
    IBOutlet NSTextField *txtName;
    IBOutlet NSTextField *txtSerialNumber;
	BOOL success;
}	
- (IBAction)registerApp:(id)sender;
- (IBAction)cancel:(id)sender;
- (BOOL)success;
@end
