
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <string>
#include <sstream>
#include <map>
#include <list>

#include "trickplay/plugins/audio-detection.h"

#include "MF_MediaID_api.h"

#include "sndfile.h"

#include <libxml/tree.h>
#include <libxml/parser.h>
#include <libxml/xpath.h>
#include <libxml/xpathInternals.h>


//******************************************************************************
// This is the virtual I/O structure we use for sndfile, so we can write samples
// to a memory buffer.

struct VirtualIO
{
    VirtualIO( )
    :
        data( 0 ),
        size( 0 ),
        position( 0 )
    {
        memset( & virtual_io , 0 , sizeof( virtual_io ) );

        virtual_io.get_filelen = VirtualIO::get_filelen;
        virtual_io.seek = VirtualIO::seek;
        virtual_io.read = VirtualIO::read;
        virtual_io.tell = VirtualIO::tell;
        virtual_io.write = VirtualIO::write;
    }

    ~VirtualIO( )
    {
        if ( data )
        {
            free( data );
        }
    }

    static sf_count_t get_filelen( void * user_data )
    {
        VirtualIO * v = ( VirtualIO * ) user_data;

        return v->size;
    }

    static sf_count_t seek( sf_count_t offset , int whence , void * user_data )
    {
        VirtualIO * v = ( VirtualIO * ) user_data;

        sf_count_t new_position = -1;

        switch ( whence )
        {
            case SEEK_SET:
                new_position = offset;
                break;

            case SEEK_CUR:
                new_position = v->position + offset;
                break;

            case SEEK_END:
                new_position = v->size + offset;
                break;
        }

        if ( new_position < 0 || new_position > sf_count_t( v->size ) )
        {
            return 1;
        }

        v->position = new_position;

        return 0;
    }

    static sf_count_t read( void * ptr , sf_count_t count , void * user_data )
    {
        VirtualIO * v = ( VirtualIO * ) user_data;

        sf_count_t result = count;

        if ( result > sf_count_t( v->size ) - v->position )
        {
            result = v->size - v->position;
        }

        if ( result <= 0 )
        {
            return 0;
        }

        memcpy( ptr , v->data + v->position , result );

        v->position += result;

        return result;
    }

    static sf_count_t tell( void * user_data )
    {
        VirtualIO * v = ( VirtualIO * ) user_data;

        return v->position;
    }

    static sf_count_t write( const void * ptr , sf_count_t count , void * user_data )
    {
        VirtualIO * v = ( VirtualIO * ) user_data;

        if ( v->position + count >= v->size )
        {
            size_t new_size = std::max( v->size , count ) * 2;

            void * new_data = realloc( v->data , new_size );

            if ( ! new_data )
            {
                return 0;
            }

            v->data = ( unsigned char * ) new_data;
            v->size = new_size;
        }

        memcpy( v->data + v->position , ptr , count );

        v->position += count;

        return count;
    }

    SF_VIRTUAL_IO   virtual_io;
    unsigned char * data;
    sf_count_t      size;
    sf_count_t      position;
};

//******************************************************************************

class State
{
public:

    //.........................................................................
    // Populates plugin info and parses the configuration data

    State( TPAudioDetectionPluginInfo * info , const char * string_config )
    :
        sound_file( 0 ),
        sound_file_vio( 0 )
    {
        strncpy( info->name , "Audible Magic" , sizeof( info->name ) - 1 );

        MFGetLibraryVersion( info->version , sizeof( info->version ) );

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
            memset( & sound_file_info , 0 , sizeof( sound_file_info ) );

            sound_file_info.channels = samples->channels;
            sound_file_info.samplerate = samples->sample_rate;
            sound_file_info.format = SF_FORMAT_RAW | SF_FORMAT_PCM_16;

            sound_file_vio = new VirtualIO;

            sound_file = sf_open_virtual( & sound_file_vio->virtual_io , SFM_WRITE , & sound_file_info , sound_file_vio );

            if ( ! sound_file )
            {
                std::cerr << "FAILED TO OPEN SOUND FILE FOR WRITING" << std::endl;

                free_sound_file();

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

        if ( seconds < 25 )
        {
//            std::cout << "WAITING FOR MORE SAMPLES, ONLY HAVE " << seconds << " SECONDS" << std::endl;

            return 0;
        }

        //.....................................................................
        // OK, we have 30 seconds. We close the file.

        sf_close( sound_file );

        sound_file = 0;

        // Now, we analyze it - and get the post body

        char * json = analyze();

        // We are done with this file.

        free_sound_file();

        // If the body is NULL, something went wrong when analyzing

        if ( ! json )
        {
            return 0;
        }

        //.........................................................................
        // The JSON is good, we return a result

        TPAudioDetectionResult * result;

        result = ( TPAudioDetectionResult * ) malloc( sizeof( TPAudioDetectionResult ) );

        memset( result , 0 , sizeof( TPAudioDetectionResult ) );

        result->json = json;
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

        if ( sound_file_vio )
        {
            delete sound_file_vio;

            sound_file_vio = 0;
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
    // Analyzes the sound file and returns the resulting JSON. Or NULL if
    // it fails.

    char * analyze()
    {
        try
        {
            MFMediaID           media_id = 0;
            MFMediaIDResponse   response = 0;
            char *              xml = 0;

            try
            {

                mf_check( MFMediaID_CreateUsingConfigFile( & media_id , ( char * ) config[ "config_file" ].c_str() ) , "FAILED TO CREATE MEDIA ID" );

                mf_check( MFMediaID_GenerateAndPostRequestFromSamples(
                    media_id ,
                    sound_file_vio->data ,
                    sound_file_info.frames,
                    sound_file_info.samplerate,
                    sound_file_info.channels,
                    MF_16BIT_SIGNED_LINEAR_PCM,
                    config[ "asset_id" ].c_str(),
                    & response ) , "FAILED TO GENERATE ID" );

                MFResponseStatus status;

                mf_check( MFMediaIDResponse_GetIDStatus( response , & status) , "FAILED TO GET STATUS" );

                if ( MF_MEDIAID_RESPONSE_FOUND != status )
                {
                    throw std::string( "RESPONSE WAS NOT FOUND" );
                }

                int length = 0;

                mf_check( MFMediaIDResponse_GetStringLength( response , & length ) , "FAILED TO GET RESPONSE LENGTH" );

                if ( length <= 1 )
                {
                    throw std::string( "RESPONSE XML LENGTH IS INVALID" );
                }

                xml = ( char * ) malloc( length );

                mf_check( MFMediaIDResponse_GetAsString( response , xml , length ) , "FAILED TO GET RESPONSE AS STRING" );

                MFMediaIDResponse_Destroy( & response );
                MFMediaID_Destroy( & media_id );

                char * result = parse_response( xml , length - 1 );

                free( xml );

                return result;
            }
            catch( ... )
            {
                if ( media_id )
                {
                    MFMediaID_Destroy( & media_id );
                }

                if ( response )
                {
                    MFMediaIDResponse_Destroy( & response );
                }

                if ( xml )
                {
                    free( xml );
                }

                throw;
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

    char * parse_response( const char * response_body , unsigned long int response_size )
    {
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

        // We have more than []

        if ( json.str().size() > 2 )
        {
            return strdup( json.str().c_str() );
        }

        return 0;
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

    typedef std::string             String;
    typedef std::map<String,String> StringMap;

    StringMap   config;
    SF_INFO     sound_file_info;
    SNDFILE *   sound_file;
    VirtualIO * sound_file_vio;
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

