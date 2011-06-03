
#include <fstream>
#include <cstdlib>

#include "trickplay/keys.h"

#include "keyboard.h"
#include "toast.h"
#include "clutter_util.h"
#include "util.h"
#include "context.h"
#include "user_data.h"
#include "images.h"
#include "lb.h"

//-----------------------------------------------------------------------------

#define TP_LOG_DOMAIN   "KEYBOARD"
#define TP_LOG_ON       true
#define TP_LOG2_ON      true

#include "log.h"

//=============================================================================

#define KB_UNFOCUSED_OPACITY        100
#define KB_FIELD_SCROLL_DURATION    250

//=============================================================================

bool Keyboard::Form::load_from_lua( lua_State * L , int n )
{
    fields.clear();
    current_field = 0;

    if ( ! lua_istable( L , n ) )
    {
        return false;
    }

    int top = lua_gettop( L );

    try
    {
        for ( int i = 1; ; ++i )
        {
            lua_rawgeti( L , n , i );

            if ( lua_isnil( L , -1 ) )
            {
                break;
            }

            if ( lua_istable( L , -1 ) )
            {
                fields.push_back( Field() );

                Field & field( fields.back() );

                int t = lua_gettop( L );

                //.............................................................
                // id. Required, it must be a string and cannot be empty,
                // since it will be used as the key to the result table.

                lua_getfield( L , t , "id" );
                failif( ! lua_really_isstring( L , -1 ) , "'id' SHOULD BE A STRING" );
                field.id = lua_tostring( L , -1 );
                failif( field.id.empty() , "'id' CANNOT BE EMPTY" );
                lua_pop( L , 1 );

                //.............................................................
                // type. It is optional, defaults to text if it is not present
                // or is something we don't recognize.

                lua_getfield( L , t , "type" );
                if ( lua_really_isstring( L , -1 ) )
                {
                    const char * type = lua_tostring( L , -1 );

                    if ( ! strcmp( type , "list" ) )
                    {
                        field.type = Field::LIST;
                    }
                    else if ( ! strcmp( type , "password" ) )
                    {
                        field.type = Field::PASSWORD;
                    }
                }
                lua_pop( L , 1 );

                //.............................................................
                // caption. Must be a non-empty string.

                lua_getfield( L , t , "caption" );
                failif( ! lua_isstring( L , -1 ) , "'caption' SHOULD BE A STRING" );
                field.caption = lua_tostring( L , -1 );
                failif( field.caption.empty() , "'caption' CANNOT BE EMPTY" );
                lua_pop( L , 1 );

                //.............................................................
                // placeholder. Optional string.

                lua_getfield( L , t , "placeholder" );
                field.placeholder = lb_optstring( L , -1 , "" );
                lua_pop( L , 1 );

                //.............................................................
                // value. Optional string.

                lua_getfield( L , t , "value" );
                field.value = lb_optstring( L , -1 , "" );
                lua_pop( L , 1 );

                //.............................................................
                // required. Optional boolean.

                lua_getfield( L , t , "required" );
                field.required = lb_optbool( L , -1 , false );
                lua_pop( L , 1 );

                //.............................................................

                switch( field.type )
                {
                    case Field::TEXT:
                        break;

                    case Field::LIST:

                    {
                        lua_getfield( L , t , "multiple" );
                        field.multiple = lb_optbool( L , -1 , false );
                        lua_pop( L , 1 );

                        lua_getfield( L , t , "choices" );
                        failif( ! lua_istable( L , -1 ) , "'choices' MUST BE A TABLE" );
                        lua_pushnil( L );
                        while( lua_next( L , -2 ) )
                        {
                            if ( lua_really_isstring( L , -2 ) && lua_isstring( L , -1 ) )
                            {
                                field.choices[ lua_tostring( L , -2 ) ] = lua_tostring( L , -1 );
                            }
                            lua_pop( L , 1 );
                        }
                        lua_pop( L , 1 );
                        failif( field.choices.empty() , "'choices' MUST HAVE AT LEAST ONE VALID ENTRY" );

                        // Make sure that the initial value provided is one of the choices

                        StringMap::const_iterator choice = field.choices.find( field.value );

                        if ( choice  == field.choices.end() )
                        {
                            field.value = "";
                        }
                        else
                        {
                            field.value = choice->second;
                        }

                        break;
                    }

                    case Field::PASSWORD:
                    {
                        lua_getfield( L , t , "password_char" );
                        gunichar pc = g_utf8_get_char_validated( lb_optstring( L , -1 , "\302\267" ) , -1 );
                        if ( pc != ( gunichar ) -1 && pc != ( gunichar ) -2 )
                        {
                            field.password_char = pc;
                        }
                        lua_pop( L , 1 );
                        break;
                    }
                }
            }

            lua_pop( L , 1 );
        }

        if ( fields.empty() )
        {
            tpwarn( "FORM IS EMPTY" );
        }
    }
    catch( const String & e )
    {
        fields.clear();

        tpwarn( "INVALID FORM : %s" , e.c_str() );
    }

    if ( lua_gettop( L ) > top )
    {
        lua_pop( L , lua_gettop( L ) - top );
    }

    return ! fields.empty();
}


