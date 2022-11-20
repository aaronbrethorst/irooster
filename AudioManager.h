//
//  AudioManager.h
//  iRooster
//
//  Created by Aaron Brethorst on 8/10/04.
//  Copyright 2004 Chimp Software LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreAudio/CoreAudio.h>

@interface AudioManager : NSObject {
	double	 _scale;
	double   _current;
	double	 _final;
	NSTimer* _timer;
}
+ (AudioManager*)sharedManager;
- (void)unmute;
- (long)intToSystemVolumeFormat:(int)volume;
- (void)setSystemVolume:(int)volume;
- (void)scaleVolumeFrom:(double)start to:(double)end timeInterval:(NSTimeInterval)time;
- (void)stopVolumeScale;
@end
