#ifndef __TRICKPLAY_PUSHTEXTURE_H__
#define __TRICKPLAY_PUSHTEXTURE_H__

#include "tp-clutter.h"
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

    // When the last subscriber is lost, this Action is posted
    // If the texture still has no subscribers at the next idle point, it releases the texture

    class ReleaseLater : public Action
    {
        PushTexture * self;

        public: ReleaseLater( PushTexture * s ) : self( s ) {};

        protected: bool run()
        {
            self->release_texture();
            return false;
        }
    };
    
    // When posted, this Action will ping all subscribers at the next idle point

    class PingAllLater : public Action
    {
        PushTexture * self;

        public: PingAllLater( PushTexture * s ) : self( s ) {};

        protected: bool run()
        {
            self->ping_all();
            return false;
        }
    };

    // Allows some object to say to a PushTexture, "Ping me whenever you change"

    class PingMe
    {
        public:
            typedef void (Callback)( PushTexture * instance, void * target );

            PingMe() : instance( NULL ), callback( NULL ), target( NULL ) {};
            ~PingMe();

            // Note: if assign() suceeds, it will immediately ping() this PingMe object using the given callback

            void assign( PushTexture * instance, Callback * callback, void * target, bool preload );

            friend class PushTexture;

        private:
            void ping();

            PushTexture * instance;
            Callback * callback;
            void * target;
    };

    PushTexture() : cache( false ), failed( false ), can_signal( true ), texture( NULL ), real( false ) {};
    virtual ~PushTexture();

    CoglHandle get_texture();
    void set_texture( CoglHandle texture, bool real );
    void get_dimensions( int * w, int * h );
    void ping_all();
    void ping_all_later() { Action::post( new PingAllLater( this ) ); };
    bool is_real() { return real; };
    bool is_failed() { return failed; };

protected:
    virtual void make_texture( bool immediately ) = 0; // Descendent implements for when texture must be created
    virtual void lost_texture() = 0;                   // Descendent implements for when texture is released, ie., there are no more subscribers
    void release_texture();

    bool cache; // if true, prevents texture from being released
    bool failed;
    std::set< PingMe * > pings;
    bool can_signal;

private:
    void subscribe( PingMe * ping, bool preload );
    virtual void unsubscribe( PingMe * ping, bool release_now ) = 0;

    CoglHandle texture;
    bool real;
};

#endif
