//
//  AlarmManager.h
//  iRooster
//
//  Created by Aaron Brethorst on Sun Jun 15 2003.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Alarm;

@interface AlarmManager : NSObject {
    NSMutableArray *dataSource;
	NSTimer *timer;
	NSCalendarDate *_nextFireDate;
	id _delegate;
	BOOL _readOnly;
}
- (id)initAsReadOnly:(BOOL)yn delegate:(id)delegate;
- (int)count;
- (Alarm*)alarmAtIndex:(int)index;
- (void)addAlarm:(Alarm*)anAlarm;
- (void)deleteAlarmAtIndex:(int)index;
- (void)writeState:(id)sender;
@end

@interface NSObject (AlarmManagerDelegate)
- (void)alarmsUpdated:(id)sender;
@end