#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <errno.h>

#include <png.h>
#ifdef LIBJPEG_MEMSRC_SUPPORT
#include <jpeglib.h>
#endif
#include <gif_lib.h>

#include <rpc4dtv/ddi_gpu.h>

#include <trickplay/image.h>

#include "tp_common.h"
#include "tp_util.h"
#include "tp_imagedecoder.h"

#ifndef LIBJPEG_MEMSRC_SUPPORT
#define JPEG_GET_UINT16(ptr)	(((ptr)[0] << 8) | (ptr)[1])
#endif


static UINT32 _gVideoVirtAddrBase = 0;
static GPU_SURFACE_INFO_T _gSurface;

static BOOLEAN _ImageDecoder_GetVideoVirtualAddrBase(UINT32 *pVideoVirtAddrBase)
{
	if (pVideoVirtAddrBase == NULL)
		return FALSE;

	const char szKeyVideoBase[]	= "video-phys=";
	const char szKeyVideoSize[]	= "video-length=";
	UINT32 videoPhysAddrBase	= 0;
	UINT32 videoMemorySize		= 0;
	char buffer[512];

	// 1. Get video memory info (from 'directfbrc' file)
	FILE *fp = fopen("/usr/local/etc/directfbrc", "r");
	if (fp == NULL)
		return FALSE;

	while (fgets(buffer, NELEMENTS(buffer), fp) != NULL) {
		if (strncmp(buffer, szKeyVideoBase, strlen(szKeyVideoBase)) == 0)
			videoPhysAddrBase	= strtoul(buffer + strlen(szKeyVideoBase), NULL, 16);
		else if (strncmp(buffer, szKeyVideoSize, strlen(szKeyVideoSize)) == 0)
			videoMemorySize		= strtoul(buffer + strlen(szKeyVideoSize), NULL, 10);
	}
	fclose(fp);

	if (videoMemorySize == 0)
		return FALSE;

	DBG_PRINT_TP("Video memory info: physical addr base=%p, size=%lu MB", (void*)videoPhysAddrBase, (videoMemorySize / 1024 / 1024));

	// 2. Get video memory virtual address using mmap()
	int fdmem = open("/dev/mem", O_RDONLY | O_SYNC);
	if (fdmem == -1)
		return FALSE;

	void *pAddr = mmap(0, videoMemorySize, PROT_READ, MAP_SHARED, fdmem, videoPhysAddrBase);
	close(fdmem);

	if (pAddr == MAP_FAILED) {
		DBG_PRINT_TP("mmap() failed. (errno:%d)", errno);
		return FALSE;
	}

	*pVideoVirtAddrBase = (UINT32)pAddr;
	return TRUE;
}

static void _ImageDecoder_PNG_Read(png_structp pstruct, png_bytep pointer, png_size_t size)
{
	// [TODO] size check
	memcpy(pointer, png_get_io_ptr(pstruct), size);
	pstruct->io_ptr += size;
}

typedef enum {
	Unknown,
	SOI,
	SOF0,
	SOF2,
	DHT,
	DQT,
	DRI,
	SOS,
	RSTn,
	APPn,
	COM,
	EOI
} JPEG_MARKER_T;

static JPEG_MARKER_T _ImageDecoder_JPEG_ReadMarker(UINT8 **ppData)
{
	if ((ppData == NULL) || (*ppData == NULL))
		return Unknown;

	JPEG_MARKER_T marker = Unknown;
	UINT8 markerByte[2];
	UINT8 *p = *ppData;

	markerByte[0] = *p++;
	markerByte[1] = *p++;

	if (markerByte[0] == 0xFF) {
		switch (markerByte[1]) {
			case 0xD8:
				marker = SOI;
				break;
			case 0xC0:
				marker = SOF0;
				break;
			case 0xC2:
				marker = SOF2;
				break;
			case 0xC4:
				marker = DHT;
				break;
			case 0xDB:
				marker = DQT;
				break;
			case 0xDD:
				marker = DRI;
				break;
			case 0xDA:
				marker = SOS;
				break;
			case 0xFE:
				marker = COM;
				break;
			case 0xD9:
				marker = EOI;
				break;
			default:
				if ((markerByte[1] >= 0xD0) && (markerByte[1] <= 0xD7))
					marker = RSTn;
				else if ((markerByte[1] & 0xF0) == 0xE0)
					marker = APPn;
				break;
		}
	}

	*ppData = p;
	return marker;
}

