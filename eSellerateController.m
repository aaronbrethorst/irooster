//
//  eSellerateController.m
//  iRooster
//
//  Created by Aaron Brethorst on Mon Feb 09 2004.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import "eSellerateController.h"
#import "EWSLib.h"
#import "validateLib.h"
#import "ActivationController.h"
#import "PrefsController.h"

#define __REGISTRATION_CALENDAR_FORMAT__ @"%B %d %Y"

@interface eSellerateController (PrivateMethods)
- (void)setRegisteredName:(NSString*)name serialNumber:(NSString*)serialNumber;
- (NSCalendarDate*)calculateFirstRunDate;
- (int)calculateDaysUsed;
@end

@implementation eSellerateController
- (void)awakeFromNib
{
	fTerminate = NO;
	fActivationSuccess = NO;
}

- (IBAction)activate:(id)sender
{
    ActivationController *ac = [[ActivationController alloc] initWithWindowNibName:@"Activation"];
	
    [NSApp runModalForWindow:[ac window]];
	
	fActivationSuccess = [ac success];
	
	[[ac window] close];
	
    [ac release];
}

- (IBAction)menuPurchase:(id)sender
{
	OSStatus error;
	char *resultData = NULL;
	BOOL result;
	
	[eSellerateController installEngine];
	
	if (!eWeb_IsSystemCompatible())
	{
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://store.eSellerate.net/s.aspx?s=STR4499832188"]];
	}
	else
	{
		NSLog(@"about to call eWeb_Purchase");
		// EWS SDK Purchase Function
		error = eWeb_Purchase("STR7557070645",		/*correct?*/							// eSeller RefNum
							  "SKU0844368508",		/*correct*/							// SKU RefNum
							  nil/*"JESIigq7"*/,	/*correct*/									// Preview Certificate
							  nil,												// Layout Certificate
							  nil,												// Tracking ID Code
							  nil,												// Affiliate ID Code
							  nil,												// Coupon ID Code
							  nil,												// Activation ID
							  nil,												// Extra information, for instance for custom serial numbers
							  &resultData);										// Pointer to memory which will be allocated and filled by the Engine upon success.

		if(error == E_SUCCESS)
		{
			char regName[256];
			char serialNumber[256];
			
			// EWS SDK
			result = eWeb_GetOrderItemByIndex(resultData,							// results from the Purchase function
											  0,									// zero-based index of the order item for which we need
											  nil,									// SKuRefNum, not needed here
											  nil,									// Redirect SkuRefNum, not needed here
											  nil,									// Quantity, not needed here
											  regName,									// Registration Name, not needed here
											  serialNumber,							// Serial Number associated with the purchase
											  nil,									// PromptedValue, not needed here
											  nil,									// ActivationID, not needed here
											  nil,									// ActivationKey, not needed here
											  nil);									// DownloadURL, not needed here
			
			[self setRegisteredName:[NSString stringWithUTF8String:regName] serialNumber:[NSString stringWithUTF8String:serialNumber]];
			
			//[self updateSN];
		}
		else
		{
			int daysUsed = [self calculateDaysUsed];
			[self displayAlert:daysUsed];
		}
		
		eWeb_DisposeResultData(resultData);
	}
}

