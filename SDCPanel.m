//
//  SDCPanel.m
//  iRooster
//
//  Created by Aaron Brethorst on 12/21/04.
//  Copyright 2004 Chimp Software LLC. All rights reserved.
//

#import "SDCPanel.h"


@implementation SDCPanel
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask backing:(NSBackingStoreType)backingType defer:(BOOL)flag
{
	if (self = [super initWithContentRect:contentRect styleMask:styleMask backing:backingType defer:flag])
	{
		mnemonics = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc
{
	[mnemonics release];
	[super dealloc];
}

- (void)addControl:(NSControl*)control mnemonic:(NSString*)mnemonic
{
	[mnemonics setObject:control forKey:[mnemonic lowercaseString]];
}

- (void)keyDown:(NSEvent*)theEvent
{
	NSString *keyCode = [[theEvent charactersIgnoringModifiers] lowercaseString];
	NSControl *control = nil;
	
	if ((control = [mnemonics objectForKey:keyCode]) != nil)
		[NSApp sendAction:[control action] to:[control target] from:control]; //act as if the control's target/action mechanism was just invoked.
	else
		[super keyDown:theEvent];
}
@end
