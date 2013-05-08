
#include <string.h>
#include "glib.h"
#include "gst/video/video.h"
#include "clutter-gst/clutter-gst.h"

#include "trickplay/audio-sampler.h"

void* connect_audio_sampler( TPContext* context );

void disconnect_audio_sampler( void* sampler );

//=============================================================================

typedef struct BufferInfo
{
    TPAudioSampler*     sampler;
    TPAudioBuffer       buffer;
    gulong              probe_handler;
}
BufferInfo;

//=============================================================================

static GstPadProbeReturn audio_buffer_received( GstPad* pad , GstPadProbeInfo* buffer , gpointer u_data );

static void disconnect_probe( gpointer pad );

//=============================================================================

static GstElement* find_element_by_name( GstElement* bin , const char* name )
{
    g_assert( bin );
    g_assert( name );

    GstElement* result = 0;

    if ( ! GST_IS_BIN( bin ) )
    {
        return 0;
    }

    GstIterator* it = gst_bin_iterate_recurse( GST_BIN( bin ) );

    if ( ! it )
    {
        return 0;
    }

    GValue el;
    g_value_unset(&el);

    int done = FALSE;

    while ( ! done )
    {
        switch ( gst_iterator_next( it , & el ) )
        {
            case GST_ITERATOR_OK:
            {
                gpointer *elem = g_value_get_pointer ( &el );
                gchar* this_name = gst_element_get_name( GST_ELEMENT( elem ) );

                if ( this_name )
                {
                    if ( ! strcmp( name , this_name ) )
                    {
                        // Take an extra ref to it

                        result = GST_ELEMENT( gst_object_ref( GST_OBJECT( elem ) ) );

                        done = TRUE;
                    }

                    g_free( this_name );
                }

                gst_object_unref( GST_OBJECT( elem ) );
            }
            break;


            case GST_ITERATOR_RESYNC:
                gst_iterator_resync( it );
                break;

            default:
                done = TRUE;
                break;
        }
    }

    g_value_unset(&el);

    gst_iterator_free( it );

    return result;
}

//=============================================================================

static GstPad* find_source_pad( GstElement* element )
{
    g_assert( element );

    GstIterator* it = gst_element_iterate_src_pads( element );

    if ( ! it )
    {
        return 0;
    }

    GstPad* result = 0;

    GValue pad;
    g_value_unset(&pad);

    int done = FALSE;

    while ( ! done )
    {
        switch ( gst_iterator_next( it , & pad ) )
        {
            case GST_ITERATOR_OK:
            {
                result = GST_PAD( g_value_get_pointer (&pad) );

                done = TRUE;
            }
            break;

            case GST_ITERATOR_RESYNC:
                gst_iterator_resync( it );
                break;

            default:
                done = TRUE;
                break;
        }
    }

    g_value_unset(&pad);

    gst_iterator_free( it );

    return result;
}

//=============================================================================

void connect_audio_sampler_old( TPContext* context , GstElement* pipeline )
{
    g_assert( context );
    g_assert( pipeline );

    const char* enabled = g_getenv( "TP_CMP_SAMPLE" );

    if ( ! enabled )
    {
        return;
    }

    if ( strcmp( enabled , "1" ) )
    {
        return;
    }

    //-------------------------------------------------------------------------
    // Find the audio converter element

    GstElement* audio_convert = find_element_by_name( pipeline , "aconv" );

    if ( ! audio_convert )
    {
        g_debug( "FAILED TO FIND AUDIO CONVERT ELEMENT" );
        return;
    }

    //-------------------------------------------------------------------------
    // We got the audio convert element, get its source pad

    GstPad* source_pad = find_source_pad( audio_convert );

    gst_object_unref( audio_convert );

    audio_convert = 0;

    if ( ! source_pad )
    {
        g_debug( "FAILED TO FIND SOURCE PAD" );
        return;
    }

    //-------------------------------------------------------------------------
    // Get the caps for the source pad

    GstCaps* caps = gst_pad_get_current_caps( GST_PAD( source_pad ) );

    if ( ! caps )
    {
        g_debug( "FAILED TO GET PAD CAPS" );
        gst_object_unref( source_pad );
        return;
    }

    gchar* s = gst_caps_to_string( caps );

    g_debug( "AUDIO CAPS : %s" , s );

    g_free( s );

    GstStructure* st = gst_caps_get_structure( caps , 0 );

    if ( ! st )
    {
        g_debug( "FAILED TO GET STRUCTURE" );
        gst_caps_unref( caps );
        gst_object_unref( source_pad );
        return;
    }

    //-------------------------------------------------------------------------
    // Got the caps structure

    //CAPS : audio/x-raw-int, endianness=(int)1234, signed=(boolean)true, width=(int)16, depth=(int)16, rate=(int)48000, channels=(int)2

    if ( ! strcmp( "audio/x-raw-int" , gst_structure_get_name( st ) ) )
    {
        gboolean ok = TRUE;

        int         endianness;
        gboolean    is_signed;
        int         width;
        int         depth;
        int         rate;
        int         channels;

        ok &= gst_structure_get_int( st , "endianness" , & endianness );
        ok &= gst_structure_get_boolean( st , "signed" , & is_signed );
        ok &= gst_structure_get_int( st , "width" , & width );
        ok &= gst_structure_get_int( st , "depth" , & depth );
        ok &= gst_structure_get_int( st , "rate" , & rate );
        ok &= gst_structure_get_int( st , "channels" , & channels );

        if ( ! ok )
        {
            g_debug( "FAILED TO GET REQUIRED INFO FROM CAPS" );
        }
        else if ( endianness == 1234 && is_signed && width == 16 && depth == 16 )
        {
            BufferInfo* info = g_new0( BufferInfo , 1 );

            info->sampler = tp_context_get_audio_sampler( context );
            info->buffer.sample_rate = rate;
            info->buffer.channels = channels;
            info->buffer.format = TP_AUDIO_FORMAT_PCM_16 | TP_AUDIO_ENDIAN_LITTLE;

            info->probe_handler = gst_pad_add_probe( GST_PAD( source_pad ) , GST_PAD_PROBE_TYPE_BUFFER, audio_buffer_received, info, NULL );

            // We attach the buffer info to the pad - so that it will be destroyed when
            // the pad goes away.

            g_object_set_data_full( G_OBJECT( source_pad ) , "tp-buffer-info" , info , g_free );

            // We attach the pad to the pipeline, so that our probe will be disconnected
            // when the pipeline goes away. It also lets us easily find the pad later
            // if we want to disconnect manually.

            g_object_set_data_full( G_OBJECT( pipeline ) , "tp-probe-pad" , gst_object_ref( source_pad ) , disconnect_probe );

            g_log( G_LOG_DOMAIN , G_LOG_LEVEL_INFO , "AUDIO SAMPLING STARTED" );
        }
        else
        {
            g_debug( "WE DON'T SUPPORT THIS AUDIO COMBINATION" );
        }
    }

    gst_caps_unref( caps );

    gst_object_unref( source_pad );
}

