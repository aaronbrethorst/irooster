//
//  TransparentWindow.h
//  iRooster
//
//  Created by Aaron Brethorst on Sun Jul 13 2003.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SDCTransparentDefinitions.h"
#import "TunesWindow.h"

@interface SDCTransparentWindow : TunesWindow {
    NSTimer *fadeTimer;
    BOOL fadeQueued;
}
- (NSTimer *)fadeTimer;
- (void)setFadeTimer:(NSTimer *)timer;
@end