#ifndef LIBJPEG_MEMSRC_SUPPORT
static BOOLEAN _ImageDecoder_JPEG_JumpToNextMarker(JPEG_MARKER_T marker, UINT8 **ppData)
{
	if ((ppData == NULL) || (*ppData == NULL))
		return FALSE;
	if (marker == EOI)
		return FALSE;

	UINT16 payload;

	switch (marker) {
		case SOF0:
		case SOF2:
		case DHT:
		case DQT:
		case SOS:
		case APPn:
		case COM:
			payload = JPEG_GET_UINT16(*ppData);
			break;
		case DRI:
			payload = 2;
			break;
		default:
			payload = 0;
			break;
	}

	*ppData += payload;
	return TRUE;
}
#endif // !LIBJPEG_MEMSRC_SUPPORT

static int _ImageDecoder_GIF_Read(GifFileType *pGif, GifByteType *pBuf, int size)
{
	// [TODO] size check
	memcpy(pBuf, pGif->UserData, size);
	pGif->UserData += size;

	return size;
}

static BOOLEAN _ImageDecoder_IsPNG(void *pData, unsigned long int size)
{
	if (pData == NULL)
		return FALSE;

	if (png_sig_cmp(pData, 0, size) == 0)
		return TRUE;

	return FALSE;
}

static BOOLEAN _ImageDecoder_IsJPEG(void *pData, unsigned long int size)
{
	// JPEG files do not have a formal header structure.
	// So we just predicate it by starting JPEG SOI(FFD8 hex)
	// and following APP0(FFE0 hex) marker.

	if ((pData == NULL) || (size < 4))
		return FALSE;

	UINT8 *p = (UINT8 *)pData;

	if ((_ImageDecoder_JPEG_ReadMarker(&p) == SOI)
			&& (_ImageDecoder_JPEG_ReadMarker(&p) == APPn))
		return TRUE;

	return FALSE;
}

static BOOLEAN _ImageDecoder_IsGIF(void *pData, unsigned long int size)
{
	if ((pData == NULL) || (size < 6))
		return FALSE;

	// No need to support GIF87 format
	static const UINT8 signatureGIF89[6] = { 'G', 'I', 'F', '8', '9', 'a' };

	if (memcmp(pData, signatureGIF89, sizeof(signatureGIF89)) == 0)
		return TRUE;

	return FALSE;
}

static GPU_IMAGE_FORMAT_T _ImageDecoder_GetImageFormat(void *pData, unsigned long int size)
{
	if (_ImageDecoder_IsPNG(pData, size))
		return GPU_IMAGE_FORMAT_PNG;
	if (_ImageDecoder_IsJPEG(pData, size))
		return GPU_IMAGE_FORMAT_JPEG;
	if (_ImageDecoder_IsGIF(pData, size))
		return GPU_IMAGE_FORMAT_GIF;

	return GPU_IMAGE_FORMAT_MAX;
}

static BOOLEAN _ImageDecoder_GetPNGInfo(void *pData, unsigned long int size, GPU_IMAGE_INFO_T *pImageInfo)
{
	if ((pData == NULL) || (size == 0) || (pImageInfo == NULL))
		return FALSE;

	png_structp	png_ptr;
	png_infop	info_ptr;

	png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	if (png_ptr == NULL)
		return FALSE;

	info_ptr = png_create_info_struct(png_ptr);
	if (info_ptr == NULL) {
		png_destroy_read_struct(&png_ptr, NULL, NULL);
		return FALSE;
	}

	png_set_read_fn(png_ptr, pData, _ImageDecoder_PNG_Read);
	png_read_info(png_ptr, info_ptr);

	pImageInfo->imageFormat	= GPU_IMAGE_FORMAT_PNG;
	pImageInfo->rect.x		= 0;
	pImageInfo->rect.y		= 0;
	pImageInfo->rect.w		= png_get_image_width(png_ptr, info_ptr);
	pImageInfo->rect.h		= png_get_image_height(png_ptr, info_ptr);
	pImageInfo->imageLength	= size;
	pImageInfo->bImageFromBuffer = TRUE;
	pImageInfo->imagePtr	= pData;

	png_destroy_read_struct(&png_ptr, &info_ptr, NULL);

	return TRUE;
}

