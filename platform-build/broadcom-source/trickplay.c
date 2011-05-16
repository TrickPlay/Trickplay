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
#include "default_nexus.h"

#include "nexus_pid_channel.h"
#include "nexus_stc_channel.h"
#include "nexus_video_window.h"
#include "nexus_composite_output.h"
#include "nexus_component_output.h"
#include "nexus_hdmi_input.h"
#include "nexus_video_input.h"
#include "nexus_audio_decoder.h"
#include "nexus_audio_dac.h"
#include "nexus_audio_output.h"
#include "nexus_audio_input.h"
#include "bstd.h"
#include "bkni.h"


#include "nexus_ir_input.h"

#include "init.h"

#include "trickplay/trickplay.h"
#include "trickplay/controller.h"
#include "trickplay/keys.h"
#include "trickplay/mediaplayer.h"

#define LINE fprintf( stderr , "%s:%d\n" , __FILE__ , __LINE__ )

NEXUS_PlatformConfiguration   platform_config;
NEXUS_DisplayHandle           nexus_display = 0;
EGLNativeDisplayType          native_display = 0;
void *                        native_window = 0;
NEXUS_IrInputHandle           mIRHandle = 0;
NXPL_PlatformHandle           nxpl_handle = 0;


TPController *                controller = 0;

NEXUS_VideoWindowHandle       video_window = 0;
NEXUS_HdmiInputHandle         hdmiInput = 0;
NEXUS_AudioDecoderHandle      hdmiAudioDecoder = 0;

/*
===============================================================================
*/

extern int nmp_constructor( TPMediaPlayer * );

/*
===============================================================================
*/

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

      if (numEvents) 
      {
         BKNI_Printf("  rc: %d, code: %08x, repeat: %s\n", rc, irEvent.code, irEvent.repeat ? "true" : "false");
         
         if ( controller && ! irEvent.repeat )
         {
            tp_controller_key_down( controller , irEvent.code , 0 );
            tp_controller_key_up( controller , irEvent.code , 0 );
         }
      }
   }
}

/*
===============================================================================
*/

void disconnect_hdmi( void )
{
   printf( "\n\n\tDISCONNECT HDMI\n\n" );
   
   NEXUS_VideoWindow_RemoveAllInputs( video_window );   

   if ( hdmiInput )
   {
      if ( hdmiAudioDecoder )
      {
         NEXUS_AudioDecoder_Stop( hdmiAudioDecoder );
      
         NEXUS_AudioOutput_RemoveInput(NEXUS_AudioDac_GetConnector(platform_config.outputs.audioDacs[0]),
         NEXUS_AudioDecoder_GetConnector(hdmiAudioDecoder, NEXUS_AudioDecoderConnectorType_eStereo));
      
         NEXUS_AudioOutput_RemoveInput(NEXUS_SpdifOutput_GetConnector(platform_config.outputs.spdif[0]),
         NEXUS_AudioDecoder_GetConnector(hdmiAudioDecoder, NEXUS_AudioDecoderConnectorType_eCompressed));
      
         NEXUS_AudioOutput_RemoveAllInputs( NEXUS_AudioDac_GetConnector(platform_config.outputs.audioDacs[0]) );
     
         NEXUS_AudioInput_Shutdown(NEXUS_AudioDecoder_GetConnector(hdmiAudioDecoder, NEXUS_AudioDecoderConnectorType_eStereo));         
         NEXUS_AudioInput_Shutdown(NEXUS_AudioDecoder_GetConnector(hdmiAudioDecoder, NEXUS_AudioDecoderConnectorType_eMultichannel ));
         NEXUS_AudioInput_Shutdown(NEXUS_AudioDecoder_GetConnector(hdmiAudioDecoder, NEXUS_AudioDecoderConnectorType_eCompressed));
         NEXUS_AudioInput_Shutdown( NEXUS_HdmiInput_GetAudioConnector( hdmiInput ) );
      }
   
      NEXUS_VideoInput_Shutdown( NEXUS_HdmiInput_GetVideoConnector( hdmiInput ) );

      if ( hdmiAudioDecoder )
      {
        NEXUS_AudioDecoder_Close( hdmiAudioDecoder );
      }

      NEXUS_HdmiInput_Close( hdmiInput );
   }
   
   hdmiInput = 0;
   hdmiAudioDecoder = 0;

   printf( "\n\n\tDISCONNECT HDMI DONE\n\n" );
}

