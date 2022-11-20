#import "SnoozeController.h"
#import "iTunes.h"
#import "iTunesLibraryReader.h"

#import "NSDate+Extras.h"
#import "NSString+Additions.h"
#import "AppPreferences.h"
#import "AudioManager.h"
#import "SongDatabase.h"
#import "AppleRemote.h"

#import <CURLHandle/CURLHandle.h>
#import <CURLHandle/CURLHandle+extras.h>

#define kWEATHERRESIZEHEIGHT 
@interface SnoozeController (Private)
- (void)_updateUI:(NSTimer*)t;
- (void)_postToChimpTunes;
- (void)_updateSongTimeInformation;
- (void)_updateSnoozeState;
- (void)_resetUI;
- (void)_setAlbumArt:(id)sender;
- (void)_setSnoozeButtonTime:(int)seconds;
- (void)_makeFrontAndCenter;
@end

@implementation SnoozeController

- (id)init
{
	if (self = [super init])
	{
		itunes = [iTunes sharediTunes];
		
		if (nil == [itunes libraryReader])
		{
			[iTunesLibraryReader addNewLibraryReaderToiTunes:itunes];
		}
		
		_songDB = [[SongDatabase alloc] init];
		
		_remoteControl = [[[AppleRemote alloc] initWithDelegate: self] retain];
		[_remoteControl startListening: self];
		
		[[AudioManager sharedManager] unmute];
		[[AudioManager sharedManager] setSystemVolume:[AppPreferences minimumVolume]];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_songDB release];
	
	[self stopTimer];
	
	[super dealloc];
}

- (void)awakeFromNib
{	
	[btnRewind setImageName:@"RWD" inBundle:[NSBundle mainBundle]];
	[btnFastForward setImageName:@"FFWD" inBundle:[NSBundle mainBundle]];
	[btnAdd setImageName:@"Plus" inBundle:[NSBundle mainBundle]];
	[btnSubtract setImageName:@"Minus" inBundle:[NSBundle mainBundle]];
	
	[txtSongInfo setStringValue:@""];
	[txtSongTime setStringValue:@""];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateSongInformation:)
												 name:@"iTunesSongDidChange" object:nil];
	
	[self _makeFrontAndCenter];
	
	snoozeCounter = 0;
	[self setSnoozing:NO];
	fStopWindow = NO;
	trackID = -1;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_setAlbumArt:)
												 name:@"IRFoundArtwork"
											   object:nil];
	
	if ([AppPreferences autoStop])
	{
		[txtStopHelper setHidden:NO];
		[txtStopHelper setStringValue:[NSString stringWithFormat:[txtStopHelper stringValue],([AppPreferences autoStopTime] / 60)]];
		_autoStopTimer = [NSTimer scheduledTimerWithTimeInterval:[AppPreferences autoStopTime] target:self selector:@selector(stop:) userInfo:nil repeats:NO];
	}
	else
	{	
		_autoStopTimer = nil;
		[txtStopHelper setHidden:YES];		
	}
	
	[self startTimer];
		
	[self application:nil openFile:nil];
}

- (void)startTimer
{
	[self stopTimer];
	refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
													target:self
												  selector:@selector(_updateUI:)
												  userInfo:nil
												   repeats:YES];
}

- (void)stopTimer
{
	[refreshTimer invalidate];
	refreshTimer = nil;
}

- (BOOL)snoozing;
{
	return fSnooze;
}

- (void)setSnoozing:(BOOL)yn;
{
	fSnooze = yn;
	
	if (!fSnooze)
		snoozeCounter = 0;
}

#pragma mark IBActions

- (IBAction)snooze:(id)sender
{
	if ([self snoozing])
		return;
	
	[itunes pause];
	
	[self _setSnoozeButtonTime:[AppPreferences snoozeDuration]];
		
	snoozeCounter = [AppPreferences snoozeDuration];
	[self setSnoozing:YES];
}

- (IBAction)stop:(id)sender
{
	[self _resetUI];
	
	fStopWindow = YES;
	
	[self stopTimer];
	[NSApp terminate:self];
}

- (IBAction)previous:(id)sender
{
	[itunes previousTrack:sender];
}

- (IBAction)next:(id)sender
{
	[itunes nextTrack:sender];
}

- (IBAction)unsnooze:(id)sender
{	
	[self _resetUI];
	[itunes play];
}

- (IBAction)changeSnoozeDuration:(id)sender
{
	if (snoozeCounter <= 300 && [sender tag] == -1)
		return;
	else
		snoozeCounter += (5 * 60 * [sender tag]); //five minutes added or subtracted depending on tag.
}

