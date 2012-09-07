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

    TP_CONTROLLER_HAS_FULL_MOTION     - The controller is capable of sending a full set of
                                        motion events beyond just accelerometer: gyro & mag, plus
                                        interpolated full aspect information

    TP_CONTROLLER_HAS_POINTER         - The controller has a pointer (mouse-like input).

    TP_CONTROLLER_HAS_POINTER_CURSOR  - The controller draws a pointer cursor on the screen.

    TP_CONTROLLER_HAS_SCROLL		  - The controller has a scroll-wheel-like device.

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

    TP_CONTROLLER_HAS_IMAGES          - The controller can can send pictures to Trickplay.

    TP_CONTROLLER_HAS_AUDIO_CLIPS     - The controller can send audio clips to Trickplay.

    TP_CONTROLLER_HAS_ADVANCED_UI     - The controller supports advanced UI operations.

    TP_CONTROLLER_HAS_VIRTUAL_REMOTE  - The controller can display a virtual remote.

*/

#define TP_CONTROLLER_HAS_KEYS                      0x0000000000000001UL
#define TP_CONTROLLER_HAS_ACCELEROMETER             0x0000000000000002UL
#define TP_CONTROLLER_HAS_POINTER                   0x0000000000000004UL
#define TP_CONTROLLER_HAS_TOUCHES                   0x0000000000000008UL
#define TP_CONTROLLER_HAS_MULTIPLE_CHOICE           0x0000000000000010UL
#define TP_CONTROLLER_HAS_SOUND                     0x0000000000000020UL
#define TP_CONTROLLER_HAS_UI                        0x0000000000000040UL
#define TP_CONTROLLER_HAS_TEXT_ENTRY                0x0000000000000080UL
#define TP_CONTROLLER_HAS_IMAGES                	0x0000000000000100UL
#define TP_CONTROLLER_HAS_AUDIO_CLIPS               0x0000000000000200UL
#define TP_CONTROLLER_HAS_VIRTUAL_REMOTE			0x0000000000000400UL
#define TP_CONTROLLER_HAS_SCROLL					0x0000000000000800UL
#define TP_CONTROLLER_HAS_ADVANCED_UI               0x0000000000001000UL
#define TP_CONTROLLER_HAS_POINTER_CURSOR			0x0000000000002000UL
#define TP_CONTROLLER_HAS_FULL_MOTION               0x0000000000004000UL
#define TP_CONTROLLER_HAS_STREAMING_VIDEO           0x0000000000008000UL

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

    unsigned long long capabilities;

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
        Field: id

        This is an optional string that can uniquely identify this controller across
        multiple connections. It can be NULL, in which case TrickPlay will assign a
        newly created id to the controller.
    */

    const char * id;

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

    When this command is sent to a controller, it should stop the accelerometer, gyro, etc., stop sending
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

        A pointer to a <TPControllerStartMotion> structure.
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

    The command also includes a 'group'; a string that groups related resources
    together. This group is passed to the command <TP_CONTROLLER_COMMAND_DROP_RESOURCE_GROUP>
    to give the controller a chance to discard all resources for the group.

    The controller should attempt to fetch the resource asynchronously and retain
    it along with a mapping to its name and group. In memory constrained environments, the
    controller may choose to retain only the name and the URI and fetch the
    resource later, when it is used.

    This command is only sent if the controller includes TP_CONTROLLER_HAS_SOUND
    or TP_CONTROLLER_HAS_UI in its capabilities.

    Parameters:

        A pointer to a <TPControllerDeclareResource> structure.
*/

#define TP_CONTROLLER_COMMAND_DECLARE_RESOURCE      20

/*
    Constant: TP_CONTROLLER_COMMAND_DROP_RESOURCE_GROUP

    This command lets the controller know that resources associated with a given
    group are no longer needed and can be safely discarded.

    If the controller has no knowledge of the group, it can just ignore the command;
    this is not considered a failure.

    This command is only sent if the controller includes TP_CONTROLLER_HAS_SOUND
    or TP_CONTROLLER_HAS_UI in its capabilities.

    Parameters:

        A pointer to a <TPControllerDropResourceGroup> structure.
*/

