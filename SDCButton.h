//
//  SDCButton.h
//  iRooster
//
//  Created by Aaron Brethorst on 9/1/04.
//  Copyright 2004 Chimp Software LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SDCButton : NSButton {
	NSImage *pulseImage;
	NSImage *unpulseImage;
	NSTimer *tmrPulse;
}
- (void)setPulseImage:(NSImage*)img;
- (NSImage*)pulseImage;

- (void)setUnpulseImage:(NSImage*)img;
- (NSImage*)unpulseImage;
@end
