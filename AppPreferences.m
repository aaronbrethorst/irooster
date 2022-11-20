//
//  AppPreferences.m
//  iRooster
//
//  Created by Aaron Brethorst on Fri Feb 20 2004.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import "AppPreferences.h"
#import "NSDictionary+Extras.h"

#ifdef BuildiRooster
#import "PowerManager.h"
#endif

@interface AppPreferences (Private)
+ (void)_setBool:(BOOL)yn forKey:(NSString*)key;
+ (BOOL)_needToMigratePrefs;
+ (void)_migrateRegistrationData;
+ (int)_versionNumber;
+ (id)prefs;
@end

@implementation AppPreferences

+ (NSDate*)defaultTime;
{
	if ([[AppPreferences prefs] objectForKey:@"DefaultTime"])
	{
		return [[AppPreferences prefs] objectForKey:@"DefaultTime"];
	}
	else
	{
		return [[[NSCalendarDate alloc] initWithYear:2007 month:1 day:1 hour:9 minute:0 second:0 timeZone:nil] autorelease]; 
	}
}

+ (void)setDefaultTime:(NSDate*)time;
{
	[[AppPreferences prefs] setObject:time forKey:@"DefaultTime"];
	[[AppPreferences prefs] synchronize];
}

+ (void)setDefaultPlaylist:(NSString*)value
{
	[[AppPreferences prefs] setObject:value forKey:@"DefaultPlaylist"];
	[[AppPreferences prefs] synchronize];
}

+ (BOOL)showQuitWarning
{
	if ([[AppPreferences prefs] objectForKey:@"ShowQuitWarning"] == nil)
		return YES;
	else
		return [[AppPreferences prefs] boolForKey:@"ShowQuitWarning"];
}

+ (NSString*)defaultPlaylist
{
	if ([[AppPreferences prefs] objectForKey:@"DefaultPlaylist"] == nil)
		return @"Library";
	else
		return [[AppPreferences prefs] objectForKey:@"DefaultPlaylist"];
}

+ (BOOL)autoWake
{
	return ([[AppPreferences prefs] objectForKey:@"AutoWake"] == nil || [[AppPreferences prefs] boolForKey:@"AutoWake"]);
}

+ (BOOL)clockShouldBlink
{
	if ([[AppPreferences prefs] objectForKey:@"ClockShouldBlink"] == nil)
		return YES;
	else
		return [[AppPreferences prefs] boolForKey:@"ClockShouldBlink"];
}

+ (BOOL)ignoreiTrip
{
	if (nil == [[AppPreferences prefs] objectForKey:@"IgnoreiTrip"])
		return YES;
	else
		return [[AppPreferences prefs] boolForKey:@"IgnoreiTrip"];
}

+ (void)setAutoWake:(BOOL)yn
{
	[AppPreferences _setBool:yn forKey:@"AutoWake"];
}

+ (void)setShowQuitWarning:(BOOL)yn
{
	[AppPreferences _setBool:yn forKey:@"ShowQuitWarning"];
}

+ (BOOL)heuristicDatePicking
{
	if ([[AppPreferences prefs] objectForKey:@"HeuristicDatePicking"] == nil)
		return YES;
	else
		return [[AppPreferences prefs] boolForKey:@"HeuristicDatePicking"];
}

+ (void)setHeuristicDatePicking:(BOOL)yn
{
	[AppPreferences _setBool:yn forKey:@"HeuristicDatePicking"];
}

+ (void)setClockShouldBlink:(BOOL)yn
{
	[AppPreferences _setBool:yn forKey:@"ClockShouldBlink"];
}

+ (void)setIgnoreiTrip:(BOOL)yn
{
	[AppPreferences _setBool:yn forKey:@"IgnoreiTrip"];
}

+ (int)snoozeDuration
{
	if ([[AppPreferences prefs] objectForKey:@"SnoozeDuration"] == nil)
		return 600;
	else
		return [[AppPreferences prefs] integerForKey:@"SnoozeDuration"];
}

+ (void)setSnoozeDuration:(int)duration
{
	[[AppPreferences prefs] setInteger:duration forKey:@"SnoozeDuration"];
	[[AppPreferences prefs] synchronize];
}

