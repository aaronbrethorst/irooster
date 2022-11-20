//
//  NSCalendarDate+Additions.m
//  iRooster
//
//  Created by Aaron Brethorst on Sat Oct 18 2003.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import "NSCalendarDate+Additions.h"

@implementation NSCalendarDate (Additions)

- (BOOL)occursInFuture
{
    return ([self compare:[NSDate date]] == NSOrderedDescending);
}


+ (BOOL)timeBetween12And6AM
{
	return ([[NSCalendarDate calendarDate] hourOfDay] < 6);
}

@end
