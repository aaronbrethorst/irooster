/*
	File:		CFUtilities.h

	Contains:	Core Foundation utility Routines.
*/

#pragma once

/////////////////////////////////////////////////////////////////

// MoreIsBetter Setup

#include "SetupRoutines.h"

// System Interfaces

#if MORE_FRAMEWORK_INCLUDES
	#include <CoreServices/CoreServices.h>
#else
	#include <CFBase.h>
	#include <CFURL.h>
	#include <CFPropertyList.h>
	#include <CFBundle.h>
	#include <Files.h>
#endif

/////////////////////////////////////////////////////////////////

#ifdef __cplusplus
extern "C" {
#endif

/////////////////////////////////////////////////////////////////
#pragma mark ***** Trivial Utilities

enum {
	kCFQKeyNotFoundErr = 5400,
	kCFQDataErr = 5401
};

extern pascal OSStatus CFQErrorBoolean(Boolean shouldBeTrue);
extern pascal OSStatus CFQError(const void *shouldBeNotNULL);

// Two wrappers around CFRelease/Retain that allow you to pass in NULL.

extern pascal CFTypeRef CFQRetain(CFTypeRef cf);
	// CFRetain if cf is not NULL.  Returns cf.
	
extern pascal void CFQRelease(CFTypeRef cf);
	// CFRelease if cf is not NULL.

extern pascal OSStatus CFQArrayCreateMutable(CFMutableArrayRef *result);
	// Creates an empty CFMutableArray that holds other CFTypes.
	//
	// result must not be NULL.
	// On input, *result must be NULL.
	// On error, *result will be NULL.
	// On success, *result will be an empty mutable array.

extern pascal OSStatus CFQArrayCreateWithDictionaryKeys(CFDictionaryRef dict, CFArrayRef *result);
extern pascal OSStatus CFQArrayCreateWithDictionaryValues(CFDictionaryRef dict, CFArrayRef *result);
	// Creates an array that holds all of the keys (or values) of dict.
	//
	// dict must not be NULL.
	// result must not be NULL.
	// On input, *result must be NULL.
	// On error, *result will be NULL.
	// On success, *result will be an array.

extern pascal OSStatus CFQDictionaryCreateMutable(CFMutableDictionaryRef *result);
	// Creates an empty CFMutableDictionary that holds other CFTypes.
	//
	// result must not be NULL.
	// On input, *result must be NULL.
	// On error, *result will be NULL.
	// On success, *result will be an empty mutable dictionary.

extern pascal OSStatus CFQDictionaryCreateWithArrayOfKeysAndValues(CFArrayRef keys, 
																   CFArrayRef values, 
																   CFDictionaryRef *result);
	// Creates a dictionary with the specified keys and values.
	//
	// keys must not be NULL.
	// values must not be NULL.
	// The length of keys and values must be the same.
	// result must not be NULL.
	// On input, *result must be NULL.
	// On error, *result will be NULL.
	// On success, *result will be an empty mutable dictionary.

extern pascal OSStatus CFQDictionarySetNumber(CFMutableDictionaryRef dict, const void *key, long value);
	// Set a CFNumber (created using kCFNumberLongType) in the 
	// dictionary with the specified key.  If an error is returned 
	// the dictionary will be unmodified.

extern pascal OSStatus CFQStringCopyCString(CFStringRef str, CFStringEncoding encoding, char **cStrPtr);
	// Extracts a C string from an arbitrary length CFString. 
	// The caller must free the resulting string using "free".
	// Returns kCFQDataErr if the CFString contains characters 
	// that can't be encoded in encoding.
	// 
	// str must not be NULL
	// On input,  cStrPtr must not be NULL
	// On input, *cStrPtr must be NULL
	// On error, *cStrPtr will be NULL
	// On success, *cStrPtr will be a C string that you must free

/////////////////////////////////////////////////////////////////
#pragma mark ***** Bundle Routines

extern pascal OSStatus CFQBundleCreateFromFrameworkName(CFStringRef frameworkName, 
														CFBundleRef *bundlePtr);
	// This routine finds a the named framework and creates a CFBundle 
	// object for it.  It looks for the framework in the frameworks folder, 
	// as defined by the Folder Manager.  Currently this is 
	// "/System/Library/Frameworks", but we recommend that you avoid hard coded 
	// paths to ensure future compatibility.
	//
	// You might think that you could use CFBundleGetBundleWithIdentifier but 
	// that only finds bundles that are already loaded into your context. 
	//
	// frameworkName must not be NULL
	// On input,    bundlePtr must not be NULL
	// On input,   *bundlePtr must be NULL
	// On error,   *bundlePtr will be NULL
	// On success, *bundlePtr will be a bundle reference that you must free

/////////////////////////////////////////////////////////////////
#pragma mark ***** Dictionary Path Routines

extern pascal OSStatus CFQDictionaryGetValueAtPath(CFDictionaryRef dict, 
												   const void *path[], CFIndex pathElementCount, 
												   const void **result);
	// Given a dictionary possibly containing nested dictionaries, 
	// this routine returns the value specified by path.  path is 
	// unbounded array of dictionary keys.  The first element of 
	// path must be the key of a property in dict.  If path has 
	// more than one element then the value of the property must 
	// be a dictionary and the next element of path must be a 
	// key in that dictionary.  And so on.  The routine returns 
	// the value of the dictionary property found at the end 
	// of the path.
	//
	// For example, if path is "A"/"B"/"C", then dict must contain 
	// a property whose key is "A" and whose value is a dictionary. 
	// That dictionary must contain a property whose key is "B" and 
	// whose value is a dictionary.  That dictionary must contain 
	// a property whose key is "C" and whose value this routine 
	// returns.
	//
	// dict must not be NULL.
	// path must not be NULL.
	// pathElementCount must be greater than 0.
	// result must not be NULL.
	// On success, *result is the value from the dictionary.

extern pascal OSStatus CFQDictionaryGetValueAtPathArray(CFDictionaryRef dict, 
												   CFArrayRef path, 
												   const void **result);
	// This routine is identical to CFQDictionaryGetValueAtPath except 
	// that you supply path as a CFArray instead of a C array.
	//
	// dict must not be NULL.
	// path must not be NULL.
	// path must have at least one element.
	// result must not be NULL.
	// On success, *result is the value from the dictionary.
	
extern pascal OSStatus CFQDictionarySetValueAtPath(CFMutableDictionaryRef dict, 
												   const void *path[], CFIndex pathElementCount, 
												   const void *value);
	// This routines works much like CFQDictionaryGetValueAtPath 
	// except that it sets the value at the end of the path 
	// instead of returning it.  For the set to work, 
	// dict must be mutable.  However, the dictionaries 
	// nested inside dict may not be mutable.  To make this 
	// work this routine makes a mutable copy of any nested 
	// dictionaries it traverses and replaces the (possibly) 
	// immutable nested dictionaries with these mutable versions. 
	//
	// The path need not necessarily denote an existing node 
	// in the nested dictionary tree.  However, this routine 
	// will only create a leaf node.  It won't create any 
	// parent nodes required to holf that leaf.
	//
	// dict must not be NULL.
	// path must not be NULL.
	// pathElementCount must be greater than 0.

extern pascal OSStatus CFQDictionarySetValueAtPathArray(CFMutableDictionaryRef dict, 
												   CFArrayRef path, 
												   const void *value);
	// This routine is identical to CFQDictionarySetValueAtPath except 
	// that you supply path as a CFArray instead of a C array.
	// 
	// dict must not be NULL.
	// path must not be NULL.
	// path must have at least one element.

extern pascal OSStatus CFQDictionaryRemoveValueAtPath(CFMutableDictionaryRef dict, 
												   const void *path[], CFIndex pathElementCount);
	// This routines works much like CFQDictionarySetValueAtPath 
	// except that it removes the value at the end of the path. 
	//
	// Unlike CFQDictionarySetValueAtPath, this routine requires 
	// that path denote an existing node in the nested dictionary 
	// tree.  Removing a non-existant node, even a leaf node, 
	// results in an error.
	// 
	// dict must not be NULL.
	// path must not be NULL.
	// pathElementCount must be greater than 0.
	
extern pascal OSStatus CFQDictionaryRemoveValueAtPathArray(CFMutableDictionaryRef dict, 
												   CFArrayRef path);
	// This routine is identical to CFQDictionaryRemoveValueAtPathArray 
	// except that you supply path as a CFArray instead of a C array.
	// 
	// dict must not be NULL.
	// path must not be NULL.
	// path must have at least one element.

/////////////////////////////////////////////////////////////////
#pragma mark ***** Property List Traversal Routines

typedef pascal void (*CFQPropertyListDeepApplierFunction)(CFTypeRef node, void *context);
	// A callback function for CFQPropertyListDeepApplyFunction.

extern pascal void CFQPropertyListDeepApplyFunction(CFPropertyListRef propList, 
													CFQPropertyListDeepApplierFunction func,
													void *context);
	// Calls "func" for every node in the property list.
	// 
	// propList must not be NULL.
	// func must not be NULL.

extern pascal Boolean CFQPropertyListIsLeaf(CFTypeRef node);
	// Given a node in a property list, this routine returns 
	// true if the node is a leaf (ie not a dictionary or an 
	// array).

typedef pascal void (*CFQPropertyListShallowApplierFunction)(CFTypeRef key, CFTypeRef node, void *context);
	// A callback function for CFQPropertyListShallowApplyFunction. 
	// 
	// node must be an element of either a dictionary or an array. 
	// If node is an element of a dictionary, key is its key within 
	// the dictionary.  If node is an element of an array, key 
	// is a CFNumber of its index in the array.

extern pascal void CFQPropertyListShallowApplyFunction(CFPropertyListRef propList, 
													   CFQPropertyListShallowApplierFunction func,
													   void *context);
	// Calls "func" for every node in the first level of the 
	// property list.  propList must be either a dictionary 
	// or an array.  To continue to lower levels, "func" should 
	// call CFQPropertyListApplyFunctionShallow again (only if 
	// CFQPropertyListIsLeaf is false).
	// 
	// propList must not be NULL.
	// func must not be NULL.

extern pascal OSStatus CFQPropertyListCreateFromXMLFSRef(const FSRef *xmlFile, CFPropertyListMutabilityOptions options, CFPropertyListRef *result);
	// Creates a property list based on the XML in the file.
	//
	// xmlFile must not be NULL
	// result must not be NULL
	// *result must be NULL
	// on success, *result will be a valid property list
	// on error, *result will be NULL
	
extern pascal OSStatus CFQPropertyListCreateFromXMLCFURL(CFURLRef xmlFile, CFPropertyListMutabilityOptions options, CFPropertyListRef *result);
	// Creates a property list based on the XML in the file.
	//
	// xmlFile must not be NULL
	// result must not be NULL
	// *result must be NULL
	// on success, *result will be a valid property list
	// on error, *result will be NULL

extern pascal OSStatus CFQDictionaryMerge(CFMutableDictionaryRef dst, CFDictionaryRef src);
	// Adds every key/value pair from src into dst, overwriting any 
	// current value for the key.
	//
	// dst must not be NULL
	// src must not be NULL
	
#ifdef __cplusplus
}
#endif
