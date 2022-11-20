//
//  KeyDownTextView.h
//  iRooster
//
//  Created by Aaron Brethorst on Sat Jul 26 2003.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KeyDownTextField : NSTextField {
	NSString *incNotificationName;
	NSString *decNotificationName;
}
- (void)setIncNotificationName:(NSString*)n;
- (NSString*)incNotificationName;

- (void)setDecNotificationName:(NSString*)n;
- (NSString*)decNotificationName;
@end