#define TP_CONTROLLER_COMMAND_DROP_RESOURCE_GROUP   21

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
    Constant: TP_CONTROLLER_COMMAND_SHOW_VIRTUAL_REMOTE

    The controller should display a virtual remote that sends key events.

    This command is only sent if the controller includes TP_CONTROLLER_HAS_VIRTUAL_REMOTE
    in its capabilities.

    Parameters:

        None.
*/

#define TP_CONTROLLER_COMMAND_SHOW_VIRTUAL_REMOTE   32

/*
    Constant: TP_CONTROLLER_COMMAND_HIDE_VIRTUAL_REMOTE

    The controller should hide the virtual remote.

    This command is only sent if the controller includes TP_CONTROLLER_HAS_VIRTUAL_REMOTE
    in its capabilities.

    Parameters:

        None.
*/

#define TP_CONTROLLER_COMMAND_HIDE_VIRTUAL_REMOTE   33

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
    Constant: TP_CONTROLLER_COMMAND_REQUEST_IMAGE

    The controller should send an image.

    This command is only sent if the controller includes TP_CONTROLLER_HAS_IMAGES
    in its capabilities.

    Parameters:

        A pointer to a <TPControllerRequestImage> structure
*/

#define TP_CONTROLLER_COMMAND_REQUEST_IMAGE        100

/*
    Constant: TP_CONTROLLER_COMMAND_REQUEST_AUDIO_CLIP

    The controller should send an audio clip.

    This command is only sent if the controller includes TP_CONTROLLER_HAS_AUDIO_CLIPS
    in its capabilities.

    Parameters:

        A pointer to a <TPControllerRequestAudio> structure
*/

#define TP_CONTROLLER_COMMAND_REQUEST_AUDIO_CLIP     101

/*
    Constant: TP_CONTROLLER_COMMAND_ADVANCED_UI

    Parameters:

    	A pointer to a <TPControllerAdvancedUI> structure.
*/

#define TP_CONTROLLER_COMMAND_ADVANCED_UI           200

/*
	Constant: TP_CONTROLLER_COMMAND_HIDE_POINTER_CURSOR

	The controller should hide its on-screen pointer cursor.

	Parameters:

    	None.
*/

#define TP_CONTROLLER_COMMAND_HIDE_POINTER_CURSOR	300

/*
	Constant: TP_CONTROLLER_COMMAND_SHOW_POINTER_CURSOR

	The controller should show its on-screen pointer cursor.

	Parameters:

    	None
*/

#define TP_CONTROLLER_COMMAND_SHOW_POINTER_CURSOR	301

/*
	Constant: TP_CONTROLLER_COMMAND_SET_POINTER_CURSOR

	The controller should change its on-screen pointer cursor.

	Parameters:

    	A pointer to a <TPControllerSetPointerCursor> structure.
*/

#define TP_CONTROLLER_COMMAND_SET_POINTER_CURSOR	302

#define TP_CONTROLLER_COMMAND_START_GYROSCOPE       400
#define TP_CONTROLLER_COMMAND_STOP_GYROSCOPE        401
#define TP_CONTROLLER_COMMAND_START_MAGNETOMETER    402
#define TP_CONTROLLER_COMMAND_STOP_MAGNETOMETER     403
#define TP_CONTROLLER_COMMAND_START_ATTITUDE        404
#define TP_CONTROLLER_COMMAND_STOP_ATTITUDE         405


#define TP_CONTROLLER_COMMAND_VIDEO_START_CALL      500
#define TP_CONTROLLER_COMMAND_VIDEO_END_CALL        501
#define TP_CONTROLLER_COMMAND_VIDEO_SEND_STATUS     502

/*-----------------------------------------------------------------------------*/

typedef struct TPControllerStartMotion TPControllerStartMotion;


#define TP_CONTROLLER_MOTION_FILTER_NONE            0
#define TP_CONTROLLER_MOTION_FILTER_LOW             1
#define TP_CONTROLLER_MOTION_FILTER_HIGH            2

/* *[deprecated]* TP_CONTROLLER_ACCELEROMETER_FILTER_NONE - use <TP_CONTROLLER_MOTION_FILTER_NONE> */
/* *[deprecated]* TP_CONTROLLER_ACCELEROMETER_FILTER_LOW - use <TP_CONTROLLER_MOTION_FILTER_LOW> */
/* *[deprecated]* TP_CONTROLLER_ACCELEROMETER_FILTER_HIGH - use <TP_CONTROLLER_MOTION_FILTER_HIGH> */

