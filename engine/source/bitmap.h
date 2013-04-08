#ifndef _TRICKPLAY_BITMAP_H
#define _TRICKPLAY_BITMAP_H

#include "common.h"
#include "images.h"
#include "app.h"

class Bitmap : public RefCounted
{
public:

    Bitmap( lua_State* L , const char* _src , bool _async , bool read_tags );

    static Bitmap* get( lua_State* L , int index );

    guint width() const;
    guint height() const;
    guint depth() const;

    bool loaded() const;

    Image* get_image();

    static Image* get_image( lua_State* L , int index );

    // Bitmap takes ownership of the image

    void set_image( Image* image );

protected:

    virtual ~Bitmap();

private:

    static void callback( Image* image , gpointer me );

    static void destroy_notify( gpointer me );

    String          src;
    Image*          image;
    LuaStateProxy* lsp;
};


#endif // _TRICKPLAY_BITMAP_H
