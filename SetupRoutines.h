/*
	File:		SetupRoutines.h

	Contains:	Sets up conditions etc for MoreIsBetter.
*/

#pragma once

	//
	//	We never want to use old names or locations.
	//	Since these settings must be consistent all the way through
	//	a compilation unit, and since we don't want to silently
	//	change them out from under a developer who uses a prefix
	//	file (C/C++ panel of Target Settings), we simply complain
	//	if they are already set in a way we don't like.
	//

#ifndef OLDROUTINELOCATIONS
	#define OLDROUTINELOCATIONS 0
#elif OLDROUTINELOCATIONS
	#error OLDROUTINELOCATIONS must be FALSE when compiling MoreIsBetter.
#endif

#ifndef OLDROUTINENAMES
	#define OLDROUTINENAMES 0
#elif OLDROUTINENAMES
	#error OLDROUTINENAMES must be FALSE when compiling MoreIsBetter.
#endif

	//
	//	The next statement sets up the various TARGET_xxx 
	//	variables needed later in this file.
	//
	
#include <TargetConditionals.h>

	//
	//  "TargetConditionals.h" on Mac OS X doesn't define 
	//  TARGET_API_MAC_CARBON, which is kinda annoying.  So, 
	//  if we're building for Mach-O and it hasn't been set, 
	//  set it.  All Mach-O builds are inherently Carbon builds.
	//
	//  Note that we *have* to set TARGET_API_MAC_CARBON because 
	//  MoreIsBetter code tests it.  However, we also want to set 
	//  the other values because otherwise GCC won't use its 
	//  precompiled header.  I thought about fixing this by 
	//  including <ConditionalMacros.h> via <CoreServices/CoreServices.h>, 
	//  but the whole goal of using <TargetConditionals.h> was to 
	//  allow MoreIsBetter projects to have no dependencies on 
	//  frameworks beyond System.framework.
	//

#if TARGET_RT_MAC_MACHO
	#define TARGET_API_MAC_OS8 0
	#define TARGET_API_MAC_CARBON 1
	#define TARGET_API_MAC_OSX 1
#endif

	//
	//	We need a master conditional to determine whether to use 
	//	framework notation to reference include files.  There is 
	//  no good way to determine whether the source tree 
	//  is using framework includes or not, so we make a guess and 
	//  say that Mach-O implies framework includes.  However, 
	//  if you're building CFM with framework includes (which is 
	//  possible, although somewhat tricky), you'll have to 
	//  override this.
	//

#if !defined(MORE_FRAMEWORK_INCLUDES)
	#if TARGET_RT_MAC_MACHO
		#define MORE_FRAMEWORK_INCLUDES 1
	#else
		#define MORE_FRAMEWORK_INCLUDES 0
	#endif
#endif

	//
	//	Now that we've included a Mac OS interface file,
	//	we know that the Universal Interfaces environment
	//	is set up.  MoreIsBetter requires Universal Interfaces
	//	3.4 or higher.  Check for it.  Of course, "TargetConditionals.h" 
	//  on Mac OS X doesn't set UNIVERSAL_INTERFACES_VERSION, so 
	//  we only check this if we're not using framework includes.
	//

#if !MORE_FRAMEWORK_INCLUDES
	#if !defined(UNIVERSAL_INTERFACES_VERSION) || UNIVERSAL_INTERFACES_VERSION < 0x0341
		#error MoreIsBetter requires Universal Interfaces 3.4.1 or higher.
	#endif
#endif

	//
	//	We usually want assertions and other debugging code
	//	turned on, but you can turn it all off if you like
	//	by setting MORE_DEBUG to 0.  Also, now that we use 
	//  the standard C assertion mechanism, we default to 
	//  have MORE_DEBUG off if NDEBUG is set.
	//

#if !defined(MORE_DEBUG)
	#if defined(NDEBUG)
		#define MORE_DEBUG 0
	#else
		#define MORE_DEBUG 1
	#endif
#endif

	//
	//  We now use standard C assertions throughout MoreIsBetter.
	//  Previously we would declare two custom assertion macros, 
	//  MoreAssert and MoreAssertQ.
	//
	//	Our assertion macros compile down to nothing if
	//	MORE_DEBUG is not true. MoreAssert produces a
	//	value indicating whether the assertion succeeded
	//	or failed. MoreAssertQ is Quinn's flavor of
	//	MoreAssert which does not produce a value.
	//

#include <assert.h>

	//
	//  Chances are that if you're building CFM then you'd much 
	//  rather have assert triggered DebugStr that abort.  The 
	//  following redefines assert that way.  We don't do this 
	//  for Mach-O because you might be building a Mach-O tool that 
	//  doesn't have access to DebugStr.
	// 
	
#if TARGET_RT_MAC_CFM && !defined(NDEBUG)
	#undef assert
	#define assert(x) ((x) ? ((void) 0) : DebugStr("\pMoreIsBetter assertion failure: " #x))
#endif

	// 
	//  Finally, we define MoreAssertPCG, to accomodate some 
	//  older MoreIsBetter code that tests the result of its 
	//  assertions.  This doesn't fit in with the standard C 
	//  assert model, so I've deprecated the approach.  However
	//  there's a bunch of existing code that works that way 
	//  and reworking it would be likely to generate errors. 
	//  Fortunately, all of the old code that uses this is 
	//  Carbon based, so I don't have to worry about not having 
	//  access to DebugStr.
	// 
	
#if MORE_DEBUG
	#define MoreAssertPCG(x) \
		((x) ? true : (DebugStr ("\pMoreIsBetter assertion failure: " #x), false))
#else
	#define MoreAssertPCG(x) (true)
#endif
