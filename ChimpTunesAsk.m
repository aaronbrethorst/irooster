#import "ChimpTunesAsk.h"
#import "AppPreferences.h"

@implementation ChimpTunesAsk

- (IBAction)ok:(id)sender
{
	[AppPreferences setEnableChimpTunes:([chkEnableChimpTunes state] == NSOnState ? YES : NO)];
	[AppPreferences setDownloadArt:([chkDownloadArt state] == NSOnState ? YES : NO)];
	
	[NSApp stopModal];
	[[super window] close];
}

@end
