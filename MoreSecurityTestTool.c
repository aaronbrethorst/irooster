/*
	File:		MoreSecurityTestTool.c

	Contains:	Helper tool for the MoreSecurityTest program.
*/

// System interfaces
#include <stdio.h>
#include <unistd.h>
#include <IOKit/pwr_mgt/IOPMLib.h>

// MoreIsBetter interfaces
#include "MoreUNIX.h"
#include "MoreSecurity.h"
#include "CFUtilities.h"

// Our interfaces
#include "MoreSecurityTestCommon.h"

/////////////////////////////////////////////////////////////////
// Executes a very simple command, which just returns 
// the EUID, RUID, and SUID of the helper tool.
static OSStatus DoAddWakeUpCommand(CFDictionaryRef request, CFDictionaryRef *result)
{
	OSStatus status = noErr;
	CFDateRef wakeUpTime;
	
	if (CFDictionaryGetValueIfPresent(request, kDateTimeKey, (const void **)&wakeUpTime))
	{
		IOReturn ioVal = IOPMSchedulePowerEvent(wakeUpTime, CFSTR(kHelperToolFullNameCSTR),CFSTR(kIOPMAutoWake));
		
		status = (kIOReturnSuccess == ioVal ? noErr : paramErr);
	}
	else
	{
		status = paramErr;
	}
	
	return status;
	
	/*! @function IOPMSchedulePowerEvent
    @abstract Schedule the machine to wake from sleep, power on, go to sleep, or shutdown. 
    @discussion This event will be added to the system's queue of power events and stored persistently on disk. 
	The sleep and shutdown events present a graphical warning and allow a console user to cancel the event.
	Must be called as root.
    @param time_to_wake Date and time that the system will power on/off.
    @param my_id A CFStringRef identifying the calling app by CFBundleIdentifier. May be NULL.
    @param type The type of power on you desire, either wake from sleep or power on. Choose from:
	CFSTR(kIOPMAutoWake) == wake machine, CFSTR(kIOPMAutoPowerOn) == power on machine, 
	CFSTR(kIOPMAutoWakeOrPowerOn) == wake(if asleep) or power on(if off),
	CFSTR(kIOPMAutoSleep) == sleep machine, CFSTR(kIOPMAutoShutdown) == power off machine.
    @result kIOReturnSuccess on success, otherwise on failure
	*/
	//IOReturn IOPMSchedulePowerEvent(CFDateRef time_to_wake, CFStringRef my_id, CFStringRef type);
}

/////////////////////////////////////////////////////////////////
// Executes a very simple command, which just returns 
// the EUID, RUID, and SUID of the helper tool.
static OSStatus DoDeleteWakeUpCommand(CFDictionaryRef request, CFDictionaryRef *result)
{
	OSStatus status = noErr;
	CFDateRef wakeUpTime;
	
	if (CFDictionaryGetValueIfPresent(request, kDateTimeKey, (const void **)&wakeUpTime))
	{
		IOReturn ioVal = IOPMCancelScheduledPowerEvent(wakeUpTime, CFSTR(kHelperToolFullNameCSTR),CFSTR(kIOPMAutoWake));
		
		status = (kIOReturnSuccess == ioVal ? noErr : paramErr);
	}
	else
	{
		status = paramErr;
	}
	
	return status;
	
	/*! @function IOPMCancelScheduledPowerEvent
    @abstract Cancel a previously scheduled power event.
    @discussion Arguments mirror those to IOPMSchedulePowerEvent. All arguments must match the original arguments 
	from when the power on was scheduled.
	Must be called as root.
    @param time_to_wake Cancel entry with this date and time.
    @param my_id Cancel entry with this name.
    @param type Type to cancel
    @result kIOReturnSuccess on success, otherwise on failure
	*/
	//IOReturn IOPMCancelScheduledPowerEvent(CFDateRef time_to_wake, CFStringRef my_id, CFStringRef type);
	
}

// Our command callback for MoreSecHelperToolMain.  Extracts 
// the command name from the request dictionary and calls 
// through to the appropriate command handler (in this case 
// there's only one).
static OSStatus WakeUpCommandProc(AuthorizationRef auth, CFDictionaryRef request, CFDictionaryRef *result)
{
	OSStatus 	err;
	CFStringRef command;
	
	assert(auth != NULL);
	assert(request != NULL);
	assert( result != NULL);
	assert(*result == NULL);
	assert(geteuid() == getuid());
	
	err = noErr;
	command = (CFStringRef) CFDictionaryGetValue(request, kWakeUpHelperCommandNameKey);
	
	if ( (command == NULL) || (CFGetTypeID(command) != CFStringGetTypeID()) )
	{
		err = paramErr;
	}
	
	if (noErr == err)
	{
		static const char *kRightName = kHelperToolFullNameCSTR;
		static const AuthorizationFlags kAuthFlags = kAuthorizationFlagDefaults 
			| kAuthorizationFlagInteractionAllowed
			| kAuthorizationFlagExtendRights
			;
		AuthorizationItem   right  = { kRightName, 0, NULL, 0 };
		AuthorizationRights rights = { 1, &right };
		
		// Before doing our privileged work, acquire an authorization right.
		// This allows the system administrator to configure the system 
		// (via "/etc/authorization") for the security level that they want.
		//
		// Unfortunately, the default rule in "/etc/authorization" always 
		// triggers a password dialog.  Right now, there's no way around 
		// this [2939908].  One commonly accepted workaround is to not 
		// acquire a authorization right (ie don't call AuthorizationCopyRights
		// here) but instead limit your tool in some other way.  For example, 
		// an Internet setup assistant helper tool might only allow the user 
		// to modify network locations that they created.
		
		//fucking stupid. Perhaps we do a quick check for 's' bit and if root is owner.
		
		if (MoreSecSetPrivilegedEUID() != 0)
		{
			err = AuthorizationCopyRights(auth, &rights, kAuthorizationEmptyEnvironment, kAuthFlags, NULL);
		}
		
		if (noErr == err)
		{
			if (CFEqual(command, kAddWakeUpCommand))
			{
				err = DoAddWakeUpCommand(request, result);
			}
			else if (CFEqual(command, kDeleteWakeUpCommand))
			{
				err = DoDeleteWakeUpCommand(request, result);
			}
			else
			{
				err = paramErr;
			}
		}
	}
	return err;
}

int main(int argc, const char *argv[])
{	
	int 				err;
	int 				result;
	AuthorizationRef 	auth;
	
	auth = MoreSecHelperToolCopyAuthRef();
	err = MoreSecDestroyInheritedEnvironment(kMoreSecKeepStandardFilesMask, argv);
	
	// Mask SIGPIPE, otherwise stuff won't work properly.
	
	if (0 == err)
	{
		err = IgnoreSIGPIPE();
	}
	
	// Call the MoreSecurity helper routine.
	
	if (0 == err)
	{
		err = MoreSecHelperToolMain(STDIN_FILENO, STDOUT_FILENO, auth, WakeUpCommandProc, argc, argv);
	}

	result = MoreSecErrorToHelperToolResult(err);

	return result;
}
