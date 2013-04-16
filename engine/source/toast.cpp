
#include "cairo/cairo.h"

#include "trickplay/keys.h"
#include "toast.h"
#include "clutter_util.h"
#include "util.h"
#include "context.h"
#include "user_data.h"

//-----------------------------------------------------------------------------

#define TOAST_ANIMATE_UP_TIME       700
#define TOAST_ANIMATE_UP_MODE       CLUTTER_EASE_IN_CUBIC
#define TOAST_ANIMATE_DOWN_TIME     400
#define TOAST_ANIMATE_DOWN_MODE     CLUTTER_LINEAR
#define TOAST_UP_TIME               5000
#define TOAST_ACTION_KEY            TP_KEY_RED

//-----------------------------------------------------------------------------

#if G_BYTE_ORDER == G_LITTLE_ENDIAN
#define CLUTTER_CAIRO_TEXTURE_PIXEL_FORMAT COGL_PIXEL_FORMAT_BGRA_8888_PRE
#else
#define CLUTTER_CAIRO_TEXTURE_PIXEL_FORMAT COGL_PIXEL_FORMAT_ARGB_8888_PRE
#endif

//=============================================================================
// This is an action that stays up as long as the toast is up. If nothing
// happens, it will simply animate the toast away after its timeout.
// While the toast is up, it listens for a key press. If this key is pressed,
// it calls the application's screen.on_toast callback. If this callback
// exists and returns true, the toast is dismissed quickly.

class ToastUpAction : public Action
{
public:

    ToastUpAction( lua_State* L , Toast* _toast )
        :
        lsp( App::get( L )->ref_lua_state_proxy() ),
        toast( _toast ),
        dismissed( false ),
        key_handler( 0 )
    {
        if ( ClutterActor* stage = toast->context->get_stage() )
        {
            key_handler = g_signal_connect( G_OBJECT( stage ) ,
                    "captured-event" ,
                    ( GCallback ) captured_event ,
                    this );
        }
    }

    virtual ~ToastUpAction()
    {
        lsp->unref();

        disconnect_key_handler();
    }


protected:

    virtual bool run()
    {
        animate_down();

        toast->hide_source = 0;

        return false;
    }

private:

    void disconnect_key_handler()
    {
        if ( ClutterActor* stage = toast->context->get_stage() )
        {
            if ( key_handler && g_signal_handler_is_connected( G_OBJECT( stage ) , key_handler ) )
            {
                g_signal_handler_disconnect( G_OBJECT( stage ) , key_handler );

                key_handler = 0;
            }
        }
    }

    void animate_down( int duration = TOAST_ANIMATE_DOWN_TIME )
    {
        disconnect_key_handler();

        if ( ! dismissed )
        {
            clutter_actor_animate( toast->group ,
                    TOAST_ANIMATE_DOWN_MODE,
                    duration ,
                    "y" , toast->down_y ,
                    "opacity" , 0 ,
                    "signal-swapped-after::completed" , clutter_actor_hide , toast->group ,
                    NULL );

            dismissed = true;
        }
    }

    static gboolean captured_event( ClutterActor* actor , ClutterEvent* event ,  ToastUpAction* me )
    {
        if ( event && event->any.type == CLUTTER_KEY_PRESS && event->key.keyval == TOAST_ACTION_KEY )
        {
            return me->selected() ? TRUE : FALSE;
        }

        return FALSE;
    }

    bool selected()
    {
        if ( lua_State* L = lsp->get_lua_state() )
        {
            if ( UserData::invoke_global_callbacks( L , "screen" , "on_toast" , 0 , 1 ) )
            {
                // If the callback returns true, we hide the toast and disconnect
                // the key handler.

                if ( lua_isboolean( L , -1 ) && lua_toboolean( L , -1 ) )
                {
                    lua_pop( L , 1 );

                    animate_down( TOAST_ANIMATE_DOWN_TIME / 3 );

                    // This eats the key - so no one else will get it

                    return true;
                }
            }
        }

        return false;
    }

    LuaStateProxy* lsp;
    Toast*          toast;
    bool            dismissed;
    gulong          key_handler;
};


//=============================================================================