//=============================================================================

bool Keyboard::show( lua_State * L , int form_index )
{
    if ( Keyboard * kb = Keyboard::get( App::get( L )->get_context() , true ) )
    {
        return kb->show_internal( L , form_index );
    }
    return false;
}

//-----------------------------------------------------------------------------

void Keyboard::hide( lua_State * L , bool skip_animation )
{
    if ( Keyboard * kb = Keyboard::get( App::get( L )->get_context() , false ) )
    {
        kb->hide_internal( skip_animation );
    }
}

//-----------------------------------------------------------------------------

Keyboard * Keyboard::get( TPContext * context , bool create )
{
    g_assert( context );

    static char key = 0;

    Keyboard * result = ( Keyboard * ) context->get_internal( & key );

    if ( ! result && create )
    {
        result = new Keyboard( context );

        context->add_internal( & key , result , ( GDestroyNotify ) destroy );
    }

    return result;
}

//-----------------------------------------------------------------------------

void Keyboard::destroy( Keyboard * me )
{
    delete me;
}

//-----------------------------------------------------------------------------

bool Keyboard::show_internal( lua_State * L , int form_index )
{
    if ( ! keyboard )
    {
        return false;
    }

    if ( CLUTTER_ACTOR_IS_VISIBLE( keyboard ) )
    {
        return false;
    }

    if ( ! form.load_from_lua( L , form_index ) )
    {
        return false;
    }

    reset();

    //.........................................................................
    // Build the field list UI

    if ( ! build_field_list() )
    {
        return false;
    }

    //.........................................................................
    // Connect the event handler

    connect_event_handler();

    //.........................................................................
    // Position, show and animate the keyboard out

    clutter_actor_set_x( keyboard , x_in );

    clutter_actor_raise_top( keyboard );

    clutter_actor_show( keyboard );

    clutter_actor_animate( keyboard ,
            CLUTTER_EASE_OUT_QUAD , 500 ,
            "x" , x_out ,
            "signal::completed" , on_finished_showing , keyboard ,
            NULL );

    if ( lsp )
    {
        lsp->unref();
        lsp = 0;
    }

    lsp = App::get( L )->ref_lua_state_proxy();

    return true;
}

//-----------------------------------------------------------------------------

void Keyboard::hide_internal( bool skip_animation )
{
    if ( ! keyboard )
    {
        return;
    }

    if ( ! CLUTTER_ACTOR_IS_VISIBLE( keyboard ) )
    {
        return;
    }

    disconnect_event_handler();

    if ( skip_animation )
    {
        on_finished_hiding( NULL , keyboard );
    }
    else
    {
        clutter_actor_animate( keyboard ,
                CLUTTER_EASE_IN_QUAD , 500 ,
                "x" , x_in ,
                "signal::completed" , on_finished_hiding , keyboard ,
                NULL );
    }

    if ( lsp )
    {
        lsp->unref();
        lsp = 0;
    }
 }

//-----------------------------------------------------------------------------

void Keyboard::on_finished_showing( ClutterAnimation * animation , ClutterActor * actor )
{
    tplog2( "SHOWING!" );
}

//-----------------------------------------------------------------------------

void Keyboard::on_finished_hiding( ClutterAnimation * animation , ClutterActor * actor )
{
    tplog2( "HIDDEN" );

    clutter_actor_hide( actor );
}

//-----------------------------------------------------------------------------

void Keyboard::load_static_images( ClutterActor * actor , gchar * assets_path )
{
    if ( CLUTTER_IS_CONTAINER( actor ) )
    {
        clutter_container_foreach( CLUTTER_CONTAINER( actor ) , CLUTTER_CALLBACK( load_static_images ) , assets_path );
    }
    else if ( CLUTTER_IS_TEXTURE( actor ) )
    {
        if ( const gchar * name = clutter_actor_get_name( actor ) )
        {
            gchar * base = g_build_filename( assets_path , name , NULL );

            gchar * filename = g_strdup_printf( "%s.png" , base );

            if ( ! Images::load_texture( CLUTTER_TEXTURE( actor ) , filename ) )
            {
                tpwarn( "MISSING IMAGE '%s'" , filename );
            }

            g_free( filename );
            g_free( base );
        }
    }
}

//-----------------------------------------------------------------------------

bool Keyboard::find_actor( ClutterScript * script , const gchar * id , GType type , ClutterActor * * actor )
{
    g_assert( script );
    g_assert( id );
    g_assert( actor );

    if ( GObject * o = clutter_script_get_object( script , id ) )
    {
        if ( ! CLUTTER_IS_ACTOR( o ) || ! G_TYPE_CHECK_INSTANCE_TYPE( o , type ) )
        {
            tpwarn( "UI ELEMENT '%s' IS OF THE INCORRECT TYPE" , id );
            return false;
        }

        * actor = CLUTTER_ACTOR( o );
        return true;
    }

    tpwarn( "UI DEFINITION MISSING ELEMENT '%s'" , id );

    return false;
}

//-----------------------------------------------------------------------------

