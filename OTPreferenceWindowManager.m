//
//  OTPreferenceWindowManager.m
//
//  Created by Tony Million on 27/09/2004.
//  Copyright 2004 Tony Million. All rights reserved.
//
// to contact me: email/AIM sexosonic@mac.com

#import "OTPreferenceWindowManager.h"


@implementation OTPreferenceWindowManager

-(void)awakeFromNib
{
	numViews = [delegate numberOfViewsInPreferenceWindow:self];
	
	identifierArray = [[NSMutableArray array] retain];
	
	maxWidth = 0;
	
	for(int x=0; x<numViews; x++)
	{
		if ([[delegate viewForPreferencePane:self atIndex:x] frame].size.width > maxWidth)
		{
			maxWidth = [[delegate viewForPreferencePane:self atIndex:x] frame].size.width;
		}
		[identifierArray addObject:[NSString stringWithFormat:@"%d", x]];
	}
	
	// initialize the toolbar
	toolbar = [[NSToolbar alloc] initWithIdentifier:@"PreferencesToolbar"];
	[toolbar setAllowsUserCustomization:NO];
	[toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
	[toolbar setDelegate:self];
	
	[preferencesWindow setToolbar:toolbar];
	[toolbar	setSelectedItemIdentifier:@"0"];	
	
	//set the first view!
	NSView * initialView = [delegate viewForPreferencePane:self atIndex:0];
    [preferencesWindow setContentSize:NSMakeSize(maxWidth,[initialView frame].size.height)];
    [preferencesWindow setContentView:initialView];
	
}


//////////////////////////////////////////////////////////////

-(float) toolbarHeight
{
    float toolbarHeight = 0.0;
    NSRect windowFrame;
    NSToolbar* toolbarTwo = [preferencesWindow toolbar];
    if(toolbarTwo && [toolbarTwo isVisible])
    {
        windowFrame = [NSWindow contentRectForFrameRect:[preferencesWindow frame]
                                              styleMask:[preferencesWindow styleMask]];
        toolbarHeight = NSHeight(windowFrame) - NSHeight([[preferencesWindow contentView] frame]);
    }
    return toolbarHeight;
}

-(void) resizeWindowToSize:(NSSize)newsize
{
    NSRect aFrame;
	
    float newHeight = newsize.height + [self toolbarHeight];
    float newWidth  = maxWidth;
	
    aFrame = [NSWindow contentRectForFrameRect:[preferencesWindow frame]
                                     styleMask:[preferencesWindow styleMask]];
	
    aFrame.origin.y += aFrame.size.height;
    aFrame.origin.y -= newHeight;
    aFrame.size.height = newHeight;
    aFrame.size.width  = newWidth;
	
    aFrame = [NSWindow frameRectForContentRect:aFrame
                                     styleMask:[preferencesWindow styleMask]];
	
    [preferencesWindow setFrame:aFrame display:YES animate:YES];
}


- (void)switchToView:(id)sender
{
	int index = [[sender itemIdentifier] intValue];
	
	NSView * newView = [delegate viewForPreferencePane:self atIndex:index];
	
	if([preferencesWindow contentView] == newView)
		return;
	
	[preferencesWindow setContentView:blankView];
	
	[self resizeWindowToSize:[newView frame].size];
	
	[preferencesWindow setContentView:newView];
}

///////////////////////////////////////////////////////////////////////////

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar*)toolbar
{
	return identifierArray;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
	return identifierArray;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
	return identifierArray;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
	
	int toolbarItemInt = [itemIdentifier intValue];
	
	[item setLabel:[delegate labelForPreferencePane:self atIndex:toolbarItemInt]];
	[item setImage:[delegate iconForPreferencePane:self atIndex:toolbarItemInt]];
	[item setTarget:self];
	[item setAction:@selector(switchToView:)];
    
    return item;
}
@end