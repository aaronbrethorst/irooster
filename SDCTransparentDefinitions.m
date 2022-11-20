//
//  SDCTransparentDefinitions.m
//  iRooster
//
//  Created by Aaron Brethorst on Sun Jul 13 2003.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import "SDCTransparentDefinitions.h"

@implementation SDCTransparentDefinitions
+ (float)SDCMaxAlphaValue
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    float alpha;
    
    if ([prefs objectForKey:@"MaximumOpacity"] == nil)
    {
        [prefs setFloat:1.0 forKey:@"MaximumOpacity"];
        [prefs synchronize];
        alpha = 1.0;
    }
    else
    {
        alpha = [prefs floatForKey:@"MaximumOpacity"];
    }

    return alpha;
}

+ (float)SDCMinAlphaValue
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    float alpha;

    if ([prefs objectForKey:@"MinimumOpacity"] == nil)
    {
        [prefs setFloat:1.0 forKey:@"MinimumOpacity"];
        [prefs synchronize];
        alpha = 1.0;
    }
    else
    {
        alpha = [prefs floatForKey:@"MinimumOpacity"];
    }

    return alpha;
}

+ (float)SDCAlphaStepValue
{
    return 0.1;
}
@end
