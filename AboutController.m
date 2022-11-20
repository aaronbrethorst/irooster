#import "AboutController.h"
#import "NSString+Additions.h"
#import "NSBundle+Extras.h"

@implementation AboutController

- (void)awakeFromNib
{
	[txtVersion setStringValue:[[NSBundle mainBundle] shortBundleVersion]];
	
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"RegisteredUser"])
        [txtRegisteredTo setStringValue:NSLocalizedStringFromTable(@"Not Registered",@"iRoosterStrings",@"Used in the About dialog when iRooster has not been registered.")];
    else
        [txtRegisteredTo setStringValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"RegisteredUser"]];

	NSData* aboutData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"rtf"]];	
	[txtReleaseNotes replaceCharactersInRange:NSMakeRange(0,[[txtReleaseNotes string] length]) withRTF:aboutData];
}

- (IBAction)goToWebsite:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.chimpsoftware.com"]];
}

- (IBAction)OK:(id)sender
{
    [NSApp stopModal];
    [[self window] close];
}
@end
