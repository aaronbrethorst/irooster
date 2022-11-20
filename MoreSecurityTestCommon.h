/*
	File:		MoreSecurityTestCommon.h

	Contains:	Definitions common to the MoreSecurityTest app and helper tool.
UCH DAMAGE.

	Change History (most recent first):

$Log: MoreSecurityTestCommon.h,v $
Revision 1.2  2003/05/25 12:25:33  eskimo1
Added support for the descriptor passing test.

Revision 1.1  2002/11/09 00:10:00  eskimo1
First checked in. Tests MoreSecurity's helper tool helper.


*/

#pragma once

/////////////////////////////////////////////////////////////////

// MoreIsBetter Setup

#include "SetupRoutines.h"

// System prototypes

/////////////////////////////////////////////////////////////////

#ifdef __cplusplus
extern "C" {
#endif

#define kWakeUpHelperCommandNameKey CFSTR("CommandName")

#define kAddWakeUpCommand CFSTR("AddWakeUp")
#define kDeleteWakeUpCommand CFSTR("DeleteWakeUp")
	
#define kDateTimeKey CFSTR("DateAndTime")

#define kHelperToolFullNameCSTR "com.chimpsoftware.iRooster.HelperTool"
	
#define kMoreSecurityTestGetUIDsResponseRUID CFSTR("RUID")
#define kMoreSecurityTestGetUIDsResponseEUID CFSTR("EUID")
#define kMoreSecurityTestGetUIDsResponseSUID CFSTR("SUID")
#define kMoreSecurityTestLowNumberPortCommand CFSTR("LowNumberedPorts")
	// response comes back in kMoreSecFileDescriptorsKey

#ifdef __cplusplus
}
#endif