#define TP_CONTROLLER_ACCELEROMETER_FILTER_NONE     TP_CONTROLLER_MOTION_FILTER_NONE
#define TP_CONTROLLER_ACCELEROMETER_FILTER_LOW      TP_CONTROLLER_MOTION_FILTER_LOW
#define TP_CONTROLLER_ACCELEROMETER_FILTER_HIGH     TP_CONTROLLER_MOTION_FILTER_HIGH

/*
    Struct: TPControllerStartMotion

    A pointer to a structure of this type is sent to execute_command when the
    command is <TP_CONTROLLER_COMMAND_START_ACCELEROMETER>, <TP_CONTROLLER_COMMAND_START_GYROSCOPE>,
    <TP_CONTROLLER_COMMAND_START_MAGNETOMETER>, or <TP_CONTROLLER_COMMAND_START_ATTITUDE>.
*/

struct TPControllerStartMotion
{
    /*
        Field: filter

        Specifies the type of filtering the controller should apply to the
        motion events.

        Values:

            TP_CONTROLLER_MOTION_FILTER_NONE - No filtering, send raw events.
            TP_CONTROLLER_MOTION_FILTER_LOW  - Low-pass filtering.
            TP_CONTROLLER_MOTION_FILTER_HIGH - High-pass filtering.

    */

    unsigned int    filter;

    /*
        Field: interval

        A suggested interval in seconds between events.
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

    /*
        Field: group

        A NULL terminated string that assigns this resource to a group. Trickplay
        may later tell the controller to drop all resources associated with this
        group by calling execute_command with <TP_CONTROLLER_COMMAND_DROP_RESOURCE_GROUP>.
    */

    const char *    group;
};

/*-----------------------------------------------------------------------------*/

typedef struct TPControllerDropResourceGroup TPControllerDropResourceGroup;

/*
    Struct: TPControllerDropResourceGroup

    A pointer to a structure of this type is passed to execute_command when the
    command is <TP_CONTROLLER_COMMAND_DROP_RESOURCE_GROUP>.
*/

struct TPControllerDropResourceGroup
{
    /*
        Field: group

        A NULL terminated string containing the group to discard.
    */

    const char *    group;
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

typedef struct TPControllerAdvancedUI TPControllerAdvancedUI;

/*
    Struct: TPControllerAdvancedUI

    A pointer to this structure is passed to execute_command when the command
    is <TP_CONTROLLER_COMMAND_ADVANCED_UI>.
*/

struct TPControllerAdvancedUI
{
    /*
        Field: payload

        A JSON text describing the advanced UI command.
    */

    const char *    payload;

    /*
        Field: result

        A JSON text describing the result of the command.
    */

    char *          result;

    /*
        Field: free_result

        A function that will be called to free the result.
    */

    void            (*free_result)( void * result);
};

/*-----------------------------------------------------------------------------*/

typedef struct TPControllerRequestImage TPControllerRequestImage;

/*
    Struct: TPControllerRequestImage

    A pointer to a structure of this type is passed to execute_command when
    the command is <TP_CONTROLLER_COMMAND_REQUEST_IMAGE>.
*/

struct TPControllerRequestImage
{
    /*
        Field: max_width

        If max_width is greater than zero, the controller should scale the
        picture preserving its aspect ratio so that the width is not more
        than max_width.
    */

    unsigned int max_width;

    /*
        Field: max_height

        If max_height is greater than zero, the controller should scale the
        picture preserving its aspect ratio so that the height is not more
        than max_height.
    */

    unsigned int max_height;

    /*
        Field: edit

        If edit is not zero, the controller should give the user a chance to
        edit the picture before it is sent to Trickplay.
    */

    int edit;

    /*
        Field: mask

        If this field is not NULL, it will be the name of a resource declared
        in a previous call to execute_command with <TP_CONTROLLER_COMMAND_DECLARE_RESOURCE>.

        If present, the controller should retrieve the mask and composite it with
        the picture before submitting the result to Trickplay.
    */

    const char * mask;

    /*
        Field: dialog_label

        If this field is not NULL, it will be a label which should be displayed to the user as a
        prompt to choose an image to be sent from the controller.
    */

    const char * dialog_label;

    /*
        Field: cancel_label

        If this field is not NULL, it will be a label which should be displayed to the user on a
        button, allowing the user to cancel choosing an image to be sent from the controller.
        When the user presses that button, the controller should then generate a cancel event to the
        engine through <tp_controller_cancel_image>
    */

