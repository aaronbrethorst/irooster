//
//  SDCTableView.h
//  iRooster
//
//  Created by Aaron Brethorst on 3/9/05.
//  Copyright 2005 Chimp Software LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define BackDeleteASCII 127
#define CarriageReturnASCII 13

@interface SDCTableView : NSTableView {
	NSAttributedString* strWatermark;
	NSAttributedString* strSmallWatermark;
	NSPoint ptWatermark;

	struct
	{
        unsigned int acceptsFirstMouse:1;
    } flags;
}
- (void)setAcceptsFirstMouse:(BOOL)flag;
- (void)setWatermark:(NSString*)watermark;
@end
