#ifndef _TRICKPLAY_KEYS_H
#define _TRICKPLAY_KEYS_H

/*
-----------------------------------------------------------------------------
 For missing codes, use
 http://cgit.freedesktop.org/xorg/proto/x11proto/plain/keysymdef.h
-----------------------------------------------------------------------------
*/

#define TP_KEY_LEFT             0xff51  
#define TP_KEY_UP               0xff52  
#define TP_KEY_RIGHT            0xff53  
#define TP_KEY_DOWN             0xff54  
#define TP_KEY_RETURN           0xff0d
#define TP_KEY_ESCAPE		    0xff1b

#define TP_KEY_0                0x0030  
#define TP_KEY_1                0x0031  
#define TP_KEY_2                0x0032  
#define TP_KEY_3                0x0033  
#define TP_KEY_4                0x0034  
#define TP_KEY_5                0x0035  
#define TP_KEY_6                0x0036  
#define TP_KEY_7                0x0037  
#define TP_KEY_8                0x0038  
#define TP_KEY_9                0x0039  

#define TP_KEY_OK               0xff0d  // same as RETURN

/*
----------------------------------------------------------------------------
 This is the base for X extensions
----------------------------------------------------------------------------
*/

#define XK_VENDOR               0x10000000

/*
----------------------------------------------------------------------------
 Color buttons
*/

#define TP_KEY_RED              (XK_VENDOR+1)
#define TP_KEY_GREEN            (XK_VENDOR+2)
#define TP_KEY_YELLOW           (XK_VENDOR+3)
#define TP_KEY_BLUE             (XK_VENDOR+4)

/*
----------------------------------------------------------------------------
 Transport control
*/

#define TP_KEY_STOP             (XK_VENDOR+10)
#define TP_KEY_PLAY             (XK_VENDOR+11)
#define TP_KEY_PAUSE            (XK_VENDOR+12)
#define TP_KEY_REW              (XK_VENDOR+13)
#define TP_KEY_FFWD             (XK_VENDOR+14)
#define TP_KEY_PREV             (XK_VENDOR+15)
#define TP_KEY_NEXT             (XK_VENDOR+16)
#define TP_KEY_REC              (XK_VENDOR+17)

/*
-----------------------------------------------------------------------------
 Navigation
*/

#define TP_KEY_MENU             (XK_VENDOR+18)
#define TP_KEY_GUIDE            (XK_VENDOR+19)
#define TP_KEY_BACK             (XK_VENDOR+20)
#define TP_KEY_EXIT             (XK_VENDOR+21)
#define TP_KEY_INFO             (XK_VENDOR+22)
#define TP_KEY_TOOLS            (XK_VENDOR+23)

/*
----------------------------------------------------------------------------
 Channels
*/

#define TP_KEY_CHAN_UP          (XK_VENDOR+24)
#define TP_KEY_CHAN_DOWN        (XK_VENDOR+25)
#define TP_KEY_CHAN_LAST        (XK_VENDOR+26)
#define TP_KEY_CHAN_LIST        (XK_VENDOR+27)
#define TP_KEY_CHAN_FAV         (XK_VENDOR+28)

/*
----------------------------------------------------------------------------
 Audio
*/

#define TP_KEY_VOL_UP           (XK_VENDOR+30)
#define TP_KEY_VOL_DOWN         (XK_VENDOR+31)
#define TP_KEY_MUTE             (XK_VENDOR+32)

/*
----------------------------------------------------------------------------
 Captions
*/

#define TP_KEY_CC               (XK_VENDOR+40)

/*
----------------------------------------------------------------------------
 Custom codes should start with this
*/

#define TP_KEY_OEM_BASE         0x10100000


#endif /* _TRICKPLAY_KEYS_H */
