//
//  AlarmTest.m
//  irooster
//
//  Created by Aaron Brethorst on 8/26/06.
//  Copyright 2006 Chimp Software LLC. All rights reserved.
//

#import "AlarmTest.h"
#import "Alarm.h"

@implementation AlarmTest

- (void)testRepeatEqualsFalseForSingleFireAlarms
{
	NSCalendarDate *calDate = [NSCalendarDate calendarDate];
	Alarm *alarm = [[Alarm alloc] initWithFireDate:calDate playlist:@"Library"];
	
	STAssertFalse([[alarm daysToRepeat] hasRepeatingDays], @"This alarm should not have repeating days!");
	
	[alarm release];
}

- (void)testControllerMethodOfBuildingAlarms
{
	NSString *playlist = @"Library";
	NSCalendarDate *date = [NSCalendarDate calendarDate];
	DaysToRepeat* dtr = [[DaysToRepeat alloc] initWithTime:date monday:NO tuesday:NO wednesday:NO thursday:NO friday:NO saturday:NO sunday:NO];
	PlaylistType playlistType = Playlist;
	
	Alarm *newAlarm = [[Alarm alloc] initWithFireDate:date playlist:playlist daysToRepeat:dtr playlistType:playlistType];

	STAssertFalse([[newAlarm daysToRepeat] hasRepeatingDays], @"This alarm should not have any repeating days!");
	
	[dtr release];
	[newAlarm release];
}

- (void)testRepeatingAlarmTimeCorrectness
{
	NSCalendarDate *calDate = [NSCalendarDate dateWithYear:2008 month:12 day:21 hour:11 minute:22 second:33 timeZone:nil];

	NSCalendarDate *repeatingCalDate = [NSCalendarDate dateWithYear:2008 month:1 day:1 hour:23 minute:47 second:11 timeZone:nil];
	
	DaysToRepeat *dtr = [[DaysToRepeat alloc] initWithTime:repeatingCalDate monday:NO tuesday:YES wednesday:NO
														thursday:YES friday:NO saturday:YES sunday:NO];

	Alarm *a = [[Alarm alloc] initWithFireDate:calDate playlist:@"Library" daysToRepeat:dtr playlistType:Library];
	
	STAssertEquals(23, [[a fireDate] hourOfDay], @"Hour of day should have been 23, but was actually %d",[[a fireDate] hourOfDay]);
	
	STAssertEquals(47, [[a fireDate] minuteOfHour], @"Minute of hour should have been 47, but was actually %d",[[a fireDate] minuteOfHour]);
	
	STAssertEquals(11, [[a fireDate] secondOfMinute], @"second of minute should have been 11, but was actually %d",[[a fireDate] secondOfMinute]);
	
	[dtr release];
	[a release];
}

- (void)testisAlarmValid
{
	//STAssertTrue(NO, @"Add test");
}

//why isn't this failing?
- (void)testOneTimePlusRepeatingAlarmCreation
{
	NSCalendarDate *oneTimeDate = [NSCalendarDate dateWithString:@"Monday 09:00 AM" calendarFormat:@"%A %I:%M %p"];
	NSCalendarDate *time = [NSCalendarDate dateWithYear:0 month:0 day:0 hour:9 minute:0 second:0 timeZone:nil];
	DaysToRepeat *dtrOneTime = [[DaysToRepeat alloc] initWithTime:time monday:NO tuesday:NO wednesday:NO thursday:NO friday:NO saturday:NO sunday:NO];
	DaysToRepeat *dtrRepeat = [[DaysToRepeat alloc] initWithTime:time monday:NO tuesday:YES wednesday:NO thursday:NO friday:NO saturday:NO sunday:NO];
	
	Alarm *oneTimeAlarm = [[Alarm alloc] initWithFireDate:oneTimeDate playlist:@"Library" daysToRepeat:dtrOneTime playlistType:Playlist];
	Alarm *repeatingAlarm = [[Alarm alloc] initWithFireDate:oneTimeDate playlist:@"Top 25 Most Played" daysToRepeat:dtrRepeat playlistType:Playlist];
	
	STAssertFalse([[oneTimeAlarm fireDate] isEqualTo:[repeatingAlarm fireDate]], @"These alarms should have different fire dates! instead, it says that they are %@ and %@",oneTimeAlarm, repeatingAlarm);
	
	[dtrOneTime release];
	[dtrRepeat release];
	[oneTimeAlarm release];
	[repeatingAlarm release];
}
@end
