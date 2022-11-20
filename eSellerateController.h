//
//  eSellerateController.h
//  iRooster
//
//  Created by Aaron Brethorst on Mon Feb 09 2004.
//  Copyright (c) 2003-2006 Chimp Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface eSellerateController : NSObject {
    IBOutlet NSMenuItem *purchaseMenu;
    IBOutlet NSMenuItem *registerMenu;
	
	BOOL fTerminate;
	BOOL fActivationSuccess;
}
- (void)checkRegistrationStatus;
- (IBAction)menuPurchase:(id)sender;
- (IBAction)activate:(id)sender;
- (BOOL)terminate;
+ (BOOL)isRegistered;
- (void)displayAlert:(int)daysUsed;
+ (void)installEngine;
@end