//=============================================================================

void disconnect_audio_sampler_old( GstElement* pipeline )
{
    g_object_set_data( G_OBJECT( pipeline ) , "tp-probe-pad" , NULL );
}

//=============================================================================

static void disconnect_probe( gpointer _pad )
{
    g_debug( "DISCONNECTING AUDIO SAMPLER" );

    GstPad* pad = GST_PAD( _pad );

    BufferInfo* info = ( BufferInfo* ) g_object_get_data( G_OBJECT( pad ) , "tp-buffer-info" );

    if ( info && info->probe_handler )
    {
        gst_pad_remove_probe( pad , info->probe_handler );

        info->probe_handler = 0;
    }

    gst_object_unref( pad );
}

//=============================================================================

static void free_samples( void* samples , void* dummy )
{
    g_free(samples);
}

//=============================================================================

static GstPadProbeReturn audio_buffer_received( GstPad* pad , GstPadProbeInfo* probe_info , gpointer u_data )
{
    BufferInfo* info = ( BufferInfo* ) u_data;

    GstBuffer *buffer = gst_pad_probe_info_get_buffer( probe_info );

    info->buffer.size = gst_buffer_extract(buffer, 0, info->buffer.samples, -1);

    info->buffer.copy_samples = 0;
    info->buffer.free_samples = free_samples;

    tp_audio_sampler_submit_buffer( info->sampler , & info->buffer );

    return GST_PAD_PROBE_OK;
}


