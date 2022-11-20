//
//  SongDatabase.h
//  iRooster
//
//  Created by Aaron Brethorst on 11/25/04.
//  Copyright 2004 Chimp Software LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SongDatabase : NSObject <NSURLHandleClient> {
	NSDate *lastPosted;
	BOOL grabImage;
	BOOL fProcessing;
}
- (void)postSong:(id)sender;
@end
