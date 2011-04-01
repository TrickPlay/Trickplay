#ifndef _TRICKPLAY_CONTROLLER_H
#define _TRICKPLAY_CONTROLLER_H

#include "trickplay/trickplay.h"

#ifdef __cplusplus
extern "C" {
#endif 

/*-----------------------------------------------------------------------------*/
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
    call <tp_context_remove_controller>. If the device will always remain connected,
    it is not necessary to call <tp_context_remove_controller>, as TrickPlay will
    dispose of the controller when it exits.
*/
/*-----------------------------------------------------------------------------*/

typedef struct TPController TPController;

/*-----------------------------------------------------------------------------*/
/*
    Section: Controller Specification
*/
/*-----------------------------------------------------------------------------*/
/*
    Constants: Capabilities
    
    These constants can be ORed together and assigned to <TPControllerSpec.capabilities>.
    
    
    TP_CONTROLLER_HAS_KEYS            - The controller is capable of sending
                                        key events.          
    
    TP_CONTROLLER_HAS_ACCELEROMETER   - The controller is capable of sending
                                        accelerometer events.
                                        
    TP_CONTROLLER_HAS_POINTER         - The controller has a pointer (mouse-like input).

                                        
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

    TP_CONTROLLER_HAS_PICTURES        - The controller can can send pictures to Trickplay.

    TP_CONTROLLER_HAS_AUDIO_CLIPS     - The controller can send audio clips to Trickplay.

*/

#define TP_CONTROLLER_HAS_KEYS                      0x0001
#define TP_CONTROLLER_HAS_ACCELEROMETER             0x0002
#define TP_CONTROLLER_HAS_POINTER                   0x0004
#define TP_CONTROLLER_HAS_TOUCHES                   0x0008
#define TP_CONTROLLER_HAS_MULTIPLE_CHOICE           0x0010
#define TP_CONTROLLER_HAS_SOUND                     0x0020
#define TP_CONTROLLER_HAS_UI                        0x0040
#define TP_CONTROLLER_HAS_TEXT_ENTRY                0x0080
#define TP_CONTROLLER_HAS_PICTURES                	0x0100
#define TP_CONTROLLER_HAS_AUDIO_CLIPS               0x0200

/*-----------------------------------------------------------------------------*/

typedef struct TPControllerKeyMap TPControllerKeyMap;

/*
    Struct: TPControllerKeyMap

    This structure lets you map external key codes to TrickPlay key codes. You
    simply create an array of entries and pass a pointer to it in your <TPControllerSpec>.
    
    When you call <tp_controller_key_down> or <tp_controller_key_up>, you can pass
    your key code as the key_code parameter, and TrickPlay will map it accordingly.
*/

struct TPControllerKeyMap
{
    /*
        Field: your_key_code
        
        The code you will use when reporting key up and down events.
    */
    
    unsigned int your_key_code;
    
    /*
        Field: trickplay_key_code
        
        The matching trickplay_key_code. There is a list of key codes in keys.h.
    */
    
    unsigned int trickplay_key_code;
};

/*-----------------------------------------------------------------------------*/

typedef struct TPControllerSpec TPControllerSpec;

/*
    Struct: TPControllerSpec
    
    This structure lets you specify the capabilities of a controller and,
    optionally, provide a callback for the controller to execute commands.
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
        Field: key_map
        
        If you wish to map your key codes to standard TrickPlay codes automatically,
        pass a pointer to an array of <TPControllerKeyMap> structures here. The array
        should be terminated by zero values for both your key code and the trickplay
        key code.
        
        TrickPlay will make a copy of this array when you call <tp_context_add_controller>.
    */
    
    TPControllerKeyMap * key_map;
    
    /*
        Function: execute_command
        
        An optional callback that TrickPlay will invoke to instruct the controller
        to execute various commands. The possible commands depend on the
        capabilities reported by the controller.
        
        Arguments:
        
            controller -    The controller.
            
            command -       One of the <Controller Commands>.
            
            parameters -    A pointer to a structure with additional parameters for
                            commands that require them, or NULL.
                            
            data -          Opaque user data that was passed to <tp_context_add_controller>.
        
        Returns:
        
            0 -     If the command was executed.
            
            other - The command failed.
    */
    
    int
    (*execute_command)(
                           
        TPController * controller,
        unsigned int command,
        void * parameters,
        void * data);
};

