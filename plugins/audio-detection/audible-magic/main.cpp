
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <string>
#include <sstream>
#include <map>
#include <list>

#include "trickplay/plugins/audio-detection.h"

#include "MF_oem_api.h"

#include "sndfile.h"

#include <libxml/tree.h>
#include <libxml/parser.h>
#include <libxml/xpath.h>
#include <libxml/xpathInternals.h>

//******************************************************************************

class State
{
public:

    //.........................................................................
    // Populates plugin info and parses the configuration data

    State( TPAudioDetectionPluginInfo * info , const char * string_config )
    :
        sound_file( 0 )
    {
        strncpy( info->name , "Audible Magic" , sizeof( info->name ) - 1 );

        MFVersion( info->version , sizeof( info->version ) );

        parse_config( string_config );
    }

    //.........................................................................
    // Deletes the sound file if it is still there.

    ~State()
    {
        free_sound_file();
    }

    //.........................................................................
    // We are going to write the samples to a wav file using sndfile until we
    // have at least 30 seconds.

    TPAudioDetectionResult * process_samples( const TPAudioDetectionSamples * samples )
    {
        //.........................................................................
        // If we already have a sound file, make sure that it matches what we
        // already have. If not, get rid of it.

        if ( sound_file )
        {
            if ( samples->channels != sound_file_info.channels || samples->sample_rate != sound_file_info.samplerate )
            {
                free_sound_file();
            }
        }

        //.........................................................................

        if ( ! sound_file )
        {
            if ( char * fn = tempnam( 0 , "am-" ) )
            {
                sound_file_name = fn;
                free( fn );
            }
            else
            {
                std::cerr << "FAILED TO ALLOCATE TEMPORARY FILE NAME" << std::endl;
                return 0;
            }

            memset( & sound_file_info , 0 , sizeof( sound_file_info ) );

            sound_file_info.channels = samples->channels;
            sound_file_info.samplerate = samples->sample_rate;
            sound_file_info.format = SF_FORMAT_WAV | SF_FORMAT_PCM_16;

            sound_file = sf_open( sound_file_name.c_str() , SFM_WRITE , & sound_file_info );

            if ( ! sound_file )
            {
                std::cerr << "FAILED TO OPEN SOUND FILE FOR WRITING : " << sound_file_name << std::endl;

                sound_file_name.clear();

                return 0;
            }
        }

        //.....................................................................
        // Write the new samples to the file

        sf_count_t written = sf_writef_float( sound_file , samples->samples , samples->frames );

        if ( written != samples->frames )
        {
            // Something went wrong with the write.

            free_sound_file();

            std::cerr << "FAILED TO WRITE SAMPLES TO SOUND FILE" << std::endl;

            return 0;
        }

        //.....................................................................
        // Increase our frame count

        sound_file_info.frames += samples->frames;

        int seconds = sound_file_info.frames / sound_file_info.samplerate;

        if ( seconds < 30 )
        {
            std::cout << "WAITING FOR MORE SAMPLES, ONLY HAVE " << seconds << " SECONDS" << std::endl;

            return 0;
        }

        //.....................................................................
        // OK, we have 30 seconds. We close the file.

        sf_close( sound_file );

        sound_file = 0;

        // Now, we analyze it - and get the post body

        char * body = media2xml();

        // We are done with this file.

        free_sound_file();

        // If the body is NULL, something went wrong when analyzing

        if ( ! body )
        {
            return 0;
        }

        //.........................................................................
        // The body is good, we return a result

        TPAudioDetectionResult * result;

        result = ( TPAudioDetectionResult * ) malloc( sizeof( TPAudioDetectionResult ) );

        memset( result , 0 , sizeof( TPAudioDetectionResult ) );

        result->url = strdup( config[ "url" ].c_str() );
        result->method = strdup( "POST" );
        result->headers = strdup( "Content-Type: text/xml" );
        result->body = body;
        result->parse_response = parse_response_external;
        result->free_result = free_result;

        result->user_data = this;

        return result;
    }

    //.........................................................................
    // This gets called when the source of audio changes, so we just dump
    // the current file (if any) and start over.

    void reset()
    {
        free_sound_file();
    }

private:

