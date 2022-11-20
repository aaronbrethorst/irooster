#import "QuitAlertController.h"
#import "AppPreferences.h"

@implementation QuitAlertController

- (void)awakeFromNib
{
	SDCPanel *sp = (SDCPanel*)[self window];
	
	[sp addControl:btnDontQuit mnemonic:@"n"];
	[sp addControl:btnQuit mnemonic:@"y"];
}

- (IBAction)click:(id)sender
{
	[AppPreferences setShowQuitWarning:([chkSuppressWarning state] == NSOffState)];
    
    if (sender == btnDontQuit)
        result = NSOKButton;
    else
        result = NSCancelButton;

    [NSApp stopModal];
}

- (unsigned)result
{
    return result;
}
@end

unsigned RunQuitAlertPanel()
{
    unsigned result;
    QuitAlertController *qac = [[QuitAlertController alloc] initWithWindowNibName:@"QuitAlert"];

    [NSApp runModalForWindow:[qac window]];
    [[qac window] close];

    result = [qac result];

    [qac release];

    return result;    
}