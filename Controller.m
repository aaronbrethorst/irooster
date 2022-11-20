#import "Controller.h"

#import "Alarm.h"
#import "AlarmManager.h"
#import "eSellerateController.h"
#import "AppPreferences.h"
#import "iTunesLibraryReader.h"
#import "iTunes.h"

//Window Controllers
#import "AlarmPanelController.h"
#import "QuitAlertController.h"
#import "AboutController.h"
#import "PrefsController.h"
#import "AlarmEditor.h"
#import "LullabyeController.h"
#import "ChimpTunesAsk.h"
#import <ILCrashReporter/ILCrashReporter.h>
#import "AlarmStringHelper.h"

@interface Controller (Private)
- (void)installNotificationObservers;
- (void)invalidLibraryPath:(id)sender;
- (void)tblDoubleClick:(id)sender;
@end

@implementation Controller

#pragma mark Alloc/Dealloc/Initialization

- (id)init
{
    NSDate *tomorrowDate;
    
    if (self = [super init])
    {
		[AppPreferences migratePreferences];
		
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"SetupRun"])
		{
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SUCheckAtStartup"];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
		
		alarmManager = [[AlarmManager alloc] init];
		
		itunes = [iTunes sharediTunes];
		[iTunesLibraryReader addNewLibraryReaderToiTunes:itunes];

		[self installNotificationObservers];

        tomorrowDate = [NSDate dateWithNaturalLanguageString:@"Tomorrow 12:00 AM"];
		
		_asHelper = [[AlarmStringHelper alloc] init];
		
        recontextualizeDatesTimer = [[NSTimer alloc] initWithFireDate:tomorrowDate interval:86400 target:self selector:@selector(recontextualizeDates:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:recontextualizeDatesTimer forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_asHelper release];
	[alarmManager release];

    [recontextualizeDatesTimer invalidate];
    [recontextualizeDatesTimer release];
    
	[lullabye release];
	[prefs release];
	
	[eSellerate release];
	
    [super dealloc];
}

- (void)awakeFromNib
{	
	[tblAlarms setDoubleAction:@selector(tableClick:)];
	
    [self updateUI:nil];
	
	[window makeKeyAndOrderFront:nil];
	
	eSellerate = [[eSellerateController alloc] init];
	[eSellerate checkRegistrationStatus];
	
	/* Chimp Tunes Ask Goes Back Here */
}

#pragma mark -

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
	if (menuItem == mnuDelete)
		return ([tblAlarms selectedRow] != -1);
	else if (menuItem == mnuEdit)
		return ([tblAlarms selectedRow] != -1);
	else
		return YES;
}

#pragma mark -

- (void)updateUI:(id)sender
{
    [tblAlarms reloadData];
}

#pragma mark -

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    if ([alarmManager count] <= 0 || [eSellerate terminate])
	{
        return YES;
	}
	
    if ([AppPreferences showQuitWarning])
		return (RunQuitAlertPanel() != NSOKButton);
	else
		return YES;
}

#pragma mark -

- (IBAction)tableClick:(id)sender
{
    if ([tblAlarms selectedRow] != -1)
        [self editAlarm:sender];
    else
        [self addAlarm:sender];
}

#pragma mark -

- (void)recontextualizeDates:(NSTimer*)t
{
    [tblAlarms reloadData];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	[[ILCrashReporter defaultReporter] launchReporterForCompany:@"Chimp Software LLC" reportAddr:@"support@chimpsoftware.com"];
}

#pragma mark Menus and Commands

- (IBAction)addAlarm:(id)sender
{
	AlarmEditor *alarmEditor = [[AlarmEditor alloc] initWithWindowNibName:@"AlarmEditor"];
	
	[NSApp runModalForWindow:[alarmEditor window]];
	
	if ([alarmEditor result] == NSOKButton)
	{
		NSString *playlist = [alarmEditor playlist];
		NSCalendarDate *date = [alarmEditor dateTime];
		DaysToRepeat* dtr = [alarmEditor daysToRepeat];
		PlaylistType playlistType = [alarmEditor playlistType];
		
		Alarm *newAlarm = [[Alarm alloc] initWithFireDate:date playlist:playlist daysToRepeat:dtr playlistType:playlistType];
		
		[alarmManager addAlarm:[newAlarm autorelease]];
		
		[self updateUI:nil];
	}
	
	[alarmEditor release];
}

- (IBAction)editAlarm:(id)sender
{
	if ([tblAlarms selectedRow] != -1)
	{
		AlarmEditor *alarmEditor = [[AlarmEditor alloc] initWithWindowNibName:@"AlarmEditor"];
		
		Alarm* alarm = [alarmManager alarmAtIndex:[tblAlarms selectedRow]];
		
		[alarmEditor setPlaylist:[alarm playlist]];
		[alarmEditor setAlarmDate:[alarm fireDate]];
		[alarmEditor setAlarmTime:[alarm fireDate]];
		[alarmEditor setDaysToRepeat:[alarm daysToRepeat]];
		
		[NSApp runModalForWindow:[alarmEditor window]];
		
		if ([alarmEditor result] == NSOKButton)
		{
			Alarm *newAlarm = [[Alarm alloc] initWithFireDate:[alarmEditor dateTime] playlist:[alarmEditor playlist] daysToRepeat:[alarmEditor daysToRepeat]];
			
			[alarmManager deleteAlarmAtIndex:[tblAlarms selectedRow]];
			[alarmManager addAlarm:newAlarm];
			
			[self updateUI:nil];
		}
		
		[alarmEditor release];
	}
	else
		NSLog(@"Controller Error 334");
}	

