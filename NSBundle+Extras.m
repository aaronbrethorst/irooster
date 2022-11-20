//
//  NSBundle+Extras.m
//  iRooster
//
//  Created by Aaron Brethorst on 12/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "NSBundle+Extras.h"


@implementation NSBundle (Extras)
- (NSString*)shortBundleVersion
{
	return [[self infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
@end
