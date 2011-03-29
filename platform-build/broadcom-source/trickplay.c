/******************************************************************************
 *    (c)2008-2010 Broadcom Corporation
 *
 * This program is the proprietary software of Broadcom Corporation and/or its licensors,
 * and may only be used, duplicated, modified or distributed pursuant to the terms and
 * conditions of a separate, written license agreement executed between you and Broadcom
 * (an "Authorized License").  Except as set forth in an Authorized License, Broadcom grants
 * no license (express or implied), right to use, or waiver of any kind with respect to the
 * Software, and Broadcom expressly reserves all rights in and to the Software and all
 * intellectual property rights therein.  IF YOU HAVE NO AUTHORIZED LICENSE, THEN YOU
 * HAVE NO RIGHT TO USE THIS SOFTWARE IN ANY WAY, AND SHOULD IMMEDIATELY
 * NOTIFY BROADCOM AND DISCONTINUE ALL USE OF THE SOFTWARE.
 *
 * Except as expressly set forth in the Authorized License,
 *
 * 1.     This program, including its structure, sequence and organization, constitutes the valuable trade
 * secrets of Broadcom, and you shall use all reasonable efforts to protect the confidentiality thereof,
 * and to use this information only in connection with your use of Broadcom integrated circuit products.
 *
 * 2.     TO THE MAXIMUM EXTENT PERMITTED BY LAW, THE SOFTWARE IS PROVIDED "AS IS"
 * AND WITH ALL FAULTS AND BROADCOM MAKES NO PROMISES, REPRESENTATIONS OR
 * WARRANTIES, EITHER EXPRESS, IMPLIED, STATUTORY, OR OTHERWISE, WITH RESPECT TO
 * THE SOFTWARE.  BROADCOM SPECIFICALLY DISCLAIMS ANY AND ALL IMPLIED WARRANTIES
 * OF TITLE, MERCHANTABILITY, NONINFRINGEMENT, FITNESS FOR A PARTICULAR PURPOSE,
 * LACK OF VIRUSES, ACCURACY OR COMPLETENESS, QUIET ENJOYMENT, QUIET POSSESSION
 * OR CORRESPONDENCE TO DESCRIPTION. YOU ASSUME THE ENTIRE RISK ARISING OUT OF
 * USE OR PERFORMANCE OF THE SOFTWARE.
 *
 * 3.     TO THE MAXIMUM EXTENT PERMITTED BY LAW, IN NO EVENT SHALL BROADCOM OR ITS
 * LICENSORS BE LIABLE FOR (i) CONSEQUENTIAL, INCIDENTAL, SPECIAL, INDIRECT, OR
 * EXEMPLARY DAMAGES WHATSOEVER ARISING OUT OF OR IN ANY WAY RELATING TO YOUR
 * USE OF OR INABILITY TO USE THE SOFTWARE EVEN IF BROADCOM HAS BEEN ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGES; OR (ii) ANY AMOUNT IN EXCESS OF THE AMOUNT
 * ACTUALLY PAID FOR THE SOFTWARE ITSELF OR U.S. $1, WHICHEVER IS GREATER. THESE
 * LIMITATIONS SHALL APPLY NOTWITHSTANDING ANY FAILURE OF ESSENTIAL PURPOSE OF
 * ANY LIMITED REMEDY.
 *
 * $brcm_Workfile: cube.c $
 * $brcm_Revision: hauxwell_35230_v3d/8 $
 * $brcm_Date: 11/3/10 3:42p $
 *
 * Module Description:
 *
 * Revision History:
 *
 * $brcm_Log: /rockford/applications/opengles/cube/cube.c $
 * 
 * hauxwell_35230_v3d/8   11/3/10 3:42p hauxwell
 * add 7422 support
 * 
 * hauxwell_35230_v3d/7   10/26/10 4:58p hills
 * Changed vertical filter mode to bilinear.
 * 
 * hauxwell_35230_v3d/6   10/19/10 2:44p hauxwell
 * update to use BRCM_RegisterDisplay() API
 * 
 * hauxwell_35230_v3d/5   10/12/10 1:22p hauxwell
 * update so frame divider doesn't half the max framerate
 * 
 * hauxwell_35230_v3d/4   10/8/10 12:01p hauxwell
 * add 60Hz
 * 
 * hauxwell_35230_v3d/3   9/7/10 12:21p hills
 * Enable back face culling.  Added arguments for display size, stretch,
 * multisample, colour depth, preserved swap and frame count
 * 
 * hauxwell_35230_v3d/2   8/18/10 3:18p gsweet
 * Fix for new window type
 * 
 * hauxwell_35230_v3d/1   7/19/10 6:02p hauxwell
 * new example
 *
 *****************************************************************************/