Keyboard::Keyboard( TPContext * context )
:
    keyboard( 0 ),
    field_list_container( 0 ),
    bottom_container( 0 ),
    typing_container( 0 ),
    typing_focus( 0 ),
    typing_layout( 0 ),
    list_container( 0 ),
    list_focus( 0 ),
    current_field_caption( 0 ),
    current_field_value( 0 ),

    x_out( 0 ),
    x_in( 0 ),

    current_typing_layout( 0 ),

    event_handler( 0 ),
    focus( 0 ),
    lsp( 0 )
{
    tplog2( "BUILDING" );

    FreeLater free_later;

    // Get the engine's resources directory

    const char * resources_path = context->get( TP_RESOURCES_PATH );
    g_assert( resources_path );

    // Get the keyboard directory inside there

    gchar * keyboard_path = g_build_filename( resources_path , "keyboard" , NULL );
    free_later( keyboard_path );

    // Get the filename for the field list UI definition, and load the contents
    // of the file.

    gchar * fp = g_build_filename( keyboard_path , "field.json" , NULL );
    free_later( fp );
    gchar * contents = 0;
    {
        GError * error = 0;
        if ( ! g_file_get_contents( fp , & contents , NULL , & error ) )
        {
            tpwarn( "FAILED TO LOAD FIELD UI DEFINITION : %s" , error->message );
            tpwarn( "> MAKE SURE THAT '%s' IS SET CORRECTLY" , TP_RESOURCES_PATH );
            g_clear_error( & error );
            return;

        }
    }
    field_script.assign( contents );
    g_free( contents );

    // Get the filename for the keyboard UI definition

    gchar * keyboard_json_path = g_build_filename( keyboard_path , "keyboard.json" , NULL );
    free_later( keyboard_json_path );

    // If it doesn't exist, not much we can do.

    if ( ! g_file_test( keyboard_json_path , G_FILE_TEST_EXISTS ) )
    {
        tpwarn( "UI DEFINITION NOT FOUND AT '%s'" , keyboard_json_path );
        tpwarn( "> MAKE SURE THAT '%s' IS SET CORRECTLY" , TP_RESOURCES_PATH );
        return;
    }

    // OK, let's load it

    ClutterScript * script = clutter_script_new();
    free_later( script , g_object_unref );

    GError * error = 0;

    clutter_script_load_from_file( script , keyboard_json_path , & error );

    if ( error )
    {
        tpwarn( "FAILED TO LOAD UI DEFINITION FROM '%s' : %s" , keyboard_json_path , error->message );
        g_clear_error( & error );
        return;
    }

    // Grab the stuff we need from the script

    bool ok =

            find_actor( script , "keyboard" , CLUTTER_TYPE_GROUP , & keyboard ) &&
            find_actor( script , "field-list-container" , CLUTTER_TYPE_GROUP , & field_list_container ) &&
            find_actor( script , "bottom-container" , CLUTTER_TYPE_GROUP , & bottom_container ) &&
            find_actor( script , "typing-container" , CLUTTER_TYPE_GROUP , & typing_container ) &&
            find_actor( script , "typing-focus" , CLUTTER_TYPE_GROUP , & typing_focus ) &&
            find_actor( script , "typing-layout" , CLUTTER_TYPE_GROUP , & typing_layout ) &&
            find_actor( script , "list-container" , CLUTTER_TYPE_GROUP , & list_container ) &&
            find_actor( script , "list-focus" , CLUTTER_TYPE_GROUP , & list_focus ) &&
            find_actor( script , "current-field-caption" , CLUTTER_TYPE_TEXT , & current_field_caption ) &&
            find_actor( script , "current-field-value" , CLUTTER_TYPE_TEXT , & current_field_value );

    if ( ! ok  )
    {
        keyboard = 0;
        return;
    }

    // Set its name

    clutter_actor_set_name( keyboard , "keyboard" );

    // Get the stage and its dimensions

    ClutterActor * stage = clutter_stage_get_default();

    gfloat stage_width;
    gfloat stage_height;

    clutter_actor_get_size( stage , & stage_width , & stage_height );

    gfloat xs = stage_width / 1920.0;
    gfloat ys = stage_height / 1080.0;

    // Set the scale on the keyboard

    clutter_actor_set_scale( keyboard , xs , ys );

    // Load all the static images

    gchar * keyboard_assets_path = g_build_filename( keyboard_path , "assets" , NULL );
    free_later( keyboard_assets_path );

    assets_path = keyboard_assets_path;

    clutter_container_foreach( CLUTTER_CONTAINER( keyboard ) , CLUTTER_CALLBACK( load_static_images ) , keyboard_assets_path );


    // Get the width of the keyboard

    gfloat w = clutter_actor_get_width( keyboard );

    // Its X position when it is out (visible)

    x_out = stage_width - w * xs;

    // Its X position when it is in (hidden)

    x_in = stage_width;

    clutter_actor_set_x( keyboard , x_out );


    // Get the filename for the layouts file and load the layouts

    gchar * layouts_path = g_build_filename( keyboard_path , "layouts.lua" , NULL );
    free_later( layouts_path );

    if ( ! load_layouts( layouts_path ) )
    {
        keyboard = 0;
        return;
    }

    g_object_ref( keyboard );

    clutter_container_add( CLUTTER_CONTAINER( stage ) , keyboard , NULL );

    clutter_actor_hide( keyboard );

    tplog2( "FINISHED BUILDING" );
}

