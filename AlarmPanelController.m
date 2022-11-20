#import "AlarmPanelController.h"
#import "AppPreferences.h"

@implementation AlarmPanelController

- (id)initWithWindowNibName:(NSString*)aNibName
{
    if (self = [super initWithWindowNibName:aNibName])
    {
		resultCode = -1;
    }
    return self;
}

- (void)awakeFromNib
{
	SDCPanel *sp = (SDCPanel*)[self window];
	
	[sp addControl:btnYes mnemonic:@"y"];
	[sp addControl:btnNo mnemonic:@"n"];
}

- (IBAction)cancel:(id)sender
{
    resultCode = NSCancelButton;

    [NSApp stopModal];
    [[self window] close];
}

- (IBAction)ok:(id)sender
{
	[AppPreferences setShowDeleteAlert:([chkDontDisplay state] == NSOffState)];
    
    resultCode = NSOKButton;

    [NSApp stopModal];
    [[self window] close];
}

- (int)resultCode
{
    return resultCode;
}
@end