+ (NSString*)defaultWindow
{
	if ([[AppPreferences prefs] objectForKey:@"DefaultWindow"] == nil)
		return @"Full Display";
	else
		return [[AppPreferences prefs] stringForKey:@"DefaultWindow"];
}

+ (void)setDefaultWindow:(NSString*)window
{
	[[AppPreferences prefs] setObject:window forKey:@"DefaultWindow"];
	[[AppPreferences prefs] synchronize];
}

+ (BOOL)bringAppToFront
{
	if ([[AppPreferences prefs] objectForKey:@"BringAppToFront"] == nil)
		return YES;
	else
		return [[AppPreferences prefs] boolForKey:@"BringAppToFront"];
}

+ (void)setBringAppToFront:(BOOL)yn
{
	[AppPreferences _setBool:yn forKey:@"BringAppToFront"];
}

+ (void)migratePreferences
{
	if ([AppPreferences _needToMigratePrefs])
	{	
		//i need to come up with a cleaner way of doing this.
#ifdef BuildiRooster 
		[PowerManager cancelWakeEvents];
#endif
		[AppPreferences setAlarms:nil];
		
		[AppPreferences _migrateRegistrationData];
		
		[[NSUserDefaults standardUserDefaults] setInteger:[AppPreferences _versionNumber] forKey:@"VersionNumber"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}	
}

+ (NSData*)alarms
{
	id alarms = [[AppPreferences prefs] objectForKey:@"Alarms"];
	
	if (nil == alarms)
	{
		return nil;
	}
	else if ([alarms respondsToSelector:@selector(objectAtIndex:)])
	{
#ifdef BuildiRooster
		[PowerManager cancelWakeEvents];
#endif
		[AppPreferences setAlarms:nil];
		return nil;
	}
	else
	{
		return alarms;
	}
}

+ (void)setAlarms:(NSData*)alarms
{
	if ([[[AppPreferences prefs] class] isEqual:[NSUserDefaults class]])
	{
		[[AppPreferences prefs] setObject:alarms forKey:@"Alarms"];
		[[AppPreferences prefs] synchronize];
	}
}

+ (void)setQuitOnStopSnooze:(BOOL)yn
{
	[AppPreferences _setBool:yn forKey:@"QuitOnStopSnooze"];
}

+ (BOOL)quitOnStopSnooze
{
	if ([[AppPreferences prefs] objectForKey:@"QuitOnStopSnooze"] == nil)
		return YES;
	else
		return [[AppPreferences prefs] boolForKey:@"QuitOnStopSnooze"]; 
}

+ (void)setShowDeleteAlert:(BOOL)yn
{
	[AppPreferences _setBool:yn forKey:@"ShowDeleteAlert"];
}

+ (BOOL)showDeleteAlert;
{
	if ([[AppPreferences prefs] objectForKey:@"ShowDeleteAlert"] == nil)
		return YES;
	else
		return [[AppPreferences prefs] boolForKey:@"ShowDeleteAlert"];
}

+ (BOOL)snoozeEnabled
{
	if ([[AppPreferences prefs] objectForKey:@"SnoozeEnabled"] == nil)
		return YES;
	else
		return [[AppPreferences prefs] boolForKey:@"SnoozeEnabled"];
}

+ (void)setSnoozeEnabled:(BOOL)yn
{
	[AppPreferences _setBool:yn forKey:@"SnoozeEnabled"];
}

+ (BOOL)downloadArt
{
	if ([[AppPreferences prefs] objectForKey:@"DownloadArt"] == nil)
		return YES;
	else
		return [[AppPreferences prefs] boolForKey:@"DownloadArt"];
}

+ (void)setDownloadArt:(BOOL)yn
{
	[AppPreferences _setBool:yn forKey:@"DownloadArt"];
}

+ (BOOL)enableChimpTunes
{
	if (nil == [[AppPreferences prefs] objectForKey:@"EnableChimpTunes"])
		return NO;
	else
		return [[AppPreferences prefs] boolForKey:@"EnableChimpTunes"];
}

+ (void)setEnableChimpTunes:(BOOL)yn
{
	[AppPreferences _setBool:yn forKey:@"EnableChimpTunes"];
}

+ (BOOL)chimpTunesConfigured
{
	if ([[AppPreferences prefs] objectForKey:@"ChimpTunesConfigured"] == nil)
		return NO;
	else
		return [[AppPreferences prefs] boolForKey:@"ChimpTunesConfigured"];
}

+ (void)setChimpTunesConfigured:(BOOL)yn
{
	[AppPreferences _setBool:yn forKey:@"ChimpTunesConfigured"];
}

+ (NSString*)playlistLibraryPath
{
	if ([[AppPreferences prefs] objectForKey:@"LibraryPath"] == nil)
		return [NSString stringWithFormat:@"%@/Music/iTunes/iTunes Music Library.xml",NSHomeDirectory()];
	else
		return [[AppPreferences prefs] stringForKey:@"LibraryPath"];
}

+ (void)setPlaylistLibraryPath:(NSString*)path
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NewLibraryPath" object:path];
	[[AppPreferences prefs] setObject:path forKey:@"LibraryPath"];
	[[AppPreferences prefs] synchronize];
}

