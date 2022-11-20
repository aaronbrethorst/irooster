//
//  AlarmEditor.h
//  iRooster
//
//  Created by Aaron Brethorst on 1/8/05.
//  Copyright 2005 Chimp Software LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "iTunes.h"
#import "NSDate+Extras.h"
#import "NSCalendarDate+Additions.h"
#import "AppPreferences.h"

@class DaysToRepeat;

@interface AlarmEditor : NSWindowController 
{
	@protected
	IBOutlet NSSegmentedControl* segRepeat;
	IBOutlet NSDatePicker* dateOneTimeAlarm;
	IBOutlet NSDatePicker* timeControl;
	IBOutlet NSPopUpButton *popPlaylists;
	
	NSString* _alarmType;
	NSDate* _alarmTime;
	NSDate* _alarmDate;
	int result;
	iTunes *itunes;
	NSString *_playlist;
	DaysToRepeat* dtr;
	NSArray *_playlists;
}
#pragma mark IBActions
- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;

#pragma mark Accessors and Mutators
- (int)result;

- (NSCalendarDate*)dateTime;

- (void)setDaysToRepeat:(DaysToRepeat*)dtr;
- (DaysToRepeat*)daysToRepeat;

- (NSDate*)alarmDate;
- (void)setAlarmDate:(NSDate*)date;

- (NSDate*)alarmTime;
- (void)setAlarmTime:(NSDate*)time;

- (NSString*)alarmType;
- (void)setAlarmType:(NSString*)type;

- (NSString*)playlist;
- (void)setPlaylist:(NSString*)playlist;

- (PlaylistType)playlistType;

- (void)setPlaylists:(NSArray*)playlists;
- (NSArray*)playlists;
@end