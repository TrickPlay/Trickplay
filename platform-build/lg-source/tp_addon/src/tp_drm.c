#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <glob.h>
#include <limits.h>

#include <NCG/NCG_Core.h>
#include <NCG/NCG_Error.h>

#include "tp_common.h"
#include "tp_drm.h"

#define BUFFER_SIZE		(1024 * 4)		// 4 KB


static BOOLEAN _TP_IsDirectory(const char *path)
{
	if (path == NULL) {
		DBG_PRINT_TP("path argument is NULL.");
		return FALSE;
	}

	struct stat statbuf;

	if (stat(path, &statbuf) != 0) {
		DBG_PRINT_TP("stat() failed. (%s)", path);
		return FALSE;
	}

	return S_ISDIR(statbuf.st_mode);
}

static BOOLEAN _TP_DecryptFileDRM(const UINT32 appID, const char *srcFilePath, const char *dstFilePath)
{
	if ((srcFilePath == NULL) || (dstFilePath == NULL)) {
		DBG_PRINT_TP("one of the path arguments is NULL.");
		return FALSE;
	}

	int nResult;
	NCG_File_Handle	hNCGFile = NULL;
	int dstFileDesc = -1;
	unsigned char bszKey[32] = { 0, };

	// 1. Open DRM-encrypted file to read
	nResult = NCG_OpenAndVerifyFile(srcFilePath, TRUE, TRUE, O_RDONLY, 0, &hNCGFile);
	if (Failed(nResult) || (hNCGFile == NULL)) {
		DBG_PRINT_TP("NCG_OpenAndVerifyFile() failed. Could not open encrypted file.");
		goto clear_and_return;
	}

	// 2. Get CEK from App ID and source file path.
	if (HOA_SECCHK_GetCEK(appID, (char *)srcFilePath, bszKey) != HOA_UC_OK) {
		DBG_PRINT_TP("HOA_SECCHK_GetCEK() failed.");
		goto clear_and_return;
	}

	// 3. Set CEK to the file handle.
	NCG_SetCEKForce(hNCGFile, bszKey);

	// 4. Open a file to write decrypted contents.
	dstFileDesc = open(dstFilePath, O_WRONLY | O_CREAT | O_EXCL, S_IREAD);
	if (dstFileDesc == -1) {
		DBG_PRINT_TP("open() failed. Could not create decrypted file.");
		goto clear_and_return;
	}

	unsigned char buffer[BUFFER_SIZE];
	unsigned long read;

	// 5. Do decryption
	do {
		nResult = NCG_Read(hNCGFile, sizeof(buffer), buffer, &read);
		if (Succeed(nResult)) {
			write(dstFileDesc, buffer, read);
		}
	} while (Succeed(nResult) && (read > 0));

clear_and_return:
	if (dstFileDesc != -1) {
		close(dstFileDesc);
	}
	if (hNCGFile != NULL) {
		NCG_ClearFileHandle(&hNCGFile);
	}

	return Succeed(nResult);
}

BOOLEAN TP_DRM_DecryptAppToPath(const UINT32 appID, const char *appDir, const char *targetDir)
{
	DBG_PRINT_TP();

	if ((appDir == NULL) || (targetDir == NULL)) {
		DBG_PRINT_TP("one of the dir arguments is NULL.");
		return FALSE;
	}

	if (mkdir(targetDir, 755) != 0) {
		DBG_PRINT_TP("mkdir() failed. Could not create target directory.");
		return FALSE;
	}

	BOOLEAN	res = FALSE;
	int		globRes;
	char	globPattern[PATH_MAX] = { '\0', };
	glob_t	pathList;

	sprintf(globPattern, "%s/*", appDir);

	globRes = glob(globPattern, GLOB_NOSORT, NULL, &pathList);
	if (globRes != 0) {
		DBG_PRINT_TP("glob() failed.");
		return res;
	}

	const char *srcPath;
	char dstPath[PATH_MAX];
	size_t i;

	for (i = 0; i < pathList.gl_pathc; ++i) {
		srcPath = pathList.gl_pathv[i];
		if (srcPath == NULL) {
			DBG_PRINT_TP("glob() result path is NULL.");
			continue;
		}

		char *tmp = strdup(srcPath);
		sprintf(dstPath, "%s/%s", targetDir, basename(tmp));
		free(tmp);

		// case of directory : make subdirectory and the call this function recursively.
		if (_TP_IsDirectory(srcPath)) {
			res = TP_DRM_DecryptAppToPath(appID, srcPath, dstPath);
		}
		// case of DRM encrypted file :  do decryption.
		else if (NCG_IsNCGFile(srcPath)) {
			res = _TP_DecryptFileDRM(appID, srcPath, dstPath);
		}
		// case of non-encrypted file : make a symbolic link to the source file.
		else {
			res = (symlink(srcPath, dstPath) == 0);
		}

		if (!res) {
			break;
		}
	}

	globfree(&pathList);
	return res;
}