//-----------------------------------------------------------------------------

Keyboard::~Keyboard()
{
    disconnect_event_handler();

    if ( keyboard )
    {
        g_object_unref( keyboard );
    }

    if ( lsp )
    {
        lsp->unref();
    }
}

//-----------------------------------------------------------------------------

void Keyboard::reset()
{
    clutter_actor_hide_all( field_list_container );

    clutter_actor_hide_all( typing_container );

    clutter_actor_hide_all( list_container );

    clutter_text_set_text( CLUTTER_TEXT( current_field_caption ) , "" );

    clutter_text_set_text( CLUTTER_TEXT( current_field_value ) , "" );

    focus = 0;
}

//-----------------------------------------------------------------------------

void Keyboard::switch_to_typing_layout( size_t layout_index , int mode )
{
    g_assert( mode == 0 || mode == 1 );

    if ( layout_index >= layouts.size() )
    {
        tpwarn( "LAYOUT '%d' NOT FOUND" , layout_index );
        return;
    }

    Layout & layout( layouts[ layout_index ] );

    clutter_actor_hide_all( list_container );

    clutter_actor_show_all( typing_container );
    clutter_actor_hide_all( typing_focus );
    clutter_actor_hide_all( typing_layout );

    clutter_actor_show( typing_focus );
    clutter_actor_show( typing_layout );
    clutter_actor_show( layout.modes[mode].image );

    layout.current_mode = mode;

    current_typing_layout = layout_index;

    Layout::Mode & lm( layout.modes[ mode ] );

    const Layout::Button * button = 0;

    // If something was already focused, see if there is a button in this layout
    // that lies in the same position - so we can focus this thing.

    if ( focus )
    {
        gfloat fx;
        gfloat fy;

        clutter_actor_get_position( focus , & fx , & fy );

        for ( Layout::ButtonVector::const_iterator it = lm.buttons.begin(); it != lm.buttons.end(); ++it )
        {
            if ( it->x == fx && it->y == fy )
            {
                button = & *it;
                break;
            }
        }
    }

    if ( ! button )
    {
        for ( Layout::ButtonVector::const_iterator it = lm.buttons.begin(); it != lm.buttons.end(); ++it )
        {
            if ( it->action == lm.first_focus )
            {
                button = & * it;
                break;
            }
        }
    }

    if ( ! button )
    {
        tpwarn( "DON'T HAVE ANYTHING TO FOCUS!" );
        button = & lm.buttons.front();
    }

    show_focus_ring( typing_focus , button->focus_ring.c_str() , button->x , button->y );
}

//-----------------------------------------------------------------------------

void Keyboard::toggle_layout_shift()
{
    Layout & layout( layouts[ current_typing_layout ] );

    int mode = layout.current_mode == 0 ? 1 : 0;

    switch_to_typing_layout( current_typing_layout , mode );
}

//-----------------------------------------------------------------------------

void Keyboard::show_focus_ring( ClutterActor * container , const char * name , gfloat x , gfloat y )
{
    ClutterActor * ring = clutter_container_find_child_by_name( CLUTTER_CONTAINER( container ) , name );

    if ( ! ring )
    {
        ring = clutter_texture_new();

        gchar * path = g_build_filename( assets_path.c_str() , name , NULL );

        Images::load_texture( CLUTTER_TEXTURE( ring ) , path );

        g_free( path );

        clutter_actor_set_name( ring , name );

        gfloat w;
        gfloat h;

        clutter_actor_get_size( ring , & w , & h );

        clutter_actor_set_anchor_point( ring , w / 2 , h / 2 );

        clutter_container_add_actor( CLUTTER_CONTAINER( container ) , ring );
    }

    clutter_actor_set_position( ring , x , y );

    clutter_actor_show( ring );

    focus = ring;
}

//-----------------------------------------------------------------------------

