//
//  NSDictionary+Extras.m
//  iRooster
//
//  Created by Aaron Brethorst on 12/31/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+Extras.h"

@implementation NSDictionary (Extras)
- (NSString *)stringForKey:(NSString *)defaultName;
{
	return [self objectForKey:defaultName]; 
}

- (NSArray *)arrayForKey:(NSString *)defaultName;
{
	return [self objectForKey:defaultName];
}

- (NSDictionary *)dictionaryForKey:(NSString *)defaultName;
{
	return [self objectForKey:defaultName];
}

- (NSData *)dataForKey:(NSString *)defaultName;
{
	return [self objectForKey:defaultName];
}

- (int)integerForKey:(NSString *)defaultName;
{
	return [[self objectForKey:defaultName] intValue];
}

- (float)floatForKey:(NSString *)defaultName; 
{
	return [[self objectForKey:defaultName] floatValue];
}

- (BOOL)boolForKey:(NSString *)defaultName;
{
	return [[self objectForKey:defaultName] boolValue];
}
@end
