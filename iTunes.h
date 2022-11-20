//
//  iTunes.h
//  iRooster
//
//  Created by Aaron Brethorst on Sun Jun 15 2003.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaylistTypes.h"
#import <QTKit/QTKit.h>

@interface iTunes : NSObject
{
	id _reader;
	QTMovie* _movie;
	
	NSArray* _playlists;
	NSArray* _playlistSongs;
	
	int _playlistPosition;
	
	NSTimeInterval _elapsedTime;
}
+ (iTunes*)sharediTunes;

- (void)startPlaylist:(NSString*)aPlaylist;

- (IBAction)nextTrack:(id)sender;
- (IBAction)previousTrack:(id)sender;

- (void)pause;
- (void)play;
- (void)stop;

- (NSString*)currentArtist;
- (NSString*)currentAlbum;
- (NSString*)currentSong;

- (NSString*)playerPosition;

- (NSTimeInterval)elapsedTime;
- (void)setElapsedTime:(NSTimeInterval)interval;

- (int)playlistCount;
- (NSString*)playlistNameAtIndex:(int)index;
- (int)indexForPlaylist:(NSString*)aPlaylist;
- (void)refreshPlaylists:(id)sender;
- (NSArray*)playlists;
- (PlaylistType)playlistTypeAtIndex:(int)index;
- (NSImage*)largeImageForPlaylistType:(PlaylistType)aType;
- (NSImage*)imageForPlaylistType:(PlaylistType)aType;
- (NSImage*)imageForPlaylistAtIndex:(int)index;
@end

@interface NSObject (LibraryReader)
- (void)updatePlaylists:(id)sender;
- (NSArray*)playlists;
- (NSArray*)playlistTypes;
- (NSString*)randomPlaylistIdentifier;
@end
