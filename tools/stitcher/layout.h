#ifndef __LAYOUT_H__

#include <glib.h>

enum {
    LAYOUT_FOUND_NONE,
    LAYOUT_FOUND_SOME,
    LAYOUT_FOUND_ALL
};

typedef struct Layout {
    unsigned int width,
        height,
        area;
    float coverage;
    int status,
        min_item_w,
        min_item_h,
        max_item_w,
        item_area;
    GSequence * leaves;
    GPtrArray * places;
} Layout;

#define __LAYOUT_H__

#include "options.h"
#include "output.h"

void layout_free ( Layout * layout );
Layout * layout_new_from_output ( Output * output, unsigned int width, Options * options );
Layout * layout_choose ( Layout * a, Layout * b, Options * options );

#endif