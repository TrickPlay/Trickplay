#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <glob.h>
#include <limits.h>

#include "tp_common.h"
#include "tp_util.h"
#include "tp_drm.h"

#include <addon_hoa.h>

#include <NCG/NCG_Core.h>
#include <NCG/NCG_Error.h>

#define BUFFER_SIZE		(1024 * 4)		// 4 KB


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
	if (HOA_SECCHK_GetCEK(appID, (char*)szSrcPath, bszKey) != HOA_UC_OK)
	{
		DBG_PRINT_TP("HOA_SECCHK_GetCEK() failed.");
		goto clear_and_return;
	}

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

