/*
	File:		MoreUNIX.c

	Contains:	Generic UNIX utilities.
*/

/////////////////////////////////////////////////////////////////

// Our prototypes

#include "MoreUNIX.h"

// System interfaces

#include <sys/param.h>
#include <mach-o/dyld.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <signal.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/uio.h>
#include <stdbool.h>

// "crt_externs.h" has no C++ guards [3126393], so we have to provide them 
// ourself otherwise we get a link error.

#ifdef __cplusplus
extern "C" {
#endif

#include <crt_externs.h>

#ifdef __cplusplus
}
#endif

// MIB Interfaces

/////////////////////////////////////////////////////////////////

#if MORE_DEBUG

	// There's a macro version of this in the header.
	
	extern int MoreUNIXErrno(int result)
	{
		int err;
		
		err = 0;
		if (result < 0) {
			err = errno;
			assert(err != 0);
		}
		return err;
	}

#endif

/////////////////////////////////////////////////////////////////

extern int UNIXRead( int fd,       void *buf, size_t bufSize, size_t *bytesRead   )
	// See comment in header.
{
	int 	err;
	char *	cursor;
	size_t	bytesLeft;
	ssize_t bytesThisTime;

	assert(fd >= 0);
	assert(buf != NULL);
	
	err = 0;
	bytesLeft = bufSize;
	cursor = (char *) buf;
	while ( (err == 0) && (bytesLeft != 0) ) {
		bytesThisTime = read(fd, cursor, bytesLeft);
		if (bytesThisTime > 0) {
			cursor    += bytesThisTime;
			bytesLeft -= bytesThisTime;
		} else if (bytesThisTime == 0) {
			err = EPIPE;
		} else {
			assert(bytesThisTime == -1);
			
			err = errno;
			assert(err != 0);
			if (err == EINTR) {
				err = 0;		// let's loop again
			}
		}
	}
	if (bytesRead != NULL) {
		*bytesRead = bufSize - bytesLeft;
	}
	
	return err;
}

extern int UNIXWrite(int fd, const void *buf, size_t bufSize, size_t *bytesWritten)
	// See comment in header.
{
	int 	err;
	char *	cursor;
	size_t	bytesLeft;
	ssize_t bytesThisTime;
	
	assert(fd >= 0);
	assert(buf != NULL);
	
	// SIGPIPE occurs when you write to pipe or socket 
	// whose other end has been closed.  The default action 
	// for SIGPIPE is to terminate the process.  That's 
	// probably not what you wanted.  So, in the debug build, 
	// we check that you've set the signal action to SIG_IGN 
	// (ignore).  Of course, you could be building a program 
	// that needs SIGPIPE to work in some special way, in 
	// which case you should define MORE_UNIX_WRITE_CHECK_SIGPIPE 
	// to 0 to bypass this check.
	//
	// IgnoreSIGPIPE, a helper routine defined below, 
	// lets you disable SIGPIPE easily.

	//XXX will this solve the issue?
	/*
	#if !defined(MORE_UNIX_WRITE_CHECK_SIGPIPE)
		#define MORE_UNIX_WRITE_CHECK_SIGPIPE 1
	#endif
	#if MORE_DEBUG && MORE_UNIX_WRITE_CHECK_SIGPIPE
		{
			int junk;
			struct sigaction currentSignalState;
			
			junk = sigaction(SIGPIPE, NULL, &currentSignalState);
			assert(junk == 0);
			
			assert( currentSignalState.sa_handler == SIG_IGN );
		}
	#endif
	*/
	
	err = 0;
	bytesLeft = bufSize;
	cursor = (char *) buf;
	while ( (err == 0) && (bytesLeft != 0) ) {
		bytesThisTime = write(fd, cursor, bytesLeft);
		if (bytesThisTime > 0) {
			cursor    += bytesThisTime;
			bytesLeft -= bytesThisTime;
		} else if (bytesThisTime == 0) {
			assert(false);
			err = EPIPE;
		} else {
			assert(bytesThisTime == -1);
			
			err = errno;
			assert(err != 0);
			if (err == EINTR) {
				err = 0;		// let's loop again
			}
		}
	}
	if (bytesWritten != NULL) {
		*bytesWritten = bufSize - bytesLeft;
	}
	
	return err;
}

extern int IgnoreSIGPIPE(void)
	// See comment in header.
{
	int err;
	struct sigaction signalState;
	
	err = sigaction(SIGPIPE, NULL, &signalState);
	err = MoreUNIXErrno(err);
	if (err == 0) {
		signalState.sa_handler = SIG_IGN;
		
		err = sigaction(SIGPIPE, &signalState, NULL);
		err = MoreUNIXErrno(err);
	}
	
	return err;
}

// When we pass a descriptor, we have to pass at least one byte 
// of data along with it, otherwise the recvmsg call will not 
// block if the descriptor hasn't been written to the other end 
// of the socket yet.

static const char kDummyData = 'D';

