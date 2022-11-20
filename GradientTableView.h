//
//  GradientTableView.h
//  iRooster
//
//  Created by Aaron Brethorst on 8/21/04.
//  Copyright 2004 Chimp Software LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GradientTableView : NSTableView {
	struct
	{
        unsigned int acceptsFirstMouse:1;
    } flags;
}
- (void)setAcceptsFirstMouse:(BOOL)flag;
@end
