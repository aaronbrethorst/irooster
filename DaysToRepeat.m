//
//  DaysToRepeat.m
//  iRooster
//
//  Created by Aaron Brethorst on 6/24/06.
//  Copyright 2006 Chimp Software LLC. All rights reserved.
//

#import "DaysToRepeat.h"
#import "NSCalendarDate+Additions.h"

@interface DaysToRepeat (Private)
+ (NSString*)_englishNameForDayOfWeek:(int)day;
@end

@implementation DaysToRepeat
- (id)initWithTime:(NSCalendarDate*)time monday:(BOOL)monday tuesday:(BOOL)tuesday wednesday:(BOOL)wednesday
		  thursday:(BOOL)thursday friday:(BOOL)friday saturday:(BOOL)saturday sunday:(BOOL)sunday
{
	if (self = [super init])
	{
		_time = [time retain];
		_days[1] = monday;
		_days[2] = tuesday; 
		_days[3] = wednesday;
		_days[4] = thursday; 
		_days[5] = friday;
		_days[6] = saturday;
		_days[0] = sunday;
	}
	return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
	if ([self initWithTime:[coder decodeObjectForKey:@"time"]
							monday:[coder decodeBoolForKey:@"Monday"]
						   tuesday:[coder decodeBoolForKey:@"Tuesday"]
						 wednesday:[coder decodeBoolForKey:@"Wednesday"]
						  thursday:[coder decodeBoolForKey:@"Thursday"]
							friday:[coder decodeBoolForKey:@"Friday"]
						  saturday:[coder decodeBoolForKey:@"Saturday"]
							sunday:[coder decodeBoolForKey:@"Sunday"]]) {

		//do something?
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
	[coder encodeObject:_time forKey:@"time"];
	[coder encodeBool:[self monday] forKey:@"Monday"];
	[coder encodeBool:[self tuesday] forKey:@"Tuesday"];
	[coder encodeBool:[self wednesday] forKey:@"Wednesday"];
	[coder encodeBool:[self thursday] forKey:@"Thursday"];
	[coder encodeBool:[self friday] forKey:@"Friday"];
	[coder encodeBool:[self saturday] forKey:@"Saturday"];
	[coder encodeBool:[self sunday] forKey:@"Sunday"];
}

- (id)copyWithZone:(NSZone *)zone
{
	//pursuant to the NSCopying protocol documentation, I only need to re-retain self, and return, since this is an immutable object.
	[self retain];
	return self;
}

- (NSCalendarDate*)nextFireDate
{
	int hour = [_time hourOfDay];
	int minute = [_time minuteOfHour];
	int second = [_time secondOfMinute];
	
	NSCalendarDate *now = [NSCalendarDate date];

	if ([self isRepeatingDay:[now dayOfWeek]])
	{
		NSCalendarDate *todayCandidate = [NSCalendarDate dateWithYear:[now yearOfCommonEra]
																month:[now monthOfYear]
																  day:[now dayOfMonth]
																 hour:[_time hourOfDay]
															   minute:[_time minuteOfHour]
															   second:[_time secondOfMinute]
															 timeZone:[now timeZone]];
		
		NSLog(@"today candidate is %@", todayCandidate);
		
		if (now == [todayCandidate earlierDate:now])
			return todayCandidate;
	}

	NSMutableArray *candidates = [[NSMutableArray alloc] initWithCapacity:7];
	
	for (int i=0; i<7;i++)
	{
		if ([self isRepeatingDay:i])
		{
			NSCalendarDate *aCandidate = [NSCalendarDate dateWithNaturalLanguageString:[NSString stringWithFormat:@"%@ %d:%d:%d ",
				[DaysToRepeat _englishNameForDayOfWeek:i],hour,minute,second]];
			
			NSAssert(nil != aCandidate, @"DaysToRepeat Assert 79.");
			
			if ([aCandidate occursInFuture])
			{
				[candidates addObject:aCandidate];
			}
		}	
	}
	
	[candidates sortUsingSelector:@selector(compare:)];
	
	return [candidates objectAtIndex:0]; //todo: fix this memory leak.
}

- (BOOL)monday
{
	return _days[1];
}

- (BOOL)tuesday
{
	return _days[2];
}

- (BOOL)wednesday
{
	return _days[3];
}

- (BOOL)thursday
{
	return _days[4];
}

- (BOOL)friday
{
	return _days[5];
}

- (BOOL)saturday
{
	return _days[6];
}

- (BOOL)sunday
{
	return _days[0];
}

- (BOOL)isRepeatingDay:(int)day
{
	NSAssert1(day >= 0 && day < 7, @"DaysToRepeat Assert 126: %d is outside the expected range of 0-6.",day);
	
	return _days[day];
}

- (BOOL)hasRepeatingDays
{
	return ([self monday] || [self tuesday] || [self wednesday] ||
			[self thursday] || [self friday] || [self saturday] || [self sunday]);
}

- (NSString*)description
{
	int hour = [_time hourOfDay];
	int minute = [_time minuteOfHour];
	NSMutableString* desc = [NSMutableString stringWithCapacity:40];
		
	[desc appendFormat:@"%d:%d ",hour,minute];
	
	if ([self monday])
		[desc appendString:@"Mon,"];
	if ([self tuesday])
		[desc appendString:@"Tue,"];
	if ([self wednesday])
		[desc appendString:@"Wed,"];
	if ([self thursday])
		[desc appendString:@"Thu,"];
	if ([self friday])
		[desc appendString:@"Fri,"];
	if ([self saturday])
		[desc appendString:@"Sat,"];
	if ([self sunday])
		[desc appendString:@"Sun"];
	
	return desc;
}

- (BOOL)isEqual:(DaysToRepeat*)aDTR
{
	return [[self description] isEqual:[aDTR description]];
}
@end

@implementation DaysToRepeat (Private)

+ (NSString*)_englishNameForDayOfWeek:(int)day
{
	NSAssert1(day >= 0 && day < 7, @"DaysToRepeat Assert 140: day is %d, should be 0 <= day < 7",day);
	
	NSString* retVal;
	
	switch (day)
	{
		case 0:
			retVal = [NSString stringWithString:@"Sunday"];
			break;
		case 1:
			retVal = [NSString stringWithString:@"Monday"];
			break;
		case 2:
			retVal = [NSString stringWithString:@"Tuesday"];
			break;
		case 3:
			retVal = [NSString stringWithString:@"Wednesday"];
			break;
		case 4:
			retVal = [NSString stringWithString:@"Thursday"];
			break;
		case 5:
			retVal = [NSString stringWithString:@"Friday"];
			break;
		case 6:
			retVal = [NSString stringWithString:@"Saturday"];
			break;
		default:
			retVal = [NSString stringWithString:@"!!!BAD DATE!!!"];
			break;
	}
	
	return retVal;
}

@end