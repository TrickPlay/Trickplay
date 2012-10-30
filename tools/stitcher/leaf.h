#ifndef __LEAF_H__
#define __LEAH_H__


#include "main.h"

#include <glib.h>

typedef struct Leaf {
    int x, y, w, h, area;
} Leaf;

void leaf_cut ( Leaf * leaf, int w, int h, GSequence *leaves_sorted_by_area, const Page *smallest );
Leaf * leaf_new ( int x, int y, int w, int h );
int leaf_compare ( gconstpointer a, gconstpointer b, gpointer user_data );

#define LEAF_AREA_COMPARE GINT_TO_POINTER(1)
#define LEAF_WIDTH_COMPARE GINT_TO_POINTER(2)
#define LEAF_HEIGHT_COMPARE GINT_TO_POINTER(3)


#endif
