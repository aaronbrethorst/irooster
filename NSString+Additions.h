//
//  NSString+Additions.h
//  iRooster
//
//  Created by Aaron Brethorst on 8/10/04.
//  Copyright 2004 Chimp Software LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CoreFoundation.h>

@interface NSString (Additions)
- (NSString*)stringValue;
- (NSString*)stringByTruncatingToWidth:(int)width dictionary:(NSDictionary*)dict;
- (NSString*)decodeLegally;
- (NSString*)encodeLegally;
+ (NSString*)stringWithSuitablePathSpaces:(NSString*)aString;
- (NSString *) trimWhiteSpace;
- (NSString *) stripHTML;
- (NSString *) ellipsizeAfterNWords: (int) n;
+ (BOOL) stringIsEmpty: (NSString *) s;
@end