/*-----------------------------------------------------------------------------*/
/*
    Section: Controller Commands
    
    These commands are passed to <TPControllerSpec.execute_command>.
    
    Some commands include additional parameters that are passed as a pointer to
    a structure. These parameters should be copied if you wish to retain them
    beyond the call to execute_command.
*/
/*-----------------------------------------------------------------------------*/
/*
    Constant: TP_CONTROLLER_COMMAND_RESET
    
    When this command is sent to a controller, it should stop the accelerometer, stop sending
    pointer events and touches, stop playing any sounds and clear the user interface, if any, removing
    backgrounds and images. The controller can continue to send key events.
    
    Parameters:
    
        None
*/

#define TP_CONTROLLER_COMMAND_RESET                 1

/*
    Constant: TP_CONTROLLER_COMMAND_START_ACCELEROMETER
    
    If the controller has an accelerometer, this command instructs it to start
    sending accelerometer events using the <tp_controller_accelerometer> function.
    This command is only sent when the controller includes
    TP_CONTROLLER_HAS_ACCELEROMETER in its capabilities.
    
    Parameters:
    
        A pointer to a <TPControllerStartAccelerometer> structure.
*/

#define TP_CONTROLLER_COMMAND_START_ACCELEROMETER   5

/*
    Constant: TP_CONTROLLER_COMMAND_STOP_ACCELEROMETER
    
    The controller should stop sending accelerometer events. This command is only
    sent when the controller includes TP_CONTROLLER_HAS_ACCELEROMETER in its
    capabilities.
    
    Parameters:
    
        None
*/

#define TP_CONTROLLER_COMMAND_STOP_ACCELEROMETER    6

/*
    Constant: TP_CONTROLLER_COMMAND_START_POINTER

    The controller should start sending pointer events. This command is only
    sent when the controller includes TP_CONTROLLER_HAS_POINTER in its
    capabilities.

    Parameters:

        None
*/

#define TP_CONTROLLER_COMMAND_START_POINTER         7

/*
    Constant: TP_CONTROLLER_COMMAND_STOP_POINTER

    The controller should stop sending pointer events. This command is only
    sent when the controller includes TP_CONTROLLER_HAS_POINTER in its
    capabilities.

    Parameters:

        None
*/

#define TP_CONTROLLER_COMMAND_STOP_POINTER          8

/*
    Constant: TP_CONTROLLER_COMMAND_START_TOUCHES
    
    The controller should start sending touch events using <tp_controller_touch_down>,
    <tp_controller_touch_move> and <tp_controller_touch_up>.
    This command is only sent when the controller includes
    TP_CONTROLLER_HAS_TOUCHES in its capabilities.
    
    Parameters:
    
        None
*/    

#define TP_CONTROLLER_COMMAND_START_TOUCHES         9

/*
    Constant: TP_CONTROLLER_COMMAND_STOP_TOUCHES
    
    The controller should stop sending touch events.
    This command is only sent when the controller includes
    TP_CONTROLLER_HAS_TOUCHES in its capabilities.
    
    Parameters:
    
        None
*/

#define TP_CONTROLLER_COMMAND_STOP_TOUCHES          10

/*
    Constant: TP_CONTROLLER_COMMAND_SHOW_MULTIPLE_CHOICE
    
    The controller should display an interface that allows the user to select
    one or more choices. TrickPlay sends a list of identifiers and captions. The
    captions should be displayed by the controller and, when the user selects one,
    the controller should generate a UI event using <tp_controller_ui_event> passing
    the associated identifier. The controller should not dismiss the list until
    TrickPlay sends <TP_CONTROLLER_COMMAND_CLEAR_UI>.
    
    The controller has some flexibility in how the list of choices is displayed
    and this presentation can vary on the number of choices. For example, if
    there are only two choices "Yes" and "No", the controller may display a simple
    alert box. If the choices are the 50 states, the controller may opt to display
    a scrolling table.

    This command is only sent if the controller includes
    TP_CONTROLLER_HAS_MULTIPLE_CHOICE in its capabilities.
    
    Parameters:
    
        A pointer to a <TPControllerMultipleChoice> structure.
*/