- (IBAction)updateSongInformation:(id)sender;
{
	[txtSongInfo setStringValue:[NSString stringWithFormat:@"%@ - %@",[itunes currentArtist],[itunes currentSong]]];	
	
	[self _postToChimpTunes];	
}


- (void)sendRemoteButtonEvent:(RemoteControlEventIdentifier)event pressedDown:(BOOL)pressedDown remoteControl:(RemoteControl*)remoteControl
{
	switch (event)
	{
		case kRemoteButtonPlay:
			[self snooze:remoteControl];
			break;			
		case kRemoteButtonMenu_Hold:
			[self stop:remoteControl];
			break;
		case kRemoteButtonRight:	
			[self next:remoteControl];
			break;
		case kRemoteButtonLeft:
			[self previous:remoteControl];
			break;
		case kRemoteButtonPlus:
			break;
		case kRemoteButtonMinus:
			break;			
		case kRemoteButtonMenu:
			break;
		case kRemoteButtonRight_Hold:
			break;	
		case kRemoteButtonLeft_Hold:
			break;			
		case kRemoteControl_Switched:
			break;
		default:
			break;
	}	
}

#pragma mark NSApplication Delegate Methods
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	NSString *playlist = @"Library";
	
	@try
	{
		NSString *file = [filename lastPathComponent];
		playlist = [[file componentsSeparatedByString:@"."] objectAtIndex:0];
		
		if (filename == nil || file == nil || playlist == nil)
			playlist = @"Library";
		
		if (![[NSFileManager defaultManager] removeFileAtPath:filename handler:nil])
		{
			NSLog(@"Unable to delete file %@", filename);
		}
	}
	@catch (NSException *ex)
	{
		NSLog(@"received an exception while trying to get our next playlist. It says %@", ex);
		NSLog(@"Let's launch Library instead, as a fallback.");
		playlist = @"Library";
	}

	[itunes startPlaylist:playlist];
	
	[[AudioManager sharedManager] scaleVolumeFrom:[AppPreferences minimumVolume]
											   to:[AppPreferences maximumVolume]
									 timeInterval:60 * 5 /* == 5 minutes */];
	
	[self _makeFrontAndCenter];
	
	return YES;
}
@end

@implementation SnoozeController (Private)
- (void)_updateUI:(NSTimer*)t
{
	UpdateSystemActivity(UsrActivity);
	
	[self _updateSongTimeInformation];
	
	if ([btnSubtract isEnabled] && snoozeCounter <= 300)
		[btnSubtract setEnabled:NO];
	else if (![btnSubtract isEnabled] && snoozeCounter > 300)
		[btnSubtract setEnabled:YES];
	
	if ([self snoozing])
	{
		[self _updateSnoozeState];
	}
}

- (void)_postToChimpTunes
{
	NSMutableDictionary *chimpTunesDict = [[[NSMutableDictionary alloc] init] autorelease];
	
	[chimpTunesDict setObject:[itunes currentArtist] forKey:@"artist"];
	[chimpTunesDict setObject:[itunes currentAlbum] forKey:@"album"];
	[chimpTunesDict setObject:[itunes currentSong] forKey:@"song"];
	[chimpTunesDict setObject:@"0" forKey:@"grabImage"];
	
	if ([AppPreferences downloadArt])
	{
		[chimpTunesDict setObject:@"1" forKey:@"grabImage"];
	}
				
	[[NSNotificationCenter defaultCenter] postNotificationName:@"IRPostSong" object:chimpTunesDict];
}

- (void)_updateSongTimeInformation
{
	if (nil != [itunes playerPosition])
		[txtSongTime setStringValue:[itunes playerPosition]];
	else
		[txtSongTime setStringValue:@"-"];
}

- (void)_updateSnoozeState;
{
	if (0 == snoozeCounter)
	{
		[self unsnooze:self];
	}
	else
	{
		snoozeCounter -= 1;
		[self _setSnoozeButtonTime:snoozeCounter];
	}
}

- (void)_resetUI
{
	[btnSnooze setTitle:@"Snooze"];
	[self setSnoozing:NO];
}

- (void)_setAlbumArt:(id)sender
{
	if ([[sender class] isEqual:[NSNotification class]])
	{
		[imgBackground setImage:[sender object]];
	}
	else if ([[sender class] isEqual:[NSImage class]])
	{
		[imgBackground setImage:sender];
	}
}

- (void)_setSnoozeButtonTime:(int)seconds
{
	NSString *formattedString = [NSString stringWithFormat:@"Snooze: %@",[NSDate secondsToFormattedTime:seconds]];
	
	[btnSnooze setTitle:formattedString];
}

- (void)_makeFrontAndCenter;
{
	[NSApp activateIgnoringOtherApps:[AppPreferences bringAppToFront]];
	[window center];
}
@end