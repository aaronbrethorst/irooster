//
//  AlarmStringHelper.m
//  iRooster
//
//  Created by Aaron Brethorst on 9/4/06.
//  Copyright 2006 Chimp Software LLC. All rights reserved.
//

#import "AlarmStringHelper.h"

#define rngSunday     NSMakeRange(1,3)
#define rngMonday     NSMakeRange(5,3)
#define rngTuesday    NSMakeRange(9,3)
#define rngWednesday  NSMakeRange(13,3)
#define rngThursday   NSMakeRange(17,3)
#define rngFriday     NSMakeRange(21,3)
#define rngSaturday   NSMakeRange(25,3)
#define rngLeftParen  NSMakeRange(0,1)
#define rngRightParen NSMakeRange(28,1)

@implementation AlarmStringHelper

- (id)init
{
	if (self = [super init])
	{
		_systemFontDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont systemFontOfSize:[NSFont systemFontSize]],NSFontAttributeName,nil];
		_dateDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont boldSystemFontOfSize:16.0],NSFontAttributeName,nil];
		
		_boldDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont boldSystemFontOfSize:[NSFont systemFontSize]],NSFontAttributeName,nil];
		_disabledDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont systemFontOfSize:[NSFont systemFontSize]],NSFontAttributeName,
																		   [NSColor grayColor],NSForegroundColorAttributeName,nil];
				
		_smallSystemFontDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]],NSFontAttributeName,nil];
		_smallDateDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont boldSystemFontOfSize:12.0],NSFontAttributeName,nil];
		
		_smallBoldDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont boldSystemFontOfSize:[NSFont smallSystemFontSize]],NSFontAttributeName,nil];
		_smallDisabledDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]],NSFontAttributeName,
			[NSColor grayColor],NSForegroundColorAttributeName,nil];

		_repeatingDays = NSLocalizedStringFromTable(@"(Sun Mon Tue Wed Thu Fri Sat)", @"iRoosterStrings", @"Three-letter abbreviations, plus parentheses.");
	}
	return self;
}

- (void)dealloc
{
	[_systemFontDictionary release];
	[_dateDictionary release];
	[_boldDictionary release];
	[_disabledDictionary release];
	[super dealloc];
}

- (NSAttributedString*)attributedDate:(NSString*)date playlist:(NSString*)playlist forSize:(AlarmStringHelperSize)size
{
	return [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %@",playlist,date] attributes:(size == Regular ? _dateDictionary : _smallDateDictionary)] autorelease];
}

- (NSAttributedString*)attributedDate:(NSString*)date monday:(BOOL)mo tuesday:(BOOL)tu wednesday:(BOOL)we thursday:(BOOL)th friday:(BOOL)fr saturday:(BOOL)sa sunday:(BOOL)su playlist:(NSString*)playlist forSize:(AlarmStringHelperSize)size
{
	NSMutableAttributedString *rptDate = [[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %@",playlist,date] attributes:(size == Regular ? _dateDictionary : _smallDateDictionary)] autorelease];
	
	[rptDate appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\n"] autorelease]];
	
	NSMutableAttributedString *days = [[NSMutableAttributedString alloc] initWithString:_repeatingDays attributes:(size == Regular ? _systemFontDictionary : _smallSystemFontDictionary)];
	
	[days addAttributes:(mo ? _boldDictionary : _disabledDictionary) range:rngMonday];
	[days addAttributes:(tu ? _boldDictionary : _disabledDictionary) range:rngTuesday];
	[days addAttributes:(we ? _boldDictionary : _disabledDictionary) range:rngWednesday];
	[days addAttributes:(th ? _boldDictionary : _disabledDictionary) range:rngThursday];	
	[days addAttributes:(fr ? _boldDictionary : _disabledDictionary) range:rngFriday];
	[days addAttributes:(sa ? _boldDictionary : _disabledDictionary) range:rngSaturday];
	[days addAttributes:(su ? _boldDictionary : _disabledDictionary) range:rngSunday];

	[rptDate appendAttributedString:days];
	
	return rptDate;
}
@end