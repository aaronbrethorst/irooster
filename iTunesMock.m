//
//  iTunesMock.m
//  irooster
//
//  Created by Aaron Brethorst on 8/29/06.
//  Copyright 2006 Chimp Software LLC. All rights reserved.
//

#import "iTunes.h"

static iTunes *sharedtunes;

@implementation iTunes

+ (id)sharediTunes
{
	if (nil == sharedtunes)
	{
		sharedtunes = [[iTunes alloc] init];
	}
}

- (void)playPlaylistAndManageSound:(NSString*)playlist
{
	NSLog(@"mock object standing in for iTunes and -playPlaylistAndManageSound");
}

- (void)startPlaylist:(NSString*)aPlaylist
{
	NSLog(@"- (void)startPlaylist:(NSString*)aPlaylist");
}

+ (void)nextTrack
{
	NSLog(@"+ (void)nextTrack");
}

+ (void)previousTrack
{
	NSLog(@"+ (void)previousTrack");
}

+ (void)pause
{
	NSLog(@"+ (void)pause");
}

+ (void)play
{
	NSLog(@"+ (void)play");
}

- (void)launch
{
	NSLog(@"- (void)launch");
}

+ (void)quit
{
	NSLog(@"+ (void)quit");
}

+ (int)currentTrackID
{
	NSLog(@"+ (int)currentTrackID");
	return 1;
}

+ (NSImage*)currentAlbumCover
{
	NSLog(@"+ (NSImage*)currentAlbumCover");
	return nil;
}

+ (NSString*)currentArtist
{
	NSLog(@"+ (NSString*)currentArtist");
	return nil;
}

+ (NSString*)currentAlbum
{
	NSLog(@"+ (NSString*)currentAlbum");
	return nil;
}

+ (NSString*)currentSong
{
	NSLog(@"+ (NSString*)currentSong");
	return nil;
}

+ (NSString*)songDuration
{
	NSLog(@"+ (NSString*)songDuration");
	return nil;
}

+ (NSString*)playerPosition
{
	NSLog(@"+ (NSString*)playerPosition");
	return nil;
}

- (int)playlistCount
{
	NSLog(@"- (int)playlistCount");
	return 1;
}

- (NSString*)playlistNameAtIndex:(int)index
{
	NSLog(@"- (NSString*)playlistNameAtIndex:(int)index");
	return nil;
}

- (int)indexForPlaylist:(NSString*)aPlaylist
{
	NSLog(@"- (int)indexForPlaylist:(NSString*)aPlaylist");
	return 1;
}

- (void)refreshPlaylists:(id)sender
{
	NSLog(@"- (void)refreshPlaylists:(id)sender");
}

- (NSArray*)playlists
{
	NSLog(@"- (NSArray*)playlists");
	return nil;
}

- (PlaylistType)playlistTypeAtIndex:(int)index
{
	NSLog(@"- (PlaylistType)playlistTypeAtIndex:(int)index");
	return 1;
}

+ (NSImage*)imageForPlaylistType:(PlaylistType)aType
{
	NSLog(@"+ (NSImage*)imageForPlaylistType:(PlaylistType)aType");
	return nil;
}

- (NSImage*)imageForPlaylistAtIndex:(int)index
{
	NSLog(@"- (NSImage*)imageForPlaylistAtIndex:(int)index");
	return nil;
}

+ (NSImage*)largeImageForPlaylistType:(PlaylistType)aType
{
	NSLog(@"+ (NSImage*)largeImageForPlaylistType:(int)foo");
	return nil;
}
@end
