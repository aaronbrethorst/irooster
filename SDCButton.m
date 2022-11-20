//
//  SDCButton.m
//  iRooster
//
//  Created by Aaron Brethorst on 9/1/04.
//  Copyright 2004 Chimp Software LLC. All rights reserved.
//

#import "SDCButton.h"

@interface SDCButton (Private)
- (void)_flipImage:(NSTimer*)tmr;
@end

@implementation SDCButton

- (void)awakeFromNib
{
	tmrPulse = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(_flipImage:) userInfo:nil repeats:YES];
}

- (void)drawRect:(NSRect)aRect
{
	[super drawRect:aRect];
}

- (void)setPulseImage:(NSImage*)img
{
	[img retain];
	[pulseImage release];
	pulseImage = img;
}
	
- (NSImage*)pulseImage
{
	return pulseImage;
}

- (void)setUnpulseImage:(NSImage*)img
{
	[img retain];
	[unpulseImage release];
	unpulseImage = img;
}

- (NSImage*)unpulseImage
{
	return unpulseImage;
}
@end

@implementation SDCButton (Private)

- (void)_flipImage:(NSTimer*)tmr
{
	if ([self unpulseImage] && [self pulseImage])
	{
		if ([self image] == [self unpulseImage])
			[self setImage:[self pulseImage]];
		else
			[self setImage:[self unpulseImage]];
	}
}
@end