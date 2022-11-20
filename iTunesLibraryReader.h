//
//  iTunesLibraryReader.h
//  iTunesLibraryReader
//
//  Created by Aaron Brethorst on Mon Sep 22 2003.
//  Copyright (c) 2003-2006 Aaron Brethorst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlaylistTypes.h"

@interface iTunesLibraryReader : NSObject
{
	@protected
    NSString *path;
    NSTimer *timer;
    id delegate;
    NSFileManager *fs;
    NSDate *lastModification;

    NSMutableArray *playlists;
	NSMutableArray *playlistTypes;
}
- (id)initWithPath:(NSString*)aPath updateInterval:(NSTimeInterval)t delegate:(id)aDelegate;

- (void)updatePlaylists:(id)sender;
- (void)checkForUpdates:(id)sender;

- (NSArray*)playlists;
- (NSArray*)playlistTypes;

- (NSArray*)itemsInPlaylist:(NSString*)aPlaylist;

- (NSString*)path;
- (void)setPath:(NSString*)aPath;

+ (void)changeLibraryPath;
+ (NSString*)libraryDirectory;

- (NSString*)randomPlaylistIdentifier;

+ (void)addNewLibraryReaderToiTunes:(id)itunes;
@end

@interface NSObject (iTunesLibraryReaderDelegate)
- (void)invalidLibraryPath:(id)sender;
- (void)playlistsUpdated:(id)sender;
- (void)setLibraryReader:(id)reader;
- (id)libraryReader;
@end