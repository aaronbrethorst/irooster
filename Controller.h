/* Controller */

#import <Cocoa/Cocoa.h>

@class SDCButton, AlarmStringHelper, AlarmManager, AboutController, iTunes,
PrefsController, eSellerateController, LullabyeController;

@interface Controller : NSObject
{	
    IBOutlet NSMenuItem *mnuDelete;
    IBOutlet NSMenuItem *mnuEdit;
    
    IBOutlet NSTableView *tblAlarms;
    IBOutlet NSWindow *window;

	IBOutlet NSMenuItem *registerMenu;
	IBOutlet NSMenuItem *purchaseMenu;
	
	IBOutlet eSellerateController *eSellerate;

    AlarmManager *alarmManager;
    iTunes *itunes;

	LullabyeController *lullabye;
    NSTimer *recontextualizeDatesTimer;
	
	PrefsController *prefs;
	AboutController* about;
	
	AlarmStringHelper* _asHelper;
}
- (IBAction)addAlarm:(id)sender;
- (IBAction)deleteAlarm:(id)sender;
- (IBAction)editAlarm:(id)sender;
- (IBAction)about:(id)sender;
- (IBAction)preferences:(id)sender;
- (IBAction)help:(id)sender;
- (IBAction)tableClick:(id)sender;

- (IBAction)lullabye:(id)sender;

- (int)showDeleteConfirmDialog;
- (IBAction)immediateDeleteAlarm:(id)sender;

- (IBAction)updateUI:(id)sender;
- (void)recontextualizeDates:(NSTimer*)t;

@end