    const char * cancel_label;
};

/*-----------------------------------------------------------------------------*/

typedef struct TPControllerRequestAudio TPControllerRequestAudio;

/*
    Struct: TPControllerRequestAudio

    A pointer to a structure of this type is passed to execute_command when
    the command is <TP_CONTROLLER_COMMAND_REQUEST_AUDIO>.
*/

struct TPControllerRequestAudioClip
{
    /*
        Field: dialog_label

        If this field is not NULL, it will be a label which should be displayed to the user as a
        prompt to choose an audio clip to be sent from the controller.
    */

    const char * dialog_label;

    /*
        Field: cancel_label

        If this field is not NULL, it will be a label which should be displayed to the user on a
        button, allowing the user to cancel choosing an audio clip to be sent from the controller.
        When the user presses that button, the controller should then generate a cancel event to the
        engine through <tp_controller_cancel_audio_clip>
    */

    const char * cancel_label;
};

/*-----------------------------------------------------------------------------*/

typedef struct TPControllerSetPointerCursor TPControllerSetPointerCursor;

/*
 	Struct: TPControllerSetPointerCursor

 	A pointer a structure of this type is passed to execute_command when
 	the command is <TP_CONTROLLER_COMMAND_SET_POINTER_CURSOR>.
*/

struct TPControllerSetPointerCursor
{
	/*
		Field: x

		The X coordinate for the cursor's handle, relative to the dimensions
		of its image.
	*/

	int x;

	/*
		Field: y

		The Y coordinate for the cursor's handle, relative to the dimensions
		of its image.
	*/

	int y;

	/*
	 	Field: image_uri

	 	A URI to the image to use for the cursor.
	*/

	const char * image_uri;
};

/*-----------------------------------------------------------------------------*/
/*
    Section: Controller Events

    When a controller generates an event, it should pass it to TrickPlay using
    one or more of the functions described below. All of these functions are
    thread safe.
*/

/*
    Constants: Key Modifiers

    These constants describe key modifiers for key and pointer events. They can be
    ORed together and passed as the 'modifier' argument of event functions.

    TP_CONTROLLER_MODIFIER_NONE			- No modifier key is down.
    TP_CONTROLLER_MODIFIER_SHIFT		- The shift key is down.
    TP_CONTROLLER_MODIFIER_LOCK			- The caps lock key is down.
    TP_CONTROLLER_MODIFIER_CONTROL		- A control key is down.
    TP_CONTROLLER_MODIFIER_SUPER		- The super key is down.
    TP_CONTROLLER_MODIFIER_HYPER		- The hyper key is down.
    TP_CONTROLLER_MODIFIER_META			- The meta key is down.

	TP_CONTROLLER_MODIFIER_1			- Modifier key 1
	TP_CONTROLLER_MODIFIER_2			- Modifier key 2
	TP_CONTROLLER_MODIFIER_3			- Modifier key 3
	TP_CONTROLLER_MODIFIER_4			- Modifier key 4
	TP_CONTROLLER_MODIFIER_5			- Modifier key 5
*/

#define TP_CONTROLLER_MODIFIER_NONE			0x0000
#define TP_CONTROLLER_MODIFIER_SHIFT		0x0001
#define TP_CONTROLLER_MODIFIER_LOCK			0x0002
#define TP_CONTROLLER_MODIFIER_CONTROL		0x0004
#define TP_CONTROLLER_MODIFIER_SUPER		0x0008
#define TP_CONTROLLER_MODIFIER_HYPER		0x0010
#define TP_CONTROLLER_MODIFIER_META			0x0020

#define TP_CONTROLLER_MODIFIER_1			0x0100
#define TP_CONTROLLER_MODIFIER_2			0x0200
#define TP_CONTROLLER_MODIFIER_3			0x0400
#define TP_CONTROLLER_MODIFIER_4			0x0800
#define TP_CONTROLLER_MODIFIER_5			0x1000

/*
 	Constants: Scroll Directions

 	TP_CONTROLLER_SCROLL_UP				- Scroll Up
 	TP_CONTROLLER_SCROLL_DOWN			- Scroll Down
 	TP_CONTROLLER_SCROLL_LEFT			- Scroll Left
 	TP_CONTROLLER_SCORLL_RIGHT			- Scroll Right
*/

#define TP_CONTROLLER_SCROLL_UP				0
#define TP_CONTROLLER_SCROLL_DOWN			1
#define TP_CONTROLLER_SCROLL_LEFT			2
#define TP_CONTROLLER_SCROLL_RIGHT			3

/*
    Callback: tp_controller_key_down

    Report that a key was pressed.

    Arguments:

        controller -    The controller returned by <tp_context_add_controller>.

        key_code -      An identifier for the key. There is a list of key codes in keys.h.

        unicode -       The unicode character for the key, if any, or zero.

        modifiers -		A combination of <Key Modifiers>.
*/

