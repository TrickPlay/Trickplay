#ifndef _TRICKPLAY_MEDIA_H
#define _TRICKPLAY_MEDIA_H

#include "lb.h"

class Media
{
  public:
    Media() : constructing( false), loaded_flag( false ), pre_load( false )
            , read_tags( false ), L( NULL ), actor( NULL )//, mute( 0 ), volume( 0.0 )
    {}

    ~Media() {}

    static Media * get( ClutterActor * _actor, lua_State *l );

    bool load_media();

    // Related to .lb
    bool           constructing;
    bool           loaded_flag;
    bool           pre_load;
    bool           read_tags;
    JSON::Object   tags;
  private:

    static void destroy( Media * instance );

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
};

#endif // _TRICKPLAY_MEDIA_H