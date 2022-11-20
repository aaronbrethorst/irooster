//
//  CSDatePicker.m
//  iRooster
//
//  Created by Aaron Brethorst on 3/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "CSDatePicker.h"

@implementation CSDatePicker
- (void)keyDown:(NSEvent *)theEvent
{
	if ([theEvent keyCode] == 36)
		[[self superview] keyDown:theEvent];
	else
		[super keyDown:theEvent];
}
@end