    //.........................................................................
    // Parse the configuration file values

    void parse_config( const char * string_config )
    {
        if ( string_config )
        {
            std::istringstream stream( string_config );
            String line;

            while( std::getline( stream , line ) )
            {
                std::istringstream lstream( line );

                String key;
                String value;

                std::getline( lstream , key , '=' );
                std::getline( lstream , value );

                if ( ! key.empty() && ! value.empty() )
                {
                    config[ key ] = value;
                }
            }
        }
    }

    //.........................................................................
    // If the file is open, close it. If the file name exists, delete the file

    void free_sound_file( )
    {
        if ( sound_file )
        {
            sf_close( sound_file );

            sound_file = 0;
        }

        if ( ! sound_file_name.empty() )
        {
            unlink( sound_file_name.c_str() );

            sound_file_name.clear();
        }
    }

    //.........................................................................
    // Utility to throw a string exception with the MFError message.

    static void mf_check( MFError error , const char * message )
    {
        if ( error == MF_SUCCESS )
        {
            return;
        }

        std::string e( message );

        char mf_message[ 1024 ];

        if ( MF_SUCCESS == MFGetErrorDescription( error , mf_message , 1024 ) )
        {
            e += std::string( " : " ) + std::string( mf_message );
        }

        throw e;
    }

    //.........................................................................
    // Analyzes the sound file and returns the resulting xml string. Or NULL if
    // it fails.

    char * media2xml()
    {
        MFXMLMessage        xml_msg = 0;
        MFXMLIDRequest      id_request = 0;
        char                request_guid[ MF_GUID_LENGTH ];
        MFXMLInfo           xml_info = 0;
        int                 xml_info_len = 0;

        try
        {
            // If this does not have a trailing slash, it will fail to run ffmpeg.

            MFSetExecutablePath( ( char * ) config[ "exe_path" ].c_str() );

            mf_check( MFPing() , "FAILED TO PING LIBRARY" );

            mf_check( MFXMLMessageCreate( & xml_msg ) , "FAILED TO CREATE XML MESSAGE" );

            mf_check( MFXMLMessageAddField( xml_msg , "UserGUID" , ( char * ) config[ "guid"].c_str() ) , "FAILED TO ADD GUID" );
            mf_check( MFXMLMessageAddField( xml_msg , "UserFullName" , ( char * ) config[ "user_full_name" ].c_str() ) , "FAILED TO ADD USER FULL NAME" );
            mf_check( MFXMLMessageAddField( xml_msg , "AppName" , ( char * ) config[ "app_name" ].c_str() ) , "FAILED TO ADD APP NAME" );
            mf_check( MFXMLMessageAddField( xml_msg , "CustomerID" , ( char * ) config[ "customer_id" ].c_str() ) , "FAILED TO ADD CUSTOMER ID" );

            // Generate request GUID and id request object

            mf_check( MFXMLIDRequestGenerateGuidAndCreate( & id_request , request_guid , xml_msg ) , "FAILED TO GENERATE ID REQUEST" );

            // Set the media file

            // TODO: hard-coded '/tmp'

            mf_check( MFXMLIDRequestSetMediaFile( id_request , ( char * ) sound_file_name.c_str() , "/tmp" , MF_MEDIA_AUDIO , ( char * ) config[ "asset_id" ].c_str() ) , "FAILED TO SET MEDIA FILE" );


            // Analyze it

            mf_check( MFXMLIDRequestAnalyzeDestroyAndReportInfo( & id_request , & xml_info , & xml_info_len ) , "FAILED TO ANALYZE" );

            // TODO: Do we need the info?

            MFXMLInfoDestroy( xml_info );

            // Get the XML out of it

            char *  xml = ( char * ) malloc( 50000 );
            int     xml_len = 50000;

            if ( ! xml )
            {
                throw std::string( "FAILED TO ALLOCATE MEMORY FOR XML" );
            }

            while( true )
            {
                MFError error = MFXMLMessageGetStringAndDestroy( & xml_msg , xml , & xml_len );

                switch( error )
                {
                    case MF_SUCCESS:
                        xml[ xml_len ] = 0;
                        return xml;
                        break;

                    case MF_BUFFER_TOO_SMALL:
                        xml_len *= 2;
                        xml = ( char * ) realloc( xml , xml_len );
                        if ( ! xml )
                        {
                            throw std::string( "FAILED TO RE-ALLOCATE MEMORY FOR XML" );
                        }
                        break;

                    default:
                        free( xml );
                        mf_check( error , "FAILED TO GET XML" );
                        break;
                }
            }
        }
        catch( const std::string & message )
        {
            std::cerr << message << std::endl;
        }

        return 0;
    }

