//
//  TransparentWindow.m
//  iRooster
//
//  Created by Aaron Brethorst on Sun Jul 13 2003.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import "SDCTransparentWindow.h"

@interface SDCTransparentWindow (PrivateMethods)
- (void)manageTransparencyAndWindowLevel:(id)sender;
@end

@implementation SDCTransparentWindow

- (void)awakeFromNib
{
	[super awakeFromNib];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(manageTransparencyAndWindowLevel:) name:@"RebuildWindowTransparencySettings" object:nil];

    [self manageTransparencyAndWindowLevel:nil];
}

- (void)manageTransparencyAndWindowLevel:(id)sender
{
    BOOL isInside = NSPointInRect([NSEvent mouseLocation],[self frame]);
    BOOL useFloatingWindow;
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AlwaysOnTop"] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AlwaysOnTop"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        useFloatingWindow = NO;
    }
    else
    {
        useFloatingWindow = [[NSUserDefaults standardUserDefaults] boolForKey:@"AlwaysOnTop"];
    }

    [self setLevel: (useFloatingWindow ? NSFloatingWindowLevel : NSNormalWindowLevel)];
    
    [[self contentView] addTrackingRect:[[self contentView] bounds] owner:self userData:nil assumeInside:isInside];
    if (isInside)
        [self mouseEntered:NULL];
    if (!isInside)
        [self mouseExited:NULL];
}

-(void)dealloc
{
    [self setFadeTimer:nil];
    [super dealloc];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    if ([self alphaValue] < [SDCTransparentDefinitions SDCMaxAlphaValue])
    {
        if (![self fadeTimer])
            [self setFadeTimer:[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(focus:) userInfo:[NSNumber numberWithShort:1] repeats:YES]];
        else if ([[[self fadeTimer] userInfo] shortValue]==0)
            fadeQueued=YES;
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    if ( [self alphaValue] > [SDCTransparentDefinitions SDCMinAlphaValue]) {
        if (![self fadeTimer]) {
            [self setFadeTimer:[NSTimer scheduledTimerWithTimeInterval:0.1
                                                                target:self
                                                              selector:@selector(unfocus:)
                                                              userInfo:[NSNumber numberWithShort:0]
                                                               repeats:YES]];
        }
        else if ( [ [ [self fadeTimer] userInfo] shortValue] == 1) {
            
            fadeQueued=YES;
        }
    }
}

- (NSTimer *)fadeTimer
{
    return fadeTimer;
}

- (void)setFadeTimer:(NSTimer *)timer
{
    [timer retain];
    [fadeTimer invalidate];
    [fadeTimer release];
    fadeTimer=timer;
}

- (void)focus:(NSTimer *)timer
{
    if ([self alphaValue] < [SDCTransparentDefinitions SDCMaxAlphaValue])
    {
        [self setAlphaValue:[self alphaValue] + [SDCTransparentDefinitions SDCAlphaStepValue]];
    }
    if ([self alphaValue] >= [SDCTransparentDefinitions SDCMaxAlphaValue])
    {
        [self setAlphaValue: [SDCTransparentDefinitions SDCMaxAlphaValue]];
        [self setFadeTimer:nil];

        // If in fact a hiding fade is queued up, get it going
        // The queue is needed to ensure smooth transitions from the mouse being inside the window
        // to being outside it.
        if (fadeQueued)
        {
            fadeQueued=NO;
            [self setFadeTimer:[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(unfocus:) userInfo:NULL repeats:YES]];
        }
    }
}

// This routine is called repeatedly when the mouse exits one of the two windows from inside them.
// -mouseExited: sets up the timer that starts calling this method.
- (void)unfocus:(NSTimer *)timer
{
    if ( [self alphaValue] > [SDCTransparentDefinitions SDCMinAlphaValue] )
    {
        [self setAlphaValue:[self alphaValue] - [SDCTransparentDefinitions SDCAlphaStepValue]];
    }
    if ( [self alphaValue] <= [SDCTransparentDefinitions SDCMinAlphaValue] )
    {
        [self setAlphaValue:[SDCTransparentDefinitions SDCMinAlphaValue]];
        [self setFadeTimer:nil];

        // If in fact a hiding fade is queued up, get it going
        // The queue is needed to ensure smooth transitions from the mouse being inside the window
        // to being outside it.
        if (fadeQueued)
        {
            fadeQueued=NO;
            [self setFadeTimer:[NSTimer scheduledTimerWithTimeInterval:0.1
                                                                target:self selector:@selector(focus:)
                                                              userInfo:NULL repeats:YES]];
        }
    }
}
@end
