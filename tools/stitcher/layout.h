#ifndef __LAYOUT_H__

#include <glib.h>

typedef struct Layout {
    unsigned int width,
                 height,
                 area,
                 items_placed,
                 min_item_w,
                 min_item_h,
                 max_item_w,
                 item_area;
                 
    float        coverage;
    GSequence *  leaves;
    GPtrArray *  places;
} Layout;

#define __LAYOUT_H__

#include "options.h"
#include "state.h"

Layout * layout_new ( unsigned int width );
Layout * layout_new_from_state ( State * state, unsigned int width, Options * options );
Layout * layout_choose ( Layout * a, Layout * b, Options * options );
void layout_free ( Layout * layout );

#endif
