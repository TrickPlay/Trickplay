
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
#define KB_LIST_SCROLL_DURATION     250

//=============================================================================
// The Layout structure

struct Layout
{
    struct Button
    {
        gfloat  x;
        gfloat  y;
        gfloat  w;
        gfloat  h;
        String  focus_ring;
        String  action;
        String  shortcut;
        String  flasher;
    };

    typedef std::vector< Button > ButtonVector;

    struct Mode
    {
        Mode() : image( 0 ) {}

        const Button * get_button_for_shortcut( const char * shortcut ) const
        {
            for ( ButtonVector::const_iterator it = buttons.begin(); it != buttons.end(); ++it )
            {
                if ( it->shortcut == shortcut )
                {
                    return & * it;
                }
            }
            return 0;
        }

        const Button * get_button_for_action( const String & action ) const
        {
            for ( ButtonVector::const_iterator it = buttons.begin(); it != buttons.end(); ++it )
            {
                if ( it->action == action )
                {
                    return & * it;
                }
            }
            return 0;
        }

        const Button * get_first_focus() const
        {
            return get_button_for_action( first_focus );
        }

        const Button * get_button_at( gfloat x , gfloat y ) const
        {
            for ( ButtonVector::const_iterator it = buttons.begin(); it != buttons.end(); ++it )
            {
                if ( it->x == x && it->y == y )
                {
                    return & * it;
                }
            }
            return 0;
        }

        const Button * get_button_at( ClutterActor * focus ) const
        {
            if ( ! focus )
            {
                return 0;
            }

            gfloat x;
            gfloat y;

            clutter_actor_get_position( focus , & x , & y );

            return get_button_at( x , y );
        }

        ClutterActor *  image;
        String          first_focus;
        ButtonVector    buttons;
    };

    Layout() : current_mode( 0 ) {}

    const Mode & get_mode() const
    {
        return modes[ current_mode ];
    }

    const Mode & toggle_mode()
    {
        current_mode = current_mode == 1 ? 0 : 1;
        return get_mode();
    }

    const Mode & reset_mode()
    {
        current_mode = 0;
        return get_mode();
    }

    bool load( const char * path , const char * assets_path , ClutterActor * container )
    {
        g_assert( path );
        g_assert( assets_path );
        g_assert( container );

        try
        {
            name.clear();
            modes[0] = Mode();
            modes[1] = Mode();
            current_mode = 0;

            using namespace JSON;

            lua_State * L = luaL_newstate();

            try
            {
                if ( luaL_dofile( L , path ) )
                {
                    throw Util::format( "FAILED TO PARSE LAYOUTS : %s" , lua_tostring( L , -1 ) );
                }

                Value root = to_json( L , 1 );

                failif( ! root.is<Object>() , "INVALID LAYOUT, EXPECTING AN OBJECT" );

                Object & o( root.as<Object>() );

                failif( ! o[ "name" ].is<String>() , "MISISNG LAYOUT NAME" );

                name = o[ "name" ].as<String>();

                failif( ! o[ "default" ].is<Object>() , "INVALID DEFAULT LAYOUT" );

                load_mode( modes[0] , o[ "default" ].as<Object>() , assets_path , container );

                if ( o.has( "shift" ) )
                {
                    failif( ! o[ "shift" ].is<Object>() , "INVALID SHIFT LAYOUT" );

                    load_mode( modes[1] , o[ "shift" ].as<Object>() , assets_path , container );
                }
                else
                {
                    modes[ 1 ] = modes[ 0 ];
                }
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
            tpwarn( "%s" , e.c_str() );
            return false;
        }
    }

    String  name;
    Mode    modes[2];
    int     current_mode;

private:

    void load_mode( Mode & mode , JSON::Object & root , const char * assets_path , ClutterActor * container ) throw (String)
    {
        using namespace JSON;

        //.........................................................................
        // Get all the button entries for this mode

        failif( ! root[ "layout" ].is<Array>() , "INVALID LAYOUT" );

        Array & a( root[ "layout" ].as<Array>() );

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

                if ( e.size() > 7 )
                {
                    button.flasher = e[ 7 ].as<String>();
                }
            }
        }

        //.........................................................................
        // Get the first focus

        mode.first_focus = root[ "first" ].as<String>();

        failif( mode.first_focus.empty() , "INVALID FIRST FOCUS" );

        //.........................................................................
        // Get the image for this mode

        FreeLater free_later;

        String image_file_name = root[ "image" ].as<String>();

        failif( image_file_name.empty() , "INVALID IMAGE LAYOUT IMAGE" );

        gchar * file_name = g_build_filename( assets_path , image_file_name.c_str() , NULL );
        free_later( file_name );

        ClutterActor * image = clutter_texture_new();