/*
===============================================================================
*/

void connect_hdmi( void )
{
   NEXUS_VideoWindowSettings windowSettings;
   NEXUS_HdmiInputSettings hdmiInputSettings;
   NEXUS_TimebaseSettings timebaseSettings;
   
#if 0
   NEXUS_AudioDecoderStartSettings audioProgram;
   NEXUS_StcChannelSettings stcSettings;
#endif   

   printf( "\n\n\tCONNECT HDMI\n\n" );
   
   NEXUS_VideoWindow_GetSettings(video_window, &windowSettings);
   
   windowSettings.position.x = 0;
   windowSettings.position.y = 0;
   windowSettings.position.width = 1920;
   windowSettings.position.height = 1080;
   NEXUS_VideoWindow_SetSettings(video_window, &windowSettings);
         
   NEXUS_Timebase_GetSettings(NEXUS_Timebase_e0, &timebaseSettings);
   timebaseSettings.sourceType = NEXUS_TimebaseSourceType_eHdDviIn;
   NEXUS_Timebase_SetSettings(NEXUS_Timebase_e0, &timebaseSettings);
   
   NEXUS_HdmiInput_GetDefaultSettings(&hdmiInputSettings);
   hdmiInputSettings.timebase = NEXUS_Timebase_e0;
   hdmiInput = NEXUS_HdmiInput_Open(0, &hdmiInputSettings);
   
   if ( ! hdmiInput )
   {
      fprintf( stderr , "FAILED TO OPEN HDMI INPUT\n" ); 
   }
   else
   {
      NEXUS_VideoWindow_AddInput(video_window, NEXUS_HdmiInput_GetVideoConnector(hdmiInput));
      
#if 0   
      hdmiAudioDecoder = NEXUS_AudioDecoder_Open(0, NULL);
      NEXUS_AudioDecoder_GetDefaultStartSettings(&audioProgram);
      audioProgram.input = NEXUS_HdmiInput_GetAudioConnector(hdmiInput);
      NEXUS_StcChannel_GetDefaultSettings(0, &stcSettings);
      stcSettings.timebase = NEXUS_Timebase_e0;
      stcSettings.autoConfigTimebase = false;
      audioProgram.stcChannel = NEXUS_StcChannel_Open(0, &stcSettings);
      NEXUS_AudioOutput_AddInput(NEXUS_AudioDac_GetConnector(platform_config.outputs.audioDacs[0]),
                                 NEXUS_AudioDecoder_GetConnector(hdmiAudioDecoder, NEXUS_AudioDecoderConnectorType_eStereo));

      NEXUS_AudioOutput_AddInput(NEXUS_SpdifOutput_GetConnector(platform_config.outputs.spdif[0]),
                                 NEXUS_AudioDecoder_GetConnector(hdmiAudioDecoder, NEXUS_AudioDecoderConnectorType_eCompressed));

      NEXUS_AudioDecoder_Start(hdmiAudioDecoder, &audioProgram);
#endif

   }   

   printf( "\n\n\tCONNECT HDMI DONE\n\n" );
}


/*
===============================================================================
*/

const unsigned int WIDTH             = 1920;
const unsigned int HEIGHT            = 1080;
const unsigned int FRAMES            = 0;
const unsigned int BPP               = 32;


bool InitDisplay( void )
{
   NXPL_NativeWindowInfo   win_info;
   NEXUS_GraphicsSettings  graphics_settings;

   if (InitPlatform())
   {
      /* We are the primary process, so open the display */
      nexus_display = OpenDisplay(0, WIDTH, HEIGHT);
      InitPanelOutput(nexus_display);
      InitCompositeOutput(nexus_display, WIDTH, HEIGHT);
      InitComponentOutput(nexus_display);
      InitHDMIOutput(nexus_display);
   }

   /* Register this display for exclusive mode access */
   NXPL_RegisterNexusDisplayPlatform(&nxpl_handle, nexus_display);

   if (nexus_display != 0)
   {
      NEXUS_Display_GetGraphicsSettings(nexus_display, &graphics_settings);
   }

   win_info.x = 0; 
   win_info.y = 0;
   win_info.width = WIDTH;
   win_info.height = HEIGHT;
   win_info.stretch = true;
   native_window = NXPL_CreateNativeWindow(&win_info);

   video_window = NEXUS_VideoWindow_Open(nexus_display, 0);

   connect_hdmi();   

   return true;
}

