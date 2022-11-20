//
//  KeyControlTableView.h
//  iRooster
//
//  Created by Aaron Brethorst on Sun Jun 27 2004.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import "GradientTableView.h"

#define BackDeleteASCII 127
#define CarriageReturnASCII 13

@interface KeyControlTableView : GradientTableView {
	NSAttributedString* strWatermark;
	NSAttributedString* strSmallWatermark;
	NSPoint ptWatermark;
}
@end
