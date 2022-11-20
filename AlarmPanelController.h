/* AlarmPanelController */

#import <Cocoa/Cocoa.h>
#import "SDCPanel.h"

@interface AlarmPanelController : NSWindowController
{
	IBOutlet NSButton *btnYes;
	IBOutlet NSButton *btnNo;
    IBOutlet NSButton *chkDontDisplay;
    int resultCode;
}
- (IBAction)cancel:(id)sender;
- (IBAction)ok:(id)sender;
- (int)resultCode;
@end
