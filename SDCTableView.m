//
//  SDCTableView.m
//  iRooster
//
//  Created by Aaron Brethorst on 3/9/05.
//  Copyright 2005 Chimp Software LLC. All rights reserved.
//

#import "SDCTableView.h"

/*
 CoreGraphics gradient helpers
 */

typedef struct {
    float red1, green1, blue1, alpha1;
    float red2, green2, blue2, alpha2;
} _twoColorsType;

static void _linearColorBlendFunction(void *info, const float *in, float *out)
{
    _twoColorsType *twoColors = info;
    
    out[0] = (1.0 - *in) * twoColors->red1 + *in * twoColors->red2;
    out[1] = (1.0 - *in) * twoColors->green1 + *in * twoColors->green2;
    out[2] = (1.0 - *in) * twoColors->blue1 + *in * twoColors->blue2;
    out[3] = (1.0 - *in) * twoColors->alpha1 + *in * twoColors->alpha2;
}

static void _linearColorReleaseInfoFunction(void *info)
{
    free(info);
}

static const CGFunctionCallbacks linearFunctionCallbacks = {0, &_linearColorBlendFunction, &_linearColorReleaseInfoFunction};

@interface SDCTableView (PrivateMethods)
- (void)dispatchToDoubleAction;
- (BOOL)dataSourceEmpty;
@end

@implementation SDCTableView
- (void)awakeFromNib
{
	[self setWatermark:@""];
	ptWatermark = NSMakePoint(3,3);
}

- (void)dealloc
{
	[strWatermark release];
	[strSmallWatermark release];
	
	[super dealloc];
}

- (void)setWatermark:(NSString*)watermark
{
	strWatermark = [[NSAttributedString alloc] initWithString:watermark attributes:
		[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:13.0],NSFontAttributeName,[NSColor darkGrayColor],NSForegroundColorAttributeName,nil]];
	
	strSmallWatermark = [[NSAttributedString alloc] initWithString:watermark attributes:
		[NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:11.0],NSFontAttributeName,[NSColor darkGrayColor],NSForegroundColorAttributeName,nil]];
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

- (void)setAcceptsFirstMouse:(BOOL)flag;
{
    flags.acceptsFirstMouse = flag;
}

// NSView subclass

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    if (flags.acceptsFirstMouse)
        return [NSApp isActive];
	
    return [super acceptsFirstMouse:theEvent];
}

// NSTableView subclass

- (id)_highlightColorForCell:(NSCell *)cell;
{
    return nil;
}

- (void)highlightSelectionInClipRect:(NSRect)rect;
{
    // Take the color apart
    NSColor *alternateSelectedControlColor = [NSColor alternateSelectedControlColor];
    float hue, saturation, brightness, alpha;
    [[alternateSelectedControlColor colorUsingColorSpaceName:NSDeviceRGBColorSpace] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
	
    // Create synthetic darker and lighter versions
    // NSColor *lighterColor = [NSColor colorWithDeviceHue:hue - (1.0/120.0) saturation:MAX(0.0, saturation-0.12) brightness:MIN(1.0, brightness+0.045) alpha:alpha];
    NSColor *lighterColor = [NSColor colorWithDeviceHue:hue saturation:MAX(0.0, saturation-.12) brightness:MIN(1.0, brightness+0.30) alpha:alpha];
    NSColor *darkerColor = [NSColor colorWithDeviceHue:hue saturation:MIN(1.0, (saturation > .04) ? saturation+0.12 : 0.0) brightness:MAX(0.0, brightness-0.045) alpha:alpha];
    
    // If this view isn't key, use the gray version of the dark color. Note that this varies from the standard gray version that NSCell returns as its highlightColorWithFrame: when the cell is not in a key view, in that this is a lot darker. Mike and I think this is justified for this kind of view -- if you're using the dark selection color to show the selected status, it makes sense to leave it dark.
    if ([[self window] firstResponder] != self || ![[self window] isKeyWindow]) {
        alternateSelectedControlColor = [[alternateSelectedControlColor colorUsingColorSpaceName:NSDeviceWhiteColorSpace] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
        lighterColor = [[lighterColor colorUsingColorSpaceName:NSDeviceWhiteColorSpace] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
        darkerColor = [[darkerColor colorUsingColorSpaceName:NSDeviceWhiteColorSpace] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    }
    
    // Set up the helper function for drawing washes
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    _twoColorsType *twoColors = malloc(sizeof(_twoColorsType)); // We malloc() the helper data because we may draw this wash during printing, in which case it won't necessarily be evaluated immediately. We need for all the data the shading function needs to draw to potentially outlive us.
    [lighterColor getRed:&twoColors->red1 green:&twoColors->green1 blue:&twoColors->blue1 alpha:&twoColors->alpha1];
    [darkerColor getRed:&twoColors->red2 green:&twoColors->green2 blue:&twoColors->blue2 alpha:&twoColors->alpha2];
    static const float domainAndRange[8] = {0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0};
    CGFunctionRef linearBlendFunctionRef = CGFunctionCreate(twoColors, 1, domainAndRange, 4, domainAndRange, &linearFunctionCallbacks);
    
    NSEnumerator *selectedRowEnumerator = [self selectedRowEnumerator];
    NSNumber *rowIndexNumber = [selectedRowEnumerator nextObject];
    unsigned int rowIndex = rowIndexNumber ? [rowIndexNumber unsignedIntValue] : NSNotFound;
	
    while (rowIndex != NSNotFound) {
        unsigned int endOfCurrentRunRowIndex, newRowIndex = rowIndex;
        do {
            endOfCurrentRunRowIndex = newRowIndex;
			
            rowIndexNumber = [selectedRowEnumerator nextObject];
            newRowIndex = rowIndexNumber ? [rowIndexNumber unsignedIntValue] : NSNotFound;
			
        } while (newRowIndex == endOfCurrentRunRowIndex + 1);
		
        NSRect rowRect = NSUnionRect([self rectOfRow:rowIndex], [self rectOfRow:endOfCurrentRunRowIndex]);
        
        NSRect topBar, washRect;
        NSDivideRect(rowRect, &topBar, &washRect, 1.0, NSMinYEdge);
        
        // Draw the top line of pixels of the selected row in the alternateSelectedControlColor
        [alternateSelectedControlColor set];
        NSRectFill(topBar);
		
        // Draw a soft wash underneath it
        CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
        CGContextSaveGState(context); {
            CGContextClipToRect(context, (CGRect){{NSMinX(washRect), NSMinY(washRect)}, {NSWidth(washRect), NSHeight(washRect)}});
            CGShadingRef cgShading = CGShadingCreateAxial(colorSpace, CGPointMake(0, NSMinY(washRect)), CGPointMake(0, NSMaxY(washRect)), linearBlendFunctionRef, NO, NO);
            CGContextDrawShading(context, cgShading);
            CGShadingRelease(cgShading);
        } CGContextRestoreGState(context);
		
        rowIndex = newRowIndex;
    }
	
    CGFunctionRelease(linearBlendFunctionRef);
    CGColorSpaceRelease(colorSpace);
}

- (void)selectRow:(int)row byExtendingSelection:(BOOL)extend;
{
    [super selectRow:row byExtendingSelection:extend];
    [self setNeedsDisplay:YES]; // we display extra because we draw multiple contiguous selected rows differently, so changing one row's selection can change how others draw.
}

- (void)deselectRow:(int)row;
{
    [super deselectRow:row];
    [self setNeedsDisplay:YES]; // we display extra because we draw multiple contiguous selected rows differently, so changing one row's selection can change how others draw.
}
@end
