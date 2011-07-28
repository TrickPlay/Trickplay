#include <stdlib.h>
#include <EGL/egl.h>
#include <EGL/fbdev_window.h>
#include "tp_opengles.h"

typedef unsigned short UINT16;
#define BOOLEAN int
#define TRUE 1
#define FALSE 0


static fbdev_window* _gpWindow = NULL;

#define SCREEN_WIDTH 1280
#define SCREEN_HEIGHT 720
/*
#define SCREEN_WIDTH 1920
#define SCREEN_HEIGHT 1080
*/

static fbdev_window* _OpenGLES_CreateWindow(UINT16 x, UINT16 y, UINT16 width, UINT16 height, BOOLEAN bStretchToDisplay)
{
    fbdev_window* pWindow = (fbdev_window*)malloc(sizeof(fbdev_window));

    if (pWindow != NULL)
    {
        /* following code is available after fbdev_window structure is extended. */
#if 0
        if (bStretchToDisplay)
        {
            pWindow->x      = 0;
            pWindow->y      = 0;
        }
        else
        {
            pWindow->x      = x;
            pWindow->y      = y;
        }
        pWindow->width  = width;
        pWindow->height = height;
        pWindow->bStretchToDisplay = bStretchToDisplay;
#endif
        pWindow->width  = width;
        pWindow->height = height;
    }

    return pWindow;
}

static void _OpenGLES_DestroyWindow(fbdev_window* pWindow)
{
    if (pWindow != NULL)
        free(pWindow);
}



int tp_pre_egl_initialize( EGLNativeDisplayType * display , EGLNativeWindowType * window )
{
    UINT16  x           = 0;
    UINT16  y           = 0;
    UINT16  width       = SCREEN_WIDTH;
    UINT16  height      = SCREEN_HEIGHT;
    BOOLEAN bStretch    = FALSE;

    *display = (EGLNativeDisplayType)2;

    if (_gpWindow != NULL)
    {
        *window = (EGLNativeWindowType)_gpWindow;
        return 0;
    }


    _gpWindow = _OpenGLES_CreateWindow(x, y, width, height, bStretch);

    *window = (EGLNativeWindowType)_gpWindow;
    return (_gpWindow == NULL);
}

void tp_post_egl_terminate( void )
{
    _OpenGLES_DestroyWindow(_gpWindow);
    _gpWindow = NULL;
}
