//
//  AlarmManager.m
//  iRooster
//
//  Created by Aaron Brethorst on Sun Jun 15 2003.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import "AlarmManager.h"
#import "Alarm.h"
#import "PowerManager.h"
#import "AppPreferences.h"
#import "NSWorkspace+Extras.h"

@interface AlarmManager (Private)
- (void)_registerNextAlarmEvent;
- (void)_runAlarmAction;
- (void)_pulse:(id)sender;
- (void)_setNextFireDate:(NSCalendarDate*)fireDate;
- (BOOL)_iRoosterIsRunning;
@end

@implementation AlarmManager

- (id)init
{
	return [self initAsReadOnly:NO delegate:nil];
}

- (id)initAsReadOnly:(BOOL)yn delegate:(id)delegate
{
    if (self = [super init])
    {		
		if (nil == [AppPreferences alarms])
		{
			dataSource = [[NSMutableArray alloc] init];
		}
		else
		{
			dataSource = [[NSKeyedUnarchiver unarchiveObjectWithData:[AppPreferences alarms]] retain];
		}
		
		[self _registerNextAlarmEvent];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(writeState:)
													 name:@"NSApplicationWillTerminateNotification" object:nil];
		
		_readOnly = yn;
		_delegate = [delegate retain];

		timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_pulse:) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[dataSource release];
	[_delegate release];
	[timer invalidate];
    [super dealloc];
}

- (int)count
{
    return [dataSource count];
}

- (Alarm*)alarmAtIndex:(int)index
{
    return [dataSource objectAtIndex:index];
}

- (void)addAlarm:(Alarm*)anAlarm
{
	NSLog(@"Adding an alarm.");

	if ([self count] > 0)
	{
		NSLog(@"Canceling the first wake event in the queue (should be the only wake event in the queue): %@.", [[self alarmAtIndex:0] fireDate]);
		[PowerManager cancelWakeEvent:[[self alarmAtIndex:0] fireDate]];
	}
	
	//check to see if the date/dtr values match up for any alarm
	for (int i=0; i<[dataSource count]; i++)
	{
		Alarm *candidate = [dataSource objectAtIndex:i];
		
		if ([[candidate fireDate] isEqual:[anAlarm fireDate]] || ([[candidate daysToRepeat] isEqual:[anAlarm daysToRepeat]] && [[candidate daysToRepeat] hasRepeatingDays] && [[anAlarm daysToRepeat] hasRepeatingDays]))
		{
			NSLog(@"found an existing match, removing it!");
			[dataSource removeObject:candidate];
			break;
		}
	}
	
	NSLog(@"Adding a new alarm to our data structure: %@", anAlarm);
	[dataSource addObject:anAlarm];
	
	[self _registerNextAlarmEvent];
}

- (void)deleteAlarmAtIndex:(int)index
{
	NSLog(@"Deleting an alarm at index %d", index);
	
	NSAssert1(index >= 0 && index < [self count], @"Alarm index to delete was outside of bounds: %d", index);

	NSDate* dateToRemove = [[self alarmAtIndex:index] fireDate];
	NSLog(@"Found our date to remove: %@", dateToRemove);
	
	if ([PowerManager wakeEventForDateExists:dateToRemove])
	{
		NSLog(@"Canceling our wake up event in the PowerManager.");
		[PowerManager cancelWakeEvent:dateToRemove];
	}
	else
	{
		NSLog(@"This alarm was not first in queue, and doesn't have a wake event associated with it. Nothing to do.");
	}
	NSLog(@"Removing alarm from our data source.");
    [dataSource removeObjectAtIndex:index];
	
	[self _registerNextAlarmEvent];
}

- (void)writeState:(id)sender
{
	[AppPreferences setAlarms:[NSKeyedArchiver archivedDataWithRootObject:dataSource]];
}
@end

@implementation AlarmManager (Private)
- (void)_registerNextAlarmEvent
{
	NSLog(@"Registering the next wake event");
	
	if ([PowerManager wakeEventsExist])
	{
		[PowerManager cancelWakeEvents];
	}
	if ([dataSource count] > 0)
	{		
		[dataSource sortUsingSelector:@selector(compare:)];
		[PowerManager addWakeEvent:[[self alarmAtIndex:0] fireDate]];
		
		[self _setNextFireDate:[[self alarmAtIndex:0] fireDate]];
		
		NSLog(@"Our next fire date is %@", _nextFireDate);
	}
	else
	{
		[self _setNextFireDate:[NSCalendarDate distantFuture]];
		
		NSLog(@"Alarm queue is empty. Nothing left to register.");
	}
	
	if (_delegate)
		[_delegate alarmsUpdated:self];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateUI" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshPlaylists" object:nil];
	
	[self writeState:nil];
}

- (void)_runAlarmAction
{
	Alarm* alarm = [dataSource objectAtIndex:0];
	
	NSLog(@"Alarm is %@", alarm);
	
	NSAssert(nil != alarm, @"_runAlarmAction - Alarm is nil.");
	
	[alarm performAction];
}

- (void)_pulse:(id)sender
{
	if ([self count] < 1)
	{
		return;
	}
	if (![_nextFireDate occursInFuture])
	{
		Alarm* nextUp = [self alarmAtIndex:0];
		
		[self _runAlarmAction];
		
		if (![nextUp isAlarmValid])
		{
			[dataSource removeObject:nextUp];
		}
		else
		{
			NSLog(@"The alarm %@ is still valid. keeping.",nextUp);
		}
		
		[self _registerNextAlarmEvent];
	}
}

- (void)_setNextFireDate:(NSCalendarDate*)fireDate
{
	NSAssert([[fireDate class] isEqual:[NSCalendarDate class]], @"nextFireDate should have been an NSCalendarDate object");
	
	[_nextFireDate release];
	_nextFireDate = [fireDate retain];
}

- (BOOL)_iRoosterIsRunning;
{
	return [[NSWorkspace sharedWorkspace] isAppRunning:@"iRooster"];
}
@end