void Keyboard::load_layout_mode( Layout::Mode & mode , const char * name , JSON::Object & root ) throw (String)
{
    using namespace JSON;

    failif( ! root[ name ].is<Object>() , "INVALID OR MISSING MODE '%s'" , name );

    Object & o( root[ name ].as<Object>() );

    //.........................................................................
    // Get all the button entries for this mode

    failif( ! o[ "layout" ].is<Array>() , "INVALID LAYOUT FOR MODE '%s'" , name );

    Array & a( o[ "layout" ].as<Array>() );

    for ( Array::Vector::iterator it = a.begin(); it != a.end(); ++it )
    {
        failif( ! it->is<Array>() , "LAYOUT MODE ENTRY IS NOT AN ARRAY" );

        Array & e( it->as<Array>() );

        failif( e.size() < 6 , "LAYOUT MODE ENTRY HAS LESS THAN 6 ELEMENTS" );

        mode.buttons.push_back( Layout::Button() );

        Layout::Button & button( mode.buttons.back() );

        button.x = e[ 0 ].as_number();
        button.y = e[ 1 ].as_number();
        button.w = e[ 2 ].as_number();
        button.h = e[ 3 ].as_number();
        button.focus_ring = e[ 4 ].as<String>();
        button.action = e[ 5 ].as<String>();

        if ( e.size() > 6 )
        {
            button.shortcut = e[ 6 ].as<String>();
        }
    }

    //.........................................................................
    // Get the first focus

    mode.first_focus = o[ "first" ].as<String>();

    failif( mode.first_focus.empty() , "INVALID FIRST FOCUS FOR MODE '%s'" );

    //.........................................................................
    // Get the image for this mode

    FreeLater free_later;

    String image_file_name = o[ "image" ].as<String>();

    failif( image_file_name.empty() , "INVALID IMAGE FOR MODE '%s'" , name );

    gchar * file_name = g_build_filename( assets_path.c_str() , image_file_name.c_str() , NULL );
    free_later( file_name );

    ClutterActor * image = clutter_texture_new();

    g_object_ref_sink( image );
    free_later( image , g_object_unref );

    failif( ! Images::load_texture( CLUTTER_TEXTURE( image ) , file_name ) , "FAILED TO LOAD LAYOUT IMAGE '%s'" , file_name );

    clutter_container_add_actor( CLUTTER_CONTAINER( typing_layout ) , image );

    mode.image = image;

}

//-----------------------------------------------------------------------------

void Keyboard::load_layout( JSON::Object & root ) throw (String)
{
    using namespace JSON;

    layouts.push_back( Layout() );

    Layout & layout( layouts.back() );

    failif( ! root[ "name" ].is<String>() , "MISISNG LAYOUT NAME" );

    layout.name = root[ "name" ].as<String>();

    load_layout_mode( layout.modes[0] , "default" , root );

    load_layout_mode( layout.modes[1] , "shift" , root );
}


//-----------------------------------------------------------------------------

bool Keyboard::load_layouts( const char * path )
{
    try
    {
        using namespace JSON;

        lua_State * L = lua_open();

        try
        {
            if ( luaL_dofile( L , path ) )
            {
                throw Util::format( "FAILED TO PARSE LAYOUTS : %s" , lua_tostring( L , -1 ) );
            }

            Value root = to_json( L , 1 );

            failif( ! root.is<Array>() , "INVALID LAYOUT, EXPECTING AN ARRAY OF LAYOUTS" );

            Array & a( root.as<Array>() );

            failif( a.empty() , "MISSING INITIAL LAYOUT" );

            failif( ! a[0].is<Object>() , "INVALID INITIAL LAYOUT, EXPECTING AN OBJECT" );

            load_layout( a[0].as<Object>() );
        }
        catch( ... )
        {
            lua_close( L );
            throw;
        }

        lua_close( L );

        return true;
    }
    catch( const String & e )
    {
        layouts.clear();

        clutter_group_remove_all( CLUTTER_GROUP( typing_layout ) );

        tpwarn( "%s" , e.c_str() );
        return false;
    }
}

//-----------------------------------------------------------------------------

void Keyboard::connect_event_handler()
{
    disconnect_event_handler();

    if ( ClutterActor * stage = clutter_stage_get_default() )
    {
        event_handler = g_signal_connect( G_OBJECT( stage  ) , "captured-event" , ( GCallback ) captured_event , this );
    }
}

//-----------------------------------------------------------------------------

void Keyboard::disconnect_event_handler()
{
    if ( ClutterActor * stage = clutter_stage_get_default() )
    {
        if ( event_handler && g_signal_handler_is_connected( G_OBJECT( stage ) , event_handler ) )
        {
            g_signal_handler_disconnect( G_OBJECT( stage ) , event_handler );

            event_handler = 0;
        }
    }
}

//-----------------------------------------------------------------------------

gboolean Keyboard::captured_event( ClutterActor * actor , ClutterEvent * event , Keyboard * me )
{
    return me->on_event( actor , event );
}

//-----------------------------------------------------------------------------

gboolean Keyboard::on_event( ClutterActor * actor , ClutterEvent * event )
{
    if ( event->any.flags & CLUTTER_EVENT_FLAG_SYNTHETIC )
    {
        if ( event->any.type == CLUTTER_KEY_PRESS )
        {
            const Layout::Button * button = 0;

            switch ( event->key.keyval )
            {
                case TP_KEY_RED:

                    if ( form.get_field().type == Form::Field::LIST )
                    {

                    }
                    else
                    {
                        button = layouts[ current_typing_layout ].get_mode().get_button_for_shortcut( "R" );
                    }
                    break;

                case TP_KEY_GREEN:

                    if ( form.get_field().type == Form::Field::LIST )
                    {

                    }
                    else
                    {
                        button = layouts[ current_typing_layout ].get_mode().get_button_for_shortcut( "G" );
                    }
                    break;

                case TP_KEY_YELLOW:

                    if ( form.get_field().type == Form::Field::LIST )
                    {

                    }
                    else
                    {
                        button = layouts[ current_typing_layout ].get_mode().get_button_for_shortcut( "Y" );
                    }
                    break;

                case TP_KEY_BLUE:

                    if ( form.get_field().type == Form::Field::LIST )
                    {

                    }
                    else
                    {
                        button = layouts[ current_typing_layout ].get_mode().get_button_for_shortcut( "B" );
                    }
                    break;

                case TP_KEY_UP:
                case TP_KEY_DOWN:
                case TP_KEY_LEFT:
                case TP_KEY_RIGHT:

                    if ( form.get_field().type == Form::Field::LIST )
                    {

                    }
                    else
                    {
                        typing_spatial_navigation( event->key.keyval );
                    }
                    break;


                case TP_KEY_OK:

                    if ( form.get_field().type == Form::Field::LIST )
                    {

                    }
                    else
                    {
                        button = get_focused_button();
                    }
                    break;
            }

            if ( button )
            {
                typing_action( button );
            }

            return TRUE;
        }
    }

    return FALSE;
}