    //.........................................................................
    // We got the server's response here, we need to parse it to JSON that
    // Trickplay understands and set result->json.

    void parse_response( TPAudioDetectionResult * result , const char * response_body , unsigned long int response_size )
    {
#if 0
        std::cout << std::endl << response_body << std::endl;
#endif

        // All we are doing here is using XPath to find all the title nodes.

        static bool initialized = false;

        if ( ! initialized )
        {
            initialized = true;
            xmlInitParser();
        }

        std::ostringstream json;

        json << "[";

        int count = 0;

        xmlDocPtr doc = xmlParseMemory( response_body , response_size );

        if ( doc )
        {
            xmlXPathContextPtr xpc = xmlXPathNewContext( doc );

            if ( xpc )
            {
                xmlXPathObjectPtr xpo;

                const xmlChar * exp = BAD_CAST "/AMIdServerResponse/Details/IdResponseInfo/IdResponse/IdDetails/Title";

                xpo = xmlXPathEvalExpression( exp , xpc );

                if ( xpo )
                {
                    if ( xpo->nodesetval )
                    {
                        for ( int i = 0; i < xpo->nodesetval->nodeNr; ++i )
                        {
                            xmlNodePtr node = xpo->nodesetval->nodeTab[ i ];

                            if ( node && node->children )
                            {
                                xmlChar * title = xmlNodeGetContent( node );

                                if ( title )
                                {
                                    if ( count > 0 )
                                    {
                                        json << ",";
                                    }

                                    // TODO : This is completely wrong - there is no way for us to know that
                                    // the title is valid JSON. We need to encode it properly.

                                    json << "{\"title\":\"" << BAD_CAST title << "\"}";

                                    xmlFree( title );

                                    ++count;

                                    // Only return the first 4 matches

                                    if ( count > 4 )
                                    {
                                        break;
                                    }
                                }
                            }
                        }
                    }

                    xmlXPathFreeObject( xpo );
                }

                xmlXPathFreeContext( xpc );
            }
            xmlFreeDoc( doc );
        }

        json << "]";

        result->json = strdup( json.str().c_str() );
    }

    //.........................................................................

    static void safe_free( void * p )
    {
        if ( p ) free( p );
    }

    static void free_result( TPAudioDetectionResult * result )
    {
        if ( result )
        {
            safe_free( result->url );
            safe_free( result->method );
            safe_free( result->headers );
            safe_free( result->json );
            safe_free( result->body );

            free( result );
        }
    }

    //.........................................................................

    static void parse_response_external( TPAudioDetectionResult * result , const char * response_body , unsigned long int response_size )
    {
        ( ( State * ) result->user_data )->parse_response( result , response_body , response_size );
    }

    //.........................................................................

    typedef std::string             String;
    typedef std::map<String,String> StringMap;

    StringMap   config;
    SF_INFO     sound_file_info;
    SNDFILE *   sound_file;
    String      sound_file_name;
};


//******************************************************************************
// The three external functions

extern "C"
void
tp_audio_detection_initialize( TPAudioDetectionPluginInfo * info , const char * config )
{
    info->user_data = new State( info , config );
}

extern "C"
TPAudioDetectionResult *
tp_audio_detection_process_samples( const TPAudioDetectionSamples * samples , void * user_data )
{
    return ( ( State * ) user_data )->process_samples( samples );
}

extern "C"
void
tp_audio_detection_reset( void * user_data )
{
    ( ( State * ) user_data )->reset();
}

extern "C"
void
tp_audio_detection_shutdown( void * user_data )
{
    delete ( State * ) user_data;
}

//*****************************************************************************