+ (void)setSleepFromLullabye:(BOOL)yn
{
	[AppPreferences _setBool:yn forKey:@"SleepFromLullabye"];
}

+ (BOOL)sleepFromLullabye
{
	if ([[AppPreferences prefs] objectForKey:@"SleepFromLullabye"] == nil)
		return YES;
	else
		return [[AppPreferences prefs] boolForKey:@"SleepFromLullabye"];
}

+ (int)volume
{
	if ([[AppPreferences prefs] objectForKey:@"Volume"] == nil)
		return 80;
	else
		return [[AppPreferences prefs] integerForKey:@"Volume"];
}

+ (void)setVolume:(int)volume
{
	[[AppPreferences prefs] setInteger:volume forKey:@"Volume"];
	[[AppPreferences prefs] synchronize];	
}

+ (BOOL)allowTransparent
{
	if ([[AppPreferences prefs] objectForKey:@"AllowTransparent"] == nil)
		return NO;
	else
		return [[AppPreferences prefs] boolForKey:@"AllowTransparent"];
}

+ (void)setAllowTransparent:(BOOL)yn
{
	[AppPreferences _setBool:yn forKey:@"AllowTransparent"];
}

+ (NSDate*)lastLibraryUpdate
{
	if ([[AppPreferences prefs] objectForKey:@"LastLibraryUpdate"] == nil)
	{
		return [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:0] autorelease];
	}
	else
	{
		return (NSDate*)[[AppPreferences prefs] objectForKey:@"LastLibraryUpdate"];
	}
}

+ (void)setLastLibraryUpdate:(NSDate*)aDate
{
	[[AppPreferences prefs] setObject:aDate forKey:@"LastLibraryUpdate"];
	[[AppPreferences prefs] synchronize];
}

+ (NSArray*)playlists
{
	if (nil == [[AppPreferences prefs] objectForKey:@"Playlists"])
		return [NSArray array];
	else
		return [[AppPreferences prefs] objectForKey:@"Playlists"];
}

+ (void)setPlaylists:(NSArray*)playlists
{
	[[AppPreferences prefs] setObject:playlists forKey:@"Playlists"];
	[[AppPreferences prefs] synchronize];
}

+ (NSArray*)playlistTypes
{
	if (nil == [[AppPreferences prefs] objectForKey:@"PlaylistTypes"])
		return [NSArray array];
	else
		return [[AppPreferences prefs] objectForKey:@"PlaylistTypes"];
}

+ (void)setPlaylistTypes:(NSArray*)playlistTypes
{
	[[AppPreferences prefs] setObject:playlistTypes forKey:@"PlaylistTypes"];
	[[AppPreferences prefs] synchronize];
}

+ (NSTimeInterval)volumeTimeInterval
{
	if (nil == [[AppPreferences prefs] objectForKey:@"VolumeTimeInterval"])
		return 300; //5 minutes
	else
		return (NSTimeInterval)[[AppPreferences prefs] floatForKey:@"VolumeTimeInterval"];
}