        g_object_ref_sink( image );
        free_later( image , g_object_unref );

        failif( ! Images::load_texture( CLUTTER_TEXTURE( image ) , file_name ) , "FAILED TO LOAD LAYOUT IMAGE '%s'" , file_name );

        clutter_actor_add_child( container, image );

        mode.image = image;
    }
};

//=============================================================================
// Navigation

struct Rect
{
    Rect()
    :
        x1( 0 ),
        y1( 0 ),
        x2( 0 ),
        y2( 0 )
    {}

    Rect( gfloat cx , gfloat cy , gfloat w , gfloat h )
    :
        x1( cx - w / 2 ),
        y1( cy - h / 2 ),
        x2( cx + w / 2 ),
        y2( cy + h / 2 )
    {}

    inline void set( gfloat _x1 , gfloat _y1 , gfloat _x2 , gfloat _y2 )
    {
        x1 = _x1;
        y1 = _y1;
        x2 = _x2;
        y2 = _y2;
    }

    inline bool intersect( const Rect & b )
    {
        return ! ( b.x1 > x2 || b.x2 < x1 || b.y1 > y2 || b.y2 < y1 );
    }

    inline bool contains( gfloat x , gfloat y )
    {
        return ( x >= x1 && x <= x2 && y >= y1 && y <= y2 );
    }

    gfloat x1;
    gfloat y1;
    gfloat x2;
    gfloat y2;
};

//=============================================================================

class KeyboardHandler
{
public:

    KeyboardHandler( Keyboard * keyboard )
    :
        kb( keyboard )
    {}

    virtual ~KeyboardHandler()
    {}

    virtual bool ok() const = 0;

    virtual void hide()
    {
        clutter_actor_hide( get_container() );
    }

    virtual void show_for_field( const Keyboard::Form::Field & field ) = 0;

    virtual void ensure_focus() = 0;

    virtual bool on_event( ClutterEvent * event ) = 0;

protected:

    virtual ClutterActor * get_container() = 0;

    void ensure_focus( const Layout::Mode & mode , ClutterActor * focus_container )
    {
        const Layout::Button * button = 0;

        // If something was already focused, see if there is a button in this layout
        // that lies in the same position - so we can focus this thing.

        button = mode.get_button_at( kb->focus );

        if ( ! button )
        {
            button = mode.get_first_focus();
        }

        if ( ! button )
        {
            tpwarn( "DON'T HAVE ANYTHING TO FOCUS!" );

            button = & mode.buttons.front();
        }

        kb->show_focus_ring( focus_container , button->focus_ring.c_str() , button->x , button->y );
    }

    bool do_event_shortcut( ClutterEvent * event , const Layout::Mode & mode , Layout::Button const * * button )
    {
        if ( event->any.type == CLUTTER_KEY_PRESS )
        {
            bool direct_press = false;

            switch( event->key.keyval )
            {
                case TP_KEY_RED:
                    * button = mode.get_button_for_shortcut( "R" );
                    break;
                case TP_KEY_GREEN:
                    * button = mode.get_button_for_shortcut( "G" );
                    break;
                case TP_KEY_YELLOW:
                    * button = mode.get_button_for_shortcut( "Y" );
                    break;
                case TP_KEY_BLUE:
                    * button = mode.get_button_for_shortcut( "B" );
                    break;
                case TP_KEY_OK:
                    * button = mode.get_button_at( kb->focus );
                    direct_press = true;
                    break;
            }

            if ( * button )
            {
                const String & action( ( * button )->action );

                if ( action == "OSK_PREVIOUS" )
                {
                    kb->move_to_previous_field();
                    if ( direct_press )
                    {
                        kb->flash_focus();
                    }
                    else
                    {
                        kb->flash_button( (*button)->flasher.c_str() , (*button)->x , (*button)->y );
                    }
                    return true;
                }

                if ( action == "OSK_NEXT" )
                {
                    kb->move_to_next_field();
                    if ( direct_press )
                    {
                        kb->flash_focus();
                    }
                    else
                    {
                        kb->flash_button( (*button)->flasher.c_str() , (*button)->x , (*button)->y );
                    }
                    return true;
                }

                if ( action == "OSK_CANCEL" )
                {
                    kb->cancel();
                    if ( direct_press )
                    {
                        kb->flash_focus();
                    }
                    return true;
                }

                if ( action == "OSK_SUBMIT" )
                {
                    kb->submit();
                    if ( direct_press )
                    {
                        kb->flash_focus();
                    }
                    return true;
                }
            }
        }
        return false;
    }

    //-----------------------------------------------------------------------------

    void show_focus_ring( ClutterActor * focus_container , const Layout::Button * button )
    {
        g_assert( focus_container );

        if ( button )
        {
            kb->show_focus_ring( focus_container , button->focus_ring.c_str() , button->x , button->y );
        }
    }

