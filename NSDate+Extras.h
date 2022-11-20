//
//  NSDate+Extras.h
//  iRooster
//
//  Created by Aaron Brethorst on Sun Jun 27 2004.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppPreferences.h"

@interface NSDate (Extras)
- (NSString*)contextualizedString;
- (NSString*)time;
- (NSString*)blinkingTime:(BOOL)blink;
+ (NSString*)secondsToFormattedTime:(int)seconds;
@end