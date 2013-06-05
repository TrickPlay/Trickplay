#ifndef __LAYOUT_H__

/*

layout.h

Layout uses a deterministic space-partitioning algorithm to arrange items from a State in a minimally wasteful manner. The space begins as one Leaf partition, and the highest-sorted Item in placed in its top-left corner, dividing the remaining space into two Leaf partitions. This repeats for each Item in the State:
    - select the Leaf that best matches the shape of the current Item and packs the tightest
    - place the Item
    - subdivide the remaining space

Layouts are then valued based on their packing efficiency, largeness, and squareness, in that order.

If the maximum textures size (-t) is too small to hold all the Items in one Layout, some items may be excluded and need to be processed into second or third Layouts.

*/

#include <glib.h>

typedef struct Layout
{
    unsigned buffer_pixels,
             width,
             height,
             area,
             min_item_w,
             min_item_h,
             max_item_w,
             max_item_h,
             item_area;

    float    coverage,
             value;

    GSequence*   leaves;
    GPtrArray*   places;
} Layout;

#define __LAYOUT_H__

#include "options.h"
#include "state.h"

Layout* layout_new( unsigned width, unsigned buffer_pixels );
Layout* layout_new_from_state( State* state, unsigned width, Options* options );
void layout_free( Layout* layout );

#endif