    //-----------------------------------------------------------------------------

    static inline gfloat rough_distance( gfloat x1 , gfloat y1 , gfloat x2 , gfloat y2 )
    {
        return ( ( x2 - x1 ) * ( x2 - x1 ) ) + ( ( y2 - y1 ) * ( y2 - y1 ) );
    }

    //-----------------------------------------------------------------------------

    const Layout::Button * get_spatial_navigation_target( ClutterEvent * event , const Layout::Mode & mode )
    {
        if ( ! kb->focus )
        {
            return 0;
        }

        unsigned int dir = 0;

        if ( event->any.type == CLUTTER_KEY_PRESS )
        {
            switch( event->key.keyval )
            {
                case TP_KEY_UP:
                case TP_KEY_DOWN:
                case TP_KEY_LEFT:
                case TP_KEY_RIGHT:
                    dir = event->key.keyval;
                    break;
            }
        }

        if ( ! dir )
        {
            return 0;
        }

        // Get the center of the current focus ring

        gfloat fx;
        gfloat fy;

        clutter_actor_get_position( kb->focus , & fx , & fy );

        // Get its size

        gfloat fw;
        gfloat fh;

        clutter_actor_get_size( kb->focus , & fw , &fh );

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

        return closest_button_by_dir ? closest_button_by_dir : closest_button;
    }

    Keyboard * kb;
};

//=============================================================================

class TypingHandler : public KeyboardHandler
{
public:

    TypingHandler( Keyboard * keyboard )
    :
        KeyboardHandler( keyboard )
    {
        gchar * path = g_build_filename( kb->keyboard_path.c_str() , "layouts" , "keyboard-default.lua" , NULL );

        layouts.push_back( Layout() );

        if ( ! layouts.back().load( path , kb->assets_path.c_str() , kb->typing_layout ) )
        {
            layouts.clear();
        }

        g_free( path );
    }

    virtual bool ok() const
    {
        return ! layouts.empty();
    }

    virtual void show_for_field( const Keyboard::Form::Field & field )
    {
        g_assert( ok() );

        clutter_actor_show( kb->typing_container );
        clutter_actor_show( kb->typing_focus );
        clutter_actor_show( kb->typing_layout );
        layouts.front().reset_mode();
        clutter_actor_show( layouts.front().get_mode().image );

        clutter_actor_show( kb->current_field_value );
    }

    virtual void ensure_focus()
    {
        KeyboardHandler::ensure_focus( layouts.front().get_mode() , kb->typing_focus );
    }

    virtual bool on_event( ClutterEvent * event )
    {
        const Layout::Button * button = 0;

        if ( KeyboardHandler::do_event_shortcut( event , layouts.front().get_mode() , & button ) )
        {
            return true;
        }

        if ( button )
        {
            bool direct_press = button == layouts.front().get_mode().get_button_at( kb->focus );

            if ( button->action == "OSK_SHIFT" )
            {
                toggle_shift();
                if ( direct_press )
                {
                    kb->flash_focus();
                }
                else
                {
                    kb->flash_button( button->flasher.c_str() , button->x , button->y );
                }
                return true;
            }

            Keyboard::Form::Field & field( kb->form.get_field() );

            if ( button->action == "OSK_BACKSPACE" )
            {
                if ( ! field.value.empty() )
                {
                    gchar * s = g_strdup( field.value.c_str() );

                    gchar * p = g_utf8_find_prev_char( s , s + strlen( s ) );

                    if ( p )
                    {
                        * p = 0;
                        field.value = s;
                        kb->field_value_changed();
                    }

                    g_free( s );
                }

                unshift();

                if ( direct_press )
                {
                    kb->flash_focus();
                }
                else
                {
                    kb->flash_button( button->flasher.c_str() , button->x , button->y );
                }

                return true;
            }

            field.value += button->action;

            kb->field_value_changed();

            unshift();

            kb->flash_focus();

            return true;
        }
        else
        {
            button = KeyboardHandler::get_spatial_navigation_target( event , layouts.front().get_mode() );

            if ( button )
            {
                kb->show_focus_ring( kb->typing_focus , button->focus_ring.c_str() , button->x , button->y );

                return true;
            }
        }

        return true;
    }

protected:

    virtual ClutterActor * get_container()
    {
        return kb->typing_container;
    }

private:

    void toggle_shift()
    {
        clutter_actor_hide( layouts.front().get_mode().image );
        layouts.front().toggle_mode();
        clutter_actor_show( layouts.front().get_mode().image );
    }

