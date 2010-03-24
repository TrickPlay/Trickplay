#ifndef _TRICKPLAY_CONTROLLER_H
#define _TRICKPLAY_CONTROLLER_H

#include "trickplay/trickplay.h"

#ifdef __cplusplus
extern "C" {
#endif 

//-----------------------------------------------------------------------------
/*
    File: Controller
    
    A controller is mostly an input device, but this specification also supports
    some output features. It can be as simple as a remote control, keyboard or
    mouse, or as complex as a touch screen device that supports custom user
    interface elements and has an accelerometer.
    
    Controllers can be added and removed at any time; all of these functions are
    thread safe.
    
    You begin by creating a <TPControllerSpec> structure that describes the
    capabilities of the controller. You can also provide a callback to allow
    TrickPlay to execute controller commands; such as displaying a user interface
    or playing sounds.
    
    You then pass that structure to <tp_context_add_controller> along with a name
    for the controller and optional user data. <tp_context_add_controller> returns
    a pointer to a controller structure. You can then call the <Controller Events>
    functions with that pointer. Finally, if the device is disconnected, you can
    call <tp_context_remove_controller>.    
*/
//-----------------------------------------------------------------------------
/*
    Section: Controller Specification
*/
//-----------------------------------------------------------------------------
/*
    Constants: Capabilities
    
    These constants can be ORed together and assigned to <TPControllerSpec.capabilities>.
    
    
    TP_CONTROLLER_HAS_KEYS            - The controller is capable of sending
                                        key events.          
    
    TP_CONTROLLER_HAS_ACCELEROMETER   - The controller is capable of sending
                                        accelerometer events.
                                        
    TP_CONTROLLER_HAS_CLICKS          - The controler can send clicks with x and
                                        y coordinates.
                                        
    TP_CONTROLLER_HAS_TOUCHES         - The controller supports touches, or swipes
                                        and can send their x and y coordinates.
                                        
    TP_CONTROLLER_HAS_MULTIPLE_CHOICE - The controller is capable of rendering
                                        a simple user interface presenting the
                                        user with a handful of choices and can
                                        notify TrickPlay when the user makes a
                                        selection.
                                      
    TP_CONTROLLER_HAS_SOUND           - The controller can play sounds.
    
    TP_CONTROLLER_HAS_UI              - The controller is able to display images
                                        overlaid on top of one another or as a                                        
                                        background.
                                        
    TP_CONTROLLER_HAS_TEXT_ENTRY      - The controller can let the user edit text
                                        sent by TrickPlay. This can be via an on
                                        screen keyboard.
*/

#define TP_CONTROLLER_HAS_KEYS                      0x0001
#define TP_CONTROLLER_HAS_ACCELEROMETER             0x0002
#define TP_CONTROLLER_HAS_CLICKS                    0x0004
#define TP_CONTROLLER_HAS_TOUCHES                   0x0008
#define TP_CONTROLLER_HAS_MULTIPLE_CHOICE           0x0010
#define TP_CONTROLLER_HAS_SOUND                     0x0020
#define TP_CONTROLLER_HAS_UI                        0x0040
#define TP_CONTROLLER_HAS_TEXT_ENTRY                0x0080

//-----------------------------------------------------------------------------
/*
    Constants: Commands
    
    TODO
*/

#define TP_CONTROLLER_COMMAND_RESET                 1
#define TP_CONTROLLER_COMMAND_START_ACCELEROMETER   5
#define TP_CONTROLLER_COMMAND_STOP_ACCELEROMETER    6
#define TP_CONTROLLER_COMMAND_START_CLICKS          7
#define TP_CONTROLLER_COMMAND_STOP_CLICKS           8
#define TP_CONTROLLER_COMMAND_START_TOUCHES         9
#define TP_CONTROLLER_COMMAND_STOP_TOUCHES          10
#define TP_CONTROLLER_COMMAND_SHOW_MULTIPLE_CHOICE  11
#define TP_CONTROLLER_COMMAND_CLEAR_UI              12
#define TP_CONTROLLER_COMMAND_SET_UI_BACKGROUND     13
#define TP_CONTROLLER_COMMAND_SET_UI_IMAGE          14
#define TP_CONTROLLER_COMMAND_PLAY_SOUND            20
#define TP_CONTROLLER_COMMAND_STOP_SOUND            21
#define TP_CONTROLLER_COMMAND_DECLARE_RESOURCE      30
#define TP_CONTROLLER_COMMAND_ENTER_TEXT            31

//-----------------------------------------------------------------------------

typedef struct TPController TPController;

//-----------------------------------------------------------------------------

typedef struct TPControllerStartAccelerometer TPControllerStartAccelerometer;

#define TP_CONTROLLER_ACCELEROMETER_FILTER_NONE     0
#define TP_CONTROLLER_ACCELEROMETER_FILTER_LOW      1
#define TP_CONTROLLER_ACCELEROMETER_FILTER_HIGH     2


struct TPControllerStartAccelerometer
{
    unsigned int    filter;
    double          interval;
};


//-----------------------------------------------------------------------------

typedef struct TPControllerMultipleChoice TPControllerMultipleChoice;

struct TPControllerMultipleChoice
{
    const char *    label;
    unsigned int    count;
    const char **   ids;
    const char **   choices;
};

//-----------------------------------------------------------------------------

#define TP_CONTROLLER_UI_BACKGROUND_MODE_CENTER     1
#define TP_CONTROLLER_UI_BACKGROUND_MODE_STRETCH    2
#define TP_CONTROLLER_UI_BACKGROUND_MODE_TILE       3

typedef struct TPControllerSetUIBackground TPControllerSetUIBackground;

struct TPControllerSetUIBackground
{
    const char *    resource;
    unsigned int    mode;
};

//-----------------------------------------------------------------------------

typedef struct TPControllerSetUIImage TPControllerSetUIImage;

struct TPControllerSetUIImage
{
    const char *    resource;
    int             x;
    int             y;
    int             width;
    int             height;
};

//-----------------------------------------------------------------------------

typedef struct TPControllerPlaySound TPControllerPlaySound;

struct TPControllerPlaySound
{
    const char *    resource;
    unsigned int    loop;
};

//-----------------------------------------------------------------------------

typedef struct TPControllerDeclareResource TPControllerDeclareResource;

struct TPControllerDeclareResource
{
    const char *    resource;
    const char *    uri;
};

//-----------------------------------------------------------------------------

typedef struct TPControllerEnterText TPControllerEnterText;

struct TPControllerEnterText
{
    const char *    label;
    const char *    text;
};

//-----------------------------------------------------------------------------

typedef struct TPControllerSpec TPControllerSpec;

/*
    Struct: TPControllerSpec
    
    This structure lets you specify the capabilities of a controller and,
    optionally provide a callback for the controller to execute commands
*/

struct TPControllerSpec
{
    /*
        Field: capabilities
    
        A combination of <Capabilities> constants.
    */
    
    unsigned int capabilities;
    
    /*
        Field: input_width
        
        If the controller has an input surface such as a touch screen or a
        touch pad, you can specify its width in pixels.
    */
    
    unsigned int input_width;
    
    /*
        Field: input_height
        
        If the controller has an input surface such as a touch screen or a
        touch pad, you can specify its height in pixels.
    */
    
    unsigned int input_height;
    
    /*
        Field: ui_width
        
        The width of the screen, in pixels, if the device supports user interfaces
    */
    
    unsigned int ui_width;
    
    /*
        Field: ui_height
    
        The height of the screen, in pixels, if the device supports user interfaces
    */
    
    unsigned int ui_height;
    
    /*
        Function: execute_command
        
        An optional callback that TrickPlay will invoke to instruct the controller
        to execute various commands. The possible commands depend on the
        capabilities reported by the controller.
        
        Arguments:
        
        controller -    The controller.
        
        command -       One of the <Commands> constants.
        
        parameters -    A pointer to a structure with additional parameters for
                        commands that require them, or NULL.
                        
        data -          Opaque user data that was passed to <tp_context_add_controller>.
        
        Returns:
        
        0 -     If the command was executed.
        
        other - The command failed.
    */
    
    int (*execute_command)(
                           
        TPController * controller,
        unsigned int command,
        void * parameters,
        void * data);
};

//-----------------------------------------------------------------------------
/*
    Section: Controller Events
    
    When a controller generates an event, it should pass it to TrickPlay using
    one or more of the functions described below. All of these functions are
    thread safe.
*/

/*
    Callback: tp_controller_key_down
    
    Report that a key was pressed. 
    
    Arguments:
    
    controller -    The controller returned by <tp_context_add_controller>.
    
    key_code -      An identifier for the key. TODO: reference list with additions.
    
    unicode -       The unicode character for the key, if any, or zero.
*/    
    
    TP_API_EXPORT
    void
    tp_controller_key_down(
            
        TPController * controller,
        unsigned int key_code,
        unsigned long int unicode);

/*
    Callback: tp_controller_key_up
    
    Report that a key was released. 
    
    Arguments:
    
    controller -    The controller returned by <tp_context_add_controller>.
    
    key_code -      An identifier for the key. TODO: reference list with additions.
    
    unicode -       The unicode character for the key, if any, or zero.
*/    

    TP_API_EXPORT
    void
    tp_controller_key_up(
                              
        TPController * controller,
        unsigned int key_code,
        unsigned long int unicode);
    
/*
    Callback: tp_controller_accelerometer
*/

    TP_API_EXPORT
    void
    tp_controller_accelerometer(
                                     
        TPController * controller,
        double x,
        double y,
        double z);

/*
    Callback: tp_controller_click
*/

    TP_API_EXPORT
    void
    tp_controller_click(
                             
        TPController * controller,
        int x,
        int y);
    
/*
    Callback: tp_controller_touch_down
*/

    TP_API_EXPORT
    void
    tp_controller_touch_down(
                                  
        TPController * controller,
        int x,
        int y);

/*
    Callback: tp_controller_touch_move
*/

    TP_API_EXPORT
    void
    tp_controller_touch_move(
                                  
        TPController * controller,
        int x,
        int y);
    
/*
    Callback: tp_controller_touch_up
*/

    TP_API_EXPORT
    void
    tp_controller_touch_up(
                                
        TPController * controller,
        int x,
        int y);
    
/*
    Callback: tp_controller_ui_event
*/

    TP_API_EXPORT
    void
    tp_controller_ui_event(
            
        TPController * controller,
        const char * parameters);

//-----------------------------------------------------------------------------
/*
    Section: Controller Insertion and Removal
*/

/*
    Function: tp_context_add_controller
*/

    TP_API_EXPORT
    TPController *
    tp_context_add_controller(
                                             
        TPContext * context,
        const char * name,
        const TPControllerSpec * spec,
        void * data);

/*
    Function: tp_context_remove_controller
*/

    TP_API_EXPORT
    void
    tp_context_remove_controller(
                                      
        TPContext * context,
        TPController * controller);


//-----------------------------------------------------------------------------

#ifdef __cplusplus
}
#endif 

//-----------------------------------------------------------------------------

#endif // _TRICKPLAY_CONTROLLER_H