#include <malloc.h>
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <EGL/egl.h>
#include <GLES2/gl2.h>

/* SIXTY_HZ needs to be defined for B552 LVDS->DVI converter support */
#define SIXTY_HZ

#include "nexus_platform.h"
#include "nexus_display.h"
#include "bkni.h"
#include "nexus_ir_input.h"

#include "trickplay/trickplay.h"
#include "trickplay/controller.h"
#include "trickplay/keys.h"
#include "trickplay/mediaplayer.h"

NEXUS_PlatformConfiguration   platform_config;
NEXUS_DisplayHandle     nexus_display = 0;
EGLNativeDisplayType    native_display = 0;
EGL_NEXUS_WIN_T         egl_window;
NEXUS_IrInputHandle     mIRHandle = 0;

TPController *          controller = 0;

extern int nmp_constructor( TPMediaPlayer * );


static void irCallback(void *pParam, int iParam)
{
   size_t numEvents = 1;
   NEXUS_Error rc = 0;
   bool overflow;
   NEXUS_IrInputHandle irHandle = *(NEXUS_IrInputHandle *)pParam;
   BSTD_UNUSED(iParam);

   while (numEvents && !rc) 
   {
      NEXUS_IrInputEvent irEvent;
      rc = NEXUS_IrInput_GetEvents(irHandle, &irEvent, 1, &numEvents, &overflow);

      if (numEvents && (irEvent.code == 0x5da2a55a || irEvent.repeat)) /* Ignore non-repeat events. We always seem to get at least 2 (except for exit). */
      {
         BKNI_Printf("irCallback: rc: %d, code: %08x, repeat: %s\n", rc, irEvent.code, irEvent.repeat ? "true" : "false");
         
         if ( controller )
         {
            tp_controller_key_down( controller , irEvent.code , 0 );
            tp_controller_key_up( controller , irEvent.code , 0 );
         }
      }
   }
}

bool InitDisplay()
{
   NEXUS_PlatformSettings        platform_settings;
   NEXUS_DisplaySettings         display_settings;
   NEXUS_GraphicsSettings        graphics_settings;
   NEXUS_IrInputSettings         irSettings;
#ifdef SIXTY_HZ
   NEXUS_PanelOutputSettings     panelOutputSettings;
#endif
   NEXUS_Error                   err;

   /* Initialise the Nexus platform */
   NEXUS_Platform_GetDefaultSettings(&platform_settings);
#ifdef SIXTY_HZ
   platform_settings.displayModuleSettings.panel.dvoLinkMode = NEXUS_PanelOutputLinkMode_eDualChannel1;
   platform_settings.displayModuleSettings.panel.lvdsColorMode = NEXUS_LvdsColorMode_e8Bit ;
#endif
   platform_settings.openOutputs = true;

   err = NEXUS_Platform_Init(&platform_settings);
   if (err)
   {
      printf("NEXUS_Platform_Init() failed\n");
      return false;
   }

#if NEXUS_DTV_PLATFORM
   /* Bring up display */
   NEXUS_Display_GetDefaultSettings(&display_settings);
   display_settings.format = NEXUS_VideoFormat_e1080p;
   nexus_display = NEXUS_Display_Open(0, &display_settings);
   if (!nexus_display)
   {
      printf("NEXUS_Display_Open() failed\n");
      return false;
   }
   NEXUS_Platform_GetConfiguration(&platform_config);
#ifdef SIXTY_HZ
   NEXUS_PanelOutput_GetSettings(platform_config.outputs.panel[0], &panelOutputSettings);
   panelOutputSettings.frameRateMultiplier = 1;
   NEXUS_PanelOutput_SetSettings(platform_config.outputs.panel[0], &panelOutputSettings);
#endif
   NEXUS_Display_AddOutput(nexus_display, NEXUS_PanelOutput_GetConnector(platform_config.outputs.panel[0]));

   /* Set filter modes for smooth resizing */
   NEXUS_Display_GetGraphicsSettings(nexus_display, &graphics_settings);
   graphics_settings.horizontalFilter = NEXUS_GraphicsFilterCoeffs_eBilinear;
   graphics_settings.verticalFilter = NEXUS_GraphicsFilterCoeffs_eBilinear;
   NEXUS_Display_SetGraphicsSettings(nexus_display, &graphics_settings);

#else
   /* Bring up display */
   NEXUS_Display_GetDefaultSettings(&display_settings);
   display_settings.format = NEXUS_VideoFormat_eNtsc;
   nexus_display = NEXUS_Display_Open(0, &display_settings);
#if NEXUS_NUM_COMPONENT_OUTPUTS
   if (platform_config.outputs.component[0])
   {
      NEXUS_Display_AddOutput(nexus_display, NEXUS_ComponentOutput_GetConnector(platform_config.outputs.component[0]));
   }
#endif
#if NEXUS_NUM_COMPOSITE_OUTPUTS
   NEXUS_Display_AddOutput(nexus_display, NEXUS_CompositeOutput_GetConnector(platform_config.outputs.composite[0]));
#endif
#endif

   /* Register this display for exclusive mode access */
   native_display = BRCM_RegisterDisplay(nexus_display);

   NEXUS_Display_GetGraphicsSettings(nexus_display, &graphics_settings);
   
   graphics_settings.enabled = true;
#if 1
   graphics_settings.sourceBlendFactor = NEXUS_CompositorBlendFactor_eSourceAlpha;
   graphics_settings.destBlendFactor = NEXUS_CompositorBlendFactor_eInverseSourceAlpha;
#else
   graphics_settings.sourceBlendFactor = NEXUS_CompositorBlendFactor_eConstantAlpha;
   graphics_settings.destBlendFactor = NEXUS_CompositorBlendFactor_eInverseConstantAlpha;
   graphics_settings.constantAlpha = 0x80;
   
#endif

   NEXUS_Display_SetGraphicsSettings( nexus_display , & graphics_settings );

   BRCM_GetDefaultNativeWindowSettings(&egl_window);
   egl_window.rect.x = 0;
   egl_window.rect.y = 0;
   egl_window.rect.width = 960;
   egl_window.rect.height = 540;
   egl_window.stretchToDisplay = 1;

   NEXUS_IrInput_GetDefaultSettings(&irSettings);
   irSettings.dataReady.callback = irCallback;
   irSettings.dataReady.context = &mIRHandle;
   mIRHandle = NEXUS_IrInput_Open(0, &irSettings);

   return true;
}

