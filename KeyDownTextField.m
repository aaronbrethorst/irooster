//
//  KeyDownTextView.m
//  iRooster
//
//  Created by Aaron Brethorst on Sat Jul 26 2003.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import "KeyDownTextField.h"

@implementation KeyDownTextField

- (void)dealloc
{
	if (nil != incNotificationName)
		[incNotificationName release];
	if (nil != decNotificationName)
		[decNotificationName release];
	
	[super dealloc];
}

- (void)keyUp:(NSEvent*)theEvent
{
    if ([[theEvent characters] characterAtIndex:0] == NSUpArrowFunctionKey)
    {
        [[NSNotificationCenter defaultCenter]
			postNotificationName:(incNotificationName == nil ? @"StepValueUp" : incNotificationName) object:self];
        
		[self selectText:self];
    }
    else if ([[theEvent characters] characterAtIndex:0] == NSDownArrowFunctionKey)
    {
        [[NSNotificationCenter defaultCenter]
			postNotificationName:(decNotificationName == nil ? @"StepValueDown" : decNotificationName) object:self];
        
		[self selectText:self];
    }
    else
    {
        [super keyUp:theEvent];
    }
}

- (void)setDecNotificationName:(NSString*)n
{
	[decNotificationName release];
	decNotificationName = [[NSString alloc] initWithString:n];
}

- (NSString*)decNotificationName
{
	return decNotificationName;
}

- (void)setIncNotificationName:(NSString*)n
{
	[incNotificationName release];
	incNotificationName = [[NSString alloc] initWithString:n];
}

- (NSString*)incNotificationName
{
	return incNotificationName;
}
@end
