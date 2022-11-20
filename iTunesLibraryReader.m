//
//  iTunesLibraryReader.m
//  iTunesLibraryReader
//
//  Created by Aaron Brethorst on Mon Sep 22 2003.
//  Copyright (c) 2003-2006 Aaron Brethorst. All rights reserved.
//

#import "iTunesLibraryReader.h"
#import "AppPreferences.h"
#import <CoreFoundation/CoreFoundation.h>

@interface iTunesLibraryReader (PrivateMethods)
- (void)badPathNotification;
- (void)newPlaylistsNotification;
- (void)newLibraryPath:(id)sender;
- (NSNumber*)playlistTypeForDictionary:(NSDictionary*)dict;
@end

@implementation iTunesLibraryReader

- (id)initWithPath:(NSString*)aPath updateInterval:(NSTimeInterval)t delegate:(id)aDelegate
{
    if (self = [super init])
    {
        playlists = [[NSMutableArray alloc] initWithArray:[AppPreferences playlists]];
		
		if ([[AppPreferences playlistTypes] count] > 0 && [[[AppPreferences playlistTypes] objectAtIndex:0] isMemberOfClass:[NSString class]]) //added for 2.2 Beta 10 - with PlaylistType cleanup and removal of NSStrings as datatype here.
			[self updatePlaylists:nil]; //do cleanup stuff
		else
			playlistTypes = [[NSMutableArray alloc] initWithArray:[AppPreferences playlistTypes]];
        path = [[aPath stringByStandardizingPath] retain];
        delegate = [aDelegate retain];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newLibraryPath:) name:@"NewLibraryPath" object:nil];
        
        fs = [NSFileManager defaultManager];
		lastModification = [[NSDate alloc] initWithTimeIntervalSinceNow:[[AppPreferences lastLibraryUpdate] timeIntervalSinceNow]];
        
		if ([AppPreferences isKindOfClass:[NSUserDefaults class]])
		{
			[self checkForUpdates:nil];
		}
		
        timer = [NSTimer scheduledTimerWithTimeInterval:t target:self selector:@selector(checkForUpdates:) userInfo:nil repeats:YES];
    }

    return self;
}

- (void)dealloc
{
    [timer invalidate];
    timer = nil;
    
    [path release];
    path = nil;

    fs = nil;
    
    [lastModification release];

    [delegate release];
	
	[playlists release];
	[playlistTypes release];

    [super dealloc];
}

- (void)updatePlaylists:(id)sender
{
    NSDictionary *library = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *playlistObjects = [library objectForKey:@"Playlists"];
	
    [playlists removeAllObjects];
    [playlistTypes removeAllObjects];
	
    for (int i=0; i<[playlistObjects count]; i++)
    {
		if ([AppPreferences ignoreiTrip])
		{
			if (![[[playlistObjects objectAtIndex:i] objectForKey:@"Name"] isEqual:@"iTrip Stations"])
			{
				[playlists addObject:[[playlistObjects objectAtIndex:i] objectForKey:@"Name"]];				
				[playlistTypes addObject:[self playlistTypeForDictionary:[playlistObjects objectAtIndex:i]]];
			}
		}
		else
		{
			[playlists addObject:[[playlistObjects objectAtIndex:i] objectForKey:@"Name"]];
			[playlistTypes addObject:[self playlistTypeForDictionary:[playlistObjects objectAtIndex:i]]];
		}
	}
	
	[playlists addObject:[self randomPlaylistIdentifier]];
    [playlistTypes addObject:[NSNumber numberWithInt:RandomPlaylist]];
	
	[AppPreferences setPlaylists:playlists];
	[AppPreferences setPlaylistTypes:playlistTypes];
	
    [self newPlaylistsNotification];
}

- (NSNumber*)playlistTypeForDictionary:(NSDictionary*)dict
{
	PlaylistType aType = Library;
	
	if ([[dict objectForKey:@"Name"] isEqual:@"Library"])
		aType = Library;
	else if ([[dict objectForKey:@"Name"] isEqual:@"Party Shuffle"])
		aType = PartyShuffle;
	else if ([[dict objectForKey:@"Name"] isEqual:@"Purchased Music"])
		aType = PurchasedMusic;
	else if ([dict objectForKey:@"Smart Criteria"] != nil)
		aType = SmartPlaylist;
	else if ([[dict objectForKey:@"Name"] isEqual:@"Podcasts"])
		aType = Podcasts;
	else if ([[dict objectForKey:@"Name"] isEqual:@"Videos"])
		aType = Videos;
	else if ([[dict objectForKey:@"Name"] isEqual:@"TV Shows"])
		aType = TVShows;
	else if ([[dict objectForKey:@"Name"] isEqual:@"Movies"])
		aType = Movies;
	else if ([[dict objectForKey:@"Name"] isEqual:@"Audiobooks"])
		aType = Audiobooks;
	else if ([[dict objectForKey:@"Name"] isEqual:@"Music"])
		aType = Music;
	else
		aType = Playlist;
	
	return [NSNumber numberWithInt:aType];
}