    TP_API_EXPORT
    void
    tp_controller_key_down(

        TPController * controller,
        unsigned int key_code,
        unsigned long int unicode,
        unsigned long int modifiers);

/*
    Callback: tp_controller_key_up

    Report that a key was released.

    Arguments:

        controller -    The controller returned by <tp_context_add_controller>.

        key_code -      An identifier for the key. There is a list of key codes in keys.h.

        unicode -       The unicode character for the key, if any, or zero.

        modifiers -		A combination of <Key Modifiers>.
*/

    TP_API_EXPORT
    void
    tp_controller_key_up(

        TPController * controller,
        unsigned int key_code,
        unsigned long int unicode,
        unsigned long int modifiers);

/*
    Callback: tp_controller_accelerometer

    Report an accelerometer event.

    Arguments:

        controller -    The controller returned by <tp_context_add_controller>.

        x,y,z -         The accelerometer values for each axis.

        modifiers -		A combination of <Key Modifiers>.
*/

    TP_API_EXPORT
    void
    tp_controller_accelerometer(

        TPController * controller,
        double x,
        double y,
        double z,
        unsigned long int modifiers);


/*
    Callback: tp_controller_gyroscope

    Report a rotation event.

    Arguments:

        controller -    The controller returned by <tp_context_add_controller>.

        x,y,z -         Rotation rate about the given axis in radians per second.  The sign follows
                        the right-hand rule: If the right hand is wrapped around the axis such that
                        the tip of the thumb points toward the positive direction in that axis, a
                        positive rotation is one towards the tips of the other four fingers.

        modifiers -     A combinations of <Key Modifiers>.
*/

    TP_API_EXPORT
    void
    tp_controller_gyroscope(

        TPController * controller,
        double x,
        double y,
        double z,
        unsigned long int modifiers);

/*
    Callback: tp_controller_magnetometer

    Report a magnetometer event.

    Arguments:

        controller -    The controller returned by <tp_context_add_controller>.

        x,y,z -         Magnetic field in microteslas in each axis.

        modifiers -     A combinations of <Key Modifiers>.
*/

    TP_API_EXPORT
    void
    tp_controller_magnetometer(

        TPController * controller,
        double x,
        double y,
        double z,
        unsigned long int modifiers);

/*
    Callback: tp_controller_attitude

    Report a rotation event.

    Arguments:

        controller -    The controller returned by <tp_context_add_controller>.

        roll -          The roll of the device, in radians.  A roll is a rotation around a
                        longitudinal axis that passes through the device from its top to bottom.

        pitch -         The pitch of the device, in radians.  A pitch is a rotation around a lateral
                        axis that passes through the device from side to side.

        yaw -           The yaw of the device, in radians.  A yaw is a rotation around an axis that
                        runs vertically through the device. It is perpendicular to the body of the
                        device, with its origin at the center of gravity and directed toward the
                        bottom of the device.

        modifiers -     A combinations of <Key Modifiers>.
*/

    TP_API_EXPORT
    void
    tp_controller_attitude(

        TPController * controller,
        double roll,
        double pitch,
        double yaw,
        unsigned long int modifiers);

/*
    Callback: tp_controller_pointer_move

    Report a pointer motion event.

    Arguments:

        controller -    The controller returned by <tp_context_add_controller>.

        x,y -           The coordinates of the event, in pixels, relative to the display size.

        modifiers -		A combination of <Key Modifiers>.
*/

    TP_API_EXPORT
    void
    tp_controller_pointer_move(

        TPController * controller,
        int x,
        int y,
        unsigned long int modifiers);

/*
    Callback: tp_controller_pointer_button_down

    Report a pointer button down event.

    Arguments:

        controller -    The controller returned by <tp_context_add_controller>.

        button -        The button number, where 1 is the first button.

        x,y -           The coordinates of the event, in pixels, relative to the display size.

        modifiers -		A combination of <Key Modifiers>.
*/

