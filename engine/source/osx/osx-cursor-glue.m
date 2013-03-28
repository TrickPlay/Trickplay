#include "osx/osx-cursor-glue.h"

#include <X11/cursorfont.h>

#import <AppKit/AppKit.h>


void osx_cursor_glue_set( int cursor )
{
    NSAutoreleasePool* autorelease_pool = [[NSAutoreleasePool alloc] init];

    switch ( cursor )
    {
        case XC_bottom_side:
            [[NSCursor resizeDownCursor] set];
            break;

        case XC_crosshair:
            [[NSCursor crosshairCursor] set];
            break;

        case XC_fleur:
            [[NSCursor closedHandCursor] set];

        case XC_left_side:
            [[NSCursor resizeLeftCursor] set];
            break;

        case XC_right_side:
            [[NSCursor resizeRightCursor] set];
            break;

        case XC_sb_h_double_arrow:
            [[NSCursor resizeLeftRightCursor] set];
            break;

        case XC_sb_v_double_arrow:
            [[NSCursor resizeUpDownCursor] set];
            break;

        case XC_top_side:
            [[NSCursor resizeUpCursor] set];
            break;

        case XC_xterm:
            [[NSCursor IBeamCursor] set];
            break;

        case XC_left_ptr:
        default:
            [[NSCursor arrowCursor] set];
    }

    [autorelease_pool release];
}