    void unshift()
    {
        clutter_actor_hide( layouts.front().get_mode().image );
        layouts.front().reset_mode();
        clutter_actor_show( layouts.front().get_mode().image );
    }

    typedef std::list< Layout > LayoutList;

    LayoutList  layouts;
};

//=============================================================================

class ListHandler : public KeyboardHandler
{
public:

    ListHandler( Keyboard * keyboard )
    :
        KeyboardHandler( keyboard )
    {
        gchar * path = g_build_filename( kb->keyboard_path.c_str() , "layouts" , "list.lua" , NULL );

        loaded = layout.load( path , kb->assets_path.c_str() , kb->list_layout );

        g_free( path );

        if ( loaded )
        {
            item_container = clutter_container_find_child_by_name( CLUTTER_CONTAINER( kb->keyboard ) , "list-item-container" );

            if ( ! item_container )
            {
                tpwarn( "UI DEFINITION IS MISSING 'list-item-container'" );
                loaded = false;
            }

            if ( loaded )
            {
                // Make an array of the buttons that represent the visible list items

                for ( Layout::ButtonVector::const_iterator it = layout.get_mode().buttons.begin(); it != layout.get_mode().buttons.end(); ++it )
                {
                    if ( it->action == "item" )
                    {
                        item_buttons.push_back( & * it );
                    }
                }
            }
        }
    }

    virtual bool ok() const
    {
        return loaded;
    }

    virtual void show_for_field( const Keyboard::Form::Field & _field )
    {
        g_assert( ok() );

        field = & _field;

        clutter_actor_show( kb->list_container );
        clutter_actor_show( kb->list_focus );
        clutter_actor_show( kb->list_layout );
        clutter_actor_show( layout.get_mode().image );

        clutter_actor_hide( kb->current_field_value );

        clutter_actor_hide(item_container );

        clutter_actor_set_y( item_container , 0 );

        // TODO: This is a bad idea, if there are a lot of choices. It will
        // take a long time to build the list. We should build it a few items
        // at a time. Maybe even write them all to canvas chunks.

        // TODO: We could also cache the pieces we build

        item_height = clutter_actor_get_height( kb->current_field_value );

        gfloat item_width = clutter_actor_get_width( item_container );

        int existing = clutter_actor_get_n_children( item_container );

        int i = 0;

        for ( StringPairVector::const_iterator it = field->choices.begin(); it != field->choices.end(); ++it , ++i )
        {
            ClutterActor * item = 0;

            if ( i < existing )
            {
                item = clutter_actor_get_child_at_index( item_container, i );
            }
            else
            {
                item = clutter_text_new();

                clutter_text_set_font_name( CLUTTER_TEXT( item ) , clutter_text_get_font_name( CLUTTER_TEXT( kb->current_field_value ) ) );

                ClutterColor color;

                clutter_text_get_color( CLUTTER_TEXT( kb->current_field_value ) , & color );

                clutter_text_set_color( CLUTTER_TEXT( item ) , & color );

                clutter_actor_set_y( item , item_height * i );

                clutter_actor_set_x( item , 10 );

                clutter_actor_set_width( item , item_width - 20 );

                clutter_text_set_ellipsize( CLUTTER_TEXT( item ) , PANGO_ELLIPSIZE_END );

                clutter_actor_add_child( item_container, item );
            }

            clutter_text_set_text( CLUTTER_TEXT( item ) , it->second.c_str() );

            clutter_actor_show( item );
        }

        clutter_actor_show( item_container );

        // Get the current value for the field and make sure the right item is selected
        // This could mean scrolling the list.

        top_item = 0;
        focused_item = 0;

        int choice_index = field->get_choice_index();

        if ( choice_index >= 0 )
        {
            focused_item = choice_index;

            if ( size_t( focused_item ) >= item_buttons.size() )
            {
                if ( focused_item + item_buttons.size() >= field->choices.size() )
                {
                    top_item = std::max( field->choices.size() - item_buttons.size() , size_t( 0 ) );
                }
                else
                {
                    top_item = focused_item;
                }

                clutter_actor_set_y( item_container , ( - item_height ) * ( top_item ) );
            }
        }
    }

    virtual void ensure_focus()
    {
        const Layout::Button * button = layout.get_mode().get_button_at( kb->focus );

        if ( ! button || ( button && button->action == "item" ) )
        {
            button = item_buttons[ focused_item - top_item ];
        }

        KeyboardHandler::show_focus_ring( kb->list_focus , button );
    }

