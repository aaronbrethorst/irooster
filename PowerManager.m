/*
 *  WakeUpCaller.c
 *  SecTest
 *
 *  Created by Aaron Brethorst on 9/5/05.
 *  Copyright 2005 Chimp Software LLC. All rights reserved.
 *
 */

#include "PowerManager.h"

static OSStatus CopyHelperTemplate( CFURLRef* tool, FolderType fType );

static OSStatus CopyHelperTemplate( CFURLRef* tool, FolderType fType )
{
	return MoreSecCopyHelperToolURLAndCheckBundled(     CFBundleGetMainBundle(), 
														CFSTR("WakeUpHelperTool"), 
														fType, 
														CFSTR("iRooster"), 
														CFSTR("WakeUpHelper"), 
														tool
														);
}

@interface PowerManager (Private)
+ (void)applyEvent:(CFStringRef)type forDate:(NSDate*)aDate;
+ (OSStatus)respondToError:(CFURLRef*)tool;
@end

@implementation PowerManager
+ (void)addWakeEvent:(NSDate*)aDate
{
	//NSAssert1(![PowerManager wakeEventForDateExists:aDate], @"addWakeEvent Assert 1 Failed for %@",aDate);
	[PowerManager applyEvent:kAddWakeUpCommand forDate:aDate];
	//NSAssert1([PowerManager wakeEventForDateExists:aDate], @"addWakeEvent Assert 2 Failed for %@", aDate);
}

+ (void)cancelWakeEvent:(NSDate*)aDate
{
	//NSAssert1([PowerManager wakeEventForDateExists:aDate], @"cancelWakeEvent Assert 1 Failed for %@",aDate);
	[PowerManager applyEvent:kDeleteWakeUpCommand forDate:aDate];
	//NSAssert1(![PowerManager wakeEventForDateExists:aDate], @"cancelWakeEvent Assert 2 Failed for %@",aDate);
}

+ (void)cancelWakeEvents
{
	NSArray* powerEvents = (NSArray*)IOPMCopyScheduledPowerEvents();
	
	if (nil == powerEvents)
		return;
	
	for (int i=0; i<[powerEvents count]; i++)
	{
		NSDictionary *powerEvent = [powerEvents objectAtIndex:i];
		
		if ([[powerEvent objectForKey:@"scheduledby"] isEqual:@"com.chimpsoftware.iRooster.HelperTool"])
		{
			[PowerManager cancelWakeEvent:[powerEvent objectForKey:@"time"]];
		}
	}
	CFRelease(powerEvents);
}

+ (BOOL)wakeEventsExist
{
	NSArray* powerEvents = (NSArray*)IOPMCopyScheduledPowerEvents();
	
	if (nil == powerEvents)
		return NO;
	
	for (int i=0; i<[powerEvents count]; i++)
	{
		NSDictionary *powerEvent = [powerEvents objectAtIndex:i];
		
		if ([[powerEvent objectForKey:@"scheduledby"] isEqual:@"com.chimpsoftware.iRooster.HelperTool"])
		{
			CFRelease(powerEvents);
			return YES;
		}
	}
	
	CFRelease(powerEvents);
	return NO;
}

+ (BOOL)wakeEventForDateExists:(NSDate*)aDate
{
	BOOL result = NO;
	
	CFArrayRef powerEvents = IOPMCopyScheduledPowerEvents();
	
	if (nil == powerEvents)
		return NO;
	
	NSArray* nsPowerEvents = (NSArray*)powerEvents;
	
	for (int i=0; i<[nsPowerEvents count]; i++)
	{
		if ([[[nsPowerEvents objectAtIndex:i] objectForKey:@"time"] isEqualToDate:aDate])
		{
			result = YES;
			break;
		}
	}
	CFRelease(powerEvents);
	return result;
}

@end

@implementation PowerManager (Private)
+ (void)applyEvent:(CFStringRef)type forDate:(NSDate*)aDate
{
	OSStatus 			err;
	CFURLRef 			tool;
	CFDictionaryRef 	request;
	CFDictionaryRef 	response;
	AuthorizationRef	auth;
	
	CFDateRef			cfDate;
	
	tool     = NULL;
	request  = NULL;
	response = NULL;
	auth 	 = NULL;
	
	cfDate = CFDateCreate(kCFAllocatorDefault, [aDate timeIntervalSinceReferenceDate]);
	
	// Create an Authorization Services environment.  Normally your 
	// application would do this as it begins so that it can pre-authorize.
	// However, I don't pre-authorized because a) the pre-authorize flag 
	// does nothing in current versions of Mac OS X [2907852], and b) doing 
	// the pre-authorize triggers two authentication dialogs the first time 
	// you run the application, which is never what you want.
	
    err = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &auth);
    
	// Find our helper tool, possibly restoring it from the template.
	
	if (err == noErr)
	{		
		CopyHelperTemplate(&tool,kApplicationSupportFolderType);
		
		// If the home directory is on an volume that doesn't support 
		// setuid root helper tools, ask the user whether they want to use 
		// a temporary tool.
		
		if (err == kMoreSecFolderInappropriateErr)
		{
			err = [PowerManager respondToError:&tool];
		}
	}
	
	// Create the request dictionary.
	
	if (err == noErr)
	{	
		CFTypeRef keys[2] = {
			kWakeUpHelperCommandNameKey,
			kDateTimeKey
		};
		
		CFTypeRef vals[2] = {
			(CFStringRef)type,
			cfDate
		};
		
		request = CFDictionaryCreate(NULL, (const void **) keys, (const void **) vals,
									 2, &kCFTypeDictionaryKeyCallBacks,
									 &kCFTypeDictionaryValueCallBacks);
		
		err = CFQError(request);
	}
	
	// Go go gadget helper tool!
	
	if (err == noErr)
	{
		err = MoreSecExecuteRequestInHelperTool(tool, auth, request, &response);
	}
	
	// Display to the user.
	
	if (err != noErr)
		NSRunAlertPanel(@"iRooster failed to set wake-from-sleep correctly. Please send an email to support@chimpsoftware.com with any and all information regarding this you may have.",@"",@"OK",nil,nil);
	
	// Clean up.
	
	CFQRelease(cfDate);
	CFQRelease(tool);
	CFQRelease(request);
	CFQRelease(response);
	
	if (auth != NULL)
	{	
		OSStatus junk = AuthorizationFree(auth, kAuthorizationFlagDestroyRights);
		assert(junk == noErr);
	}
}

+ (OSStatus)respondToError:(CFURLRef*)tool
{
	OSStatus status = noErr;
	
	int result = NSRunAlertPanel(@"Your Home directory does not support Helper Tools",
								 @"Would you like to use a temporary copy of the tool? The temporary tool will be deleted periodically. In the Finder's Get Info window, uncheck the 'Ignore ownership' on the disk containing your home directory.",
								 @"Use Temporary Copy",
								 @"Cancel",
								 nil
								 );
	
	if (result == NSOKButton)
	{
		status = CopyHelperTemplate(tool,kTemporaryFolderType);
	}
	else
	{
		status = userCanceledErr;
	}
	
	return status;
}
@end