//-----------------------------------------------------------------------------

bool Keyboard::build_field_list()
{
    //.........................................................................
    // See how many fields we already have in the field list container

    int existing_fields = clutter_group_get_n_children( CLUTTER_GROUP( field_list_container ) );

    int form_fields = form.fields.size();

    //.........................................................................
    // If the form has more than that, we need to build some new ones

    if ( form_fields > existing_fields )
    {
        int top = 0;

        //.....................................................................
        // If we have created some already, figure out the top coordinate for
        // the new ones.

        if ( existing_fields > 0 )
        {
            ClutterActor * field = clutter_group_get_nth_child( CLUTTER_GROUP( field_list_container ) , 0 );

            top = existing_fields * ( clutter_actor_get_y( field ) + clutter_actor_get_height( field ) );
        }

        for ( int i = 0; i < form_fields - existing_fields; ++i )
        {
            FreeLater free_later;

            ClutterScript * script = clutter_script_new();

            free_later( script , g_object_unref );

            GError * error = 0;

            clutter_script_load_from_data( script , field_script.c_str() , -1 , & error );

            if ( error )
            {
                tpwarn( "FAILED TO PARSE FIELD LIST UI DEFINITION : %s" , error->message );
                g_clear_error( & error );
                return false;
            }

            ClutterActor * group = 0;

            if ( ! find_actor( script , "field" , CLUTTER_TYPE_GROUP , & group ) )
            {
                tpwarn( "FAILED TO FIND 'field' GROUP IN FIELD LIST UI DEFINITION" );
                return false;
            }

            //.................................................................
            // The first time around, we make sure all the children we want are there

            if ( i == 0 and existing_fields == 0 )
            {
                if ( ! clutter_container_find_child_by_name( CLUTTER_CONTAINER( group ) , "caption" ) )
                {
                    tpwarn( "FAILED TO FIND 'caption' IN FIELD LIST UI DEFINITION" );
                    return false;
                }

                if ( ! clutter_container_find_child_by_name( CLUTTER_CONTAINER( group ) , "value" ) )
                {
                    tpwarn( "FAILED TO FIND 'value' IN FIELD LIST UI DEFINITION" );
                    return false;
                }
            }

            clutter_container_foreach( CLUTTER_CONTAINER( group ) , CLUTTER_CALLBACK( load_static_images ) , ( gpointer ) assets_path.c_str() );

            clutter_container_add_actor( CLUTTER_CONTAINER( field_list_container ) , group );

            gfloat y = clutter_actor_get_y( group );

            clutter_actor_set_y( group , y + top );

            top += y + clutter_actor_get_height( group );
        }
    }

    //.........................................................................
    // Hide everything

    clutter_actor_hide_all( field_list_container );

    //.........................................................................
    // Now, set-up each field

    for ( int i = 0; i < form_fields; ++i )
    {
        const Form::Field & ff( form.fields[ i ] );

        ClutterActor * field = clutter_group_get_nth_child( CLUTTER_GROUP( field_list_container ) , i );

        g_assert( field );

        //.....................................................................
        // Set the field caption

        ClutterActor * caption = clutter_container_find_child_by_name( CLUTTER_CONTAINER( field ) , "caption" );

        g_assert( caption );

        clutter_text_set_text( CLUTTER_TEXT( caption ) , ff.caption.c_str() );

        //.....................................................................
        // Set the value

        ClutterActor * value = clutter_container_find_child_by_name( CLUTTER_CONTAINER( field ) , "value" );

        g_assert( value );

        clutter_text_set_text( CLUTTER_TEXT( value ) , ff.value.c_str() );

        //.....................................................................
        // The password character

        if ( ff.type != Form::Field::PASSWORD )
        {
            clutter_text_set_password_char( CLUTTER_TEXT( value ) , 0 );
        }
        else
        {
            clutter_text_set_password_char( CLUTTER_TEXT( value ) , ff.password_char );
        }

        //.....................................................................
        // TODO: mark it as required or not required

        //.....................................................................
        // Change their opacity to show them as either focused or not

        clutter_actor_set_opacity( field , i == 0 ? 255 : KB_UNFOCUSED_OPACITY );

        //.....................................................................
        // Show the field

        clutter_actor_show( field );
    }

    //.....................................................................
    // Show the whole container

    clutter_actor_show( field_list_container );

    //.....................................................................
    // Make sure the container is at the top

    clutter_actor_set_y( field_list_container , 0 );

    //.....................................................................

    switch_to_field( 0 );

    return true;
}

