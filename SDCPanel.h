//
//  SDCPanel.h
//  iRooster
//
//  Created by Aaron Brethorst on 12/21/04.
//  Copyright 2004 Chimp Software LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SDCPanel : NSPanel {
	NSMutableDictionary *mnemonics;
}
- (void)addControl:(NSControl*)control mnemonic:(NSString*)mnemonic;
@end
