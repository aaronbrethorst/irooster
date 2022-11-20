#import "LullabyeController.h"
#import <IOKit/pwr_mgt/IOPMLib.h>
#import "NSDate+Extras.h"
#import "iTunes.h"
#import "iTunesLibraryReader.h"
#import <unistd.h>

@interface LullabyeController (Private)
- (void)timerFired:(id)sender;
- (void)initiateSleep;
- (void)resetUI;
@end

@implementation LullabyeController

static LullabyeController *singleton;

+ (LullabyeController*)sharedLullabye
{
	@synchronized(self)
	{
		if (nil == singleton)
		{
			[[self alloc] initWithWindowNibName:@"Lullabye"];
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

+ (void)initialize
{
	[LullabyeController setKeys:[NSArray arrayWithObject:@"sleepAutomatically"] triggerChangeNotificationsForDependentKey:@"windowHeight"];
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

- (void)awakeFromNib
{
	itunes = [iTunes sharediTunes];
	[iTunesLibraryReader addNewLibraryReaderToiTunes:itunes];
	
	[self setSleepAutomatically:YES];
	
	NSArray *playlists = [itunes playlists];
	menu = [[[NSMenu alloc] initWithTitle:@"Playlist Menu"] autorelease];
	
	for (int i=0; i<[playlists count]; i++)
	{
		NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:[playlists objectAtIndex:i] action:nil keyEquivalent:@""] autorelease];
		[item setImage:[itunes imageForPlaylistType:[itunes playlistTypeAtIndex:i]]];
		[menu addItem:item];
	}
	
	_simulateUserActivity = [AppPreferences autoLullabyActivity];
	
	[popFallAsleep setMenu:menu];
	[self updateTimeListing:nil];
}

- (void)dealloc
{
	[super dealloc];
}

- (void)setSleepAutomatically:(BOOL)yn;
{
	_sleepAutomatically = yn;
}

- (BOOL)sleepAutomatically;
{
	return _sleepAutomatically;
}

- (int)windowHeight
{
	if ([self sleepAutomatically])
	{
		return 233;
	}
	else
	{
		return 133;
	}
}

- (IBAction)updateTimeListing:(id)sender
{
	if ([[popDuration selectedItem] tag] == -1)
	{
		[self setSleepAutomatically:NO];
	}
	else
	{
		int seconds = ([[popDuration selectedItem] tag] * 60);
		NSString *formattedString = [NSString stringWithFormat:@"%@",[NSDate secondsToFormattedTime:seconds]];
		[txtTimeRemaining setStringValue:formattedString];
	}
}

- (IBAction)cancel:(id)sender
{
	if (nil != timer)
	{
		[timer invalidate];
		timer = nil;
	}
	
	[itunes stop];
	
	[[super window] close];
	[self resetUI];
}

- (IBAction)start:(id)sender
{
	remainingSeconds = ([[popDuration selectedItem] tag] * 60);
	timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
	
	[btnClose setTitle:@"Cancel"];
	[popDuration setEnabled:NO];
	[popFallAsleep setEnabled:NO];
	[btnStart setEnabled:NO];
	
	[itunes startPlaylist:[popFallAsleep titleOfSelectedItem]];
}
@end

@implementation LullabyeController (Private)
- (void)timerFired:(id)sender
{
	if (_simulateUserActivity)
		UpdateSystemActivity(UsrActivity);
	
	remainingSeconds -= 1;
	if (remainingSeconds <= 0)
	{
		[timer invalidate];
		
		[[super window] close];		
		[self resetUI];
		
		[itunes stop];
		
		if ([AppPreferences sleepFromLullabye])
			[self initiateSleep];
	}
	else
	{
		NSString *formattedString = [NSString stringWithFormat:@"%@",[NSDate secondsToFormattedTime:remainingSeconds]];
		[txtTimeRemaining setStringValue:formattedString];
	}
}

- (void)initiateSleep
{
	mach_port_t machPort;
	
	if (KERN_SUCCESS != IOMasterPort(MACH_PORT_NULL,&machPort))
	{
		NSLog(@"Lullabye Error: 53 IOMasterPort() failed");
		return;
	} 
	
	io_connect_t ioRootDomain = IOPMFindPowerManagement(machPort);
	
	if (0 == ioRootDomain)
	{
		NSLog(@"Lullabye Error: 61 ioRootDomain is nil");
		return;
	}
	
	IOReturn ret = IOPMSleepSystem(ioRootDomain);
	
	if (kIOReturnSuccess != ret)
	{
		NSLog(@"Lullabye Error: 69 IOPMSleepSystem() did not return kIOReturnSuccess");
		return;
	}
}

- (void)resetUI
{
	[btnClose setTitle:@"Close"];
	[btnStart setEnabled:YES];
	[popDuration setEnabled:YES];
	[popFallAsleep setEnabled:YES];
	[self updateTimeListing:nil];
}
@end