    TP_API_EXPORT
    void
    tp_controller_pointer_button_down(

        TPController * controller,
        int button,
        int x,
        int y,
        unsigned long int modifiers);

/*
    Callback: tp_controller_pointer_button_up

    Report a pointer button up event.

    Arguments:

        controller -    The controller returned by <tp_context_add_controller>.

        button -        The button number, where 1 is the first button.

        x,y -           The coordinates of the event, in pixels, relative to the display size.

        modifiers -		A combination of <Key Modifiers>.
*/

    TP_API_EXPORT
    void
    tp_controller_pointer_button_up(

        TPController * controller,
        int button,
        int x,
        int y,
        unsigned long int modifiers);

/*
	Callback: tp_controller_pointer_active

	Report that the pointer is active.

	Arguments:

		controller -    The controller returned by <tp_context_add_controller>.
*/

	TP_API_EXPORT
	void
	tp_controller_pointer_active(

		TPController * controller);

/*
	Callback: tp_controller_pointer_inactive

	Report that the pointer is inactive.

	Arguments:

		controller -    The controller returned by <tp_context_add_controller>.
*/

	TP_API_EXPORT
	void
	tp_controller_pointer_inactive(

		TPController * controller);

/*
    Callback: tp_controller_touch_down

    Report a touch down event.

    Arguments:

        controller -    The controller returned by <tp_context_add_controller>.

        finger -        The finger number, starting with 1.

        x,y -           The coordinates of the event, in pixels.

        modifiers -		A combination of <Key Modifiers>.
*/

    TP_API_EXPORT
    void
    tp_controller_touch_down(

        TPController * controller,
        int finger,
        int x,
        int y,
        unsigned long int modifiers);

/*
    Callback: tp_controller_touch_move

    Report a touch move event.

    Arguments:

        controller -    The controller returned by <tp_context_add_controller>.

        finger -        The finger number, starting with 1.

        x,y -           The coordinates of the event, in pixels.

        modifiers -		A combination of <Key Modifiers>.
*/

    TP_API_EXPORT
    void
    tp_controller_touch_move(

        TPController * controller,
        int finger,
        int x,
        int y,
        unsigned long int modifiers);

/*
    Callback: tp_controller_touch_up

    Report a touch move event.

    Arguments:

        controller -    The controller returned by <tp_context_add_controller>.

        finger -        The finger number, starting with 1.

        x,y -           The coordinates of the event, in pixels.

        modifiers -		A combination of <Key Modifiers>.
*/

    TP_API_EXPORT
    void
    tp_controller_touch_up(

        TPController * controller,
        int finger,
        int x,
        int y,
        unsigned long int modifiers);

/*
	Callback: tp_controller_scroll

	Report a scroll event.

	Arguments:

		controller	- The controller.

		direction	- One of the <Scroll Directions>.

		modifiers	- A combination of <Key Modifiers>.
*/

    TP_API_EXPORT
    void
    tp_controller_scroll(

        TPController * controller,
        int direction,
        unsigned long int modifiers);

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
	Callback: tp_controller_submit_image

	Send image data to Trickplay. This is in response to <TP_CONTROLLER_COMMAND_REQUEST_IMAGE>.

	Arguments:

		controller -    The controller returned by <tp_context_add_controller>.

		data 		-   A pointer to the image data.

		size		- 	The size of the image data.

		mime_type	- 	The mime type of the image data. This can be NULL.
*/

    TP_API_EXPORT
    void
    tp_controller_submit_image(

        TPController * controller,
        const void * data,
        unsigned int size,
        const char * mime_type);

/*
	Callback: tp_controller_submit_audio_clip

	Send audio clip data to Trickplay. This is in response to <TP_CONTROLLER_COMMAND_REQUEST_AUDIO_CLIP>.

	Arguments:

		controller -    The controller returned by <tp_context_add_controller>.

		data 		-   A pointer to the audio clip data.

		size		- 	The size of the audio clip data.

		mime_type	- 	The mime type of the audio clip data. This can be NULL.
*/