#define TP_CONTROLLER_COMMAND_SHOW_MULTIPLE_CHOICE  11

/*
    Constant: TP_CONTROLLER_COMMAND_CLEAR_UI
    
    The controller should clear all user interface elements, including multiple
    choice, background, images and text entry.
    
    This command is sent if the controller includes TP_CONTROLLER_HAS_MULTIPLE_CHOICE,
    TP_CONTROLLER_HAS_UI or TP_CONTROLLER_HAS_TEXT_ENTRY in its capabilities.
    
    Parameters:
    
        None
*/

#define TP_CONTROLLER_COMMAND_CLEAR_UI              12

/*
    Constant: TP_CONTROLLER_COMMAND_ENTER_TEXT
    
    The controller should allow the user to edit and submit some text. The
    parameters to this command include a caption for the text as well as an
    initial value. When the user has finished editing, the result should be
    submitted to TrickPlay using <tp_controller_ui_event>, passing the final
    string. The text entry user interface can be dismissed by the controller
    at the same time.
    
    This command is only sent if the controller includes
    TP_CONTROLLER_HAS_TEXT_ENTRY in its capabilities.
    
    Parameters:
    
        A pointer to a <TPControllerEnterText> structure.
*/

#define TP_CONTROLLER_COMMAND_ENTER_TEXT            13

/*
    Constant: TP_CONTROLLER_COMMAND_DECLARE_RESOURCE
    
    This command is used to let the controller know about resources that TrickPlay
    plans to use in the near future. Resources are images and sounds. TrickPlay
    sends the controller a 'resource name' which is a simple string used to
    refer to the resource as well as a URI to the resource. The URI could be
    local (file:) or remote (http:,https:).
    
    The controller should attempt to fetch the resource asynchronously and retain
    it along with a mapping to its name. In memory constrained environments, the
    controller may choose to retain only the name and the URI and fetch the
    resource later, when it is used.
    
    This command is only sent if the controller includes TP_CONTROLLER_HAS_SOUND
    or TP_CONTROLLER_HAS_UI in its capabilities.
    
    Parameters:
    
        A pointer to a <TPControllerDeclareResource> structure.
*/

#define TP_CONTROLLER_COMMAND_DECLARE_RESOURCE      20

/*
    Constant: TP_CONTROLLER_COMMAND_SET_UI_BACKGROUND
    
    The controller should display a background image.
    
    This command is only sent if the controller includes TP_CONTROLLER_HAS_UI
    in its capabilities.
    
    Parameters:
    
        A pointer to a <TPControllerSetUIBackground> structure.
*/

#define TP_CONTROLLER_COMMAND_SET_UI_BACKGROUND     30

/*
    Constant: TP_CONTROLLER_COMMAND_SET_UI_IMAGE
    
    The controller should display an image over the background and any other
    images.

    This command is only sent if the controller includes TP_CONTROLLER_HAS_UI
    in its capabilities.
    
    Parameters:
    
        A pointer to a <TPControllerSetUIImage> structure.
*/

#define TP_CONTROLLER_COMMAND_SET_UI_IMAGE          31

/*
    Constant: TP_CONTROLLER_COMMAND_PLAY_SOUND
    
    The controller should play a sound. The parameters include the resource name
    as well as a 'loop' variable.
    
    This command is only sent if the controller includes TP_CONTROLLER_HAS_SOUND
    in its capabilities.
    
    Parameters:
    
        A pointer to a <TPControllerPlaySound> structure.
*/

#define TP_CONTROLLER_COMMAND_PLAY_SOUND            40

/*
    Constant: TP_CONTROLLER_COMMAND_STOP_SOUND
    
    The controller should stop playing sounds.

    This command is only sent if the controller includes TP_CONTROLLER_HAS_SOUND
    in its capabilities.
    
    Parameters:
        
        None
*/

#define TP_CONTROLLER_COMMAND_STOP_SOUND            41

