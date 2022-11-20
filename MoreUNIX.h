/*
	File:		MoreUNIX.h

	Contains:	Generic UNIX utilities.
*/

#pragma once

/////////////////////////////////////////////////////////////////

// MoreIsBetter Setup

#include "SetupRoutines.h"

#if !TARGET_RT_MAC_MACHO
	#error MoreUNIX requires the use of Mach-O
#endif

// System prototypes

#include <stdlib.h>

/////////////////////////////////////////////////////////////////

#ifdef __cplusplus
extern "C" {
#endif

// Macros that act like functions to convert OSStatus error codes to errno-style 
// error codes, and vice versa.  Right now these are just pass throughs because 
// OSStatus errors are 32 bit signed values that are generally negative, and 
// errno errors are 32 bit signed values that are small positive.

#define OSStatusToEXXX(os) ((int) (os))
#define EXXXToOSStatus(ex) ((OSStatus) (ex))

// A mechanism to extra errno if a function fails.  You typically use this as 
//
//   fd = open(...);
//   err = MoreUNIXErrno(fd);
//
// or
//
//   err = setuid(0);
//   err = MoreUNIXErrno(err);

#if MORE_DEBUG

	extern int MoreUNIXErrno(int result);

#else

	#define MoreUNIXErrno(err) (((err) < 0) ? errno : 0)

#endif

/////////////////////////////////////////////////////////////////

extern int UNIXRead( int fd,       void *buf, size_t bufSize, size_t *bytesRead   );
	// A wrapper around "read" that keeps reading until either 
	// bufSize bytes are read or until EOF is encountered, 
	// in which case you get EPIPE.
	//
	// If bytesRead is not NULL, *bytesRead will be set to the number 
	// of bytes successfully read.

extern int UNIXWrite(int fd, const void *buf, size_t bufSize, size_t *bytesWritten);
	// A wrapper around "write" that keeps writing until either 
	// all the data is written or an error occurs, in which case 
	// you get EPIPE.
	//
	// If bytesWritten is not NULL, *bytesWritten will be set to the number 
	// of bytes successfully written.

extern int IgnoreSIGPIPE(void);
	// Sets the handler for SIGPIPE to SIG_IGN.  If you don't call 
	// this, writing to a broken pipe will cause SIGPIPE (rather 
	// than having "write" return EPIPE), which is hardly ever 
	// what you want.

extern int UNIXReadDescriptor(int fd, int *fdRead);
	// Reads a file descriptor from a UNIX domain socket.
	//
	// On entry, fd must be non-negative.
	// On entry, fdRead must not be NULL, *fdRead must be -1
	// On success, *fdRead will be non-negative
	// On error, *fdRead will be -1

extern int UNIXWriteDescriptor(int fd, int fdToWrite);
	// Writes a file descriptor to a UNIX domain socket.
	//
	// On entry, fd must be non-negative, fdToWrite must be 
	// non-negative.

extern int UNIXCopyDescriptorToDescriptor(int source, int dest);
	// A naive copy engine, that copies from source to dest 
	// until EOF is encountered on source.  Not meant for 
	// copying large amounts of data.
	
extern int UNIXCopyFile(const char *source, const char *dest);
	// A very naive file copy implementation, that just opens 
	// up source and dest and copies the contents across 
	// using UNIXCopyDescriptorToDescriptor.
	// It does, however, handle setting the mode and access/modification 
	// times of dest properly.

#ifdef __cplusplus
}
#endif
