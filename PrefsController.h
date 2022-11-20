/* PreferencesController */

#import <Cocoa/Cocoa.h>
#import "OTPreferenceWindowManager.h"

@class iTunes;

@interface PrefsController : NSWindowController
{    
	IBOutlet NSView *vwGeneral;
	IBOutlet NSView *vwiTunes;
	IBOutlet NSView *vwWakeAndSleep;
	IBOutlet NSView *vwChimpTunes;
	
	IBOutlet id clockPatchController;
	
	/*** General ***/
	IBOutlet NSPopUpButton *popPlaylists;
	IBOutlet NSPopUpButton *popVolumeMin;
	IBOutlet NSPopUpButton *popVolumeMax;
	
	/*** Wake and Sleep ***/
	IBOutlet NSTextField *txtSnoozeTime;
	IBOutlet NSPopUpButton *popSnoozeDuration;
	IBOutlet NSPopUpButton *popAutoStopTime;	
}
- (IBAction)writeState:(id)sender;
- (IBAction)snoozeCheckChanged:(id)sender;
- (IBAction)viewPrivacyPolicy:(id)sender;
- (IBAction)reloadPlaylists:(id)sender;
@end
