#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <glob.h>
#include <limits.h>

#include "trickplay/trickplay.h"
#include "trickplay/resource.h"
#include "tp_common.h"
#include "tp_util.h"
#include "tp_drm.h"

//#include <addon_hoa.h>
#include <appfrwk_openapi.h>
#include <drm_openapi.h>

#include <NCG_Core.h>
#include <NCG_Error.h>

#define BUFFER_SIZE		(1024 * 4)		// 4 KB


// TODO sanggi0.lee - remove
#if 0
static BOOLEAN _DRM_DecryptFileDRM(
		const UINT32 appID,
		const char* szSrcPath, const char* szDstPath)
{
	if ((szSrcPath == NULL) || (szDstPath == NULL))
	{
		DBG_PRINT_TP("one of the path arguments is NULL.");
		return FALSE;
	}

	int nResult;
	NCG_File_Handle	hNCGFile = NULL;
	int dstFileDesc = -1;
	unsigned char bszKey[32] = { 0, };

	/* 1. Open DRM-encrypted file to read */
	nResult = NCG_OpenAndVerifyFile(szSrcPath, TRUE, TRUE, O_RDONLY, 0, &hNCGFile);
	if (Failed(nResult) || (hNCGFile == NULL))
	{
		DBG_PRINT_TP("NCG_OpenAndVerifyFile() failed. Could not open encrypted file.");
		goto clear_and_return;
	}

	/* 2. Get CEK from App ID and source file path. */
	// TODO sanggi0.lee - new function
	/*
	if (HOA_SECCHK_GetCEK(appID, (char*)szSrcPath, bszKey) != HOA_UC_OK)
	{
		DBG_PRINT_TP("HOA_SECCHK_GetCEK() failed.");
		goto clear_and_return;
	}
	*/

	/* 3. Set CEK to the file handle. */
	NCG_SetCEKForce(hNCGFile, bszKey);

	/* 4. Open a file to write decrypted contents. */
	dstFileDesc = open(szDstPath, O_WRONLY | O_CREAT | O_EXCL, S_IREAD);
	if (dstFileDesc == -1)
	{
		DBG_PRINT_TP("open() failed. Could not create decrypted file.");
		goto clear_and_return;
	}

	unsigned char buffer[BUFFER_SIZE];
	unsigned long read;

	/* 5. Do decryption */
	do
	{
		nResult = NCG_Read(hNCGFile, sizeof(buffer), buffer, &read);
		if (Succeed(nResult))
			write(dstFileDesc, buffer, read);
	} while (Succeed(nResult) && (read > 0));

clear_and_return:
	if (dstFileDesc != -1)
		close(dstFileDesc);

	if (hNCGFile != NULL)
		NCG_ClearFileHandle(&hNCGFile);

	return Succeed(nResult);
}

BOOLEAN TP_DRM_DecryptAppToPath(
		const UINT32 appID,
		const char* szAppDir, const char* szTargetDir)
{
	DBG_PRINT_TP(NULL);

	if ((szAppDir == NULL) || (szTargetDir == NULL))
	{
		DBG_PRINT_TP("one of the dir arguments is NULL.");
		return FALSE;
	}

	if (mkdir(szTargetDir, 755) != 0)
	{
		DBG_PRINT_TP("mkdir() failed. Could not create target directory.");
		return FALSE;
	}

	BOOLEAN	res = FALSE;
	int		globRes;
	char	globPattern[PATH_MAX] = { '\0', };
	glob_t	pathList;

	sprintf(globPattern, "%s/*", szAppDir);

	globRes = glob(globPattern, GLOB_NOSORT, NULL, &pathList);
	if (globRes != 0)
	{
		DBG_PRINT_TP("glob() failed.");
		return res;
	}

	const char* szSrcPath;
	char szDstPath[PATH_MAX];
	size_t i;

	for (i = 0; i < pathList.gl_pathc; ++i)
	{
		szSrcPath = pathList.gl_pathv[i];
		if (szSrcPath == NULL)
		{
			DBG_PRINT_TP("glob() result path is NULL.");
			continue;
		}

		char *szTmp = strdup(szSrcPath);
		sprintf(szDstPath, "%s/%s", szTargetDir, basename(szTmp));
		free(szTmp);

		/* case of directory : make subdirectory and the call this function recursively. */
		if (TP_Util_IsDirectory(szSrcPath))
			res = TP_DRM_DecryptAppToPath(appID, szSrcPath, szDstPath);
		/* case of DRM encrypted file :  do decryption. */
		else if (NCG_IsNCGFile(szSrcPath))
			res = _DRM_DecryptFileDRM(appID, szSrcPath, szDstPath);
		/* case of non-encrypted file : make a symbolic link to the source file. */
		else
			res = (symlink(szSrcPath, szDstPath) == 0);

		if (!res)
			break;
	}

	globfree(&pathList);
	return res;
}
#endif

static unsigned long int _TP_DRM_resource_reader(
	void * buffer,
	unsigned long int bytes,
	void * user_data )
{
	FILE * file = ( FILE * ) user_data;

	size_t result = fread( buffer , 1 , bytes , file );

	if ( result < bytes )
	{
		fclose( file );
	}

	DBG_PRINT_TP("bytes = %d, result = %d", bytes, result);

	return result;
}

static unsigned long int _TP_DRM_resource_decrypt_reader(
	void * buffer,
	unsigned long int bytes,
	void * user_data )
{
	int hFile = ( int ) user_data;

	size_t result = HOA_NCG_POSIX_read( hFile , buffer , bytes );

	if ( result < bytes )
	{
		HOA_NCG_POSIX_close( hFile );
	}

	DBG_PRINT_TP("bytes = %d, result = %d", bytes, result);

	return result;
}

int TP_DRM_resource_loader(
	TPContext * context ,
	unsigned int resource_type,
	const char * filename,
	TPResourceReader * reader,
	void * user_data )
{
	int result = 0;

	result = HOA_NCG_POSIX_IsEncrypted(filename);

	DBG_PRINT_TP("filename: %s, result=%d", filename, result);

	if ( result != 1)
	{
		DBG_PRINT_TP("===== not encrypted =====");

		FILE * file = fopen( filename , "rb" );

		if ( 0 == file )
		{
			return 1;
		}

		reader->read = _TP_DRM_resource_reader;
		reader->user_data = file;
	}
	else
	{
		DBG_PRINT_TP("+++++ encrypted +++++");

		int hFile = HOA_NCG_POSIX_open( filename , O_RDONLY , 0);

		if ( hFile < 0 )
		{
			return 1;
		}

		reader->read = _TP_DRM_resource_decrypt_reader;
		reader->user_data = ( void * ) hFile;
	}

	return 0;
}

