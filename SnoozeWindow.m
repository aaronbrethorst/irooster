//
//  SnoozeWindow.m
//  iRooster
//
//  Created by Aaron Brethorst on Tue Jan 20 2004.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import "SnoozeWindow.h"

@interface NSObject (DelegateExtras)
- (void)snooze:(id)object;
@end

@implementation SnoozeWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)bufferingType defer:(BOOL)deferCreation
{
	if (self = [super initWithContentRect:contentRect styleMask:styleMask backing:bufferingType defer:deferCreation])
	{
	
	}
	
	return self;
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
	if ([self delegate] != nil && [[self delegate] respondsToSelector:@selector(snooze:)])
		[[self delegate] snooze:theEvent];
	
	[super keyDown:theEvent];
}
@end