void* connect_audio_sampler( TPContext* context )
{
    g_assert( context );

    const char* enabled = g_getenv( "TP_CMP_SAMPLE" );

    if ( ! enabled )
    {
        return NULL;;
    }

    if ( strcmp( enabled , "1" ) )
    {
        return NULL;
    }

    clutter_gst_init( 0 , 0 );

    //.........................................................................
    // Create a pipeline

    GstElement* pipeline = gst_pipeline_new( "tp-audio-sampler" );

    if ( ! pipeline )
    {
        g_debug( "FAILED TO CREATE PIPELINE" );
        return 0;
    }

    //.........................................................................
    // Auto audio source and fakesink

    GstElement* audio_source = gst_element_factory_make( "autoaudiosrc" , "src" );
    g_assert(audio_source);

    GstElement* sink = gst_element_factory_make( "fakesink" , "sink" );
    g_assert(sink);

    gst_bin_add_many( GST_BIN( pipeline ) , audio_source , sink , NULL );

    GstCaps *audioCaps = gst_caps_new_simple("audio/x-raw",
        "endianness", G_TYPE_INT, 1234,
        "signed", G_TYPE_BOOLEAN, TRUE,
        "width", G_TYPE_INT, 16,
        "depth", G_TYPE_INT, 16,
        NULL);

    gst_element_link_filtered( audio_source , sink , audioCaps );

    gst_caps_unref(audioCaps);

    GstStateChangeReturn ret = gst_element_set_state( pipeline , GST_STATE_PLAYING );

    if(GST_STATE_CHANGE_FAILURE == ret ||
        (GST_STATE_CHANGE_ASYNC == ret && gst_element_get_state( pipeline , NULL , NULL , GST_SECOND ) == GST_STATE_CHANGE_FAILURE))
    {
        g_debug( "FAILED TO GO INTO PLAY" );
        gst_element_set_state( pipeline , GST_STATE_NULL );
        gst_object_unref( pipeline );
        return 0;
    }

    //.........................................................................
    // Get the source pad for the audio source

    GstPad* pad = gst_element_get_static_pad( audio_source , "src" );

    if ( ! pad )
    {
        g_debug( "FAILED TO GET SOURCE PAD" );
        gst_element_set_state( pipeline , GST_STATE_NULL );
        gst_object_unref( pipeline );
        return 0;
    }

    //.........................................................................
    // Get its caps

    GstCaps* caps = gst_pad_get_current_caps( GST_PAD( pad ) );

    if ( ! caps )
    {
        g_debug( "FAILED TO GET CAPS" );
        gst_object_unref( pad );
        gst_element_set_state( pipeline , GST_STATE_NULL );
        gst_object_unref( pipeline );
        return 0;
    }

    //.........................................................................
    // Get details from the caps

    gchar* s = gst_caps_to_string( caps );

    g_debug( "AUDIO CAPS : %s" , s );

    g_free( s );

    GstStructure* st = gst_caps_get_structure( caps , 0 );

    if ( ! st )
    {
        g_debug( "FAILED TO GET CAPS STRUCTURE" );
        gst_caps_unref( caps );
        gst_object_unref( pad );
        gst_element_set_state( pipeline , GST_STATE_NULL );
        gst_object_unref( pipeline );
        return 0;
    }

    int         endianness;
    gboolean    is_signed;
    int         width;
    int         depth;
    int         rate;
    int         channels;

    gboolean ok = TRUE;

    ok &= ! strcmp( "audio/x-raw" , gst_structure_get_name( st ) );
    ok &= gst_structure_get_int( st , "endianness" , & endianness );
    ok &= gst_structure_get_boolean( st , "signed" , & is_signed );
    ok &= gst_structure_get_int( st , "width" , & width );
    ok &= gst_structure_get_int( st , "depth" , & depth );
    ok &= gst_structure_get_int( st , "rate" , & rate );
    ok &= gst_structure_get_int( st , "channels" , & channels );

    if ( ! ok )
    {
        g_debug( "FAILED TO GET CAPS DETAILS" );
        gst_caps_unref( caps );
        gst_object_unref( pad );
        gst_element_set_state( pipeline , GST_STATE_NULL );
        gst_object_unref( pipeline );
        return 0;
    }

    if ( width != 16 || depth != 16 )
    {
        g_debug( "UNSUPPORTED WIDTH %d AND DEPTH %d" , width , depth );
        gst_caps_unref( caps );
        gst_object_unref( pad );
        gst_element_set_state( pipeline , GST_STATE_NULL );
        gst_object_unref( pipeline );
        return 0;
    }

    //.........................................................................
    // Populate the buffer info structure based on the caps.

    BufferInfo* info = g_new0( BufferInfo , 1 );

    info->sampler = tp_context_get_audio_sampler( context );
    info->buffer.sample_rate = rate;
    info->buffer.channels = channels;
    info->buffer.format = TP_AUDIO_FORMAT_PCM_16;

    if ( endianness == G_LITTLE_ENDIAN )
    {
        info->buffer.format |= TP_AUDIO_ENDIAN_LITTLE;
    }
    else
    {
        info->buffer.format |= TP_AUDIO_ENDIAN_BIG;
    }

    info->probe_handler = gst_pad_add_probe( GST_PAD( pad ) , GST_PAD_PROBE_TYPE_BUFFER, audio_buffer_received, info, NULL );

    // We attach the buffer info to the pad - so that it will be destroyed when
    // the pad goes away.

    g_object_set_data_full( G_OBJECT( pad ) , "tp-buffer-info" , info , g_free );

    // We attach the pad to the pipeline, so that our probe will be disconnected
    // when the pipeline goes away. It also lets us easily find the pad later
    // if we want to disconnect manually.

    g_object_set_data_full( G_OBJECT( pipeline ) , "tp-probe-pad" , gst_object_ref( pad ) , disconnect_probe );

    g_log( G_LOG_DOMAIN , G_LOG_LEVEL_INFO , "AUDIO SAMPLING STARTED" );

    //.........................................................................

    gst_caps_unref( caps );

    gst_object_unref( pad );

    return pipeline;
}

void disconnect_audio_sampler( void* sampler )
{
    if ( sampler == 0 )
    {
        return;
    }

    GstElement* pipeline = GST_ELEMENT( sampler );

    g_object_set_data( G_OBJECT( pipeline ) , "tp-probe-pad" , NULL );

    gst_object_unref( pipeline );
}