- (IBAction)lullabye:(id)sender
{
	if (lullabye == nil)
		lullabye = [[LullabyeController alloc] initWithWindowNibName:@"Lullabye"];
	
	[[lullabye window] makeKeyAndOrderFront:nil];
}

- (IBAction)about:(id)sender
{
	if (!about)
		about = [[AboutController alloc] initWithWindowNibName:@"About"];
	
	[[about window] makeKeyAndOrderFront:sender];
}

- (IBAction)preferences:(id)sender
{
	if (prefs == nil)
		prefs = [[PrefsController alloc] initWithWindowNibName:@"Preferences"];
    
	[[prefs window] makeKeyAndOrderFront:nil];
}

- (IBAction)help:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.chimpsoftware.com/forum"]];
}

- (IBAction)deleteAlarm:(id)sender
{
	int result = NSOKButton;
	
	if ([AppPreferences showDeleteAlert])
		result = [self showDeleteConfirmDialog];
	
	if (result == NSOKButton)
	{
		[alarmManager deleteAlarmAtIndex:[tblAlarms selectedRow]];
	}

	[self updateUI:nil];
}

- (int)showDeleteConfirmDialog
{
	AlarmPanelController *alarmPanel = [[AlarmPanelController alloc] initWithWindowNibName:@"DeleteAlarmPanel"];
	
	[NSApp runModalForWindow:[alarmPanel window]];
	
	int result = [alarmPanel resultCode];
	
	[alarmPanel release];
	
	return result;
}

- (IBAction)immediateDeleteAlarm:(id)sender
{
	[alarmManager deleteAlarmAtIndex:[tblAlarms selectedRow]];
	[self updateUI:nil];
}

#pragma mark NSTableDataSource Protocol
- (int)numberOfRowsInTableView:(NSTableView *) tableView
{	
	return [alarmManager count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	Alarm *alarm = [alarmManager alarmAtIndex:rowIndex];
	
	AlarmStringHelperSize helperSize = (aTableView == tblAlarms ? Regular : Small);
	
	if ([[aTableColumn identifier] isEqual:@"image"])
	{
		return [itunes largeImageForPlaylistType:[alarm playlistType]];
	}
	else if ([[aTableColumn identifier] isEqual:@"date"])
	{
		if ([[alarm daysToRepeat] hasRepeatingDays])
			return [_asHelper attributedDate:[[alarm fireDate] contextualizedString] monday:[[alarm daysToRepeat] monday] tuesday:[[alarm daysToRepeat] tuesday] wednesday:[[alarm daysToRepeat] wednesday] thursday:[[alarm daysToRepeat] thursday] friday:[[alarm daysToRepeat] friday] saturday:[[alarm daysToRepeat] saturday] sunday:[[alarm daysToRepeat] sunday] playlist:[alarm playlist] forSize:helperSize];
		else
			return [_asHelper attributedDate:[[alarm fireDate] contextualizedString] playlist:[alarm playlist] forSize:helperSize];
	}
	else
	{
		return @"this is an error. you shouldn't see this.";
	}
}
@end


@implementation Controller (Private)
- (void)installNotificationObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tblDoubleClick:) name:@"tblDoubleClick" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAlarm:) name:@"DeleteAlarm" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editAlarm:) name:@"EditAlarm" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI:) name:@"UpdateUI" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(immediateDeleteAlarm:) name:@"ImmediateDeleteAlarm" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidLibraryPath:) name:@"InvalidLibraryPath" object:nil];
}	

- (void)invalidLibraryPath:(id)sender
{
	static BOOL UIMutex = YES;
	
	if (UIMutex)
	{
		UIMutex = NO;
		
		NSString *locTitle = NSLocalizedStringFromTable(@"iTunes Library Missing",@"iRoosterStrings",@"Used as the title to an alert panel to indicate that the iTunes Library XML file cannot be located");
		NSString *locBody = NSLocalizedStringFromTable(@"iRooster cannot find the iTunes library. Please locate it now. This file is normally named \"iTunes Music Library.xml\"",@"iRoosterStrings",@"Used as the body to an alert panel to indicate that the iTunes Library XML file cannot be located");
		NSString *locButton = NSLocalizedStringFromTable(@"Find iTunes Library File...",@"iRoosterStrings",@"Used as button text for an alert panel to indicate that the iTunes Library XML file cannot be located");
		
		NSRunAlertPanel(locTitle, locBody, locButton, nil, nil);
		
		[iTunesLibraryReader changeLibraryPath];
		
		UIMutex = YES;
	}
}

- (IBAction)tblDoubleClick:(id)sender
{
	if ([sender object] == tblAlarms)
	{
		if ([tblAlarms selectedRow] == -1)
			[self addAlarm:sender];
		else
			[self editAlarm:sender];
	}
}
@end