bool Toast::show( lua_State* L , const char* title , const char* prompt , Image* image )
{
    if ( Toast* toast = Toast::get( App::get( L )->get_context() , true ) )
    {
        return toast->show_internal( L , title , prompt , image );
    }

    return false;
}

//-----------------------------------------------------------------------------

void Toast::hide( TPContext* context )
{
    if ( Toast* toast = Toast::get( context , false ) )
    {
        toast->hide_internal();
    }
}

//-----------------------------------------------------------------------------

Toast* Toast::get( TPContext* context , bool create )
{
    g_assert( context );

    static char key = 0;

    Toast* result = ( Toast* ) context->get_internal( & key );

    if ( ! result && create )
    {
        result = new Toast( context );

        context->add_internal( & key , result , ( GDestroyNotify ) destroy );
    }

    return result;
}

//-----------------------------------------------------------------------------

void Toast::destroy( Toast* me )
{
    delete me;
}

//-----------------------------------------------------------------------------

Toast::Toast( TPContext* c )
    :
    context( c ),
    group( 0 ),
    background( 0 ),
    title( 0 ),
    image( 0 ),
    prompt( 0 ),
    hide_source( 0 )
{
    ClutterScript* script = 0;

    // See if the context has a filename for the toast JSON

    const char* path = context->get( TP_TOAST_JSON_PATH );

    if ( path )
    {
        script = clutter_script_new();

        GError* error = 0;

        clutter_script_load_from_file( script , path , & error );

        if ( error )
        {
            g_warning( "FAILED TO LOAD TOAST UI FROM %s : %s" , path , error->message );

            g_clear_error( & error );

            g_object_unref( script );

            script = 0;
        }
    }

    // We failed to load it from a file, or there is no file. We will
    // use our own default JSON.

    if ( ! script )
    {
        script = clutter_script_new();

        GError* error = 0;

        clutter_script_load_from_data( script , default_toast_json , -1 , & error );

        if ( error )
        {
            g_warning( "FAILED TO LOAD DEFAULT TOAST UI : %s" , error->message );

            g_clear_error( & error );

            g_object_unref( script );

            return;
        }
    }

    // OK, the JSON script for the toast UI has been loaded, we are ready
    // to pluck out the interesting bits.

    g_assert( script );

    FreeLater free_later;

    free_later( script , g_object_unref );

    GObject* go_group = 0;
    GObject* go_background = 0;
    GObject* go_title = 0;
    GObject* go_prompt = 0;
    GObject* go_image = 0;

    if ( 5 != clutter_script_get_objects( script ,
            "group" , & go_group ,
            "background" , & go_background ,
            "title" , & go_title,
            "prompt" , & go_prompt,
            "image" , & go_image ,
            NULL ) )
    {
        g_warning( "TOAST UI IS MISSING SOME NAMED ELEMENTS" );

        return;
    }

    // Make sure they are the right types

    g_assert( CLUTTER_IS_CONTAINER( go_group ) );
    g_assert( CLUTTER_IS_RECTANGLE( go_background ) );
    g_assert( CLUTTER_IS_TEXT( go_title ) );
    g_assert( CLUTTER_IS_TEXT( go_prompt ) );
    g_assert( CLUTTER_IS_TEXTURE( go_image ) );

    // Convert them. We only ref the group because the others
    // should be descendants.

    group = CLUTTER_ACTOR( g_object_ref( go_group ) );
    background = CLUTTER_ACTOR( go_background );
    title = CLUTTER_ACTOR( go_title );
    prompt = CLUTTER_ACTOR( go_prompt );
    image = CLUTTER_ACTOR( go_image );

    // Make sure they all have parents

    g_assert( ! clutter_actor_get_parent( group ) );
    g_assert( clutter_actor_get_parent( background ) );
    g_assert( clutter_actor_get_parent( title ) );
    g_assert( clutter_actor_get_parent( prompt ) );
    g_assert( clutter_actor_get_parent( image ) );

    // Set the name on the group

    clutter_actor_set_name( group , "toast" );

    // Get the stage and its dimensions

    ClutterActor* stage = context->get_stage();

    gfloat stage_width;
    gfloat stage_height;

    clutter_actor_get_size( stage , & stage_width , & stage_height );

    gfloat xs = stage_width / context->get_int( TP_VIRTUAL_WIDTH );
    gfloat ys = stage_height / context->get_int( TP_VIRTUAL_HEIGHT );

    // Set the scale on the group

    clutter_actor_set_scale( group , xs , ys );

    // Set its position

    gfloat group_width;
    gfloat group_height;

    clutter_actor_get_size( group , & group_width , & group_height );

    up_y = stage_height - group_height * xs;
    down_y = stage_height + 1 ;

    replace_background();

    clutter_actor_set_position( group , 0 , down_y );

    clutter_actor_hide( group );

    // Get the default size for the image

    image_size = clutter_actor_get_width( image );
    image_x = clutter_actor_get_x( image );
    image_y = clutter_actor_get_y( image );

    // Add the group to the stage

    clutter_actor_add_child( stage, group );
}

