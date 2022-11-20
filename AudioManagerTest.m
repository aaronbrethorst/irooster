//
//  AudioManagerTest.m
//  iRooster
//
//  Created by Aaron Brethorst on 9/11/06.
//  Copyright 2006 Chimp Software LLC. All rights reserved.
//

#import "AudioManagerTest.h"
#import "AudioManager.h"

@implementation AudioManagerTest
- (void)testVolumeConversion
{
	AudioManager *mgr = [AudioManager sharedManager];
	long result100 = [mgr intToSystemVolumeFormat:100];
	long resultNegative = [mgr intToSystemVolumeFormat:-10];
	long result99 = [mgr intToSystemVolumeFormat:99];
	
	STAssertEqualObjects([NSNumber numberWithLong:0x00990099], [NSNumber numberWithLong:result99],@"Incorrect result, got: %x, expected: %x",result99, 0x00990099);
	STAssertEqualObjects([NSNumber numberWithLong:0x00800080], [NSNumber numberWithLong:resultNegative],@"Incorrect result, got: %x, expected: %x",resultNegative, 0x00800080);
	STAssertEqualObjects([NSNumber numberWithLong:0x01000100], [NSNumber numberWithLong:result100],@"Incorrect result, got: %x, expected: %x",result100, 0x01000100);
}
@end
