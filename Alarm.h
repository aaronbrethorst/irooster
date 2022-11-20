//
//  Alarm.h
//  iRooster
//
//  Created by Aaron Brethorst on Sun Jun 15 2003.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+Extras.h"
#import "NSCalendarDate+Additions.h"
#import "DaysToRepeat.h"
#import "iTunes.h"

@interface Alarm : NSObject<NSCopying,NSCoding> {
    NSCalendarDate* _fireDate;
    NSString* _playlist;
	DaysToRepeat* _dtr;
	PlaylistType _playlistType;
}
- (id)initWithFireDate:(NSCalendarDate*)aDate playlist:(NSString*)aPlaylist daysToRepeat:(DaysToRepeat*)value playlistType:(PlaylistType)plType;
- (id)initWithFireDate:(NSCalendarDate*)aDate playlist:(NSString*)aPlaylist daysToRepeat:(DaysToRepeat*)value;
- (id)initWithFireDate:(NSCalendarDate*)aDate playlist:(NSString*)aPlaylist;

- (NSCalendarDate*)fireDate;
- (void)setFireDate:(NSCalendarDate*)aFireDate;

- (void)performAction;

- (NSString*)playlist;
- (void)setPlaylist:(NSString*)aPlaylist;

- (PlaylistType)playlistType;
- (void)setPlaylistType:(PlaylistType)playlistType;

- (DaysToRepeat*)daysToRepeat;
- (void)setDaysToRepeat:(DaysToRepeat*)newDtr;

- (NSComparisonResult)compare:(Alarm*)anAlarm;
- (BOOL)isAlarmValid;
@end