/*
    Constant: TP_CONTROLLER_COMMAND_SUBMIT_PICTURE

    The controller should send a picture.

    This command is only sent if the controller includes TP_CONTROLLER_HAS_PICTURES
    in its capabilities.

    Parameters:

        None
*/

#define TP_CONTROLLER_COMMAND_SUBMIT_PICTURE        100

/*
    Constant: TP_CONTROLLER_COMMAND_SUBMIT_AUDIO_CLIP

    The controller should send a picture.

    This command is only sent if the controller includes TP_CONTROLLER_HAS_AUDIO_CLIPS
    in its capabilities.

    Parameters:

        None
*/

#define TP_CONTROLLER_COMMAND_SUBMIT_AUDIO_CLIP     101

/*-----------------------------------------------------------------------------*/

typedef struct TPControllerStartAccelerometer TPControllerStartAccelerometer;

#define TP_CONTROLLER_ACCELEROMETER_FILTER_NONE     0
#define TP_CONTROLLER_ACCELEROMETER_FILTER_LOW      1
#define TP_CONTROLLER_ACCELEROMETER_FILTER_HIGH     2


/*
    Struct: TPControllerStartAccelerometer
    
    A pointer to a structure of this type is sent to execute_command when the
    command is <TP_CONTROLLER_COMMAND_START_ACCELEROMETER>.
*/

struct TPControllerStartAccelerometer
{
    /*
        Field: filter
        
        Specifies the type of filtering the controller should apply to the
        accelerometer events.
        
        Values:
        
            TP_CONTROLLER_ACCELEROMETER_FILTER_NONE - No filtering, send raw events.
            TP_CONTROLLER_ACCELEROMETER_FILTER_LOW  - Low-pass filtering.
            TP_CONTROLLER_ACCELEROMETER_FILTER_HIGH - High-pass filtering.    
        
    */
    
    unsigned int    filter;
    
    /*
        Field: interval
        
        A suggested interval in seconds between accelerometer events.
    */
    
    double          interval;
};


/*-----------------------------------------------------------------------------*/

typedef struct TPControllerMultipleChoice TPControllerMultipleChoice;

/*
    Struct: TPControllerMultipleChoice
    
    A pointer to a structure of this type is sent to execute_command when the
    command is <TP_CONTROLLER_COMMAND_SHOW_MULTIPLE_CHOICE>.
*/

struct TPControllerMultipleChoice
{
    /*
        Field: label
        
        A NULL terminated string that should be displayed along with the choices.
        It acts as the 'title' for the list of choices.
    */
    
    const char *    label;
    
    /*
        Field: count
        
        The number of ids and choices.
    */
    
    unsigned int    count;
    
    /*
        Field: ids
        
        An array of NULL terminated strings with count elements. When the user
        makes a selection, you should send one of these ids as the parameter to
        <tp_controller_ui_event>. The ids should not be displayed.
    */
    
    const char **   ids;
    
    /*
        Field: choices
        
        An array of NULL terminated strings with count elements. These should be
        shown to the user.
    */
    
    const char **   choices;
};

/*-----------------------------------------------------------------------------*/

typedef struct TPControllerEnterText TPControllerEnterText;

/*
    Struct: TPControllerEnterText
    
    A pointer to a structure of this type is passed to execute_command when the
    command is <TP_CONTROLLER_COMMAND_ENTER_TEXT>.
*/

struct TPControllerEnterText
{
    /*
        Field: label
        
        A NULL terminated string that should be displayed along with the text.
        This acts as the 'prompt' for the text. For example "Enter your user name".
    */
    
    const char *    label;
    
    /*
        Field: text
        
        A NULL terminated string that is the initial value. It may be empty.
    */
    
    const char *    text;
};

/*-----------------------------------------------------------------------------*/

typedef struct TPControllerDeclareResource TPControllerDeclareResource;

/*
    Struct: TPControllerDeclareResource
    
    A pointer to a structure of this type is passed to execute_command when the
    command is <TP_CONTROLLER_COMMAND_DECLARE_RESOURCE>.
*/

