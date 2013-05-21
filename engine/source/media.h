#ifndef _TRICKPLAY_MEDIA_H
#define _TRICKPLAY_MEDIA_H

#include "app_resource.h"
#include "context.h"
#include "lb.h"

#define MPLOCK Util::GSRMutexLock lock(&mutex)

class Media
{
  public:

    Media() : constructing( false ), loaded_flag( false ), pre_load( false )
            , read_tags( false ), L( NULL ), actor( NULL )//, mute( 0 ), volume( 0.0 )
    {
#ifndef GLIB_VERSION_2_32
        g_static_rec_mutex_init( &mutex );
#else
        g_rec_mutex_init( &mutex );
#endif
    }

    ~Media()
    {
        {
            MPLOCK;
        }
#ifndef GLIB_VERSION_2_32
    g_static_rec_mutex_free( &mutex );
#else
    g_rec_mutex_clear( &mutex );
#endif
    }

    static Media * get( ClutterActor * _actor, lua_State *l );

    bool load_media();

    const StringSet& get_valid_schemes() const { return schemes; }

    // Related to .lb
    bool           constructing;
    bool           loaded_flag;
    bool           pre_load;
    bool           read_tags;
    JSON::Object   tags;

  private:

    static void destroy( Media * instance );
    //int load( const char* uri, const char* extra );

    void loaded();
    void error( int code, const char * message );
    void end_of_stream();

    lua_State     * L;
    ClutterActor  * actor;

    // Related to media file/url

    // Related to mediaplayer status
    //int             mute;
    //double          volume;
    //ClutterMedia  * cm;

#ifndef GLIB_VERSION_2_32
    GStaticRecMutex mutex;
#else
    GRecMutex mutex;
#endif
    StringSet         schemes;
};

#endif // _TRICKPLAY_MEDIA_H