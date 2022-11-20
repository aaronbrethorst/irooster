//
//  NSWorkspace+Extras.m
//  iRooster
//
//  Created by Aaron Brethorst on 3/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSWorkspace+Extras.h"

@implementation NSWorkspace (Extras)
- (BOOL)isAppRunning:(NSString*)title;
{
	NSArray *apps = [self launchedApplications];
	
	for (int i=0; i<[apps count];i++)
	{
		if ([[[apps objectAtIndex:i] objectForKey:@"NSApplicationName"] isEqual:title])
			return YES;
	}
	return NO;
}
@end