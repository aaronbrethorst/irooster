//
//  AudioManager.m
//  iRooster
//
//  Created by Aaron Brethorst on 8/10/04.
//  Copyright 2004 Chimp Software LLC. All rights reserved.
//

#import "AudioManager.h"
#import <Carbon/Carbon.h>

#define Unmute 0
#define Mute   1

@interface AudioManager (Private)
- (void)scaleVolume:(id)sender;
- (void)setTimer:(NSTimer *)t;
- (void)setSystemVolumeWithLong:(long)volume;
- (long)convertToSystemVolumeFormat:(int)volume;
- (UInt32)channelCountForDevice:(AudioDeviceID)device;
@end

@implementation AudioManager

static AudioManager *singleton;

+ (AudioManager*)sharedManager
{
	@synchronized(self)
	{
		if (nil == singleton)
		{
			[[self alloc] init];
		}
	}
	return singleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
	{
        if (nil == singleton)
		{
            singleton = [super allocWithZone:zone];
            return singleton;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil	
}

- (id)copyWithZone:(NSZone *)zone
{	
    return self;
}

- (id)retain
{
    return self;	
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released	
}

- (void)release
{
    //do nothing	
}

- (id)autorelease
{
    return self;	
}

- (long)intToSystemVolumeFormat:(int)volume
{
	if (volume <= 0 || volume > 100)
	{
		return 0x00800080;
	}
	else if (100 == volume)
	{
		return 0x01000100;
	}
	else
	{
		return [self convertToSystemVolumeFormat:volume];
	}
}

- (void)unmute
{
	OSStatus err;
	
	UInt32 channel;
	AudioDeviceID audioDevice;
	UInt32 muteSetting = Unmute;
	UInt32 count = sizeof(AudioDeviceID);
	
	err = AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice,  &count, (void *) &audioDevice);
	UInt32 numChannels = [self channelCountForDevice:audioDevice];
	
	for (channel=0;channel<numChannels;channel++)
	{
		err = AudioDeviceSetProperty(   /* AudioDeviceID */   audioDevice,
										/* AudioTimeStamp */  0,
										/* UInt32 */		  channel,
										/* IsInput */		  false,
										/* devicepropid */	  kAudioDevicePropertyMute,
										/* UInt32 */		  sizeof(UInt32),
										/* const void* */	  &muteSetting);
	}
}

- (void)scaleVolumeFrom:(double)start to:(double)end timeInterval:(NSTimeInterval)time
{
	if (0 >= time)
		return;
	
	double scaleAmt = (end - start) / time;

	if (0 >= scaleAmt)
		return;
	
	_scale = scaleAmt;
	_current = start;
	_final = end;
	
	NSTimer *t = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(scaleVolume:) userInfo:nil repeats:YES];	
	[self setTimer:t];
}

- (void)setSystemVolume:(int)volume
{
	long longVolume = [self convertToSystemVolumeFormat:volume]; 
	[self setSystemVolumeWithLong:longVolume];
}

- (void)stopVolumeScale
{
	[self setTimer:nil];
}
@end

@implementation AudioManager (Private)
- (void)setSystemVolumeWithLong:(long)volume
{
	SetDefaultOutputVolume(volume);
}

- (void)scaleVolume:(id)sender
{
	_current += _scale;
	
	if (_current > _final)
	{
		[self setTimer:nil];
	}
	else
	{	
		[self setSystemVolume:_current];	
	}
}

- (void)setTimer:(NSTimer *)t
{
	if (_timer != nil)
	{
		[_timer invalidate];
	}
	
	_timer = t;
	
	if (_timer != nil)
	{
		[[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
	}
}

- (UInt32)channelCountForDevice:(AudioDeviceID)device
{
	OSStatus err;
	UInt32 propSize;
	int result = 0;
	
	err = AudioDeviceGetPropertyInfo(device, 0, false/*mIsInput*/, kAudioDevicePropertyStreamConfiguration, &propSize, NULL);
	if (err) return 0;
	
	AudioBufferList *buflist = (AudioBufferList *)malloc(propSize);
	err = AudioDeviceGetProperty(device, 0, false/*mIsInput*/, kAudioDevicePropertyStreamConfiguration, &propSize, buflist);
	
	if (!err)
	{
		for (UInt32 i = 0; i < buflist->mNumberBuffers; ++i)
		{
			result += buflist->mBuffers[i].mNumberChannels;
		}
	}
	
	free(buflist);
	return result;
}

- (long)convertToSystemVolumeFormat:(int)volume
{
	int tens = 0x0;
	int ones = 0x0;
	
	switch (volume / 10)
	{
		case 0:
			tens = 0x00000000;
			break;
		case 1:
			tens = 0x00100010;
			break;
		case 2:
			tens = 0x00200020;
			break;
		case 3:
			tens = 0x00300030;
			break;
		case 4:
			tens = 0x00400040;
			break;
		case 5:
			tens = 0x00500050;
			break;
		case 6:
			tens = 0x00600060;
			break;
		case 7:
			tens = 0x00700070;
			break;
		case 8:
			tens = 0x00800080;
			break;
		case 9:
			tens = 0x00900090;
			break;
	}
	
	switch (volume % 10)
	{
		case 0:
			ones = 0x00000000;
			break;
		case 1:
			ones = 0x00010001;
			break;
		case 2:
			ones = 0x00020002;
			break;
		case 3:
			ones = 0x00030003;
			break;
		case 4:
			ones = 0x00040004;
			break;
		case 5:
			ones = 0x00050005;
			break;
		case 6:
			ones = 0x00060006;
			break;
		case 7:
			ones = 0x00070007;
			break;
		case 8:
			ones = 0x00080008;
			break;
		case 9:
			ones = 0x00090009;
			break;
	}
	
	return (tens + ones);
}	
@end