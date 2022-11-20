/* SnoozeController */

#import <Cocoa/Cocoa.h>
#import <IOKit/IOKitLib.h>
#import "OAAquaButton.h"

@class iTunes, SongDatabase, AppleRemote;

@interface SnoozeController : NSObject
{
    IBOutlet NSButton *btnSnooze;
	IBOutlet NSImageView *imgBackground;
	
	IBOutlet NSTextField *txtSongInfo;
	
	IBOutlet OAAquaButton *btnAdd;
	IBOutlet OAAquaButton *btnSubtract;
	
	IBOutlet NSTextField *txtSongTime;
	
	IBOutlet NSTextField *txtStopHelper;
	
	IBOutlet OAAquaButton *btnRewind;
	IBOutlet OAAquaButton *btnFastForward;
	
	IBOutlet NSImageView *imgClockBackground;
	
	IBOutlet NSWindow *window;
	
	AppleRemote *_remoteControl;
	
	iTunes *itunes;
	SongDatabase *_songDB;
	
	NSTimer *refreshTimer;
	NSTimer *_autoStopTimer;
	
	int snoozeCounter;
	BOOL fSnooze;
	BOOL fStopWindow;
	int trackID;
}
- (IBAction)snooze:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)previous:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)changeSnoozeDuration:(id)sender;

- (IBAction)unsnooze:(id)sender;

- (IBAction)updateSongInformation:(id)sender;

- (void)startTimer;
- (void)stopTimer;

- (BOOL)snoozing;
- (void)setSnoozing:(BOOL)yn;
@end
