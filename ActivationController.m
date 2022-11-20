//
//  ActivationController.m
//  iRooster
//
//  Created by Aaron Brethorst on Tue Aug 12 2003.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import "ActivationController.h"
#import "eSellerateController.h"
#import "validateLib.h"

@implementation ActivationController

- (id)initWithWindowNibName:(NSString*)name
{
	if (self = [super initWithWindowNibName:name])
	{
		success = NO;
	}
	
	return self;
}

- (void)awakeFromNib
{
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	
	NSArray *types = [pb types];
	
	if (NSNotFound == [types indexOfObject:@"NSStringPboardType"])
		return;
	
	NSString *serial = [pb stringForType:@"NSStringPboardType"];
	
	[txtSerialNumber setStringValue:serial];
}

- (IBAction)registerApp:(id)sender
{
	const char* serialNumber = [[txtSerialNumber stringValue] cStringUsingEncoding:NSUTF8StringEncoding];
	const char* name = [[txtName stringValue] cStringUsingEncoding:NSUTF8StringEncoding];
	
	[eSellerateController installEngine]; //added for March eSellerate API update.

    if (0 != eWeb_ValidateSerialNumber(serialNumber, name, nil, nil/*"\p67538"*/))
    {
        [[NSUserDefaults standardUserDefaults] setObject:[txtName stringValue] forKey:@"RegisteredUser"];
        [[NSUserDefaults standardUserDefaults] setObject:[txtSerialNumber stringValue] forKey:@"SerialNumber"];
        [[NSUserDefaults standardUserDefaults] synchronize];
		
		success = YES;
        
        [NSApp stopModal];
    }
	else
	{
		success = NO;
	}

	success = NO;
}


- (BOOL)success
{
	return success;
}

- (IBAction)cancel:(id)sender
{
    [NSApp stopModal];
	success = NO;
}

@end