- (void)checkForUpdates:(id)sender
{
    if ([fs fileExistsAtPath:path])
    {
        NSDictionary *fattrs = [fs fileAttributesAtPath:[path stringByStandardizingPath] traverseLink:YES];
        NSDate *moddate = [fattrs objectForKey:NSFileModificationDate];
        
        if ([lastModification compare:moddate] == NSOrderedAscending)
        {
            [lastModification release];
            lastModification = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:[moddate timeIntervalSinceReferenceDate]];
			
			[AppPreferences setLastLibraryUpdate:lastModification];
            [self updatePlaylists:nil];
        }
    }
    else
    {
        [self badPathNotification];
    }
}

+ (void)changeLibraryPath
{
	NSOpenPanel *open = [NSOpenPanel openPanel];
	
	if (NSOKButton == [open runModalForDirectory:[iTunesLibraryReader libraryDirectory] file:@"iTunes Music Library.xml" types:[NSArray arrayWithObjects:@"xml",nil]])
    {
        NSString *newLibPath = [[open filenames] objectAtIndex:0];
		
		[AppPreferences setPlaylistLibraryPath:newLibPath];
	}
	else
		[iTunesLibraryReader changeLibraryPath];
}

- (NSString*)path
{
    return path;
}

- (void)newLibraryPath:(id)sender
{
	[self setPath:[sender object]];
}

- (void)setPath:(NSString*)aPath
{
    NSString *p = [[aPath stringByStandardizingPath] retain];
    [path release];

    path = p;
}

- (NSArray*)playlists
{
    return playlists;
}

- (NSArray*)playlistTypes
{
    return playlistTypes;
}

- (NSArray*)itemsInPlaylist:(NSString*)aPlaylist;
{
	if (![playlists containsObject:aPlaylist])
		return nil;
	
	NSDictionary *iTunesDict = [NSDictionary dictionaryWithContentsOfFile:[self path]];
	NSArray *playlistItems = nil;
	
	for (int i=0; i<[[iTunesDict objectForKey:@"Playlists"] count];i++)
	{
		if ([[[[iTunesDict objectForKey:@"Playlists"] objectAtIndex:i] objectForKey:@"Name"] isEqual:aPlaylist])
		{
			playlistItems = [[[iTunesDict objectForKey:@"Playlists"] objectAtIndex:i] objectForKey:@"Playlist Items"];
			break;
		}
	}
	
	if (nil == playlistItems)
		return nil;
	
	NSMutableArray *songList = [[NSMutableArray alloc] initWithCapacity:[playlistItems count]];
	
	for (int j=0; j<[playlistItems count]; j++)
	{
		NSString *trackID = [[[playlistItems objectAtIndex:j] objectForKey:@"Track ID"] stringValue];
		[songList addObject:[[iTunesDict objectForKey:@"Tracks"] objectForKey:trackID]];
	}
	
	return [songList autorelease];
}

- (void)badPathNotification
{
    if (delegate != nil && [delegate respondsToSelector:@selector(invalidLibraryPath:)])
    {
        [delegate invalidLibraryPath:self];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"InvalidLibraryPath" object:self];
}

- (void)newPlaylistsNotification
{
    if (delegate != nil && [delegate respondsToSelector:@selector(playlistsUpdated:)])
    {
        [delegate playlistsUpdated:self];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlaylistsUpdated" object:self];
}

+ (NSString*)libraryDirectory
{
    NSString *assumedDirectory = [NSString stringWithFormat:@"%@/Music/iTunes/iTunes Music Library.xml",NSHomeDirectory()];
	
    if (nil != [[NSUserDefaults standardUserDefaults] objectForKey:@"LibraryPath"])
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"LibraryPath"];
    else if ([[NSFileManager defaultManager] fileExistsAtPath:assumedDirectory])
        return assumedDirectory;
    else
        return NSHomeDirectory();
}

- (NSString*)randomPlaylistIdentifier
{
	return [NSString stringWithString:NSLocalizedStringFromTable(@"Select a Random Playlist",@"iRoosterStrings",@"Identifier for the random playlist.")];
}

+ (void)addNewLibraryReaderToiTunes:(id)itunes
{
	iTunesLibraryReader *reader = [[iTunesLibraryReader alloc] initWithPath:[AppPreferences playlistLibraryPath] updateInterval:10.0 delegate:itunes];
	
	if (nil == [itunes libraryReader]) 
		[itunes setLibraryReader:reader];
}
@end