//
//  NSCalendarDate+Additions.h
//  iRooster
//
//  Created by Aaron Brethorst on Sat Oct 18 2003.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import <Foundation/NSCalendarDate.h>

@interface NSCalendarDate (Additions)

- (BOOL)occursInFuture;
+ (BOOL)timeBetween12And6AM;

@end
