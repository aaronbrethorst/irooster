//
//  NSString+Additions.m
//  iRooster
//
//  Created by Aaron Brethorst on 8/10/04.
//  Copyright 2004 Chimp Software LLC. All rights reserved.
//

#import "NSString+Additions.h"


@implementation NSString (Additions)
- (NSString*)stringValue
{
	return self;
}

- (NSString*)stringByTruncatingToWidth:(int)width dictionary:(NSDictionary*)dict
{
	if ([self sizeWithAttributes:dict].width <= width)
		return self;
	
	NSArray* components = [self componentsSeparatedByString:@" "];
	
	int currentWidth = [[NSString stringWithString:@"..."] sizeWithAttributes:dict].width;
	int index = 0;
	
	NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
	
	while (currentWidth < (width - 50))
	{
		currentWidth += [[components objectAtIndex:index] sizeWithAttributes:dict].width;
		[result appendString:[components objectAtIndex:index]];
		[result appendString:@" "];
		index++;
	}
	
	[result deleteCharactersInRange:NSMakeRange([result length] - 1,1)];
	
	[result appendString:@"..."];
	
	[self release];
	return result;
}

/*
	Encode a string legally so it can be turned into an NSURL
	Original Source: <http://cocoa.karelia.com/Foundation_Categories/NSString/Encode_a_string_leg.m>
	(See copyright notice at <http://cocoa.karelia.com>)
	 */

/*"	Fix a URL-encoded string that may have some characters that makes NSURL barf.
It basicaly re-encodes the string, but ignores escape characters + and %, and also #.
"*/
- (NSString *)encodeLegally
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(
																			NULL, (CFStringRef) self, (CFStringRef) @"%+#", NULL,
																			CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
	return result;
}

- (NSString*)decodeLegally
{
	NSString *result = (NSString *) CFURLCreateStringByReplacingPercentEscapes(NULL, (CFStringRef) self, CFSTR(""));
	return result;
}

+ (NSString*)stringWithSuitablePathSpaces:(NSString*)aString
{
	if (NSNotFound == [aString rangeOfString:@" "].location)
		return aString;
	else
	{
		NSMutableString *replacement = [[NSMutableString alloc] initWithString:aString];
		[replacement replaceOccurrencesOfString:@" " withString:@"\\ " options:NSLiteralSearch range:NSMakeRange(0, [replacement length])];
		return [replacement autorelease];
	}		
}



- (NSString *) trimWhiteSpace {
	
	NSMutableString *s = [[self mutableCopy] autorelease];
	
	CFStringTrimWhitespace ((CFMutableStringRef) s);
	
	return (NSString *) [[s copy] autorelease];
} /*trimWhiteSpace*/


- (NSString *) ellipsizeAfterNWords: (int) n {
	
	NSArray *stringComponents = [self componentsSeparatedByString: @" "];
	NSMutableArray *componentsCopy = [stringComponents mutableCopy];
	int ix = n;
	int len = [componentsCopy count];
	
	if (len < n)
		ix = len;
	
	[componentsCopy removeObjectsInRange: NSMakeRange (ix, len - ix)];
	
	return [componentsCopy componentsJoinedByString: @" "];
} /*ellipsizeAfterNWords*/


- (NSString *) stripHTML {
	
	int len = [self length];
	NSMutableString *s = [NSMutableString stringWithCapacity: len];
	int i = 0, level = 0;
	
	for (i = 0; i < len; i++) {
		
		NSString *ch = [self substringWithRange: NSMakeRange (i, 1)];
		
		if ([ch isEqualTo: @"<"])
			level++;
		
		else if ([ch isEqualTo: @">"]) {
			
			level--;
			
			if (level == 0)			
				[s appendString: @" "];
		} /*else if*/
		
		else if (level == 0)			
			[s appendString: ch];
	} /*for*/
	
	return (NSString *) [[s copy] autorelease];
} /*stripHTML*/


+ (BOOL) stringIsEmpty: (NSString *) s {
	
	NSString *copy;
	
	if (s == nil)
		return (YES);
	
	if ([s isEqualTo: @""])
		return (YES);
	
	copy = [[s copy] autorelease];
	
	if ([[copy trimWhiteSpace] isEqualTo: @""])
		return (YES);
	
	return (NO);
} /*stringIsEmpty*/


@end
