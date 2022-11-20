//
//  NSWorkspace+Extras.h
//  iRooster
//
//  Created by Aaron Brethorst on 3/11/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSWorkspace (Extras)
- (BOOL)isAppRunning:(NSString*)title;
@end
