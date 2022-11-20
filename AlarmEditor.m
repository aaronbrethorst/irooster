//
//  AlarmEditor.m
//  iRooster
//
//  Created by Aaron Brethorst on 1/8/05.
//  Copyright 2005 Chimp Software LLC. All rights reserved.
//

#import "AlarmEditor.h"
#import "iTunes.h"
#import "iTunesLibraryReader.h"
#import "AppPreferences.h"
#import "DaysToRepeat.h"

@interface AlarmEditor (Private)
- (void)_configureDateControls;
- (void)_configurePlaylists;
- (void)_configureDTRControl;
- (void)_stopAndClose;
@end

@implementation AlarmEditor

#pragma mark Initialization

- (id)initWithWindowNibName:(NSString*)nib
{
	if (self = [super initWithWindowNibName:nib])
	{
		itunes = [iTunes sharediTunes];
		[iTunesLibraryReader addNewLibraryReaderToiTunes:itunes];
		[self _configureDateControls];
	}
	return self;
}

- (void)awakeFromNib
{	
	[dateOneTimeAlarm setMinDate:[NSDate date]];
	[dateOneTimeAlarm setLocale:[NSLocale currentLocale]];
	[timeControl setLocale:[NSLocale currentLocale]];
	
	if ([dtr hasRepeatingDays])
	{
		[self setAlarmType:@"repeating"];
		[self _configureDTRControl];
	}
	else
	{
		[self setAlarmType:@"onetime"];
	}
	
	if (![self playlist])
		[self setPlaylist:[AppPreferences defaultPlaylist]];
	
	[self _configurePlaylists];
}

- (void)dealloc
{
	[_playlist release];
	[_alarmType release];
	
	[super dealloc];
}

#pragma mark IBActions

- (IBAction)ok:(id)sender
{
	result = NSOKButton;
	
	[self _stopAndClose];
}

- (IBAction)cancel:(id)sender
{
	result = NSCancelButton;
	[self _stopAndClose];
}

#pragma mark Accessors and Mutators

- (int)result
{
	return result;
}

- (NSString*)playlist
{
	return _playlist;
}

- (void)setPlaylist:(NSString*)aPlaylist
{
	[aPlaylist retain];
	[_playlist release];
	_playlist = aPlaylist;
}

- (void)setPlaylists:(NSArray*)playlists
{
	[playlists retain];
	[_playlists release];
	_playlists = playlists;
}

- (NSArray*)playlists
{
	return _playlists;
}

- (NSDate*)alarmTime;
{
	return _alarmTime;
}

- (void)setAlarmTime:(NSDate*)time;
{
	[_alarmTime release];
	_alarmTime = [time retain];
}

- (NSDate*)alarmDate;
{
	return _alarmDate;
}

- (void)setAlarmDate:(NSDate*)date;
{
	[_alarmDate release];
	_alarmDate = [date retain];
}

- (void)setDaysToRepeat:(DaysToRepeat*)days
{
	[days retain];
	[dtr release];
	dtr = days;
}

- (DaysToRepeat*)daysToRepeat
{
	NSCalendarDate *time = [NSCalendarDate dateWithYear:0 month:0 day:0 hour:[[self dateTime] hourOfDay] minute:[[self dateTime] minuteOfHour] second:0 timeZone:nil];
	return [[[DaysToRepeat alloc] initWithTime:time
													 monday:[segRepeat isSelectedForSegment:1]
													tuesday:[segRepeat isSelectedForSegment:2]
												  wednesday:[segRepeat isSelectedForSegment:3]
												   thursday:[segRepeat isSelectedForSegment:4]
													 friday:[segRepeat isSelectedForSegment:5]
												   saturday:[segRepeat isSelectedForSegment:6]
													 sunday:[segRepeat isSelectedForSegment:0]]
						autorelease];
	
	
}

- (NSString*)alarmType;
{
	return _alarmType;
}

- (void)setAlarmType:(NSString*)type;
{
	[_alarmType release];
	_alarmType = [type retain];
}

- (PlaylistType)playlistType
{
	return [itunes playlistTypeAtIndex:[[popPlaylists selectedItem] tag]];
}

- (NSCalendarDate*)dateTime;
{
	NSCalendarDate *calDate = [[[NSCalendarDate alloc] initWithTimeIntervalSinceNow:[[self alarmDate] timeIntervalSinceNow]] autorelease];
	NSCalendarDate *calTime = [[[NSCalendarDate alloc] initWithTimeIntervalSinceNow:[[self alarmTime] timeIntervalSinceNow]] autorelease];	
	return [[[NSCalendarDate alloc] initWithYear:[calDate yearOfCommonEra] month:[calDate monthOfYear] day:[calDate dayOfMonth] hour:[calTime hourOfDay] minute:[calTime minuteOfHour] second:[calTime secondOfMinute] timeZone:nil] autorelease];
}

@end

@implementation AlarmEditor (Private)
- (void)_configureDateControls
{	
	if ([NSCalendarDate timeBetween12And6AM] && [AppPreferences heuristicDatePicking])
		[self setAlarmDate:[NSDate date]];
	else
		[self setAlarmDate:[NSDate dateWithTimeIntervalSinceNow:(60 * 60 * 24)]]; //24 hours from now.
	
	[self setAlarmTime:[AppPreferences defaultTime]];
	
	[self setAlarmType:@"onetime"];
	[self setDaysToRepeat:nil];
}

- (void)_configurePlaylists;
{
	NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"Playlist Menu"] autorelease];
	
	for (int i=0; i<[[itunes playlists] count]; i++)
	{
		NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:[[itunes playlists] objectAtIndex:i] action:nil keyEquivalent:@""] autorelease];
		[item setImage:[itunes imageForPlaylistType:[itunes playlistTypeAtIndex:i]]];
		[item setTag:i];
		[menu addItem:item];
	}
	
	[popPlaylists setMenu:menu];
	
	if ([self playlist])
	{
		[popPlaylists selectItem:[menu itemAtIndex:[menu indexOfItemWithTitle:[self playlist]]]];		 
	}
}

- (void)_configureDTRControl;
{
	if ([dtr sunday])
		 [segRepeat setSelectedSegment:0];
	if ([dtr monday])
		[segRepeat setSelectedSegment:1];
	if ([dtr tuesday])
		[segRepeat setSelectedSegment:2];
	if ([dtr wednesday])
		[segRepeat setSelectedSegment:3];
	if ([dtr thursday])
		[segRepeat setSelectedSegment:4];
	if ([dtr friday])
		[segRepeat setSelectedSegment:5];
	if ([dtr saturday])
		[segRepeat setSelectedSegment:6];
}

- (void)_stopAndClose
{
	[[self window] makeFirstResponder:nil];
	[NSApp stopModal];
	[[self window] close];
}
@end