struct TPControllerDeclareResource
{
    /*
        Field: resource
        
        A NULL terminated string to associate with the resource. Other calls will
        refer to the resource by this name.
    */
    
    const char *    resource;
    
    /*
        Field: uri
        
        A NULL terminated URI to the resource. This may be local (file:) or
        remote (http: or https:). It is recommend that controllers fail on other
        schemes.
    */
    
    const char *    uri;
};

/*-----------------------------------------------------------------------------*/

typedef struct TPControllerSetUIBackground TPControllerSetUIBackground;

#define TP_CONTROLLER_UI_BACKGROUND_MODE_CENTER     1
#define TP_CONTROLLER_UI_BACKGROUND_MODE_STRETCH    2
#define TP_CONTROLLER_UI_BACKGROUND_MODE_TILE       3

/*
    Struct: TPControllerSetUIBackground
    
    A pointer to this structure is sent to execute_command when the command is
    <TP_CONTROLLER_COMMAND_SET_UI_BACKGROUND>.
*/

struct TPControllerSetUIBackground
{
    /*
        Field: resource
        
        The name of a resource that was declared in a previous call to
        execute_command with <TP_CONTROLLER_COMMAND_DECLARE_RESOURCE>.
    */
    
    const char *    resource;

    /*
        Field: mode
        
        How to scale the background.
        
        Values:
        
            TP_CONTROLLER_UI_BACKGROUND_MODE_CENTER     - The image should not be
                                                        scaled or stretched, it should
                                                        be displayed in its native
                                                        resolution and centered both
                                                        horizontally and vertically.
                                                        
            TP_CONTROLLER_UI_BACKGROUND_MODE_STRETCH    - The image should be scaled
                                                        to fit the size of the screen.
                                                        
            TP_CONTROLLER_UI_BACKGROUND_MODE_TILE       - The image should be tiled
                                                        both horizontally and vertically
                                                        to fit the size of the screen.
    */        
    
    unsigned int    mode;
};

/*-----------------------------------------------------------------------------*/

typedef struct TPControllerSetUIImage TPControllerSetUIImage;

/*
    Struct: TPControllerSetUIImage
    
    A pointer to a structure of this type is passed to execute_command when the
    command is <TP_CONTROLLER_COMMAND_SET_UI_IMAGE>.
*/

struct TPControllerSetUIImage
{
    /*
        Field: resource

        The name of a resource that was declared in a previous call to
        execute_command with <TP_CONTROLLER_COMMAND_DECLARE_RESOURCE>.
    */
    
    const char *    resource;
    
    /*
        Field: x
        
        Left coordinate for the image, in pixels.
    */
    
    int             x;
    
    /*
        Field: y
        
        Top coordinate for the image, in pixels.
    */
    
    int             y;
    
    /*
        Field: width
        
        The width of the bounding box for the image, in pixels.
    */
    
    int             width;
    
    /*
        Field: height
        
        The height of the bounding box for the image, in pixels.
    */
    
    int             height;
};

/*-----------------------------------------------------------------------------*/

typedef struct TPControllerPlaySound TPControllerPlaySound;

/*
    Struct: TPControllerPlaySound
    
    A pointer to a structure of this type is passed to execute_command when the
    command is <TP_CONTROLLER_COMMAND_PLAY_SOUND>.
*/
    
struct TPControllerPlaySound
{
    /*
        Field: resource
        
        The name of a resource that was declared in a previous call to
        execute_command with <TP_CONTROLLER_COMMAND_DECLARE_RESOURCE>.
    */
    
    const char *    resource;
    
    /*
        Field: loop
        
        How many times to play the sound. If zero, the sound should be played
        continuously until execute_command is called with
        <TP_CONTROLLER_COMMAND_STOP_SOUND> or <TP_CONTROLLER_COMMAND_RESET>.
        Otherwise, the sound should be played loop number of times.
    */
    
    unsigned int    loop;
};

/*-----------------------------------------------------------------------------*/
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
        
        key_code -      An identifier for the key. There is a list of key codes in keys.h.
        
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
        
        key_code -      An identifier for the key. There is a list of key codes in keys.h.
        
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
    
    Report an accelerometer event.
    
    Arguments:
    
        controller -    The controller returned by <tp_context_add_controller>.
        
        x,y,z -         The accelerometer values for each axis.