    virtual bool on_event( ClutterEvent * event )
    {
        const Layout::Button * button = 0;

        if ( KeyboardHandler::do_event_shortcut( event , layout.get_mode() , & button ) )
        {
            return true;
        }

        // Get the focused button

        button = layout.get_mode().get_button_at( kb->focus );

        if ( ! button )
        {
            return true;
        }

        if ( event->any.type == CLUTTER_KEY_PRESS && event->key.keyval == TP_KEY_OK && button->action == "item" )
        {
            String old_value = kb->form.get_field().value;

            kb->form.get_field().value = field->choices[ focused_item ].first;

            if ( kb->form.get_field().value != old_value )
            {
                kb->field_value_changed();
            }

            const Layout::Button * target = 0;

            if ( kb->form.current_field == kb->form.fields.size() - 1 )
            {
                target = layout.get_mode().get_button_for_action( "OSK_SUBMIT" );
            }
            else
            {
                target = layout.get_mode().get_button_for_action( "OSK_NEXT" );
            }

            if ( target )
            {
                KeyboardHandler::show_focus_ring( kb->list_focus , target );
            }

            return true;
        }


        const Layout::Button * target = KeyboardHandler::get_spatial_navigation_target( event , layout.get_mode() );

        if ( ! target )
        {
            return true;
        }

        // If we are not moving into the list, out of the list or within the list,
        // we can just focus the target and bail.

        if ( button->action != "item" && target->action != "item" )
        {
            KeyboardHandler::show_focus_ring( kb->list_focus , target );
            return true;
        }

        // If we are moving into the list, we just focus whatever was focused last

        if ( button->action != "item" && target->action == "item" )
        {
            KeyboardHandler::show_focus_ring( kb->list_focus , item_buttons[ focused_item - top_item ] );
            return true;
        }

        // OK, now we know that we are either moving within the list or
        // out of it.

        if ( event->any.type == CLUTTER_KEY_PRESS )
        {
            switch( event->key.keyval )
            {
                // Pressing left or right on a list item does nothing

                case TP_KEY_LEFT:
                case TP_KEY_RIGHT:
                    return true;
                    break;

                // This will either focus the next item above it, scroll
                // the list up or jump out of the list to the buttons
                // above it.

                case TP_KEY_UP:
                {
                    // We are moving up to another list item

                    if ( target->action == "item" )
                    {
                        --focused_item;
                        KeyboardHandler::show_focus_ring( kb->list_focus , target );
                        return true;
                    }

                    // We are moving up and we are at the top of the list,
                    // so we focus whatever is above the list - the target.

                    if ( top_item == 0 )
                    {
                        KeyboardHandler::show_focus_ring( kb->list_focus , target );
                        return true;
                    }

                    // Otherwise, we need to scroll the list down and keep the focus
                    // where it is.

                    --top_item;
                    --focused_item;

                    if ( ClutterAnimation * an = clutter_actor_get_animation( item_container ) )
                    {
                        clutter_animation_completed( an );
                    }

                    gfloat y = clutter_actor_get_y( item_container ) + item_height;

                    clutter_actor_animate( item_container , CLUTTER_EASE_OUT_QUAD , KB_LIST_SCROLL_DURATION , "y" , y , NULL );

                    return true;

                    break;
                }

                case TP_KEY_DOWN:
                {
                    // Moving down to another item, but that item may be empty

                    if ( target->action == "item" )
                    {
                        if ( size_t( focused_item ) < field->choices.size() - 1 )
                        {
                            ++focused_item;
                            KeyboardHandler::show_focus_ring( kb->list_focus , target );
                            return true;
                        }

                        // That item is empty, we need to jump out

                        KeyboardHandler::show_focus_ring( kb->list_focus , item_buttons.back() );
                        target = KeyboardHandler::get_spatial_navigation_target( event , layout.get_mode() );
                        if ( target )
                        {
                            KeyboardHandler::show_focus_ring( kb->list_focus , target );
                            return true;
                        }
                        return true;
                    }

                    // The target is below the list.

                    // If we are already showing the last item, jump out of the list

                    if ( size_t( focused_item + 1 ) >= field->choices.size() )
                    {
                        KeyboardHandler::show_focus_ring( kb->list_focus , target );
                        return true;
                    }

                    // OK, scroll

                    ++top_item;
                    ++focused_item;

                    if ( ClutterAnimation * an = clutter_actor_get_animation( item_container ) )
                    {
                        clutter_animation_completed( an );
                    }

                    gfloat y = clutter_actor_get_y( item_container ) - item_height;

                    clutter_actor_animate( item_container , CLUTTER_EASE_OUT_QUAD , KB_LIST_SCROLL_DURATION , "y" , y , NULL );

                    return true;

                    break;
                }
            }
        }

        return true;
    }

protected:

    virtual ClutterActor * get_container()
    {
        return kb->list_container;
    }

private:

    bool                loaded;
    Layout              layout;
    ClutterActor *      item_container;

    typedef std::vector< const Layout::Button * > Buttons;

