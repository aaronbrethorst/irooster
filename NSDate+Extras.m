//
//  NSDate+Extras.m
//  iRooster
//
//  Created by Aaron Brethorst on Sun Jun 27 2004.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import "NSDate+Extras.h"

@implementation NSDate (Extras)
- (NSString*)contextualizedString
{
	int year = [[self dateWithCalendarFormat:nil timeZone:nil] yearOfCommonEra];
	int month = [[self dateWithCalendarFormat:nil timeZone:nil] monthOfYear];
	int date = [[self dateWithCalendarFormat:nil timeZone:nil] dayOfMonth];
	
	NSCalendarDate *tomorrow = [[NSCalendarDate calendarDate] dateByAddingYears:0 months:0 days:1 hours:0 minutes:0 seconds:0];
	int tomorrowYear = [tomorrow yearOfCommonEra];
	int tomorrowMonth = [tomorrow monthOfYear];
	int tomorrowDate = [tomorrow dayOfMonth];
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	
	if ([[NSCalendarDate calendarDate] yearOfCommonEra] == year && [[NSCalendarDate calendarDate] monthOfYear] == month && [[NSCalendarDate calendarDate] dayOfMonth] == date)
	{
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		
		return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Today, %@",@"iRooster Strings",@"Short contextual date and time for today."),[dateFormatter stringFromDate:self]];
	}
	else if (tomorrowYear == year && tomorrowMonth == month && tomorrowDate == date)
	{
		[dateFormatter setDateStyle:NSDateFormatterNoStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		
		return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Tomorrow, %@",@"iRooster Strings",@"Short contextual date and time for tomorrow."),[dateFormatter stringFromDate:self]];
	}
	else
	{
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		return [dateFormatter stringFromDate:self];
	}
}

- (NSString*)blinkingTime:(BOOL)blink;
{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	
	if (blink)
	{
		NSArray *components = [[dateFormatter stringFromDate:self] componentsSeparatedByString:@":"];
		return [NSString stringWithFormat:@"%@ %@", [components objectAtIndex:0], [components objectAtIndex:1]];
	}
	else
	{
		return [dateFormatter stringFromDate:self];
	}	
}

- (NSString*)time
{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	return [dateFormatter stringFromDate:self];
}

+ (NSString*)secondsToFormattedTime:(int)seconds
{
	int minutes = seconds / 60;
	int sec = seconds % 60;
	
	if (sec < 10)
		return [NSString stringWithFormat:@"%d:0%d",minutes,sec];
	else
		return [NSString stringWithFormat:@"%d:%d",minutes,sec];
}
@end