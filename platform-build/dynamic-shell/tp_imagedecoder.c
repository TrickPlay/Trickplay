#include <stdlib.h>

#include <trickplay/image.h>

#include "tp_imagedecoder.h"

// typedef void (*TPImageFreePixels)(void *pixels)
static void _TP_ImageDecoder_FreePixels(void *pPixels)
{
	free(pPixels);
}

// typedef int (*TPImageDecoder)(void *data, unsinged long int size, TPImage *image, void *user)
int _TP_ImageDecoder_DecodeImage(void *pData, unsigned long int size, TPImage *pImage, void *pUser)
{
	if ((pData == NULL) || (size == 0) || (pImage == NULL)) {
		DBG_PRINT_TP("Invalid argument.");
		return TP_IMAGE_DECODE_FAILED;
	}

	// [TODO]
	pImage->pixels		= NULL;
	pImage->width		= 0;
	pImage->height		= 0;
	pImage->pitch		= 0;
	pImage->depth		= 0;
	pImage->bgr			= 0;
	pImage->free_pixels	= _TP_ImageDecoder_FreePixels;

	return TP_IMAGE_UNSUPPORTED_FORMAT;
}

BOOLEAN TP_ImageDecoder_Initialize(TPContext *pContext)
{
	DBG_PRINT_TP();

	if (pContext == NULL) {
		DBG_PRINT_TP("pContext is NULL.");
		return FALSE;
	}

#ifndef USE_HW_IMAGEDECODER
	DBG_PRINT_TP("HW image decoder is not ready. Use internal SW image decoder.");
	return TRUE;
#endif

	tp_context_set_image_decoder(pContext, _TP_ImageDecoder_DecodeImage, NULL);

	return TRUE;
}