    Buttons                         item_buttons;
    const Keyboard::Form::Field *   field;
    int                             top_item;
    int                             focused_item;
    gfloat                          item_height;
};

//=============================================================================

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
                        String value;
                        lua_pushnil( L );
                        while( lua_next( L , -2 ) )
                        {
                            if ( lua_istable( L , -1 ) )
                            {
                                lua_rawgeti( L , -1 , 1 );
                                lua_rawgeti( L , -2 , 2 );

                                const char * k = lua_tostring( L , -2 );
                                const char * v = lua_tostring( L , -1 );

                                if ( k && v )
                                {
                                    field.choices.push_back( StringPair( k , v ) );

                                    if ( field.value == k )
                                    {
                                        value = v;
                                    }
                                }

                                lua_pop( L , 2 );
                            }
                            lua_pop( L , 1 );
                        }
                        lua_pop( L , 1 );
                        failif( field.choices.empty() , "'choices' MUST HAVE AT LEAST ONE VALID ENTRY" );

                        // Make sure that the initial value provided is one of the choices

                        if ( value.empty() )
                        {
                            field.value.clear();
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

    clutter_actor_set_child_above_sibling( clutter_actor_get_parent( keyboard ), keyboard, NULL );

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

void Keyboard::load_static_images( ClutterActor * actor , const gchar * assets_path )
{
    if ( CLUTTER_IS_TEXTURE( actor ) )
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
    else if ( CLUTTER_IS_CONTAINER( actor ) )
    {
        ClutterActorIter iter;
        ClutterActor *child;
        clutter_actor_iter_init( &iter, actor );
        while(clutter_actor_iter_next( &iter, &child ))
        {
            load_static_images( child, assets_path );
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

Keyboard::Keyboard( TPContext * c )
:
    context( c ),
    keyboard( 0 ),
    field_list_container( 0 ),
    bottom_container( 0 ),
    typing_container( 0 ),
    typing_focus( 0 ),
    typing_layout( 0 ),
    list_container( 0 ),
    list_layout( 0 ),
    list_focus( 0 ),
    current_field_caption( 0 ),
    current_field_value( 0 ),

    focus_rings( 0 ),

    x_out( 0 ),
    x_in( 0 ),

    event_handler( 0 ),
    focus( 0 ),
    lsp( 0 ),

    typing_handler( 0 ),
    list_handler( 0 )
{
    tplog2( "BUILDING" );

    FreeLater free_later;

    // Get the engine's resources directory

    const char * resources_path = context->get( TP_RESOURCES_PATH );
    g_assert( resources_path );

    // Get the keyboard directory inside there

    gchar * kp = g_build_filename( resources_path , "keyboard" , NULL );
    keyboard_path = kp;
    g_free( kp );

    // Get the filename for the field list UI definition, and load the contents
    // of the file.

    gchar * fp = g_build_filename( keyboard_path.c_str() , "field.json" , NULL );
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

    gchar * keyboard_json_path = g_build_filename( keyboard_path.c_str() , "keyboard.json" , NULL );
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
            find_actor( script , "list-layout" , CLUTTER_TYPE_GROUP , & list_layout ) &&
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

    ClutterActor * stage = context->get_stage();

    gfloat stage_width;
    gfloat stage_height;

    clutter_actor_get_size( stage , & stage_width , & stage_height );

    gfloat xs = stage_width / 1920.0;
    gfloat ys = stage_height / 1080.0;

    // Set the scale on the keyboard

    clutter_actor_set_scale( keyboard , xs , ys );

    // Load all the static images

    gchar * keyboard_assets_path = g_build_filename( keyboard_path.c_str() , "assets" , NULL );
    free_later( keyboard_assets_path );

    assets_path = keyboard_assets_path;

        ClutterActorIter iter;
        ClutterActor *child;
        clutter_actor_iter_init( &iter, keyboard );
        while(clutter_actor_iter_next( &iter, &child ))
        {
            load_static_images( child, keyboard_assets_path );
        }

    // Get the width of the keyboard

    gfloat w = clutter_actor_get_width( keyboard );

    // Its X position when it is out (visible)

    x_out = stage_width - w * xs;

    // Its X position when it is in (hidden)

    x_in = stage_width;

    clutter_actor_set_x( keyboard , x_out );

    // Create a group to hold focus rings

    focus_rings = clutter_actor_new();

    clutter_actor_set_name( focus_rings , "focus-rings" );

    clutter_actor_add_child( keyboard, focus_rings );

    clutter_actor_hide( focus_rings );

    // Load the handlers

    typing_handler = new TypingHandler( this );
    list_handler = new ListHandler( this );

    if ( ! typing_handler->ok() || ! list_handler->ok() )
    {
        delete typing_handler;
        delete list_handler;
        typing_handler = 0;
        list_handler = 0;
        keyboard = 0;
        return;
    }

    typing_handler->hide();
    list_handler->hide();

    g_object_ref( keyboard );

    clutter_actor_add_child( stage, keyboard );

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

    if ( typing_handler )
    {
    	delete typing_handler;
    }

    if ( list_handler )
    {
    	delete list_handler;
    }
}

//-----------------------------------------------------------------------------

void Keyboard::reset()
{
    focus = 0;
}

//-----------------------------------------------------------------------------

ClutterActor * Keyboard::show_focus_ring( ClutterActor * container , const char * name , gfloat x , gfloat y , bool set_it )
{
    ClutterActor * ring = clutter_container_find_child_by_name( CLUTTER_CONTAINER( container ) , name );

    if ( ! ring )
    {
        ClutterActor * source = clutter_container_find_child_by_name( CLUTTER_CONTAINER( focus_rings ) , name );

        if ( ! source )
        {
            source = clutter_texture_new();

            gchar * path = g_build_filename( assets_path.c_str() , name , NULL );

            Images::load_texture( CLUTTER_TEXTURE( source ) , path );

            g_free( path );

            clutter_actor_set_name( source , name );

            clutter_actor_add_child( focus_rings, source );
        }

        ring = clutter_clone_new( source );

        gfloat w;
        gfloat h;

        clutter_actor_get_size( source , & w , & h );

        clutter_actor_set_anchor_point( ring , w / 2 , h / 2 );

        clutter_actor_set_name( ring , name );

        clutter_actor_add_child( container, ring );
    }

    clutter_actor_set_position( ring , x , y );

    if ( focus && focus != ring && set_it )
    {
        clutter_actor_hide( focus );
    }

    if ( set_it )
    {
        focus = ring;
    }

    clutter_actor_show( ring );

    return ring;
}

//-----------------------------------------------------------------------------

void Keyboard::flash_focus()
{
    if ( focus )
    {
        if ( ClutterAnimation * an = clutter_actor_get_animation( focus ) )
        {
            clutter_animation_completed( an );
        }

        //clutter_actor_set_scale( focus , 0.95 , 0.95 );
        clutter_actor_set_opacity( focus , 128 );

        clutter_actor_animate( focus , CLUTTER_EASE_OUT_QUINT , 250 ,
                "scale-x" , 1.0 ,
                "scale-y" , 1.0 ,
                "opacity" , 255 ,
                NULL );
    }
}

//-----------------------------------------------------------------------------

static void hide_on_completed( ClutterAnimation * animation , ClutterActor * actor )
{
    clutter_actor_hide( actor );
}

//-----------------------------------------------------------------------------

void Keyboard::flash_button( const char * name , gfloat x , gfloat y )
{
    if ( ! focus || ! name )
    {
        return;
    }

    gfloat fx;
    gfloat fy;

    clutter_actor_get_position( focus , & fx , & fy );

    if ( fx == x && fy == y )
    {
        flash_focus();
        return;
    }

    if ( ! strlen( name ) )
    {
        return;
    }

    ClutterActor * flasher = show_focus_ring( clutter_actor_get_parent( focus ) , name , x , y , false );

    if ( flasher )
    {
        clutter_actor_set_scale( flasher , 1.0 , 1.0 );

        clutter_actor_animate( flasher , CLUTTER_EASE_OUT_QUINT , 250 ,
                "scale-x" , 1.0 ,
                "scale-y" , 1.0 ,
                "signal::completed" , hide_on_completed , flasher ,
                NULL );
    }

}

//-----------------------------------------------------------------------------

void Keyboard::connect_event_handler()
{
    disconnect_event_handler();

    if ( ClutterActor * stage = context->get_stage() )
    {
        event_handler = g_signal_connect( G_OBJECT( stage  ) , "captured-event" , ( GCallback ) captured_event , this );
    }
}

//-----------------------------------------------------------------------------

void Keyboard::disconnect_event_handler()
{
    if ( ClutterActor * stage = context->get_stage() )
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
        if ( form.get_field().handler->on_event( event ) )
        {
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

    int existing_fields = clutter_actor_get_n_children( field_list_container );

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
            ClutterActor * field = clutter_actor_get_first_child( field_list_container );

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

            ClutterActorIter iter;
            ClutterActor *child;
            clutter_actor_iter_init( &iter, group );
            while(clutter_actor_iter_next( &iter, &child ))
            {
                load_static_images( child, assets_path.c_str() );
            }

            clutter_actor_add_child( field_list_container, group );

            gfloat y = clutter_actor_get_y( group );

            clutter_actor_set_y( group , y + top );

            top += y + clutter_actor_get_height( group );
        }
    }

    //.........................................................................
    // Hide everything

    clutter_actor_hide( field_list_container );

    //.........................................................................
    // Now, set-up each field

    for ( int i = 0; i < form_fields; ++i )
    {
        Form::Field & ff( form.fields[ i ] );

        if ( ff.type == Form::Field::LIST )
        {
            ff.handler = list_handler;
        }
        else
        {
            ff.handler = typing_handler;
        }

        ClutterActor * field = clutter_actor_get_child_at_index( field_list_container, i );

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

        clutter_text_set_text( CLUTTER_TEXT( value ) , ff.get_display_value().c_str() );

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

    // Hide all the handlers

    for ( Form::FieldVector::const_iterator it = form.fields.begin(); it != form.fields.end(); ++it )
    {
    	it->handler->hide();
    }

    // Make sure the container has the right number of fields

    g_assert( clutter_actor_get_n_children( field_list_container ) >= int( nfields ) );

    // Get the first field, so we can calculate the height of all fields

    ClutterActor * first_field = clutter_actor_get_first_child( field_list_container );

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
        clutter_actor_set_opacity( clutter_actor_get_child_at_index( field_list_container, i ) , i == field_index ? 255 : KB_UNFOCUSED_OPACITY );
    }

    form.current_field = field_index;

    Form::Field & field( form.get_field() );

    //.........................................................................
    // We center the field caption manually

    gfloat mw = clutter_actor_get_width( clutter_actor_get_parent( current_field_caption ) );

    clutter_actor_set_size( current_field_caption , -1 , -1 );

    clutter_text_set_text( CLUTTER_TEXT( current_field_caption ) , field.caption.c_str() );

    gfloat w = clutter_actor_get_width( current_field_caption );

    if ( w > mw )
    {
        w = mw;

        clutter_actor_set_width( current_field_caption , w );
    }

    gfloat x = ( mw / 2.0 ) - ( w / 2.0 );

    clutter_actor_set_x( current_field_caption , x );

    //.........................................................................

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
        String count( Util::format( "%u / %u" , field_index + 1 , form.fields.size() ) );
        clutter_text_set_text( CLUTTER_TEXT( field_count ) , count.c_str() );
    }

    update_field_value();

    //-------------------------------------------------------------------------
    // Now, prepare the keyboard for this field

    field.handler->show_for_field( field );

    field.handler->ensure_focus();
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

void Keyboard::field_value_changed()
{
    update_field_value();

    if ( lsp )
    {
        if ( lua_State * L = lsp->get_lua_state() )
        {
            lua_pushstring( L , form.get_field().id.c_str() );
            lua_pushstring( L , form.get_field().value.c_str() );

            UserData::invoke_global_callbacks( L , "keyboard" , "on_field_changed" , 2 , 0 );
        }
    }
}

//-----------------------------------------------------------------------------

void Keyboard::update_field_value()
{
    const Form::Field & field( form.get_field() );

    ClutterActor * ff = clutter_actor_get_child_at_index( field_list_container, form.current_field );

    g_assert( ff );

    clutter_text_set_text( CLUTTER_TEXT( clutter_container_find_child_by_name( CLUTTER_CONTAINER( ff ) , "value" ) ) , field.get_display_value().c_str() );

    if ( ClutterActor * placeholder = clutter_container_find_child_by_name( CLUTTER_CONTAINER( keyboard ) , "current-field-placeholder" ) )
    {
        if ( field.value.empty() && ! field.placeholder.empty() && field.type != Form::Field::LIST )
        {
            clutter_text_set_text( CLUTTER_TEXT( placeholder ) , field.placeholder.c_str() );
            clutter_actor_show( placeholder );
        }
        else
        {
            clutter_actor_hide( placeholder );
        }
    }

    clutter_text_set_text( CLUTTER_TEXT( current_field_value ) , field.get_display_value().c_str() );
}

//-----------------------------------------------------------------------------

void Keyboard::cancel()
{
    if ( lsp )
    {
        if ( lua_State * L = lsp->get_lua_state() )
        {
            UserData::invoke_global_callbacks( L , "keyboard" , "on_cancel" , 0 , 0 );
        }
    }

    hide_internal( false );
}

//-----------------------------------------------------------------------------

void Keyboard::submit()
{
    // TODO: validate required fields

	bool hide = true;

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

            if ( UserData::invoke_global_callbacks( L , "keyboard" , "on_submit" , 1 , 1 , 1 ) )
            {
            	if ( lua_isboolean( L , -1 ) && ! lua_toboolean( L , -1 ) )
            	{
            		hide = false;
            	}
           		lua_pop( L , 1 );
            }
        }
    }

    if ( hide )
    {
    	hide_internal( false );
    }
}

//-----------------------------------------------------------------------------
