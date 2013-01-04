#ifndef __LEAF_H__
#define __LEAH_H__

#include <stdlib.h>
#include "layout.h"
#include "item.h"

typedef struct Leaf {
    unsigned int w, h, area, x, y;
    Item * item;
} Leaf;

void leaf_cut ( Leaf * leaf, unsigned int w, unsigned int h, Layout * layout );
Leaf * leaf_new ( unsigned int x, unsigned int y, unsigned int w, unsigned int h );
int leaf_compare ( gconstpointer a, gconstpointer b, gpointer user_data );
void g_sequence_remove_sorted ( GSequence * seq, gpointer data, GCompareDataFunc cmp_func, gpointer cmp_data );


#endif
