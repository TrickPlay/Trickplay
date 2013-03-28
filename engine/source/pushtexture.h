#ifndef __TRICKPLAY_PUSHTEXTURE_H__
#define __TRICKPLAY_PUSHTEXTURE_H__

#include "tp-clutter.h"
#include <stdlib.h>
#include "common.h"
#include "app_resource.h"
#include "util.h"

#define TP_COGL_TEXTURE(t) (COGL_TEXTURE(t))
#define TP_CoglTexture CoglTexture *

class PushTexture
{
public:

    // Allows some object to say to a PushTexture, "Ping me whenever you change"

    class PingMe
    {
    public:
        typedef void ( Callback )( PushTexture* instance, void* target );

        PingMe() : instance( NULL ), callback( NULL ), target( NULL ) {}
        ~PingMe();

        // Note: if assign() suceeds, it will immediately ping() this PingMe object using the given callback

        void assign( PushTexture* instance, Callback* callback, void* target, bool preload );

        friend class PushTexture;

    private:
        void ping();

        PushTexture* instance;
        Callback* callback;
        void* target;
    };

    PushTexture() : failed( false ), texture( NULL ), real( false ) {}
    virtual ~PushTexture();

    CoglHandle get_texture();
    void set_texture( CoglHandle texture, bool real, bool trigger );
    void get_dimensions( int* w, int* h );
    void ping_all();
    bool is_real() { return real; }
    bool is_failed() { return failed; }
    void release_texture();

protected:
    virtual void make_texture( bool immediately ) = 0; // Descendent implements for when texture must be created
    virtual void lost_texture() = 0;                   // Descendent implements for when texture is released, ie., there are no more subscribers

    bool failed;
    std::set< PingMe* > pings;

private:
    void subscribe( PingMe* ping, bool preload );
    virtual void unsubscribe( PingMe* ping, bool release_now ) = 0;

    CoglHandle texture;
    bool real;
};

#endif
