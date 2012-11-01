#ifndef __LEAF_H__
#define __LEAH_H__


#include "main.h"
#include "item.h"
#include <stdlib.h>

typedef struct Leaf {
    unsigned int w, h, area, x, y;
    Item * item;
} Leaf;

void leaf_cut ( Leaf * leaf, unsigned int w, unsigned int h, GSequence * leaves, Output * output );
Leaf * leaf_new ( unsigned int x, unsigned int y, unsigned int w, unsigned int h );
int leaf_compare ( gconstpointer a, gconstpointer b, gpointer user_data );
char * leaf_tostring ( Leaf * leaf, Options * options );


#endif
