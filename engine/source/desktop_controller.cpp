
#ifndef TP_CLUTTER_BACKEND_EGL

#include "clutter/clutter-keysyms.h"

#include "trickplay/controller.h"
#include "trickplay/keys.h"

#include "clutter_util.h"
#include "context.h"
#include "desktop_controller.h"

static int controller_execute_command( TPController* , unsigned int command , void* , void* context )
{
    switch ( command )
    {
        case TP_CONTROLLER_COMMAND_START_POINTER:
            return 0;

        case TP_CONTROLLER_COMMAND_STOP_POINTER:
            return 0;

        case TP_CONTROLLER_COMMAND_SHOW_POINTER_CURSOR:
            clutter_stage_show_cursor( CLUTTER_STAGE( ( ( TPContext* )context )->get_stage() ) );
            return 0;

        case TP_CONTROLLER_COMMAND_HIDE_POINTER_CURSOR:
            clutter_stage_hide_cursor( CLUTTER_STAGE( ( ( TPContext* )context )->get_stage() ) );
            return 0;

        case TP_CONTROLLER_COMMAND_SET_POINTER_CURSOR:
            return 2;
    }

    return 1;
}

static void map_key( ClutterEvent* event , guint* keyval , gunichar* unicode )
{
    * keyval = event->key.keyval;
    * unicode = event->key.unicode_value;

    switch ( * keyval )
    {
        case CLUTTER_F5:
            * keyval = TP_KEY_RED;
            * unicode = 0;
            break;

        case CLUTTER_F6:
            * keyval = TP_KEY_GREEN;
            * unicode = 0;
            break;

        case CLUTTER_F7:
            * keyval = TP_KEY_YELLOW;
            * unicode = 0;
            break;

        case CLUTTER_F8:
            * keyval = TP_KEY_BLUE;
            * unicode = 0;
            break;

        case CLUTTER_F9:
            * keyval = TP_KEY_BACK;
            * unicode = 0;
            break;
    }
}

// In desktop builds, we catch all key events that are not synthetic and pass
// them through a keyboard controller. That will generate an event for the
// controller and re-inject the event into clutter as a synthetic event.
//
// We also use this for mouse events.

gboolean controller_keys( ClutterActor* actor, ClutterEvent* event, gpointer controller )
{
    if ( event )
    {
        switch ( event->any.type )
        {
            case CLUTTER_KEY_PRESS:
            {
                if ( !( event->key.flags & CLUTTER_EVENT_FLAG_SYNTHETIC ) )
                {
                    switch ( event->key.keyval )
                    {
                        case CLUTTER_F10:
                            tp_controller_pointer_active( ( TPController* ) controller );
                            break;

                        case CLUTTER_F11:
                            tp_controller_pointer_inactive( ( TPController* ) controller );
                            break;
                    }

                    guint keyval;
                    gunichar unicode;

                    map_key( event , & keyval , & unicode );

                    unsigned int modifiers = ClutterUtil::get_tp_modifiers( event );

                    tp_controller_key_down( ( TPController* )controller, keyval, unicode , modifiers );
                    return TRUE;
                }

                break;
            }

            case CLUTTER_KEY_RELEASE:
            {
                if ( !( event->key.flags & CLUTTER_EVENT_FLAG_SYNTHETIC ) )
                {
                    guint keyval;
                    gunichar unicode;

                    map_key( event , & keyval , & unicode );

                    unsigned int modifiers = ClutterUtil::get_tp_modifiers( event );

                    tp_controller_key_up( ( TPController* )controller, keyval, unicode , modifiers );
                    return TRUE;
                }

                break;
            }

            case CLUTTER_MOTION:
            {
                if ( !( event->motion.flags & CLUTTER_EVENT_FLAG_SYNTHETIC ) )
                {
                    if ( tp_controller_wants_pointer_events( ( TPController* ) controller ) )
                    {
                        unsigned int modifiers = ClutterUtil::get_tp_modifiers( event );

                        tp_controller_pointer_move( ( TPController* ) controller , event->motion.x , event->motion.y , modifiers );
                    }

                    return TRUE;
                }

                break;
            }

            case CLUTTER_BUTTON_PRESS:
            {
                if ( !( event->button.flags & CLUTTER_EVENT_FLAG_SYNTHETIC ) )
                {
                    if ( tp_controller_wants_pointer_events( ( TPController* ) controller ) )
                    {
                        unsigned int modifiers = ClutterUtil::get_tp_modifiers( event );

                        tp_controller_pointer_button_down( ( TPController* ) controller , event->button.button , event->button.x , event->button.y , modifiers );
                    }

                    return TRUE;
                }
            }

            case CLUTTER_BUTTON_RELEASE:
            {
                if ( !( event->button.flags & CLUTTER_EVENT_FLAG_SYNTHETIC ) )
                {
                    if ( tp_controller_wants_pointer_events( ( TPController* ) controller ) )
                    {
                        unsigned int modifiers = ClutterUtil::get_tp_modifiers( event );

                        tp_controller_pointer_button_up( ( TPController* ) controller , event->button.button , event->button.x , event->button.y , modifiers );
                    }

                    return TRUE;
                }
            }

            case CLUTTER_SCROLL:
            {
                if ( !( event->scroll.flags & CLUTTER_EVENT_FLAG_SYNTHETIC ) )
                {
                    unsigned int modifiers = ClutterUtil::get_tp_modifiers( event );

                    int direction = -1;

                    switch ( event->scroll.direction )
                    {
                        case CLUTTER_SCROLL_UP:     direction = TP_CONTROLLER_SCROLL_UP; break;

                        case CLUTTER_SCROLL_DOWN:   direction = TP_CONTROLLER_SCROLL_DOWN; break;

                        case CLUTTER_SCROLL_LEFT:   direction = TP_CONTROLLER_SCROLL_LEFT; break;

                        case CLUTTER_SCROLL_RIGHT:  direction = TP_CONTROLLER_SCROLL_RIGHT; break;

                            // In this case, we have to call clutter_event_get_scroll_delta which
                            // gives us x and y deltas. Our API can't handle this yet.

                        case CLUTTER_SCROLL_SMOOTH: break;
                    }

                    if ( direction != -1 )
                    {
                        tp_controller_scroll( ( TPController* ) controller , direction , modifiers );
                    }

                    return TRUE;
                }
            }

            default:
            {
                break;
            }
        }
    }

    return FALSE;
}

void install_desktop_controller( TPContext* context )
{
    // We add a controller for the keyboard in non-egl builds

    TPControllerSpec spec;

    memset( & spec , 0 , sizeof( spec ) );

    spec.capabilities =
            TP_CONTROLLER_HAS_KEYS |
            TP_CONTROLLER_HAS_POINTER |
            TP_CONTROLLER_HAS_SCROLL |
            TP_CONTROLLER_HAS_POINTER_CURSOR;

    spec.execute_command = controller_execute_command;

    spec.id = "d6a59106-8879-4748-bcfe-e3c976f82556";

    // This controller won't leak because the controller list will free it

    TPController* keyboard = tp_context_add_controller( context , "Keyboard", & spec , ( void* )context );

    ClutterActor* stage = context->get_stage();

    g_signal_connect( stage , "captured-event", ( GCallback ) controller_keys , keyboard );
}


#endif // TP_CLUTTER_BACKEND_EGL