//-----------------------------------------------------------------------------

Toast::~Toast()
{
    hide_internal();

    if ( group )
    {
        g_object_unref( group );
    }
}

//-----------------------------------------------------------------------------

bool Toast::show_internal( lua_State* L , const char* _title , const char* _prompt , Image* _image )
{
    // The toast was never completely created

    if ( ! group )
    {
        return false;
    }

    // A toast is already up - can't have more than one of them

    if ( CLUTTER_ACTOR_IS_VISIBLE( group ) )
    {
        return false;
    }

    // A toast is animating. It should be visible, but just in case

    if ( clutter_actor_get_animation( group ) )
    {
        return false;
    }

    // Populate the toast

    clutter_text_set_markup( CLUTTER_TEXT( title ) , _title );

    clutter_text_set_markup( CLUTTER_TEXT( prompt ) , _prompt );

    set_image( _image );

    // Set initial position and show

    clutter_actor_set_y( group , down_y );

    clutter_actor_set_opacity( group , 0 );

    clutter_actor_set_child_above_sibling( clutter_actor_get_parent( group ), group, NULL );

    clutter_actor_show( group );

    // Start the animation

    clutter_actor_animate( group ,
            TOAST_ANIMATE_UP_MODE ,
            TOAST_ANIMATE_UP_TIME ,
            "y" , up_y ,
            "opacity" , 255 ,
            NULL );

    // Create the action that will deal with it while the toast is up
    hide_source = Action::post( new ToastUpAction( L , this ) , TOAST_ANIMATE_UP_TIME + TOAST_UP_TIME );

    return true;
}


//-----------------------------------------------------------------------------

void Toast::hide_internal()
{
    if ( group )
    {
        clutter_actor_hide( group );
        clutter_actor_set_y( group , down_y );
    }

    if ( hide_source )
    {
        g_source_remove( hide_source );
        hide_source = 0;
    }
}

//-----------------------------------------------------------------------------