/*
===============================================================================
*/

NativeWindowType tp_egl_get_native_window( void )
{
    return ( NativeWindowType ) native_window;
}

/*
===============================================================================
*/

static void install_controller( TPContext * ctx )
{
    NEXUS_IrInputSettings irSettings;

    TPControllerSpec remoteSpec;

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

        /* RCA remote */

        { 0x1ae504fb , TP_KEY_BACK },
        
        /* Broadcom remote */
        
        { 0x4eb100ff , TP_KEY_UP },
        { 0x0cf300ff , TP_KEY_DOWN },
        { 0x49b600ff , TP_KEY_RIGHT },
        { 0x0bf400ff , TP_KEY_LEFT },
        { 0x08f700ff , TP_KEY_RETURN },
        { 0x06f900ff , TP_KEY_BACK },
        { 0x4db200ff , TP_KEY_EXIT },
        { 0x50af00ff , TP_KEY_RED },
        { 0x10ef00ff , TP_KEY_GREEN },
        { 0x11ee00ff , TP_KEY_YELLOW },
        { 0x51ae00ff , TP_KEY_BLUE },
        { 0x52ad00ff , TP_KEY_0 },
        { 0x1fe000ff , TP_KEY_1 },
        { 0x5ea100ff , TP_KEY_2 },
        { 0x5fa000ff , TP_KEY_3 },
        { 0x1be400ff , TP_KEY_4 },
        { 0x5aa500ff , TP_KEY_5 },
        { 0x5ba400ff , TP_KEY_6 },
        { 0x17e800ff , TP_KEY_7 },
        { 0x56a900ff , TP_KEY_8 },
        { 0x57a800ff , TP_KEY_9 },      

        {0,0}
    };

    NEXUS_IrInput_GetDefaultSettings(&irSettings);
    irSettings.repeatFilterTime = 80;
    irSettings.dataReady.callback = irCallback;
    irSettings.dataReady.context = &mIRHandle;
    mIRHandle = NEXUS_IrInput_Open(0, &irSettings);

    memset(&remoteSpec, 0, sizeof(remoteSpec));
    remoteSpec.capabilities	= TP_CONTROLLER_HAS_KEYS;
    remoteSpec.key_map = map;   
    controller = tp_context_add_controller( ctx, "Remote", &remoteSpec, NULL);    
}

/*
===============================================================================
*/

int main(int argc, char** argv)
{
    int         result = 0;
    TPContext * ctx = 0;
    EGLDisplay  eglDisplay;
  
    if ( InitDisplay() )
    {
        printf( "\n\n\tTRICKPLAY\n\n" );
      
        tp_init( & argc , & argv );
      
        ctx = tp_context_new();
      
        install_controller( ctx );
      
        tp_context_set_int( ctx , TP_SCREEN_WIDTH , WIDTH );
        tp_context_set_int( ctx , TP_SCREEN_HEIGHT , HEIGHT );
      
        tp_context_set_media_player_constructor( ctx , nmp_constructor );
      
        result = tp_context_run( ctx );
      
        tp_context_free( ctx );      
    }

    eglDisplay = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    eglMakeCurrent(eglDisplay, EGL_NO_SURFACE, EGL_NO_SURFACE, EGL_NO_CONTEXT);
    eglTerminate(eglDisplay);

    NXPL_DestroyNativeWindow(native_window);

    NXPL_UnregisterNexusDisplayPlatform(nxpl_handle);

    if (nexus_display != 0)
    {
        NEXUS_Display_Close(nexus_display);
    }

    if (mIRHandle)
    {
        NEXUS_IrInput_Close(mIRHandle);
    }

/*
    This is causing a segfault. (cube example does it too)
*/

    NEXUS_Platform_Uninit();

    return result;
}