static BOOLEAN _ImageDecoder_GetJPEGInfo(void *pData, unsigned long int size, GPU_IMAGE_INFO_T *pImageInfo)
{
#ifdef LIBJPEG_MEMSRC_SUPPORT
	struct jpeg_decompress_struct cinfo;
	struct jpeg_error_mgr jerr;

	cinfo.err = jpeg_std_error(&jerr);
	jpeg_create_decompress(&cinfo);

	jpeg_mem_src(&cinfo, pData, size);

	if (jpeg_read_header(&cinfo, TRUE) != JPEG_HEADER_OK)
		return FALSE;

	pImageInfo->imageFormat	= GPU_IMAGE_FORMAT_JPEG;
	pImageInfo->rect.x		= 0;
	pImageInfo->rect.y		= 0;
	pImageInfo->rect.w		= cinfo.image_width;
	pImageInfo->rect.h		= cinfo.image_height;
	pImageInfo->imageLength	= size;
	pImageInfo->bImageFromBuffer = TRUE;
	pImageInfo->imagePtr	= pData;

	jpeg_destroy_decompress(&cinfo);

	return TRUE;
#else
	if ((pData == NULL) || (size < 2) || (pImageInfo == NULL))
		return FALSE;

	// Find SOF0 or SOF2 marker
	UINT8 *p = (UINT8 *)pData;
	JPEG_MARKER_T marker;

	while (TRUE) {
		marker = _ImageDecoder_JPEG_ReadMarker(&p);
		if (marker == Unknown)
			return FALSE;

		if ((marker == SOF0) || (marker == SOF2))
			break;

		if (!_ImageDecoder_JPEG_JumpToNextMarker(marker, &p))
			return FALSE;
		if (p - (UINT8 *)pData > size)
			return FALSE;
	}

	pImageInfo->imageFormat	= GPU_IMAGE_FORMAT_JPEG;
	pImageInfo->rect.x		= 0;
	pImageInfo->rect.y		= 0;
	pImageInfo->rect.w		= JPEG_GET_UINT16(p + 3);
	pImageInfo->rect.h		= JPEG_GET_UINT16(p + 5);
	pImageInfo->imageLength	= size;
	pImageInfo->bImageFromBuffer = TRUE;
	pImageInfo->imagePtr	= pData;

	return TRUE;
#endif
}

static BOOLEAN _ImageDecoder_GetGIFInfo(void *pData, unsigned long int size, GPU_IMAGE_INFO_T *pImageInfo)
{
	if ((pData == NULL) || (size == 0) || (pImageInfo == NULL))
		return FALSE;

	GifFileType *pGif = DGifOpen(pData, _ImageDecoder_GIF_Read);

	if (pGif == NULL)
		return FALSE;

	pImageInfo->imageFormat	= GPU_IMAGE_FORMAT_JPEG;
	pImageInfo->rect.x		= 0;
	pImageInfo->rect.y		= 0;
	pImageInfo->rect.w		= pGif->SWidth;
	pImageInfo->rect.h		= pGif->SHeight;
	pImageInfo->imageLength	= size;
	pImageInfo->bImageFromBuffer = TRUE;
	pImageInfo->imagePtr	= pData;

	DGifCloseFile(pGif);

	return TRUE;
}

static void _ImageDecoder_DestroySurface(void* pData)
{
	// This is OK because TrickPlay decodes image one by one.
	DDI_GPU_DeallocSurface(_gSurface);
}

