//
//  AppPreferences.h
//  iRooster
//
//  Created by Aaron Brethorst on Fri Feb 20 2004.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

@interface AppPreferences : NSObject {

}
+ (BOOL)autoWake;
+ (void)setAutoWake:(BOOL)yn;

+ (BOOL)showQuitWarning;
+ (void)setShowQuitWarning:(BOOL)yn;

+ (BOOL)heuristicDatePicking;
+ (void)setHeuristicDatePicking:(BOOL)yn;

+ (BOOL)clockShouldBlink;
+ (void)setClockShouldBlink:(BOOL)yn;

+ (BOOL)ignoreiTrip;
+ (void)setIgnoreiTrip:(BOOL)yn;

+ (NSDate*)defaultTime;
+ (void)setDefaultTime:(NSDate*)time;

+ (NSString*)defaultPlaylist;
+ (void)setDefaultPlaylist:(NSString*)value;

+ (int)snoozeDuration;
+ (void)setSnoozeDuration:(int)time;

+ (NSString*)defaultWindow;
+ (void)setDefaultWindow:(NSString*)window;

+ (BOOL)bringAppToFront;
+ (void)setBringAppToFront:(BOOL)yn;

+ (void)migratePreferences;

+ (NSData*)alarms;
+ (void)setAlarms:(NSData*)alarms;

+ (void)setQuitOnStopSnooze:(BOOL)yn;
+ (BOOL)quitOnStopSnooze;

+ (void)setShowDeleteAlert:(BOOL)yn;
+ (BOOL)showDeleteAlert;

+ (BOOL)snoozeEnabled;
+ (void)setSnoozeEnabled:(BOOL)yn;

+ (BOOL)downloadArt;
+ (void)setDownloadArt:(BOOL)yn;

+ (BOOL)enableChimpTunes;
+ (void)setEnableChimpTunes:(BOOL)yn;

+ (BOOL)chimpTunesConfigured;
+ (void)setChimpTunesConfigured:(BOOL)yn;

+ (NSString*)playlistLibraryPath;
+ (void)setPlaylistLibraryPath:(NSString*)path;

+ (void)setSleepFromLullabye:(BOOL)yn;
+ (BOOL)sleepFromLullabye;

+ (int)volume;
+ (void)setVolume:(int)volume;

+ (BOOL)allowTransparent;
+ (void)setAllowTransparent:(BOOL)yn;

+ (NSDate*)lastLibraryUpdate;
+ (void)setLastLibraryUpdate:(NSDate*)aDate;

+ (NSArray*)playlists;
+ (void)setPlaylists:(NSArray*)playlists;

+ (NSArray*)playlistTypes;
+ (void)setPlaylistTypes:(NSArray*)playlistTypes;

+ (NSTimeInterval)volumeTimeInterval;
+ (void)setVolumeTimeInterval:(NSTimeInterval)interval;

+ (int)minimumVolume;
+ (void)setMinimumVolume:(int)volume;
+ (int)maximumVolume;
+ (void)setMaximumVolume:(int)volume;

+ (BOOL)autoStop;
+ (void)setAutoStop:(BOOL)yn;

+ (NSTimeInterval)autoStopTime;
+ (void)setAutoStopTime:(NSTimeInterval)interval;

+ (BOOL)autoLullabyActivity;
@end