+ (void)setVolumeTimeInterval:(NSTimeInterval)interval
{
	[[AppPreferences prefs] setFloat:interval forKey:@"VolumeTimeInterval"];
	[[AppPreferences prefs] synchronize];
}

+ (int)minimumVolume
{	
	if (nil == [[AppPreferences prefs] objectForKey:@"MinimumVolume"])
		return 0;
	else	
		return [[AppPreferences prefs] integerForKey:@"MinimumVolume"];
}

+ (void)setMinimumVolume:(int)volume
{
	[[AppPreferences prefs] setInteger:volume forKey:@"MinimumVolume"];
	[[AppPreferences prefs] synchronize];
}

+ (int)maximumVolume
{
	if (nil == [[AppPreferences prefs] objectForKey:@"MaximumVolume"])
		return 80;
	else	
		return [[AppPreferences prefs] integerForKey:@"MaximumVolume"];
}

+ (void)setMaximumVolume:(int)volume
{
	[[AppPreferences prefs] setInteger:volume forKey:@"MaximumVolume"];
	[[AppPreferences prefs] synchronize];
}


+ (BOOL)autoStop
{
	if (nil == [[AppPreferences prefs] objectForKey:@"AutoStop"])
		return NO;
	else
		return [[AppPreferences prefs] boolForKey:@"AutoStop"];
}
+ (void)setAutoStop:(BOOL)yn;
{
	[AppPreferences _setBool:yn forKey:@"AutoStop"];
}

+ (NSTimeInterval)autoStopTime
{
	if (nil == [[AppPreferences prefs] objectForKey:@"AutoStopTime"])
		return 1800; //30 minutes
	else
		return (NSTimeInterval)[[AppPreferences prefs] floatForKey:@"AutoStopTime"];
}

+ (void)setAutoStopTime:(NSTimeInterval)interval;
{
	[[AppPreferences prefs] setFloat:interval forKey:@"AutoStopTime"];
	[[AppPreferences prefs] synchronize];
}

+ (BOOL)autoLullabyActivity;
{
	if (nil == [[AppPreferences prefs] objectForKey:@"AutoLullabyActivity"])
		return YES;
	else
		return [[AppPreferences prefs] boolForKey:@"AutoLullabyActivity"];
}

@end

@implementation AppPreferences (Private)
+ (void)_setBool:(BOOL)yn forKey:(NSString*)key
{
	[[AppPreferences prefs] setBool:yn forKey:key];
	[[AppPreferences prefs] synchronize];
}

+ (BOOL)_needToMigratePrefs
{
	if (nil != [[AppPreferences prefs] objectForKey:@"VersionNumber"])
	{
		int version = [[AppPreferences prefs] integerForKey:@"VersionNumber"];
		
		return ([AppPreferences _versionNumber] > version);
	}
	else
		return YES;
}

+ (void)_migrateRegistrationData
{
	NSString *reg = @"RegisteredUser";
	NSString *serial = @"SerialNumber";
	
	NSString *regName = nil;
	NSString *serialNumber = nil;
	
	NSEnumerator *enumerator = [[[AppPreferences prefs] dictionaryRepresentation] keyEnumerator];
	id key;
	
	if (nil != [[AppPreferences prefs] objectForKey:reg])
	{
		regName = [[AppPreferences prefs] objectForKey:reg];
		serialNumber = [[AppPreferences prefs] objectForKey:serial];
		
		while ((key = [enumerator nextObject]))
		{
			[[AppPreferences prefs] removeObjectForKey:key]; 
		}
		
		[[AppPreferences prefs] setObject:regName forKey:reg];
		[[AppPreferences prefs] setObject:serialNumber forKey:serial];
		[[AppPreferences prefs] synchronize];
	}
	else
	{
		while ((key = [enumerator nextObject]))
		{
			[[AppPreferences prefs] removeObjectForKey:key]; 
		}
		
		[[AppPreferences prefs] synchronize];
	}
}



+ (int)_versionNumber;
{
	return [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CSPreferencesVersion"] intValue];
}

+ (id)prefs
{
#ifdef BuildiRooster
	return [NSUserDefaults standardUserDefaults];
#endif
#ifdef BuildSatelliteApp
	return [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.ChimpSoftware.iRooster"];
#endif
}
@end