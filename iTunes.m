//
//  iTunes.m
//  iRooster
//
//  Created by Aaron Brethorst on Sun Jun 15 2003.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import "iTunes.h"
#import "iTunesLibraryReader.h"
#import "Alarm.h"
#import "AppPreferences.h"
#import "AudioManager.h"
#import "NSWorkspace+Extras.h"

@interface iTunes (Private)
- (void)writeReaderErrorToLog;
- (void)updateMovie;
@end

@implementation iTunes

#pragma Singleton Implementation

static iTunes *singleton;

+ (iTunes*)sharediTunes
{
	@synchronized(self)
	{
		if (nil == singleton)
		{
			[[self alloc] init];
		}
	}
	return singleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
	{
        if (nil == singleton)
		{
            singleton = [super allocWithZone:zone];
            return singleton;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil	
}

- (id)copyWithZone:(NSZone *)zone
{	
    return self;
}

- (id)retain
{
    return self;	
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released	
}

- (void)release
{
    //do nothing	
}

- (id)autorelease
{
    return self;
}

- (id)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPlaylists:) name:@"RefreshPlaylists" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nextTrack:) name:@"QTMovieDidEndNotification" object:nil];
    }
    return self;
}

- (void)dealloc
{
	[_reader release];
	[_movie release];
	
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma LibraryReader

- (void)setLibraryReader:(id)reader
{
	[reader retain];
	[_reader release];
	_reader = reader;
}

- (id)libraryReader
{
	return _reader;
}

#pragma iTunes Commands

- (IBAction)nextTrack:(id)sender;
{
	_playlistPosition += 1;
	
	if (_playlistPosition >= [_playlistSongs count])
		_playlistPosition = 0;
	
	[self updateMovie];
}

- (IBAction)previousTrack:(id)sender
{
	_playlistPosition -= 1;
	
	if (_playlistPosition < 0)
		_playlistPosition = [_playlistSongs count] - 1;
	
	[self updateMovie];
}

- (NSTimeInterval)elapsedTime;
{
	return _elapsedTime;
}

- (void)setElapsedTime:(NSTimeInterval)interval;
{
	_elapsedTime = interval;
}

- (void)pause
{
	[_movie stop];
}

- (void)play
{
	if ([self elapsedTime] != 0)
	{
		[_movie setCurrentTime:QTMakeTimeWithTimeInterval([self elapsedTime])];
	}
	
	[_movie play];
}

- (void)stop
{
	[self setElapsedTime:0];
	[_movie stop];
}

- (void)startPlaylist:(NSString*)aPlaylist
{
	[_playlistSongs release];
	
	if (nil == aPlaylist)	
	{
		_playlistSongs = [[_reader itemsInPlaylist:@"Music"] retain];	
	}
	else
	{
		_playlistSongs = [[_reader itemsInPlaylist:aPlaylist] retain];
	}

	if (nil == _playlistSongs || [_playlistSongs count] == 0)
	{
		[_playlistSongs release];
		_playlistSongs = [[_reader itemsInPlaylist:@"Music"] retain];
	}
	
	_playlistPosition = 0;
	
	[self updateMovie];
}

- (NSString*)currentArtist
{
	return [[_playlistSongs objectAtIndex:_playlistPosition] objectForKey:@"Artist"];
}

- (NSString*)currentAlbum
{
	return [[_playlistSongs objectAtIndex:_playlistPosition] objectForKey:@"Album"];
}

- (NSString*)currentSong
{
	return [[_playlistSongs objectAtIndex:_playlistPosition] objectForKey:@"Name"];
}

- (NSString*)playerPosition
{
	NSTimeInterval interval = -1;
	
	if (QTGetTimeInterval([_movie currentTime],&interval))
	{
		NSString *seconds = ((int)interval % 60) < 10 ? [NSString stringWithFormat:@"0%d", ((int)interval % 60)] : [NSString stringWithFormat:@"%d", ((int)interval % 60)];
		return [NSString stringWithFormat:@"%d:%@",((int)[self elapsedTime]) / 60,seconds];
	}
	else
		return @"";
}

- (int)playlistCount
{
	if (_reader != nil)
	{
		return [[_reader playlists] count];
	}
	else
	{
		[self writeReaderErrorToLog];
		return 0;
	}
}

- (NSString*)playlistNameAtIndex:(int)index
{
	if (_reader != nil)
	{
		return [[_reader playlists] objectAtIndex:index];
	}
	else
	{
		[self writeReaderErrorToLog];
		return @"Unknown Playlist";
	}
}

- (PlaylistType)playlistTypeAtIndex:(int)index
{	
	if (_reader != nil)
	{
		return (PlaylistType)[[[_reader playlistTypes] objectAtIndex:index] intValue];
	}
	else
	{
		[self writeReaderErrorToLog];
		return UnknownPlaylistType;
	}
}

- (NSImage*)imageForPlaylistType:(PlaylistType)aType
{
	switch (aType)
	{
		case Library:
			return [NSImage imageNamed:@"Library"];
			break;
		case PartyShuffle:
			return [NSImage imageNamed:@"Party Shuffle"];
			break;
		case PurchasedMusic:
			return [NSImage imageNamed:@"Purchased Music"];
			break;
		case SmartPlaylist:
			return [NSImage imageNamed:@"Smart Playlist"];
			break;
		case Playlist:
			return [NSImage imageNamed:@"Playlist"];
			break;
		case Podcasts:
			return [NSImage imageNamed:@"Podcasts"];
			break;
		case Videos:
			return [NSImage imageNamed:@"Videos"];
			break;
		case TVShows:
			return [NSImage imageNamed:@"TV Shows"];
			break;
		case Movies:
			return [NSImage imageNamed:@"Movies"];
			break;
		case Audiobooks:
			return [NSImage imageNamed:@"Audiobooks"];
			break;
		case Music:
			return [NSImage imageNamed:@"Music"];
			break;
		case RandomPlaylist:
			return [NSImage imageNamed:@"Playlist"];
			break;
		default:
			NSLog(@"iTunes 310: Bad image value, received %d.",aType);
			return [NSImage imageNamed:@"Playlist"];
			break;
	}
}

- (NSImage*)largeImageForPlaylistType:(PlaylistType)aType
{
	switch (aType)
	{
		case Library:
			return [NSImage imageNamed:@"Library Large"];
			break;
		case PartyShuffle:
			return [NSImage imageNamed:@"Party Shuffle Large"];
			break;
		case PurchasedMusic:
			return [NSImage imageNamed:@"Purchased Music Large"];
			break;
		case SmartPlaylist:
			return [NSImage imageNamed:@"Smart Playlist Large"];
			break;
		case Playlist:
			return [NSImage imageNamed:@"Playlist Large"];
			break;
		case Podcasts:
			return [NSImage imageNamed:@"Podcasts Large"];
			break;
		case Videos:
			return [NSImage imageNamed:@"Videos Large"];
			break;
		case TVShows:
			return [NSImage imageNamed:@"TV Shows Large"];
			break;
		case Movies:
			return [NSImage imageNamed:@"Movies Large"];
			break;
		case Audiobooks:
			return [NSImage imageNamed:@"Audiobooks Large"];
			break;
		case Music:
			return [NSImage imageNamed:@"Music Large"];
			break;			
		case RandomPlaylist:
			return [NSImage imageNamed:@"Playlist Large"];
			break;
		default:
			NSLog(@"iTunes 310: Bad image value, received %d.",aType);
			return [NSImage imageNamed:@"Playlist"];
			break;
	}
}

- (NSArray*)playlists
{
	if (_reader != nil)
		return [_reader playlists];
	else
	{
		[self writeReaderErrorToLog];
		return nil;
	}
}

- (int)indexForPlaylist:(NSString*)aPlaylist
{
	if (_reader != nil)
		return [[_reader playlists] indexOfObject:aPlaylist];
	else
	{
		[self writeReaderErrorToLog];
		return -1;
	}
}

- (NSImage*)imageForPlaylistAtIndex:(int)index
{
	return [self imageForPlaylistType:[self playlistTypeAtIndex:index]];
}

- (void)refreshPlaylists:(id)sender
{
	if (_reader != nil)
		[_reader updatePlaylists:sender];
	else
		[self writeReaderErrorToLog];
}
@end

@implementation iTunes (Private)
- (void)writeReaderErrorToLog
{
	NSLog(@"iTunes Library Reader was not correctly initalized. Unable to perform requested action.");
}

- (void)updateMovie;
{
	NSURL *path = [NSURL URLWithString:[[_playlistSongs objectAtIndex:_playlistPosition] objectForKey:@"Location"]];
	
	QTMovie *newMovie = [[QTMovie alloc] initWithURL:path error:nil];
	[newMovie play];
	
	[_movie stop];
	[_movie release];
	
	[self setElapsedTime:0];
	
	_movie = newMovie;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"iTunesSongDidChange" object:self];
}
@end