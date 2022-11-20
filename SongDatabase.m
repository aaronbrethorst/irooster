//
//  SongDatabase.m
//  iRooster
//
//  Created by Aaron Brethorst on 11/25/04.
//  Copyright 2004 Chimp Software LLC. All rights reserved.
//

#import "SongDatabase.h"
#import "NSString+Additions.h"
#import "NSBundle+Extras.h"
#import "AppPreferences.h"

#import <CURLHandle/CURLHandle.h>

@implementation SongDatabase
- (id)init
{
	if (self = [super init])
	{
		lastPosted = [NSDate distantPast];
		fProcessing = NO;
		grabImage = NO;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postSong:) name:@"IRPostSong" object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

- (void)postSong:(id)sender
{
	NSLog(@"Calling postSong");
	
	if (fProcessing)
		return;
	
	fProcessing = YES;

	NSString *artist = [[sender object] objectForKey:@"artist"];
	NSString *album = [[sender object] objectForKey:@"album"];
	NSString *song = [[sender object] objectForKey:@"song"];
	
	if ([[[sender object] objectForKey:@"grabImage"] isEqual:@"1"])
		grabImage = YES;
	else
		grabImage = NO;
	
	NSString *postToDB;

	if ([AppPreferences enableChimpTunes])
		postToDB = @"1";
	else
	{
		if (!grabImage) //if we're not submitting info to the db and we already have album art, then get out. 
		{
			fProcessing = NO;
			return;
		}
		postToDB = @"0";
	}
	
	if ((nil == artist || nil == album || nil == song) || ([artist isEqual:@""] || [album isEqual:@""] || [song isEqual:@""]))
	{
		//get rid of the bogus requests.
		fProcessing = NO;
		return;
	}
	
	NSString *strUrl = [NSString stringWithFormat:@"http://www.chimpsoftware.com/chimptunes/add/?artist=%@&album=%@&song=%@&grabImage=%@&postToDB=%@&version=%@",[artist encodeLegally],[album encodeLegally],[song encodeLegally],[[sender object] objectForKey:@"grabImage"],postToDB,[[[NSBundle mainBundle] shortBundleVersion] encodeLegally]];
	
	//NSLog(@"posting data %@", strUrl);
	
	CURLHandle *curl = [[[CURLHandle alloc] initWithURL:[NSURL URLWithString:strUrl] cached:NO] autorelease];
	[curl addClient:self];
	[curl loadInBackground];

}

#pragma mark CURLHandle Delegate Methods

- (void)URLHandle:(NSURLHandle *)sender resourceDataDidBecomeAvailable:(NSData *)newBytes
{

}

- (void)URLHandleResourceDidBeginLoading:(NSURLHandle *)sender
{

}

- (void)URLHandleResourceDidFinishLoading:(NSURLHandle *)sender
{
	if (grabImage)
	{
		NSImage *img = [[[NSImage alloc] initWithData:[sender resourceData]] autorelease];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"IRFoundArtwork" object:img];
	}
	else
	{
		NSString *str = [[[NSString alloc] initWithData:[sender resourceData] encoding:NSUTF8StringEncoding] autorelease];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"IRFoundArtworkURL" object:str];
	}
	
	fProcessing = NO;
}

- (void)URLHandle:(NSURLHandle *)sender resourceDidFailLoadingWithReason:(NSString *)reason
{
	fProcessing = NO;
}

- (void)URLHandleResourceDidCancelLoading:(NSURLHandle *)sender
{
	fProcessing = NO;
}
@end
