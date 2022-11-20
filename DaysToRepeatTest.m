//
//  DaysToRepeatTest.m
//  irooster
//
//  Created by Aaron Brethorst on 8/26/06.
//  Copyright 2006 Chimp Software LLC. All rights reserved.
//

#import "DaysToRepeatTest.h"


@implementation DaysToRepeatTest
- (void)testSimpleRepeats
{
	DaysToRepeat *dtr = [[DaysToRepeat alloc] initWithTime:nil monday:YES tuesday:YES wednesday:YES thursday:YES friday:YES saturday:YES sunday:YES];
	
	STAssertTrue([dtr monday], @"Monday should've been true.");
	STAssertTrue([dtr tuesday], @"Tuesday should've been true.");
	STAssertTrue([dtr wednesday], @"Wednesday should've been true.");
	STAssertTrue([dtr thursday], @"Thursday should've been true.");
	STAssertTrue([dtr friday], @"Friday should've been true.");
	STAssertTrue([dtr saturday], @"Saturday should've been true.");
	STAssertTrue([dtr sunday], @"Sunday should've been true.");
	
	[dtr release];
}
@end
