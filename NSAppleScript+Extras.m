//
//  NSAppleScript+Extras.m
//  iRooster
//
//  Created by Aaron Brethorst on 12/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "NSAppleScript+Extras.h"

@implementation NSAppleScript (Extras)
+ (void)playAppleScript:(NSString*)script;
{
	NSAppleScript *player;
	player = [[NSAppleScript alloc] initWithSource:script];
	[player executeAndReturnError:nil];
	[player release];
}
@end
