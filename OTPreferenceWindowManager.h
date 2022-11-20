//
//  OTPreferenceWindowManager.h
//
//  Created by Tony Million on 27/09/2004.
//  Copyright 2004 Tony Million. All rights reserved.
//
// to contact me: email/AIM sexosonic@mac.com

#import <Cocoa/Cocoa.h>


@interface OTPreferenceWindowManager : NSObject 
{
	IBOutlet		NSWindow		*		preferencesWindow;
	IBOutlet		NSView			*		blankView;
	IBOutlet		id						delegate;

	NSToolbar						*		toolbar;
	int										numViews;
	NSMutableArray					*		identifierArray;
	
	float									maxWidth;
}

- (void)resizeWindowToSize:(NSSize)newSize;
- (void)switchToView:(id)sender;

@end


@interface NSObject ( OTPreferenceWindowManagerDelegate )

-(int)numberOfViewsInPreferenceWindow:(OTPreferenceWindowManager*)prefs;

-(NSView*)	viewForPreferencePane:(OTPreferenceWindowManager*)prefs		atIndex:(int)index;
-(NSString*)labelForPreferencePane:(OTPreferenceWindowManager*)prefs	atIndex:(int)index;
-(NSImage*)	iconForPreferencePane:(OTPreferenceWindowManager*)prefs		atIndex:(int)index;

@end
