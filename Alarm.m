//
//  Alarm.m
//  iRooster
//
//  Created by Aaron Brethorst on Sun Jun 15 2003.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import "Alarm.h"
#import "NSString+Additions.h"

@interface Alarm (Private)
- (NSString*)_writeTemporaryFileForPlaylist:(NSString*)aPlaylist;
@end

@implementation Alarm

#pragma mark NSCoding Support

- (id)initWithCoder:(NSCoder*)coder
{
	if (self = [super init])
	{
		NSCalendarDate* fireDate = [coder decodeObjectForKey:@"FireDate"];
		[self setFireDate:fireDate];
		
		NSString *playlist = [coder decodeObjectForKey:@"Playlist"];
		[self setPlaylist:playlist];
		
		DaysToRepeat* dtr = [coder decodeObjectForKey:@"DaysToRepeat"];
		[self setDaysToRepeat:dtr];
		
		PlaylistType ptype = [coder decodeIntForKey:@"PlaylistType"];
		[self setPlaylistType:ptype];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeObject:_fireDate forKey:@"FireDate"];
    [coder encodeObject:_playlist forKey:@"Playlist"];
	[coder encodeObject:_dtr forKey:@"DaysToRepeat"];
	[coder encodeInt:_playlistType forKey:@"PlaylistType"];
}

#pragma mark Constructors

- (id)initWithFireDate:(NSCalendarDate*)aDate playlist:(NSString*)aPlaylist daysToRepeat:(DaysToRepeat*)value playlistType:(PlaylistType)plType
{
    if (self = [super init])
    {
		_fireDate = [aDate retain];
		_dtr = [value retain];
			
		_playlist = [aPlaylist retain];
		_playlistType = plType;
    }
    return self;
}

- (id)initWithFireDate:(NSCalendarDate*)aDate playlist:(NSString*)aPlaylist daysToRepeat:(DaysToRepeat*)value
{
    return [self initWithFireDate:aDate playlist:aPlaylist daysToRepeat:value playlistType:Playlist];
}

- (id)initWithFireDate:(NSCalendarDate*)aDate playlist:(NSString*)aPlaylist
{
	return [self initWithFireDate:aDate playlist:aPlaylist daysToRepeat:[[DaysToRepeat alloc] initWithTime:aDate monday:NO tuesday:NO wednesday:NO thursday:NO friday:NO saturday:NO sunday:NO]];
}

- (void)dealloc
{
    [_fireDate release];
	_fireDate = nil;
	
    [_playlist release];
	_playlist = nil;
	
	[_dtr release];
	_dtr = nil;
	
	_playlistType = -1;
	
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[Alarm allocWithZone:zone] initWithFireDate:[self fireDate] playlist:[self playlist] daysToRepeat:[self daysToRepeat] playlistType:[self playlistType]];
}

#pragma mark Accessors and Mutators

- (NSCalendarDate*)fireDate
{
	if (nil != _dtr && [_dtr hasRepeatingDays])
		return [_dtr nextFireDate];
	else
		return _fireDate;
}

- (void)setFireDate:(NSCalendarDate*)aFireDate
{
	NSAssert(nil == _dtr, @"Alarm Assert 89. Setting fire date will have no effect for a repeating alarm.");
    
	[_fireDate release];
    [aFireDate retain];

    _fireDate = aFireDate;
}

- (NSString*)playlist
{
    return _playlist;
}

- (void)setPlaylist:(NSString*)aPlaylist
{
	NSAssert(aPlaylist != nil, @"Alarm Assert 98. aPlaylist should not be nil.");
	
    [_playlist release];
    [aPlaylist retain];

    _playlist = aPlaylist;
}

- (PlaylistType)playlistType
{
	return _playlistType;
}

- (void)setPlaylistType:(PlaylistType)playlistType
{
	_playlistType = playlistType;
}

- (DaysToRepeat*)daysToRepeat
{
	return _dtr;
}

- (void)setDaysToRepeat:(DaysToRepeat*)newDtr
{
	NSAssert(newDtr != nil, @"Alarm Assert 148. The new repeat value should not be nil.");
	[newDtr retain];
	[_dtr release];
	
	_dtr = newDtr;
}

- (void)performAction
{	
	if (![[NSWorkspace sharedWorkspace] openFile:[self _writeTemporaryFileForPlaylist:[self playlist]]
								 withApplication:[[NSBundle mainBundle] pathForResource:@"iRooster Snooze" ofType:@"app"]
								   andDeactivate:YES]) {
		NSLog(@"iRooster Snooze failed to launch.");
	}
}

- (NSComparisonResult)compare:(Alarm*)anAlarm
{
    return [[self fireDate] compare:[anAlarm fireDate]];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@ :: %@ :: %@ :: %d", _fireDate, _playlist, _dtr, _playlistType];
}

//TODO: I think this will work perfectly now with the third clause. Need to add a test to validate it, though.
- (BOOL)isAlarmValid
{
	return ((nil != _dtr && [_dtr hasRepeatingDays]) || [[self fireDate] occursInFuture]);
}
@end

@implementation Alarm (Private)
- (NSString*)_writeTemporaryFileForPlaylist:(NSString*)aPlaylist;
{
	NSString *tmp = NSTemporaryDirectory();
	NSString *filename = [aPlaylist stringByAppendingString:@".irooster"];
	
	if (nil != tmp)
	{
		NSString *fullPath = [tmp stringByAppendingPathComponent:filename];
		
		if ([fullPath writeToFile:fullPath atomically:YES])
			return fullPath;
		else
			return nil;
	}
	else
	{
		NSLog(@"NSTemporaryDirectory() returned nil. Unable to create temp file for %@", filename);
		return nil;
	}
}
@end