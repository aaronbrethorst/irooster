//
//  DaysToRepeat.h
//  iRooster
//
//  Created by Aaron Brethorst on 6/24/06.
//  Copyright 2006 Chimp Software LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DaysToRepeat : NSObject <NSCoding,NSCopying>
{
	NSCalendarDate* _time;
	BOOL _days[7]; //0 == Sunday.
}
- (id)initWithTime:(NSCalendarDate*)time monday:(BOOL)monday tuesday:(BOOL)tuesday wednesday:(BOOL)wednesday
		  thursday:(BOOL)thursday friday:(BOOL)friday saturday:(BOOL)saturday sunday:(BOOL)sunday;

- (NSCalendarDate*)nextFireDate;

- (BOOL)monday;
- (BOOL)tuesday;
- (BOOL)wednesday;
- (BOOL)thursday;
- (BOOL)friday;
- (BOOL)saturday;
- (BOOL)sunday;
- (BOOL)isRepeatingDay:(int)day;
- (BOOL)hasRepeatingDays;
@end
