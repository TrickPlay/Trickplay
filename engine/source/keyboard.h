#ifndef _TRICKPLAY_KEYBOARD_H
#define _TRICKPLAY_KEYBOARD_H

#include "common.h"
#include "json.h"
#include "app.h"

class Keyboard
{
public:

    static bool show( lua_State * L , int form_index );

    static void hide( lua_State * L , bool skip_animation = false );

private:

    Keyboard( TPContext * context );

    virtual ~Keyboard();

    Keyboard( const Keyboard & )
    {}

    static Keyboard * get( TPContext * context , bool create );

    static void destroy( Keyboard * me );

    bool show_internal( lua_State * L , int form_index );

    void hide_internal( bool skip_animation );

    // Recursively loads all the static images

    static void load_static_images( ClutterActor * actor , gchar * assets_path );

    // Finds an actor in the script and checks its type

    static bool find_actor( ClutterScript * script , const gchar * id , GType type , ClutterActor * * actor );

    // Callbacks

    static void on_finished_showing( ClutterAnimation * animation , ClutterActor * actor );

    static void on_finished_hiding( ClutterAnimation * animation , ClutterActor * actor );

    // Resets the keyboard

    void reset();

    // Prepares the field list from the form

    bool build_field_list();

    // Makes this the top field and sets up the keyboard to edit it

    void switch_to_field( size_t field_index );

    void move_to_previous_field();

    void move_to_next_field();

    // Switches to the layout specified, in default mode

    void switch_to_typing_layout( size_t layout_index , int mode = 0 );

    void toggle_layout_shift();

    void show_focus_ring( ClutterActor * container , const char * name , gfloat x , gfloat y );

    // Event handlers

    void connect_event_handler();

    void disconnect_event_handler();

    static gboolean captured_event( ClutterActor * actor , ClutterEvent * event , Keyboard * me );

    gboolean on_event( ClutterActor * actor , ClutterEvent * event );

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

    void typing_spatial_navigation( unsigned int dir );

    // Update the current field's value

    void update_field_value();

    //-------------------------------------------------------------------------
    // All the actors we pull from the JSON UI definition

    ClutterActor *  keyboard;
    ClutterActor *  field_list_container;
    ClutterActor *  bottom_container;
    ClutterActor *  typing_container;
    ClutterActor *  typing_focus;
    ClutterActor *  typing_layout;
    ClutterActor *  list_container;
    ClutterActor *  list_focus;
    ClutterActor *  current_field_caption;
    ClutterActor *  current_field_value;

    //-------------------------------------------------------------------------
    // Stage x coordinates for when the keyboars is out (visible) and in (hidden)

    gfloat          x_out;
    gfloat          x_in;

    //-------------------------------------------------------------------------
    // The JSON script for the field list UI

    String          field_script;

    //-------------------------------------------------------------------------
    // The path to <resources>/keyboard/assets

    String          assets_path;

    //-------------------------------------------------------------------------
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

            ClutterActor *  image;
            String          first_focus;
            ButtonVector    buttons;
        };

        Layout() : current_mode( 0 ) {}

        const Mode & get_mode() const
        {
            return modes[ current_mode ];
        }

        String  name;
        Mode    modes[2];
        int     current_mode;
    };

    typedef std::vector< Layout > LayoutVector;

    LayoutVector   layouts;

    //-------------------------------------------------------------------------
    // Load the layouts

    void load_layout_mode( Layout::Mode & mode , const char * name , JSON::Object & root ) throw (String);

    void load_layout( JSON::Object & root ) throw (String);

    bool load_layouts( const char * path );

    //-------------------------------------------------------------------------

    const Layout::Button * get_focused_button();

    // When a keyboard button is pressed

    void typing_action( const Layout::Button * button );

    //-------------------------------------------------------------------------
    // Our collection of focus ring images

    typedef std::map< String , ClutterActor * > ImageMap;

    ImageMap    focus_rings;

    //-------------------------------------------------------------------------

    size_t      current_typing_layout;

    //-------------------------------------------------------------------------

    gulong      event_handler;

    //-------------------------------------------------------------------------

    struct Form
    {
        struct Field
        {
            // TODO: from HTML5
            // email , url , number, range , date , month , week, time , datetime, datetime-local

            typedef enum { TEXT , LIST , PASSWORD } Type;

            Field() : type( TEXT ) , required( false ) , multiple( false ) , password_char( "*" ) {}

            Type        type;
            String      id;
            String      caption;
            String      placeholder;
            String      value;
            bool        required;

            // For list fields

            StringMap   choices;
            bool        multiple;

            // For password fields

            String      password_char;
        };

        Form() : current_field( 0 ) {}

        bool load_from_lua( lua_State * L , int n );

        Field & get_field()
        {
            return fields[ current_field ];
        }

        typedef std::vector< Field > FieldVector;

        FieldVector fields;
        size_t      current_field;
    };

    Form    form;

    ClutterActor * focus;

    LuaStateProxy * lsp;
};

#endif // _TRICKPLAY_KEYBOARD_H