- (void)setRegisteredName:(NSString*)name serialNumber:(NSString*)serialNumber
{
	[[NSUserDefaults standardUserDefaults] setObject:name forKey:@"RegisteredUser"];
	[[NSUserDefaults standardUserDefaults] setObject:serialNumber forKey:@"SerialNumber"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isRegistered
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    eSellerate_DaysSince2000 validSN;
   
	NSString *regName = [prefs objectForKey:@"RegisteredUser"];
	NSString *serialNumber = [prefs objectForKey:@"SerialNumber"];
	
    if (regName && serialNumber)
    {
		validSN = eWeb_ValidateSerialNumber([serialNumber UTF8String], [regName UTF8String], nil, nil);
		return (BOOL)validSN;
	}
	else
	{
		return NO;
	}
}

- (void)checkRegistrationStatus
{
    NSCalendarDate *firstRunDate;
    int daysUsed;
    
    NSString *dayForm;
    int clickResult;
	
	if ([eSellerateController isRegistered])
	{		
		[[purchaseMenu menu] removeItem:purchaseMenu];
		[[registerMenu menu] removeItem:registerMenu];
		return;
	}
	
	firstRunDate = [self calculateFirstRunDate];
	
    daysUsed = [self calculateDaysUsed];
	
	if (daysUsed > 14 || daysUsed < 0)
		[self displayAlert:daysUsed];
	else
    {
        if (daysUsed == 1)
			dayForm = NSLocalizedStringFromTable(@"day",@"iRoosterStrings",@"Localized word for day, like one day instead of the converse of night.");
		else
			dayForm = NSLocalizedStringFromTable(@"days",@"iRoosterStrings",@"Localized word for days, like two days instead of the converse of night.");
		
		NSString *locTitle = NSLocalizedStringFromTable(@"Register iRooster",@"iRoosterStrings",@"Pretty straightforward. Used as button text.");
		NSString *locBody = NSLocalizedStringFromTable(@"You have used iRooster for %d %@. You must purchase iRooster or delete it after 14 days.",@"iRoosterStrings",@"Body text for the Registration alert panel.");
		NSString *locOK = NSLocalizedStringFromTable(@"OK",@"iRoosterStrings",@"Standard OK button text.");
		NSString *locPurchase = NSLocalizedStringFromTable(@"Purchase...",@"iRoosterStrings",@"Purchase button for the Registration alert panel.");

        clickResult = NSRunAlertPanel(locTitle, [NSString stringWithFormat:locBody,daysUsed, dayForm],locOK,locPurchase,nil);

        if (NSOKButton != clickResult)
        {
            [self menuPurchase:nil];
        }
    }
}

- (void)displayAlert:(int)daysUsed
{
	int clickResult;
	
	if (daysUsed > 14 || daysUsed < 0)
    {
        clickResult = NSRunAlertPanel(NSLocalizedStringFromTable(@"Register iRooster",@"iRoosterStrings",@"Pretty straightforward. Used as button text."),
                                      [NSString stringWithFormat:NSLocalizedStringFromTable(@"You have used iRooster for %d days. You must now purchase iRooster or delete it.",@"iRoosterStrings",@"- (void)checkRegistrationStatus"),daysUsed],
                                      NSLocalizedStringFromTable(@"Purchase...",@"iRoosterStrings",@"Purchase button for the Registration alert panel."),
                                      NSLocalizedStringFromTable(@"Quit",@"iRoosterStrings",@"- (void)checkRegistrationStatus"),
									  NSLocalizedStringFromTable(@"Register",@"iRoosterStrings",@"- (void)checkRegistrationStatus"),
                                      nil);
        if (NSOKButton == clickResult)
        {
            [self menuPurchase:nil];
        }
        else if (NSCancelButton == clickResult)
        {
			fTerminate = YES;
            [NSApp terminate:nil];
        }
		else
		{
			[self activate:nil];
			
			if (fActivationSuccess)
			{
				return;
			}
			else
			{
				[self displayAlert:daysUsed];
			}
		}
	}
}

- (int)calculateDaysUsed
{
	return [[NSCalendarDate calendarDate] dayOfCommonEra] - [[self calculateFirstRunDate] dayOfCommonEra];
}

- (NSCalendarDate*)calculateFirstRunDate
{
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	if (nil == [prefs objectForKey:@"FirstRunDate"])
    {
        PrefsController *prefsController = [[PrefsController alloc] initWithWindowNibName:@"Preferences"];
        [prefsController awakeFromNib];
        [prefsController release];
        
        [prefs setObject:[NSCalendarDate calendarDate] forKey:@"FirstRunDate"];
        [prefs synchronize];
        
		return [NSCalendarDate calendarDate];
    }
    else
    {
        return [NSCalendarDate dateWithString:[[prefs objectForKey:@"FirstRunDate"]
									 descriptionWithCalendarFormat:__REGISTRATION_CALENDAR_FORMAT__ timeZone:nil locale:nil]
							   calendarFormat:__REGISTRATION_CALENDAR_FORMAT__];
    }	
}

+ (void)installEngine
{
	NSString *mypath;
	
	mypath = [[NSBundle mainBundle] pathForResource:@"EWSMacCompress.tar.gz" ofType:nil];
	
	OSStatus error = eWeb_InstallEngineFromPath([mypath UTF8String]);
	
	if (error < 0) 
		NSRunAlertPanel(@"iRooster was unable to install the eSellerate engine. Please contact us at support@chimpsoftware.com for assistance.", @"", @"OK", nil, nil);
}

- (BOOL)terminate
{
	return fTerminate;
}
@end
