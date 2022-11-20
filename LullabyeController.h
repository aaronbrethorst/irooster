/* LullabyeController */

#import <Cocoa/Cocoa.h>

@class iTunes;

@interface LullabyeController : NSWindowController
{
	IBOutlet NSButton *btnClose;
    IBOutlet NSButton *btnStart;
    IBOutlet NSPopUpButton *popDuration;
    IBOutlet NSPopUpButton *popFallAsleep;
    IBOutlet NSTextField *txtTimeRemaining;
		
	iTunes *itunes;
	
	int initialVolume;
	
	NSMenu *menu;
	
	NSTimeInterval remainingSeconds;
	BOOL _sleepAutomatically;
	BOOL _simulateUserActivity;
	
	NSTimer *timer;
}
+ (LullabyeController*)sharedLullabye;
- (BOOL)sleepAutomatically;
- (void)setSleepAutomatically:(BOOL)yn;
- (int)windowHeight;
- (IBAction)updateTimeListing:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)start:(id)sender;
@end