*/

    TP_API_EXPORT
    void
    tp_controller_accelerometer(
                                     
        TPController * controller,
        double x,
        double y,
        double z);

/*
    Callback: tp_controller_pointer_move

    Report a pointer motion event.

    Arguments:

        controller -    The controller returned by <tp_context_add_controller>.

        x,y -           The coordinates of the event, in pixels, relative to the display size.
*/

    TP_API_EXPORT
    void
    tp_controller_pointer_move(

        TPController * controller,
        int x,
        int y);

/*
    Callback: tp_controller_pointer_button_down

    Report a pointer button down event.

    Arguments:

        controller -    The controller returned by <tp_context_add_controller>.

        button -        The button number, where 1 is the first button.

        x,y -           The coordinates of the event, in pixels, relative to the display size.
*/

    TP_API_EXPORT
    void
    tp_controller_pointer_button_down(

        TPController * controller,
        int button,
        int x,
        int y);

/*
    Callback: tp_controller_pointer_button_up
    
    Report a pointer button up event.
    
    Arguments:
    
        controller -    The controller returned by <tp_context_add_controller>.
        
        button -        The button number, where 1 is the first button.

        x,y -           The coordinates of the event, in pixels, relative to the display size.
*/

    TP_API_EXPORT
    void
    tp_controller_pointer_button_up(
                             
        TPController * controller,
        int button,
        int x,
        int y);
    
/*
    Callback: tp_controller_touch_down
    
    Report a touch down event.

    Arguments:
    
        controller -    The controller returned by <tp_context_add_controller>.
        
        finger -        The finger number, starting with 1.

        x,y -           The coordinates of the event, in pixels.    
*/

    TP_API_EXPORT
    void
    tp_controller_touch_down(
                                  
        TPController * controller,
        int finger,
        int x,
        int y);

/*
    Callback: tp_controller_touch_move

    Report a touch move event.

    Arguments:
    
        controller -    The controller returned by <tp_context_add_controller>.
        
        finger -        The finger number, starting with 1.

        x,y -           The coordinates of the event, in pixels.
*/

    TP_API_EXPORT
    void
    tp_controller_touch_move(
                                  
        TPController * controller,
        int finger,
        int x,
        int y);
    
/*
    Callback: tp_controller_touch_up

    Report a touch move event.

    Arguments:
    
        controller -    The controller returned by <tp_context_add_controller>.
        
        finger -        The finger number, starting with 1.

        x,y -           The coordinates of the event, in pixels.
*/

    TP_API_EXPORT
    void
    tp_controller_touch_up(
                                
        TPController * controller,
        int finger,
        int x,
        int y);
    
/*
    Callback: tp_controller_ui_event

    Report a UI event. This is in response to <TP_CONTROLLER_COMMAND_SHOW_MULTIPLE_CHOICE>
    or <TP_CONTROLLER_COMMAND_ENTER_TEXT>.

    Arguments:
    
        controller -    The controller returned by <tp_context_add_controller>.
        
        parameters -    A NULL terminated string. In the case of <TP_CONTROLLER_COMMAND_SHOW_MULTIPLE_CHOICE>
                        this should be one of the identifiers. For <TP_CONTROLLER_COMMAND_ENTER_TEXT>,
                        this should be the final value of the text edited by the user.
*/

    TP_API_EXPORT
    void
    tp_controller_ui_event(
            
        TPController * controller,
        const char * parameters);


/*
	Callback: tp_controller_submit_picture

	Send picture data to Trickplay. This is in response to <TP_CONTROLLER_COMMAND_SUBMIT_PICTURE>.

	Arguments:

		controller -    The controller returned by <tp_context_add_controller>.

		data 		-   A pointer to the picture data
		size		- 	The size of the picture data
		mime_type	- 	The mime type of the picture data.
*/

    TP_API_EXPORT
    void
    tp_controller_submit_picture(
        TPController * controller, void * data, unsigned int size, const char * mime_type);

