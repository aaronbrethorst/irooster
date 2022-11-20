//
//  AlarmStringHelper.h
//  iRooster
//
//  Created by Aaron Brethorst on 9/4/06.
//  Copyright 2006 Chimp Software LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum _AlarmStringHelperSize
{
	Regular=1,
	Small=2,
} AlarmStringHelperSize;

@interface AlarmStringHelper : NSObject
{
@private
	NSDictionary* _systemFontDictionary;
	NSDictionary* _dateDictionary;
	NSDictionary* _boldDictionary;
	NSDictionary* _disabledDictionary;
	
	NSDictionary* _smallSystemFontDictionary;
	NSDictionary* _smallDateDictionary;
	NSDictionary* _smallBoldDictionary;
	NSDictionary* _smallDisabledDictionary;
	
	NSString *_repeatingDays;
}
- (NSAttributedString*)attributedDate:(NSString*)date playlist:(NSString*)playlist forSize:(AlarmStringHelperSize)size;
- (NSAttributedString*)attributedDate:(NSString*)date monday:(BOOL)mo tuesday:(BOOL)tu wednesday:(BOOL)we thursday:(BOOL)th friday:(BOOL)fr saturday:(BOOL)sa sunday:(BOOL)su playlist:(NSString*)playlist forSize:(AlarmStringHelperSize)size;
@end