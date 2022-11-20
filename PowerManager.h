/*
 *  WakeUpCaller.h
 *  SecTest
 *
 *  Created by Aaron Brethorst on 9/5/05.
 *  Copyright 2005 Chimp Software LLC. All rights reserved.
 *
 */

#import <Carbon/Carbon.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>

#import <stdio.h>
#import <stdlib.h>
#import <assert.h>
#import <fcntl.h>
#import <unistd.h>
#import <IOKit/pwr_mgt/IOPMLib.h>

// MoreIsBetter interfaces

#import "MoreUNIX.h"
#import "MoreSecurity.h"
#import "CFUtilities.h"

// Our interfaces

#import "MoreSecurityTestCommon.h"

//static void DoPowerManagementTask(CFDateRef theDate, CFStringRef pwrMgtCommand);

@interface PowerManager : NSObject
{
	//
}
+ (void)addWakeEvent:(NSDate*)aDate;
+ (BOOL)wakeEventForDateExists:(NSDate*)aDate;
+ (void)cancelWakeEvent:(NSDate*)aDate;
+ (BOOL)wakeEventsExist;
+ (void)cancelWakeEvents;
@end