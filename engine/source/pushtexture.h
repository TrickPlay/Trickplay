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

        void assign( PushTexture* instance, Callback* callback, void* target, bool immediately );

        friend class PushTexture;

    private:
        void ping();

        PushTexture* instance;
        Callback* callback;
        void* target;
    };

    PushTexture() : texture( NULL ) {}
    virtual ~PushTexture();

    CoglHandle get_texture();
    void set_texture( CoglHandle texture, bool trigger );
    void get_dimensions( int* w, int* h );
    void ping_all();
    void release_texture();

protected:
    virtual void make_texture( bool immediately ) = 0; // Descendent implements for when texture must be created
    virtual void lost_texture() = 0;                   // Descendent implements for when texture is released, ie., there are no more subscribers

    std::set< PingMe* > pings;

private:
    void subscribe( PingMe* ping, bool immediately );
    virtual void unsubscribe( PingMe* ping, bool release_now ) = 0;

    CoglHandle texture;
};

#endif