//-----------------------------------------------------------------------------

void Keyboard::switch_to_field( size_t field_index )
{
    size_t nfields = form.fields.size();

    if ( field_index >= nfields )
    {
        return;
    }

    g_assert( nfields > 0 );

    // Make sure the container has the right number of fields

    g_assert( clutter_group_get_n_children( CLUTTER_GROUP( field_list_container ) ) >= int( nfields ) );

    // Get the first field, so we can calculate the height of all fields

    ClutterActor * first_field = clutter_group_get_nth_child( CLUTTER_GROUP( field_list_container ) , 0 );

    g_assert( first_field );

    // The height of each field

    gfloat h = clutter_actor_get_y( first_field ) + clutter_actor_get_height( first_field );

    // The y position of the desired field

    gfloat y = h * field_index;

    // The height of the scroll box

    gfloat sh = clutter_actor_get_height( clutter_actor_get_parent( field_list_container ) );

    gfloat cy = clutter_actor_get_y( field_list_container );

    if ( y >= abs( cy ) + sh )
    {
        y = sh - ( y + h );

        clutter_actor_animate( field_list_container , CLUTTER_EASE_OUT_QUAD , KB_FIELD_SCROLL_DURATION , "y" , y , NULL );
    }
    else if ( y < abs( cy ) )
    {
        y = -y;

        clutter_actor_animate( field_list_container , CLUTTER_EASE_OUT_QUAD , KB_FIELD_SCROLL_DURATION , "y" , y , NULL );
    }

    for ( size_t i = 0; i < nfields; ++i )
    {
        clutter_actor_set_opacity( clutter_group_get_nth_child( CLUTTER_GROUP( field_list_container ) , i ) , i == field_index ? 255 : KB_UNFOCUSED_OPACITY );
    }

    form.current_field = field_index;

    Form::Field & field( form.get_field() );

    clutter_text_set_text( CLUTTER_TEXT( current_field_caption ) , field.caption.c_str() );

    if ( field.type == Form::Field::PASSWORD )
    {
        clutter_text_set_password_char( CLUTTER_TEXT( current_field_value ) , field.password_char );
    }
    else
    {
        clutter_text_set_password_char( CLUTTER_TEXT( current_field_value ) , 0 );
    }

    if ( ClutterActor * field_count = clutter_container_find_child_by_name( CLUTTER_CONTAINER( keyboard ) , "field-count" ) )
    {
        String count( Util::format( "%u/%u" , field_index + 1 , form.fields.size() ) );
        clutter_text_set_text( CLUTTER_TEXT( field_count ) , count.c_str() );
    }

    update_field_value();

    //-------------------------------------------------------------------------
    // Now, prepare the keyboard for this field



    if ( field.type == Form::Field::LIST )
    {

    }
    else
    {
        switch_to_typing_layout( 0 );
    }
}

//-----------------------------------------------------------------------------

void Keyboard::move_to_previous_field()
{
    if ( form.current_field > 0 )
    {
        switch_to_field( form.current_field - 1 );
    }
}

//-----------------------------------------------------------------------------

void Keyboard::move_to_next_field()
{
    if ( form.current_field < form.fields.size() - 1 )
    {
        switch_to_field( form.current_field + 1 );
    }
}

//-----------------------------------------------------------------------------

static inline gfloat rough_distance( gfloat x1 , gfloat y1 , gfloat x2 , gfloat y2 )
{
    return ( ( x2 - x1 ) * ( x2 - x1 ) ) + ( ( y2 - y1 ) * ( y2 - y1 ) );
}

//-----------------------------------------------------------------------------