extern int UNIXReadDescriptor(int fd, int *fdRead)
	// See comment in header.
{
	int 				err;
	struct msghdr 		msg;
	struct iovec		iov;
	struct {
		struct cmsghdr 	hdr;
		int            	fd;
	} 					control;
	char				dummyData;
	ssize_t				bytesReceived;

	assert(fd >= 0);
	assert( fdRead != NULL);
	assert(*fdRead == -1);

	iov.iov_base = (char *) &dummyData;
	iov.iov_len  = sizeof(dummyData);
	
    msg.msg_name       = NULL;
    msg.msg_namelen    = 0;
    msg.msg_iov        = &iov;
    msg.msg_iovlen     = 1;
    msg.msg_control    = (caddr_t) &control;
    msg.msg_controllen = sizeof(control);
    msg.msg_flags	   = MSG_WAITALL;
    
    do {
	    bytesReceived = recvmsg(fd, &msg, 0);
	    if (bytesReceived == sizeof(dummyData)) {
	    	if (   (dummyData != kDummyData)
	    		|| (msg.msg_flags != 0) 
	    		|| (msg.msg_control == NULL) 
	    		|| (msg.msg_controllen != sizeof(control)) 
	    		|| (control.hdr.cmsg_len != sizeof(control)) 
	    		|| (control.hdr.cmsg_level != SOL_SOCKET)
				|| (control.hdr.cmsg_type  != SCM_RIGHTS) 
				|| (control.fd < 0) ) {
	    		err = EINVAL;
	    	} else {
	    		*fdRead = control.fd;
		    	err = 0;
	    	}
	    } else if (bytesReceived == 0) {
	    	err = EPIPE;
	    } else {
	    	assert(bytesReceived == -1);

	    	err = errno;
	    	assert(err != 0);
	    }
	} while (err == EINTR);

	assert( (err == 0) == (*fdRead >= 0) );
	
	return err;
}

extern int UNIXWriteDescriptor(int fd, int fdToWrite)
	// See comment in header.
{
	int 				err;
	struct msghdr 		msg;
	struct iovec		iov;
	struct {
		struct cmsghdr 	hdr;
		int            	fd;
	} 					control;
	ssize_t 			bytesSent;

	assert(fd >= 0);
	assert(fdToWrite >= 0);

    control.hdr.cmsg_len   = sizeof(control);
    control.hdr.cmsg_level = SOL_SOCKET;
    control.hdr.cmsg_type  = SCM_RIGHTS;
    control.fd             = fdToWrite;

	iov.iov_base = (char *) &kDummyData;
	iov.iov_len  = sizeof(kDummyData);
	
    msg.msg_name       = NULL;
    msg.msg_namelen    = 0;
    msg.msg_iov        = &iov;
    msg.msg_iovlen     = 1;
    msg.msg_control    = (caddr_t) &control;
    msg.msg_controllen = control.hdr.cmsg_len;
    msg.msg_flags	   = 0;
    do {
	    bytesSent = sendmsg(fd, &msg, 0);
	    if (bytesSent == sizeof(kDummyData)) {
	    	err = 0;
	    } else {
	    	assert(bytesSent == -1);

	    	err = errno;
	    	assert(err != 0);
	    }
	} while (err == EINTR);

    return err;
}

extern int UNIXCopyDescriptorToDescriptor(int source, int dest)
	// See comment in header.
{
	int		err;
	bool    done;
	char *  buffer;
	static const size_t kBufferSize = 64 * 1024;
	
	assert(source >= 0);
	assert(dest   >= 0);
	
	err = 0;
	buffer = (char *) malloc(kBufferSize);
	if (buffer == NULL) {
		err = ENOMEM;
	}

	if (err == 0) {	
		done = false;
		do {
			size_t bytesRead;
			
			err = UNIXRead(source, buffer, kBufferSize, &bytesRead);
			if (err == EPIPE) {
				done = true;
				err = 0;
			}
			if (err == 0) {
				err = UNIXWrite(dest, buffer, bytesRead, NULL);
			}
		} while (err == 0 && !done);
	}
	
	free(buffer);
	
	return err;
}

extern int UNIXCopyFile(const char *source, const char *dest)
	// See comment in header.
{
	int 		err;
	int 		junk;
	int 		sourceFD;
	int 		destFD;
	struct stat sb;
	
	assert(source != NULL);
	assert(dest   != NULL);
	
	sourceFD = -1;
	destFD   = -1;

	err = stat(source, &sb);
	err = MoreUNIXErrno(err);
	
	if (err == 0) {
		sourceFD = open(source, O_RDONLY, 0);
		err = MoreUNIXErrno(sourceFD);
	}
	
	if (err == 0) {
		destFD = open(dest, O_WRONLY | O_CREAT | O_TRUNC, sb.st_mode & ~(S_ISUID | S_ISGID | S_ISVTX));
		err = MoreUNIXErrno(destFD);
	}
	
	if (err == 0) {
		err = UNIXCopyDescriptorToDescriptor(sourceFD, destFD);
	}

	// Close the descriptors.
	
	if (sourceFD != -1) {
		junk = close(sourceFD);
		assert(junk == 0);
	}
	if (destFD != -1) {
		junk = close(destFD);
		assert(junk == 0);
	}

	// Set the access and modification times of the destination 
	// to match the source.  I originally did this using futimes, 
	// but hey, that's not available on 10.1, so now I do it 
	// using utimes.  *sigh*
	
	if (err == 0) {
		struct timeval times[2];
		
		TIMESPEC_TO_TIMEVAL(&times[0], &sb.st_atimespec);
		TIMESPEC_TO_TIMEVAL(&times[1], &sb.st_mtimespec);
		
		err = utimes(dest, times);
		err = MoreUNIXErrno(err);
	}

	return err;
}
