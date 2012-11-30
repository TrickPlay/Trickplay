#ifndef _TRICKPLAY_TOAST_H
#define _TRICKPLAY_TOAST_H

#include "common.h"
#include "images.h"

class Toast
{
public:

    static bool show( lua_State * L , const char * title , const char * prompt , Image * image );

    static void hide( TPContext * context );

private:

    Toast( TPContext * context );

    ~Toast();

    Toast( const Toast & )
    {}

    static Toast * get( TPContext * context , bool create );

    static void destroy( Toast * me );

    bool show_internal( lua_State * L , const char * title , const char * prompt , Image * image );

    void hide_internal();

    void replace_background();

    void set_image( Image * image );

    friend class ToastUpAction;

    TPContext *     context;
    ClutterActor *  group;
    ClutterActor *  background;
    ClutterActor *  title;
    ClutterActor *  image;
    ClutterActor *  prompt;

    gfloat          up_y;
    gfloat          down_y;
    gfloat          image_size;
    gfloat          image_x;
    gfloat          image_y;

    guint           hide_source;

    static const char * default_toast_json;
};

#endif // _TRICKPLAY_TOAST_H
