#ifndef __TRICKPLAY_PUSHTEXTURE_H__
#define __TRICKPLAY_PUSHTEXTURE_H__

#define CLUTTER_VERSION_MIN_REQUIRED CLUTTER_VERSION_CUR_STABLE
#include <clutter/clutter.h>
#include <stdlib.h>
#include "common.h"
#include "app_resource.h"
#include "util.h"

#ifdef CLUTTER_VERSION_1_10
#define TP_COGL_TEXTURE(t) (COGL_TEXTURE(t))
#define TP_CoglTexture CoglTexture *
#else
#define TP_COGL_TEXTURE(t) (t)
#define TP_CoglTexture CoglHandle
#endif

class PushTexture
{
public:

    class ReleaseLater : public Action
    {
        PushTexture * self;

        public: ReleaseLater( PushTexture * self ) : self( self ) {};

        protected: bool run()
        {
            self->release_texture();
            return false;
        }
    };

    class PingAllLater : public Action
    {
        PushTexture * self;

        public: PingAllLater( PushTexture * self ) : self( self ) {};

        protected: bool run()
        {
            self->ping_all();
            return false;
        }
    };

    class PingMe
    {
        public:
            typedef void (Callback)( PushTexture * source, void * target );

            PingMe() : source( NULL ), callback( NULL ), target( NULL ), async( true ) {};
            ~PingMe();

            void set( PushTexture * source, Callback * callback, void * target, bool async );

            friend class PushTexture;

        private:
            void ping();

            PushTexture * source;
            Callback * callback;
            void * target;
            bool async;
    };

    PushTexture() : cache( false ), all_pings_async( false ), texture( NULL ), can_signal( true ) {};
    ~PushTexture();

    CoglHandle get_texture();
    void set_texture( CoglHandle texture );
    void get_dimensions( int * w, int * h );
    void ping_all();
    void ping_all_later() { Action::post( new PingAllLater( this ) ); };

    friend class Subscription;

protected:
    virtual void on_sync_change() = 0;
    virtual void make_texture() = 0;
    virtual void lost_texture() = 0;

    bool cache;
    bool all_pings_async;

private:
    void subscribe( PingMe * ping );
    void unsubscribe( PingMe * ping );
    void release_texture();

    std::set< PingMe * > pings;
    CoglHandle texture;
    bool can_signal;
};

#endif
