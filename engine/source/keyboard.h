#ifndef _TRICKPLAY_KEYBOARD_H
#define _TRICKPLAY_KEYBOARD_H

#include "common.h"
#include "json.h"
#include "app.h"

class KeyboardHandler;

class Keyboard
{
public:

    static bool show( lua_State* L , int form_index );

    static void hide( lua_State* L , bool skip_animation = false );

private:

    friend class KeyboardHandler;
    friend class TypingHandler;
    friend class ListHandler;

    Keyboard( TPContext* context );

    virtual ~Keyboard();

    Keyboard( const Keyboard& )
    {}

    static Keyboard* get( TPContext* context , bool create );

    static void destroy( Keyboard* me );

    bool show_internal( lua_State* L , int form_index );

    void hide_internal( bool skip_animation );

    // Recursively loads all the static images

    static void load_static_images( ClutterActor* actor , const gchar* assets_path );

    // Finds an actor in the script and checks its type

    static bool find_actor( ClutterScript* script , const gchar* id , GType type , ClutterActor * * actor );

    // Callbacks

    static void on_finished_showing( ClutterAnimation* animation , ClutterActor* actor );

    static void on_finished_hiding( ClutterAnimation* animation , ClutterActor* actor );

    // Resets the keyboard

    void reset();

    // Prepares the field list from the form

    bool build_field_list();

    // Makes this the top field and sets up the keyboard to edit it

    void switch_to_field( size_t field_index );

    void move_to_previous_field();

    void move_to_next_field();

    ClutterActor* show_focus_ring( ClutterActor* container , const char* name , gfloat x , gfloat y , bool set_it = true );

    void flash_focus();

    void flash_button( const char* name , gfloat x , gfloat y );

    // Event handlers

    void connect_event_handler();

    void disconnect_event_handler();

    static gboolean captured_event( ClutterActor* actor , ClutterEvent* event , Keyboard* me );

    gboolean on_event( ClutterActor* actor , ClutterEvent* event );

    // Update the current field's value

    void field_value_changed();

    void update_field_value();

    // Duh!

    void submit();

    void cancel();

    TPContext* context;

    //-------------------------------------------------------------------------
    // Path to <resources>/keyboard

    String keyboard_path;

    //-------------------------------------------------------------------------
    // All the actors we pull from the JSON UI definition

    ClutterActor*   keyboard;
    ClutterActor*   field_list_container;
    ClutterActor*   bottom_container;
    ClutterActor*   typing_container;
    ClutterActor*   typing_focus;
    ClutterActor*   typing_layout;
    ClutterActor*   list_container;
    ClutterActor*   list_layout;
    ClutterActor*   list_focus;
    ClutterActor*   current_field_caption;
    ClutterActor*   current_field_value;

    //-------------------------------------------------------------------------
    // A container we add to hold all the focus rings

    ClutterActor*   focus_rings;

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

    gulong      event_handler;

    //-------------------------------------------------------------------------

    struct Form
    {
        struct Field
        {
            // TODO: from HTML5
            // email , url , number, range , date , month , week, time , datetime, datetime-local

            typedef enum { TEXT , LIST , PASSWORD } Type;

            Field()
                :
                type( TEXT ) ,
                handler( 0 ) ,
                required( false ) ,
                multiple( false ) ,
                password_char( 0x00B7 )
            {}

            String get_display_value() const
            {
                if ( type != LIST )
                {
                    return value;
                }

                for ( StringPairVector::const_iterator it = choices.begin(); it != choices.end(); ++it )
                {
                    if ( it->first == value )
                    {
                        return it->second;
                    }
                }

                return String();
            }

            int get_choice_index() const
            {
                if ( type == LIST && ! value.empty() )
                {
                    int i = 0;

                    for ( StringPairVector::const_iterator it = choices.begin(); it != choices.end(); ++it , ++i )
                    {
                        if ( it->first == value )
                        {
                            return i;
                        }
                    }
                }

                return -1;
            }

            Type                type;
            KeyboardHandler*    handler;
            String              id;
            String              caption;
            String              placeholder;
            String              value;
            bool                required;

            // For list fields

            StringPairVector    choices;
            bool                multiple;

            // For password fields

            gunichar            password_char;
        };

        Form() : current_field( 0 ) {}

        bool load_from_lua( lua_State* L , int n );

        Field& get_field()
        {
            return fields[ current_field ];
        }

        typedef std::vector< Field > FieldVector;

        FieldVector fields;
        size_t      current_field;
    };

    Form    form;

    ClutterActor* focus;

    LuaStateProxy* lsp;

    KeyboardHandler* typing_handler;
    KeyboardHandler* list_handler;
};

#endif // _TRICKPLAY_KEYBOARD_H
