/*
 *----------------------------------------------------------------------------
 * Copyright notice:
 * (c) Copyright 2011 Audible Magic
 * All rights reserved.
 *
 * This program is protected as an unpublished work under the U.S. copyright
 * laws. The above copyright notice is not intended to effect a publication of
 * this work.
 *
 * This program is the confidential and proprietary information of Audible
 * Magic.  Neither the binaries nor the source code may be redistributed 
 * without prior written permission from Audible Magic. 
 *----------------------------------------------------------------------------
 *
 * File: MF_MediaID_api.h
 */

#ifndef _mf_mediaid_api_h
#define _mf_mediaid_api_h

#include "mfGlobals.h"
#include "mfErrors_oem.h"
#include "mfMacros.h"
#include "mfAlloc.h"

#ifdef __cplusplus
extern "C" {
#endif

/*--------------------- Media Identification Request API ----------------------*/

#define MF_ERROR_STRING_LENGTH 		(100)
#define MF_VERSION_STRING_LENGTH 	(20)

typedef void* MFMediaID;	   /* this object holds information about the client application */
				   /* it can be initialized once and used to identify many files */

typedef void* MFMediaIDResponse;   /* this object represents the response from the server */
				   /* There are a few routines to help extract the nature of the response */

typedef void* MFMediaIDRequest;    /* this object represents the ID request that will be sent to the server */

typedef char* MFFilePath;
typedef const char* MFConstString;

typedef enum 
{
    MF_MEDIAID_RESPONSE_UNKNOWN = 0,	/* the server returned some sort of error condition */
    MF_MEDIAID_RESPONSE_NOT_FOUND,	/* we did not find this file in our database */
    MF_MEDIAID_RESPONSE_FOUND,		/* this file matched a known file in our database */
} MFResponseStatus;

typedef enum
{
    MF_16BIT_SIGNED_LINEAR_PCM,
} MFSampleFormat;


/* 
 * The create routines require an Audible Magic .config file.
 *
 * The create routines to construct the MFMediaID object, requires a configuration file supplied 
 * by Audible Magic. The first form will use the first .config file found in the current directory.  
 * The second form lets the caller specify a particular file.
 */
MFError MF_CALLCONV MFMediaID_Create(MFMediaID* mediaID);
MFError MF_CALLCONV MFMediaID_CreateUsingConfigFile(MFMediaID* mediaID, MFFilePath strPathToConfigFile);


/* 
 * When you are all done identifying files, call the Destroy function below to clean up the 
 * mememory allocated for this object.  Notice that you will be sending the address of MFMediaID 
 * pointer.  This is so that the Destroy function can set your local variable to NULL after it 
 * is destroyed.
 */
MFError MF_CALLCONV MFMediaID_Destroy(MFMediaID* mediaID);

/* 
 * This is the main call to identify a file. A variety of errors can occur that can prevent 
 * an identification. Error codes are listed in the file mfErrors_oem.h.
 * If no error is returned (MF_SUCCESS), then the response structure will have more information 
 * about the file. However, sometimes, a server error, or other problem will occur which will not 
 * be returned as an error.  You must call MFMediaIDResponseGetIDStatus() to find out the 
 * dispensation of the file (as an MFResponseStatus enum - defined above).
 * Call MFMediaIDResponseGetAsString() to get the server response in an ascii string format.  
 * If the file was FOUND in our database, then the string will contain an xml object representing 
 * the metadata associated with that file.  It is up to the user to parse the xml object to extract 
 * the specific fields that he/she is interested in.  
 * You must supply the complete path to the filename in strMediaFile, and you must create a unique 
 * string that helps you uniquely identify the file that you are requesting identification of.  
 * The strAssetID will be associated with this request and will be returned in the XML metadata 
 * structure.
 * The MFMediaIDResponse will be created by this function, you will need to call 
 * MFMediaIDResponseDestroy() when you are done with the response data.
 */
MFError MF_CALLCONV MFMediaID_GenerateAndPostRequest(MFMediaID mediaID, MFFilePath strMediaFile, 
  MFString strAssetID, MFMediaIDResponse* response);

/*
 * Same as the call above but takes a buffer of samples instead of a path to a file.
 *
 * This sample-based API does not use FFMPEG.  If you use the no-FFMPEG library configuration
 * then you must use this variation of the API. Calling  MFMediaID_GenerateAndPostRequest()
 * will result in MF_CALLING_PROGRAM_ERROR (error return code = 4).
 */
MFError MF_CALLCONV MFMediaID_GenerateAndPostRequestFromSamples(MFMediaID mediaID, const void* samples, 
  int numFrames, float sampleRate, int numChannels, MFSampleFormat sampleFormat, MFConstString strAssetID, 
  MFMediaIDResponse* response);

/*
 * Some users need to handle the posting themselves. The following two calls are 
 * similar to the two calls above, but produce an MFMediaIDRequest object which can 
 * then be posted with the MFMediaID_PostRequest call.
 *
 * Note that you will need to call MFMediaIDRequest_Destory() when you are done 
 * calling MFMediaID_PostRequest().
 */
MFError MF_CALLCONV MFMediaID_GenerateRequest(MFMediaID mediaID, MFFilePath strMediaFile, 
  MFConstString strAssetID, MFMediaIDRequest* request);

/*
 * Same as the call above but takes a buffer of samples instead of a path to a file.
 *
 * This sample-based API does not use FFMPEG.  If you use the no-FFMPEG library configuration
 * then you must use this variation of the API. Calling  MFMediaID_GenerateAndPostRequest()
 * will result in MF_CALLING_PROGRAM_ERROR (error return code = 4).
 */
MFError MF_CALLCONV MFMediaID_GenerateRequestFromSamples(MFMediaID mediaID, const void* samples, 
  int numFrames, float sampleRate, int numChannels, MFSampleFormat sampleFormat, 
  MFConstString strAssetID, MFMediaIDRequest* request);

/*
 * Used to perform the post operation. Returns an MFMediaIDResponse object.
 *
 * Note that it's the caller's responsibility to deallocate the request and the 
 * response by calling the MFMediaIDRequest_Destroy() and MF_MediaIDResponse_Destroy() 
 * when done with them.
 */
MFError MF_CALLCONV MFMediaID_PostRequest(MFMediaID mediaID, MFMediaIDRequest request, 
  MFMediaIDResponse* response);

/*
 * Destroys and deallocates an MFMediaID_PostRequest object
 */
MFError MF_CALLCONV MFMediaIDRequest_Destroy(MFMediaIDRequest* request);


/*
 * The following functions are used to get information out of the MFMediaIDResponse object returned in the
 * call to MFMediaIDRequestID().  
 */

/*
 * Call this function to get the length of the string that will be returned by MFMediaIDResponseGetAsString.
 * You will need to provide your own pre-allocated string to pass into that function, and it should be
 * at least as long as this length to fit all of the response 
 */
MFError MF_CALLCONV MFMediaIDResponse_GetStringLength(MFMediaIDResponse response, int* length);

/*
 * Returns the response as a string to your pre-allocated string.  If the string storage you provide is
 * not large enough an error code will be returned.  The string could be the XML metadata structure, if
 * the file has been FOUND in our database.  Or it could be other responses from the server, such as 
 * 404 error codes, or other error conditions....
 */
MFError MF_CALLCONV MFMediaIDResponse_GetAsString(MFMediaIDResponse response, MFString strResponse, int strLength);

/*
 * If you just want to find out if the file has been FOUND, NOT_FOUND, or the state is NOT_KNOWN,
 * call this function and examine the status value (MFResponseStatus) as an enum defined above.
 */
MFError MF_CALLCONV MFMediaIDResponse_GetIDStatus(MFMediaIDResponse response, MFResponseStatus* status);

/*
 * If you know what key you want to look at in the response, call this to get the value.  You must
 * pre alloc the strValue and set its maximum length in strValueLen
 */
MFError MF_CALLCONV MFMediaIDResponse_GetKeyValue(MFMediaIDResponse response, char* strKey, char* strValue, int strValueLen);

/*
 * Each response object is created by the library and returned to the user after each call
 * to MFMediaIDRequestID().  It is up to the user to call this destroy function when they are done
 * with the response data. 
 * Notice that you are sending the address of the MFMediaIDResponse pointer to the destroy function.
 * This allows the destroy function to set the value of the pointer to NULL.
 */
MFError MF_CALLCONV MFMediaIDResponse_Destroy(MFMediaIDResponse* response);

/*
 * Get the version of the library.
 * We recommend this function called and the string displayed so that it can be returned in
 * when issues are reported back to Audible Magic.
 * length should be at least MF_VERSION_STRING_LENGTH to return the full string.
 * If less, the string will be truncated.
 */
MFError MF_CALLCONV MFGetLibraryVersion(MFString strVersion, int strLen);

/*
 * Convert an error number to a human-readable string.
 * length should be at least MF_ERROR_STRING_LENGTH to return the full string.
 * If less, the string will be truncated.
 */
MFError MF_CALLCONV MFGetErrorDescription(MFError err, MFString strDescription, int strLen);

/*
 * These are helper functions for diagnosing timing issues
 * After a the call to MFMediaID_GenerateAndPostRequest returns
 * you can call these to find out where the time was spent.
 */
MFError MFMediaID_GetAnalysisTime(MFMediaID mediaID, double* dSecs);
MFError MFMediaID_GetRequestAndResponseTime(MFMediaID mediaID, double* dSecs);

#ifdef __cplusplus
}
#endif

#endif /* _mf_mediaid_api_h */