/*
	Callback: tp_controller_submit_audio_clip

	Send audio clip data to Trickplay. This is in response to <TP_CONTROLLER_COMMAND_SUBMIT_AUDIO_CLIP>.

	Arguments:

		controller -    The controller returned by <tp_context_add_controller>.

		data 		-   A pointer to the audio clip data
		size		- 	The size of the audio clip data
		mime_type	- 	The mime type of the audio clip data.
*/

    TP_API_EXPORT
    void
    tp_controller_submit_audio_clip(
        TPController * controller, void * data, unsigned int size, const char * mime_type);

/*-----------------------------------------------------------------------------*/
/*
    Section: Controller Event Queries

    These functions let you know whether a controller wants certain types of events.
    They are a convenience; so you don't have to keep track of the related start
    and stop commands.

    For example, a controller will want accelerometer events only if a) it has
    TP_CONTROLLER_HAS_ACCELEROMETER in its capabilities and b) the result of
    execute_command with TP_CONTROLLER_COMMAND_START_ACCELEROMETER was zero (success).

    You don't have to check these functions when you invoke the related event
    callbacks; they are checked automatically for you. For example, if you call
    tp_controller_accelerometer, and the controller does not want accelerometer
    events, the call is ignored.
*/

/*
    Function: tp_controller_wants_accelerometer_events

    Arguments:

        controller - The controller returned by <tp_context_add_controller>.

    Returns:

        0 - The controller does not want these events.

        other - The controller wants these events.
*/

    TP_API_EXPORT
    int
    tp_controller_wants_accelerometer_events(

        TPController * controller);

/*
    Function: tp_controller_wants_pointer_events

    Arguments:

        controller - The controller returned by <tp_context_add_controller>.

    Returns:

        0 - The controller does not want these events.

        other - The controller wants these events.
*/

    TP_API_EXPORT
    int
    tp_controller_wants_pointer_events(

        TPController * controller);

/*
    Function: tp_controller_wants_touch_events

    Arguments:

        controller - The controller returned by <tp_context_add_controller>.

    Returns:

        0 - The controller does not want these events.

        other - The controller wants these events.
*/

    TP_API_EXPORT
    int
    tp_controller_wants_touch_events(

        TPController * controller);

/*-----------------------------------------------------------------------------*/
/*
    Section: Controller Insertion and Removal
*/

/*
    Function: tp_context_add_controller
    
    Let TrickPlay know that a new controller has been connected. This function
    can be called before or after <tp_context_run> is called and is thread safe.
    
    TrickPlay will make a copy of the name and the spec.
    
    (code)
    
    TPControllerSpec spec;
    
    memset(&spec,0,sizeof(spec));
    
    spec.capabilities=TP_CONTROLLER_HAS_KEYS | TP_CONTROLLER_HAS_SOUND;
    
    TPController * controller=tp_context_add_controller(context,"My controller",&spec,NULL);
    
    (end)
    
    Arguments:
    
        context -   A pointer to the associated TrickPlay context.
        
        name -      A NULL terminated name for the controller. This should be
                    short and user friendly, such as "Remote control" or
                    "Craig's phone".
                    
        spec -      A pointer to a <TPControllerSpec> structure describing the
                    capabilities of the controller and providing a callback
                    for commands.
                    
        data -      User data opaque to TrickPlay. This is passed back to you
                    in calls to execute_command. It can be NULL.
                    
    Returns:
    
        controller - A pointer to a TPController structure. This structure is
                    opaque to you and does not need to be freed. You use this
                    pointer to associate events with the controller when calling
                    one of the <Controller Events> functions.
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
    
    Notify TrickPlay that a controller has been disconnected. Once you call
    this function, the TPController pointer will become invalid and making
    any other calls with it will result in an assertion.
    
    Arguments:
    
        context -   The associated TrickPlay context.
        
        controller - The controller that was disconnected.
*/

    TP_API_EXPORT
    void
    tp_context_remove_controller(
                                      
        TPContext * context,
        TPController * controller);


/*-----------------------------------------------------------------------------*/

#ifdef __cplusplus
}
#endif 

/*-----------------------------------------------------------------------------*/

#endif /* _TRICKPLAY_CONTROLLER_H */
