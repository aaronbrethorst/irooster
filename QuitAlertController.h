/* QuitAlertController */

#import <Cocoa/Cocoa.h>
#import "SDCPanel.h"
@interface QuitAlertController : NSWindowController
{
    IBOutlet NSButton *btnDontQuit;
    IBOutlet NSButton *btnQuit;
    IBOutlet NSButton *chkSuppressWarning;

    unsigned result;
}
- (unsigned)result;
- (IBAction)click:(id)sender;
@end

unsigned RunQuitAlertPanel();