NativeWindowType tp_egl_get_native_window( void )
{
    return ( NativeWindowType ) & egl_window;
}

static void install_controller( TPContext * ctx )
{
	TPControllerSpec remoteSpec;

	memset(&remoteSpec, 0, sizeof(remoteSpec));

	remoteSpec.capabilities	= TP_CONTROLLER_HAS_KEYS;
	
	TPControllerKeyMap map[] =
	{
	    { 0x40bf04fb , TP_KEY_UP },
	    { 0x41be04fb , TP_KEY_DOWN },
	    { 0x06f904fb , TP_KEY_RIGHT },
	    { 0x07f804fb , TP_KEY_LEFT },
	    { 0x44bb04fb , TP_KEY_RETURN },
	    { 0x28d704fb , TP_KEY_BACK },
	    { 0x5ba404fb , TP_KEY_EXIT },
	    { 0x728d04fb , TP_KEY_RED },
            { 0x718e04fb , TP_KEY_GREEN },
            { 0x639c04fb , TP_KEY_YELLOW },
            { 0x619e04fb , TP_KEY_BLUE },
            
            { 0x10ef04fb , TP_KEY_0 },
            { 0x11ee04fb , TP_KEY_1 },
            { 0x12ed04fb , TP_KEY_2 },
            { 0x13ec04fb , TP_KEY_3 },
            { 0x14eb04fb , TP_KEY_4 },
            { 0x15ea04fb , TP_KEY_5 },
            { 0x16e904fb , TP_KEY_6 },
            { 0x17e804fb , TP_KEY_7 },
            { 0x18e704fb , TP_KEY_8 },
            { 0x19e604fb , TP_KEY_9 },
	    
	    {0,0}
	};

    remoteSpec.key_map = map;
    
    controller = tp_context_add_controller( ctx, "Remote", &remoteSpec, NULL);    
}

int main(int argc, char** argv)
{
   int                  result;
   TPContext *          ctx;

   
   result = 0;
   ctx = 0;
   mIRHandle = 0;
   
   /* Setup the display and EGL */
   if ( InitDisplay() )
   {
      printf( "\n\n\tTRICKPLAY\n\n" );
      
      tp_init( & argc , & argv );
      
      ctx = tp_context_new();
      
      install_controller( ctx );
      
      tp_context_set_media_player_constructor( ctx , nmp_constructor );
      
      result = tp_context_run( ctx );
      
      tp_context_free( ctx );      
   }

   if (nexus_display != 0)
   {
       EGLDisplay   eglDisplay;
      /* Terminate EGL */

      eglDisplay = eglGetDisplay(EGL_DEFAULT_DISPLAY);
      eglMakeCurrent(eglDisplay, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
      eglTerminate(eglDisplay);

      BRCM_UnregisterDisplay(native_display);

      /* Close the Nexus display */
      NEXUS_Display_Close(nexus_display);
   }

   if (mIRHandle)
   {
      NEXUS_IrInput_Close(mIRHandle);
   }
   
   /* Close the platform */
   NEXUS_Platform_Uninit();

   return result;
}