    TP_API_EXPORT
    void
    tp_controller_submit_audio_clip(

        TPController * controller,
        const void * data,
        unsigned int size,
        const char * mime_type);

/*
	Callback: tp_controller_cancel_image

	Cancel send of image data to Trickplay. This is in response to <TP_CONTROLLER_COMMAND_REQUEST_IMAGE>.

	Arguments:

		controller -    The controller returned by <tp_context_add_controller>.
*/

    TP_API_EXPORT
    void
    tp_controller_cancel_image(

        TPController * controller);

/*
	Callback: tp_controller_cancel_audio_clip

	Cancel send of audio clip data to Trickplay. This is in response to <TP_CONTROLLER_COMMAND_REQUEST_IMAGE>.

	Arguments:

		controller -    The controller returned by <tp_context_add_controller>.
*/

    TP_API_EXPORT
    void
    tp_controller_cancel_audio_clip(

        TPController * controller);


/*
    Callback: tp_controller_advanced_ui_ready

    Report that advanced UI features are ready for use.

    Arguments:

        controller -    The controller returned by <tp_context_add_controller>.
*/

	TP_API_EXPORT
	void
	tp_controller_advanced_ui_ready(

		TPController * controller);

/*
	Callback: tp_controller_advanced_ui_event

	Report an advanced UI event.

	Arguments:

		controller -    The controller returned by <tp_context_add_controller>.

		json 	   -    A NULL terminated string.
*/

	TP_API_EXPORT
	void
	tp_controller_advanced_ui_event(

		TPController * controller,
		const char * json);

/*
	Callback: tp_controller_streaming_video_connected

	Report that a call connected successfully

	Arguments:

		controller -    The controller returned by <tp_context_add_controller>.

		address	   -    A NULL terminated string.
*/

	TP_API_EXPORT
	void
	tp_controller_streaming_video_connected(

		TPController * controller,
		const char * address);

/*
	Callback: tp_controller_streaming_video_failed

	Report that a call failed to connect successfully

	Arguments:

		controller -    The controller returned by <tp_context_add_controller>.

		address	   -    A NULL terminated string.

		reason     -    A NULL terminated string.
*/

	TP_API_EXPORT
	void
	tp_controller_streaming_video_failed(

		TPController * controller,
		const char * address,
		const char * reason);

/*
	Callback: tp_controller_streaming_video_dropped

	Report that a call which had connected has shut down abnormally

	Arguments:

		controller -    The controller returned by <tp_context_add_controller>.

		address	   -    A NULL terminated string.

		reason     -    A NULL terminated string.
*/

	TP_API_EXPORT
	void
	tp_controller_streaming_video_dropped(

		TPController * controller,
		const char * address,
		const char * reason);

/*
	Callback: tp_controller_streaming_video_ended

	Report that a call connected successfully

	Arguments:

		controller -    The controller returned by <tp_context_add_controller>.

		address	   -    A NULL terminated string.

		who        -    A NULL terminated string.
*/

	TP_API_EXPORT
	void
	tp_controller_streaming_video_ended(

		TPController * controller,
		const char * address,
		const char * who);

/*
	Callback: tp_controller_streaming_video_status

	Report the current status of the video calling system

	Arguments:

		controller -    The controller returned by <tp_context_add_controller>.

		status	   -    A NULL terminated string.

		arg        -    A NULL terminated string.
*/

	TP_API_EXPORT
	void
	tp_controller_streaming_video_status(

		TPController * controller,
		const char * status,
		const char * arg);


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
    Function: tp_controller_wants_gyroscope_events

    Arguments:

        controller - The controller returned by <tp_context_add_controller>.

    Returns:

        0 - The controller does not want these events.

        other - The controller wants these events.
*/

    TP_API_EXPORT
    int
    tp_controller_wants_gyroscope_events(

        TPController * controller);

/*
    Function: tp_controller_wants_magnetometer_events

    Arguments:

        controller - The controller returned by <tp_context_add_controller>.

    Returns:

        0 - The controller does not want these events.

        other - The controller wants these events.
*/

    TP_API_EXPORT
    int
    tp_controller_wants_magnetometer_events(

        TPController * controller);

/*
    Function: tp_controller_wants_attitude_events

    Arguments:

        controller - The controller returned by <tp_context_add_controller>.

    Returns:

        0 - The controller does not want these events.

        other - The controller wants these events.
*/

    TP_API_EXPORT
    int
    tp_controller_wants_attitude_events(

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
