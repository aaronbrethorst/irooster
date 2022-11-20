//
//  ThemedTextCell.m
//  iRooster
//
//  Created by Aaron Brethorst on 8/25/04.
//  Copyright 2004 Chimp Software LLC. All rights reserved.
//

#import "ThemedTextCell.h"


@implementation ThemedTextCell
- (NSColor *)textColor;
{
    if ([self isHighlighted])
		return [NSColor textBackgroundColor];
    else
        return [super textColor];
}
@end
