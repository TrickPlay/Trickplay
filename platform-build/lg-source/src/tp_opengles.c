#include <stdlib.h>

#include "tp_common.h"
#include "tp_settings.h"
#include "tp_opengles.h"


static fbdev_window* _OpenGLES_CreateWindow(UINT16 x, UINT16 y, UINT16 width, UINT16 height, BOOLEAN bStretchToDisplay)
{
	fbdev_window* pWindow = (fbdev_window*)malloc(sizeof(fbdev_window));

	if (pWindow != NULL)
	{
		/* following code is available after fbdev_window structure is extended. */
#if 0
		if (bStretchToDisplay)
		{
			pWindow->x		= 0;
			pWindow->y		= 0;
		}
		else
		{
			pWindow->x		= x;
			pWindow->y		= y;
		}
		pWindow->width	= width;
		pWindow->height	= height;
		pWindow->bStretchToDisplay = bStretchToDisplay;
#endif
		pWindow->width	= width;
		pWindow->height	= height;
	}

	return pWindow;
}

static void _OpenGLES_DestroyWindow(fbdev_window* pWindow)
{
	if (pWindow != NULL)
		free(pWindow);
}

static fbdev_window* _gpWindow = NULL;

BOOLEAN TP_OpenGLES_Initialize(const UINT32* pAttrList)
{
	UINT16	x			= 0;
	UINT16	y			= 0;
	UINT16	width		= 1920;
	UINT16	height		= 1080;
	BOOLEAN	bStretch	= FALSE;

	BOOLEAN	bEnd = FALSE;

	if (_gpWindow != NULL)
		return TRUE;

	while (!bEnd)
	{
		UINT32 attrib	= *pAttrList++;
		UINT32 value	= *pAttrList++;

		switch (attrib)
		{
			case OPENGLES_WINDOW_ATTRIB_X:
				x = value;
				break;

			case OPENGLES_WINDOW_ATTRIB_Y:
				y = value;
				break;

			case OPENGLES_WINDOW_ATTRIB_WIDTH:
				width = value;
				break;

			case OPENGLES_WINDOW_ATTRIB_HEIGHT:
				height = value;
				break;

			case OPENGLES_WINDOW_ATTRIB_STRETCH:
				bStretch = value;
				break;

			case OPENGLES_WINDOW_ATTRIB_FORMAT:
				break;

			case OPENGLES_WINDOW_ATTRIB_NONE:
				bEnd = TRUE;
				break;
		}
	}

	_gpWindow = _OpenGLES_CreateWindow(x, y, width, height, bStretch);

	return (_gpWindow != NULL);
}

void TP_OpenGLES_Finalize(void)
{
	_OpenGLES_DestroyWindow(_gpWindow);
	_gpWindow = NULL;
}

EGLNativeWindowType TP_OpenGLES_GetEGLNativeWindow(void)
{
	if (_gpWindow == NULL)
		DBG_PRINT_TP("EGLNativeWindow is NULL. You must call TP_OpenGLES_Initialize() first.");

	return (EGLNativeWindowType)_gpWindow;
}

