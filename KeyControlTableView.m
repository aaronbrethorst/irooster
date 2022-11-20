//
//  KeyControlTableView.m
//  iRooster
//
//  Created by Aaron Brethorst on Sun Jun 27 2004.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import "KeyControlTableView.h"

@interface KeyControlTableView (PrivateMethods)
- (void)dispatchToDoubleAction;
- (BOOL)dataSourceEmpty;
@end

@interface NSObject (CustomDataSource)
- (NSView*)placeholderViewRequest:(id)sender;
@end

@implementation KeyControlTableView

- (void)awakeFromNib
{
	NSString *locWatermark = NSLocalizedStringFromTable(@"Double-click to add a new alarm.",@"iRoosterStrings",@"Alarm table watermark text");
	strWatermark = [[NSAttributedString alloc] initWithString:locWatermark attributes:
		[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:13.0],NSFontAttributeName,[NSColor darkGrayColor],NSForegroundColorAttributeName,nil]];
	
	strSmallWatermark = [[NSAttributedString alloc] initWithString:locWatermark attributes:
		[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:11.0],NSFontAttributeName,[NSColor darkGrayColor],NSForegroundColorAttributeName,nil]];

	ptWatermark = NSMakePoint(3,3);
	
	[self setNeedsDisplay:YES];
}

- (void)dealloc
{
	[strWatermark release];
	[strSmallWatermark release];
	
	[super dealloc];
}

- (void)mouseDown:(NSEvent*)theEvent
{
	if ([theEvent clickCount] == 2)
		[self dispatchToDoubleAction];
	else
		[super mouseDown:theEvent];
}

- (void)dispatchToDoubleAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tblDoubleClick" object:self];
}

- (void)keyDown:(NSEvent *)theEvent
{
	NSString *keyString;
	unichar keyChar;
	
	keyString = [theEvent charactersIgnoringModifiers];
	keyChar = [keyString characterAtIndex:0];
	
	switch(keyChar)
	{
		case NSDeleteCharacter: // Delete key on an iBook.
		case NSDeleteFunctionKey:
		case NSDeleteCharFunctionKey:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"DeleteAlarm" object:nil];
			break;
		case CarriageReturnASCII:
			[[NSNotificationCenter defaultCenter] postNotificationName:@"EditAlarm" object:nil];
			break;
		case NSHomeFunctionKey:
		case NSPageUpFunctionKey:
			if ([self numberOfRows] > 0)
			{
				[self selectRow:0 byExtendingSelection:NO];
			}
			break;
		case NSEndFunctionKey:
		case NSPageDownFunctionKey:
			if ([self numberOfRows] > 0)
			{
				[self selectRow:([self numberOfRows] - 1) byExtendingSelection:NO];
			}
			break;
		default:
			[super keyDown:theEvent];
			break;
	}
}

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	
	if (![self dataSourceEmpty])
		return;
	
	if ([self bounds].size.width >= 400)
		[strWatermark drawAtPoint:ptWatermark];
	else
		[strSmallWatermark drawAtPoint:ptWatermark];
}

- (BOOL)dataSourceEmpty
{
	return [[self dataSource] numberOfRowsInTableView:self] == 0;
}
@end