void Toast::replace_background()
{
    g_assert( background );

    gfloat w;
    gfloat h;

    clutter_actor_get_size( background , & w , & h );

    cairo_surface_t* surface = cairo_image_surface_create( CAIRO_FORMAT_ARGB32 , w , h );

    cairo_t* cairo = cairo_create( surface );

    cairo_set_line_width( cairo , 4 );

    gfloat x = 2;
    gfloat y = 2;
    gfloat r = 24;
    w -= 4;
    h -= 4;

    cairo_move_to( cairo, x + r, y );
    cairo_line_to( cairo, x + w - r, y );
    cairo_curve_to( cairo, x + w, y, x + w, y, x + w, y + r );
    cairo_line_to( cairo, x + w, y + h - r );
    cairo_curve_to( cairo, x + w, y + h, x + w, y + h, x + w - r, y + h );
    cairo_line_to( cairo, x + r, y + h );
    cairo_curve_to( cairo, x, y + h, x, y + h, x, y + h - r );
    cairo_line_to( cairo, x, y + r );
    cairo_curve_to( cairo, x, y, x, y, x + r, y );

    cairo_pattern_t* pattern = cairo_pattern_create_linear( 0 , 0 , 0 , h );

    cairo_pattern_add_color_stop_rgba( pattern , 0 , 0.5 , 0.5 , 0.5 , 0.80 );
    cairo_pattern_add_color_stop_rgba( pattern , 1 , 0 , 0 , 0 , 0.80 );

    cairo_set_source( cairo , pattern );

    cairo_pattern_destroy( pattern );

    cairo_fill_preserve( cairo );

    cairo_set_operator( cairo , CAIRO_OPERATOR_SOURCE );

    pattern = cairo_pattern_create_linear( 0 , 0 , 0 , h );

    cairo_pattern_add_color_stop_rgba( pattern , 0 , 0.83 , 0.83 , 0.83 , 0.80 );
    cairo_pattern_add_color_stop_rgba( pattern , 1 , 0.32 , 0.32 , 0.32 , 0.80 );

    cairo_set_source( cairo , pattern );

    cairo_pattern_destroy( pattern );

    cairo_stroke( cairo );

    cairo_destroy( cairo );


    ClutterActor* texture = clutter_texture_new();

    CoglHandle cogl_texture = cogl_texture_new_from_data(
            cairo_image_surface_get_width( surface ),
            cairo_image_surface_get_height( surface ),
            COGL_TEXTURE_NONE,
            CLUTTER_CAIRO_TEXTURE_PIXEL_FORMAT,
            COGL_PIXEL_FORMAT_ANY,
            cairo_image_surface_get_stride( surface ),
            cairo_image_surface_get_data( surface ) );

    clutter_texture_set_cogl_texture( CLUTTER_TEXTURE( texture ) , cogl_texture );

    cogl_handle_unref( cogl_texture );

    cairo_surface_destroy( surface );

    clutter_actor_get_position( background , & x , & y );
    clutter_actor_set_position( texture , x , y );

    ClutterActor* parent = clutter_actor_get_parent( background );

    clutter_actor_replace_child( parent, background, texture );

    background = 0;
}

//-----------------------------------------------------------------------------

void Toast::set_image( Image* _image )
{
    if ( ! _image )
    {
        // TODO: Should we move the text over to the left?

        clutter_actor_hide( image );

        return;
    }

    gfloat w = _image->width();
    gfloat h = _image->height();

    if ( w > image_size || h > image_size )
    {
        gfloat scale = std::max( w , h ) / image_size;

        w /= scale;
        h /= scale;
    }

    Images::load_texture( CLUTTER_TEXTURE( image ) , _image );

    clutter_actor_set_size( image , w , h );

    clutter_actor_set_y( image , image_y + image_size - h );

    clutter_actor_set_x( image , image_x + ( ( image_size - w ) / 2 ) );

    clutter_actor_show( image );
}

//-----------------------------------------------------------------------------
// You can put a different one in a file and set TP_TOAST_JSON_PATH
// in the context.

const char* Toast::default_toast_json =

        "["
        "    {"
        "        'id'        : 'group',"
        "        'type'      : 'ClutterGroup',"
        "        'name'      : 'toast',"
        "        'width'     : 797,"
        "        'height'    : 140,"
        "        'children'  :"
        "        ["
        "            {"
        "                'id'            : 'background',"
        "                'type'          : 'ClutterRectangle',"
        "                'x'             : 27,"
        "                'y'             : 0,"
        "                'width'         : 770,"
        "                'height'        : 113,"
        "                'color'         : '#828282cc',"
        "                'border-width'  : 4,"
        "                'border-color'  : '#535353cc'"
        "            }"
        "            ,"
        "            {"
        "                'id'        : 'title',"
        "                'type'      : 'ClutterText',"
        "                'color'     : '#ffffff',"
        "                'font-name' : 'DejaVu Sans bold 25px',"
        "                'ellipsize' : 'end',"
        "                'x'         : 191,"
        "                'y'         : 16,"
        "                'width'     : 579"
        "            }"
        "            ,"
        "            {"
        "                'id'        : 'prompt',"
        "                'type'      : 'ClutterText',"
        "                'color'     : '#ffffff',"
        "                'font-name' : 'DejaVu Sans 24px',"
        "                'ellipsize' : 'end',"
        "                'x'         : 191,"
        "                'y'         : 57,"
        "                'width'     : 579                "
        "            }"
        "            ,"
        "            {"
        "                'id'        : 'image',"
        "                'type'      : 'ClutterTexture',"
        "                'x'         : 37,"
        "                'y'         : -47,"
        "                'width'     : 150,"
        "                'height'    : 150"
        "            }"
        "        ]"
        "    }"
        "]";
