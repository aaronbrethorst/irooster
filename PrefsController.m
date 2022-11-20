#import "PrefsController.h"
#import "iTunes.h"
#import "NSCalendarDate+Additions.h"
#import "AppPreferences.h"
#import "AlarmManager.h"

@interface PrefsController (Private)
- (void)_configureVolumeControls;
- (void)_setGeneralState;
- (void)_writeGeneralState;
@end

@implementation PrefsController

- (void)dealloc
{
    [super dealloc];
}

- (void)awakeFromNib
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	[self _setGeneralState];
	
	[popSnoozeDuration setEnabled:[AppPreferences snoozeEnabled]];
	
	[self _configureVolumeControls];	
	
    [popPlaylists addItemsWithTitles:[[iTunes sharediTunes] playlists]];

    if ([prefs objectForKey:@"DefaultPlaylist"] == nil || [popPlaylists indexOfItemWithTitle:[prefs objectForKey:@"DefaultPlaylist"]] == -1)
    {
        [popPlaylists selectItemAtIndex:0];
    }
    else
    {
        [popPlaylists selectItemWithTitle:[prefs objectForKey:@"DefaultPlaylist"]];
    }
		
	[popSnoozeDuration selectItemAtIndex:[popSnoozeDuration indexOfItemWithTag:[AppPreferences snoozeDuration]]];
	[popAutoStopTime selectItemAtIndex:[popAutoStopTime indexOfItemWithTag:[AppPreferences autoStopTime]]];
	
}

#pragma mark Delegate Methods

- (void)windowWillClose:(NSNotification *)aNotification
{
	[self writeState:aNotification];
}

#pragma mark -

- (IBAction)writeState:(id)sender
{  
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	[self _writeGeneralState];
	
	[AppPreferences setAutoStopTime:[[popAutoStopTime selectedItem] tag]];
	[AppPreferences setSnoozeDuration:[[popSnoozeDuration selectedItem] tag]];
	
	[prefs setObject:[popPlaylists titleOfSelectedItem] forKey:@"DefaultPlaylist"];
	
    [prefs synchronize];
}

- (IBAction)reloadPlaylists:(id)sender
{
	[[iTunes sharediTunes] refreshPlaylists:sender];
}

- (IBAction)snoozeCheckChanged:(id)sender
{
	[txtSnoozeTime setTextColor:([sender state] == NSOnState ? [NSColor controlTextColor] : [NSColor disabledControlTextColor])];
}

#pragma mark -

- (IBAction)viewPrivacyPolicy:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://chimpsoftware.com/privacy"]];
}

#pragma mark OTPreferenceWindowManager Protocol

-(int)numberOfViewsInPreferenceWindow:(OTPreferenceWindowManager*)prefs
{
	return 4;
}

-(NSView*)viewForPreferencePane:(OTPreferenceWindowManager*)prefs	atIndex:(int)index
{	
	if (index == 0)
		return vwGeneral;
	else if (index == 1)
		return vwiTunes;
	else if (index == 2)
		return vwWakeAndSleep;
	else if (index == 3)
		return vwChimpTunes;
	else
		return nil;
}

-(NSString*)labelForPreferencePane:(OTPreferenceWindowManager*)prefs atIndex:(int)index
{
	if (index == 0)
		return @"General";
	else if (index == 1)
		return @"iTunes";
	else if (index == 2)
		return @"Wake and Sleep";
	else if (index == 3)
		return @"Web Services";
	else
		return @"bad index";
}

-(NSImage*)iconForPreferencePane:(OTPreferenceWindowManager*)prefs	atIndex:(int)index
{
	if (index == 0)
		return [NSImage imageNamed:@"GeneralPreferences"];
	else if (index == 1)
		return [NSImage imageNamed:@"iTunes"];
	else if (index == 2)
		return [NSApp applicationIconImage];
	else if (index == 3)
		return [NSImage imageNamed:@"WebServices"];
	else
		return [NSApp applicationIconImage];
}
@end

@implementation PrefsController (Private)

- (void)_setGeneralState;
{

}

- (void)_writeGeneralState;
{
	[[NSUserDefaults standardUserDefaults] setInteger:([popVolumeMin indexOfSelectedItem] * 10) forKey:@"Volume"];
	
	if ([popVolumeMax indexOfSelectedItem] < [popVolumeMin indexOfSelectedItem])
	{
		[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"MinimumVolume"];
		[[NSUserDefaults standardUserDefaults] setInteger:80 forKey:@"MaximumVolume"];
	}
	else
	{
		[[NSUserDefaults standardUserDefaults] setInteger:([popVolumeMin indexOfSelectedItem] * 10) forKey:@"MinimumVolume"];
		[[NSUserDefaults standardUserDefaults] setInteger:([popVolumeMax indexOfSelectedItem] * 10) forKey:@"MaximumVolume"];
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)_configureVolumeControls
{
	[popVolumeMin removeAllItems];
	for (int i=0; i<=10; i++)
	{
		NSString *title = [NSString stringWithFormat:@"%d%c",i*10,37];
		
		[popVolumeMin addItemWithTitle:title];
	}
	
	[popVolumeMin selectItemAtIndex:([AppPreferences volume] / 10)];
	
	[popVolumeMin removeAllItems];
	[popVolumeMax removeAllItems];
	
	for (int i=0; i<=10; i++)
	{
		NSString *title = [NSString stringWithFormat:@"%d%c",i*10,37];
		
		[popVolumeMin addItemWithTitle:title];
		[popVolumeMax addItemWithTitle:title];
	}
	
	[popVolumeMin selectItemAtIndex:([AppPreferences minimumVolume] / 10)];
	[popVolumeMax selectItemAtIndex:([AppPreferences maximumVolume] / 10)];
}

@end