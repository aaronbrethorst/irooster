//
//  FlatKeyDownTextField.m
//  iRooster
//
//  Created by Aaron Brethorst on Sun Apr 18 2004.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import "FlatKeyDownTextField.h"


@implementation FlatKeyDownTextField
- (void)drawRect:(NSRect)frame
{
	NSColor *border = [NSColor colorWithCalibratedRed:(158.0/255.0) green:(158.0/255.0) blue:(158.0/255.0) alpha:1.0];		
	
	[[NSColor whiteColor] set];
	NSRectFill([self bounds]);
	
	[border set];
	NSFrameRect([self bounds]);
	
	[[self cell] drawInteriorWithFrame:frame inView:self];
}
@end