void Keyboard::typing_spatial_navigation( unsigned int dir )
{
    if ( ! focus )
    {
        return;
    }

    // Get the center of the current focus ring

    gfloat fx;
    gfloat fy;

    clutter_actor_get_position( focus , & fx , & fy );

    // Get its size

    gfloat fw;
    gfloat fh;

    clutter_actor_get_size( focus , & fw , &fh );

    // Now, make a rectangle for it

    Rect fr( fx , fy , fw , fh );
    Rect fr2;

    // Expand the rectangle in the given direction

    switch( dir )
    {
        case TP_KEY_UP:
            fr2.set( 0 , 0 , 1920 , fr.y1 );
            fr.y1 = 0;
            break;

        case TP_KEY_DOWN:
            fr2.set( 0 , fr.y2 , 1920 , 1080 );
            fr.y2 = 1080;
            break;

        case TP_KEY_LEFT:
            fr2.set( 0 , 0 , fr.x1 , 1080 );
            fr.x1 = 0;
            break;

        case TP_KEY_RIGHT:
            fr2.set( fr.x2 , 0 , 1920 , 1080 );
            fr.x2 = 1920;
            break;

        default : g_assert( false );
    }

    // Get the current layout mode

    const Layout::Mode & mode( layouts[ current_typing_layout ].get_mode() );

    // To save the closest one

    const Layout::Button * closest_button_by_dir = 0;
    gfloat closest_button_by_dir_distance = -1;

    const Layout::Button * closest_button = 0;
    gfloat closest_button_distance = -1;

    // Iterate over all the buttons in the layout

    for ( Layout::ButtonVector::const_iterator it = mode.buttons.begin(); it != mode.buttons.end(); ++it )
    {
        // Skip the currently focused one

        if ( it->x == fx && it->y == fy )
        {
            continue;
        }

        // Rough distance from my center to this button's center

        gfloat d = rough_distance( it->x , it->y , fx , fy );

        // See if this button intersects my direction rectangle

        if ( fr.intersect( Rect( it->x , it->y , it->w , it->h ) ) )
        {
            if ( closest_button_by_dir_distance < 0 || d < closest_button_by_dir_distance )
            {
                closest_button_by_dir = & *it;
                closest_button_by_dir_distance = d;
            }
        }
        else if ( fr2.contains( it->x , it->y ) )
        {
            if ( closest_button_distance < 0 || d < closest_button_distance )
            {
                closest_button = & * it;
                closest_button_distance = d;
            }
        }
    }

    const Layout::Button * button = closest_button_by_dir ? closest_button_by_dir : closest_button;

    if ( button )
    {
        clutter_actor_hide( focus );
        show_focus_ring( typing_focus , button->focus_ring.c_str() , button->x , button->y );
    }
}

//-----------------------------------------------------------------------------

void Keyboard::typing_action( const Layout::Button * button )
{
    g_assert( button );

    if ( button->action == "OSK_PREVIOUS" )
    {
        move_to_previous_field();
    }
    else if ( button->action == "OSK_NEXT" )
    {
        move_to_next_field();
    }
    else if ( button->action == "OSK_SHIFT" )
    {
        toggle_layout_shift();
    }
    else if ( button->action == "OSK_BACKSPACE" )
    {
        Form::Field & field( form.get_field() );

        if ( ! field.value.empty() )
        {
            gchar * s = g_strdup( field.value.c_str() );

            gchar * p = g_utf8_find_prev_char( s , s + strlen( s ) );

            if ( p )
            {
                * p = 0;
                field.value = s;
                update_field_value();
            }

            g_free( s );
        }
    }
    else if ( button->action == "OSK_CANCEL" )
    {
        if ( lsp )
        {
            if ( lua_State * L = lsp->get_lua_state() )
            {
                UserData::invoke_global_callback( L , "keyboard" , "on_cancel" , 0 , 0 );
            }
        }

        hide_internal( false );
    }
    else if ( button->action == "OSK_SUBMIT" )
    {
        // TODO: validate required fields

        if ( lsp )
        {
            if ( lua_State * L = lsp->get_lua_state() )
            {
                lua_newtable( L );

                for ( Form::FieldVector::const_iterator it = form.fields.begin(); it != form.fields.end(); ++it )
                {
                    lua_pushstring( L , it->id.c_str() );
                    lua_pushstring( L , it->value.c_str() );
                    lua_rawset( L , -3 );
                }

                UserData::invoke_global_callback( L , "keyboard" , "on_submit" , 1 , 0 );
            }
        }

        hide_internal( false );
    }
    else
    {
        Form::Field & field( form.get_field() );

        field.value += button->action;

        update_field_value();

        // To unshift

        switch_to_typing_layout( current_typing_layout );
    }
}

//-----------------------------------------------------------------------------

void Keyboard::update_field_value()
{
    const Form::Field & field( form.get_field() );

    ClutterActor * ff = clutter_group_get_nth_child( CLUTTER_GROUP( field_list_container ) , form.current_field );

    g_assert( ff );

    clutter_text_set_text( CLUTTER_TEXT( clutter_container_find_child_by_name( CLUTTER_CONTAINER( ff ) , "value" ) ) , field.value.c_str() );

    if ( ClutterActor * placeholder = clutter_container_find_child_by_name( CLUTTER_CONTAINER( keyboard ) , "current-field-placeholder" ) )
    {
        if ( field.value.empty() && ! field.placeholder.empty() )
        {
            clutter_text_set_text( CLUTTER_TEXT( placeholder ) , field.placeholder.c_str() );
            clutter_actor_show( placeholder );
        }
        else
        {
            clutter_actor_hide( placeholder );
        }
    }


    clutter_text_set_text( CLUTTER_TEXT( current_field_value ) , form.get_field().value.c_str() );
}

//-----------------------------------------------------------------------------

const Keyboard::Layout::Button * Keyboard::get_focused_button()
{
    if ( ! focus )
    {
        return 0;
    }

    if ( form.get_field().type == Form::Field::LIST )
    {
        return 0;
    }

    gfloat x;
    gfloat y;

    clutter_actor_get_position( focus , & x , & y );

    return layouts[ current_typing_layout ].get_mode().get_button_at( x , y );
}