static int _ImageDecoder_DecodeImage(void *pData, unsigned long int size, TPImage *pImage, void *pUser)
{
	if ((pData == NULL) || (size == 0)) {
		DBG_PRINT_TP("Invalid argument.");
		return TP_IMAGE_DECODE_FAILED;
	}

	BOOLEAN res;
	GPU_IMAGE_FORMAT_T	imageFormat = _ImageDecoder_GetImageFormat(pData, size);
	GPU_IMAGE_INFO_T	imageInfo;

	// When pImage is NULL, just returns whether Nexus can decode this image.
	if (pImage == NULL)
		return (imageFormat == GPU_IMAGE_FORMAT_MAX) ? TP_IMAGE_UNSUPPORTED_FORMAT : TP_IMAGE_SUPPORTED_FORMAT;

	if (size > 512 * 1024)	// RPC_SMEM_SIZE is 512 KByte.
		return TP_IMAGE_UNSUPPORTED_FORMAT;

	switch (imageFormat) {
		case GPU_IMAGE_FORMAT_PNG:
			res = _ImageDecoder_GetPNGInfo(pData, size, &imageInfo);
			break;
		case GPU_IMAGE_FORMAT_JPEG:
			res = _ImageDecoder_GetJPEGInfo(pData, size, &imageInfo);
			break;
		case GPU_IMAGE_FORMAT_GIF:
			res = _ImageDecoder_GetGIFInfo(pData, size, &imageInfo);
			break;
		default:
			res = FALSE;
			break;
	}
	if (!res) {
		DBG_PRINT_TP("Getting image information failed.");
		return TP_IMAGE_DECODE_FAILED;
	}

	if (imageInfo.rect.w * imageInfo.rect.h > 1280 * 720)
		return TP_IMAGE_UNSUPPORTED_FORMAT;

#ifdef _TP_DEBUG
	TP_Util_StartTimer();
#endif

	// [TODO] NEXUS_PixelFormat_eA8_eB8_G8_R8 actually generates RGBA format pixels. (reverse byte-order)
	// I should figure this out with Broadcom.
	if (DDI_GPU_AllocSurface(imageInfo.rect.w, imageInfo.rect.h, GPU_PIXEL_FORMAT_ABGR, &_gSurface) != OK) {
		DBG_PRINT_TP("DDI_GPU_AllocSurface() failed.");
		return TP_IMAGE_DECODE_FAILED;
	}

	if (DDI_GPU_DecodeImage(imageInfo, _gSurface, GPU_DECODEIMAGE_NOFX) != OK) {
		DBG_PRINT_TP("DDI_GPU_DecodeImage() failed.");
		DDI_GPU_DeallocSurface(_gSurface);
		return TP_IMAGE_UNSUPPORTED_FORMAT;
	}

	pImage->pixels		= (void *)(_gVideoVirtAddrBase + _gSurface.offset);
	pImage->width		= _gSurface.width;
	pImage->height		= _gSurface.height;
	pImage->pitch		= _gSurface.pitch;
	pImage->depth		= _gSurface.bpp;
	pImage->bgr			= FALSE;
	pImage->free_pixels	= _ImageDecoder_DestroySurface;

#ifdef _TP_DEBUG
	TP_Util_EndTimer();
	DBG_PRINT_TP("%.3f sec to decode image %dx%d", TP_Util_GetElapsedTime(), imageInfo.rect.w, imageInfo.rect.h);
#endif

	return TP_IMAGE_DECODE_OK;
}

BOOLEAN TP_ImageDecoder_Initialize(TPContext *pContext)
{
	DBG_PRINT_TP();

#ifndef USE_HW_IMAGEDECODER
	DBG_PRINT_TP("HW image decoder is not ready. Use internal SW image decoder.");
	return TRUE;
#endif

	if (pContext == NULL) {
		DBG_PRINT_TP("pContext is NULL.");
		return FALSE;
	}

	if (RPC_OpenDDI_GPU(0) != OK) {
		DBG_PRINT_TP("RPC_OpenDDI_GPU() failed.");
		return FALSE;
	}

	if (!_ImageDecoder_GetVideoVirtualAddrBase(&_gVideoVirtAddrBase))
		return FALSE;

	tp_context_set_image_decoder(pContext, _ImageDecoder_DecodeImage, NULL);

	return TRUE;
}

void TP_ImageDecoder_Finalize(TPContext *pContext)
{
	RPC_CloseDDI_GPU();
}

