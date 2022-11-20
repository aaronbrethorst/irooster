/* AboutController */

#import <Cocoa/Cocoa.h>

@interface AboutController : NSWindowController
{
    IBOutlet NSTextField* txtRegisteredTo;
	IBOutlet NSTextField* txtVersion;
	IBOutlet NSTextView* txtReleaseNotes;
}
- (IBAction)goToWebsite:(id)sender;
- (IBAction)OK:(id)sender;
@end