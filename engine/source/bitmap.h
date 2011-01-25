#ifndef _TRICKPLAY_BITMAP_H
#define _TRICKPLAY_BITMAP_H

#include "common.h"
#include "images.h"
#include "app.h"

class Bitmap : public RefCounted
{
public:

    Bitmap( lua_State * L , const char * _src , bool _async );

    guint width() const;
    guint height() const;

    bool loaded() const;

    Image * get_image();

    static Image * get_image( lua_State * L , int index );

protected:

    virtual ~Bitmap();

private:

    static void callback( Image * image , gpointer me );

    static void destroy_notify( gpointer me );

    String          src;
    Image *         image;
    LuaStateProxy * lsp;
};


#endif // _TRICKPLAY_BITMAP_H
