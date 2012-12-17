#include <math.h>
#include "layout.h"
#include "leaf.h"
#include "item.h"

Layout * layout_new ( unsigned width, unsigned buffer_pixels )
{
    Layout * layout = malloc( sizeof( Layout ) );
    
    layout->buffer_pixels = buffer_pixels;
    layout->width = width;
    layout->height = 0;
    layout->area = 0;
    layout->coverage = 0.0f;
    layout->min_item_w = 256;
    layout->min_item_h = 256;
    layout->max_item_w = 0;
    layout->item_area  = 0;
    
    layout->leaves = g_sequence_new( NULL );
    layout->places = g_ptr_array_new_with_free_func( g_free );
    
    return layout;
}

void layout_free ( Layout * layout )
{
    g_ptr_array_free( layout->places, TRUE );
    g_sequence_foreach( layout->leaves, (GFunc) g_free, NULL );
    g_sequence_free( layout->leaves );
    free( layout );
}

/*
unsigned int gcf( unsigned int a, unsigned int b )
{
    unsigned int t;
    if ( b > a )
    {
        t = b;
        b = a;
        a = t;
    }
    while ( b != 0 )
    {
        t = b;
        b = a % b;
        a = t;
    }
    return a;
}
*/

#define W( item ) ( ( item )->w + 2 * layout->buffer_pixels )
#define H( item ) ( ( item )->h + 2 * layout->buffer_pixels )
#define AREA( item ) ( W( item ) * H( item ) )

Leaf * layout_leaf_for_item ( Layout * layout, Item * item )
{
    // searches for a leaf with the best shape-match that expands the height of the page the least

    unsigned int growth, close_growth = 0, fallback_growth = 0;
    Leaf * leaf     = NULL,
         * best     = NULL,
         * close    = NULL,
         * fallback = NULL;

    GSequenceIter * si = g_sequence_search( layout->leaves, item, leaf_compare, NULL );
    while ( !g_sequence_iter_is_end( si ) )
    {
        leaf = g_sequence_get( si );
        if ( leaf->w >= W( item ) && leaf->h >= H( item ) )
        {
            growth = MAX( layout->height, leaf->y + H( item ) ) - layout->height;
            if ( leaf->w == W( item ) || leaf->h == H( item ) )
            {
                if ( growth == 0 )
                {
                    return leaf;
                }
                else if ( growth < close_growth || close_growth == 0 )
                {
                    close = leaf;
                    close_growth = growth;
                }
            }
            else
            {
                if ( growth == 0 )
                {
                    best = leaf;
                }
                else if ( growth < fallback_growth || fallback_growth == 0 )
                {
                    fallback = leaf;
                    fallback_growth = growth;
                }
            }
        }

        si = g_sequence_iter_next( si );
    }

    if ( best )     return best;
    if ( close )    return close;
    if ( fallback ) return fallback;
    return NULL;
}

void layout_scan_item( Item * item, Layout * layout )
{
    layout->min_item_w = MIN( layout->min_item_w, W( item ) );
    layout->min_item_h = MIN( layout->min_item_h, H( item ) );
    layout->max_item_w = MAX( layout->max_item_w, W( item ) );
    layout->item_area += AREA( item );
}

void layout_loop_item( Item * item, Layout * layout )
{
    Leaf * leaf = layout_leaf_for_item( layout, item );

    if ( leaf )
    {
        unsigned covered = (unsigned) ( layout->coverage * (float) layout->area );
        layout->height = MAX( layout->height, leaf->y + H( item ) );
        layout->area = layout->width * layout->height;
        layout->coverage = (float) ( covered + AREA( item ) ) / (float) layout->area;

        leaf->item = item;
        g_ptr_array_add( layout->places, leaf );
        leaf_cut( leaf, W( item ), H( item ), layout );
    }
}

Layout * layout_new_from_state ( State * state, unsigned width, Options * options )
{
    Layout * layout = layout_new( width, options->add_buffer_pixels ? 1 : 0 );
    g_sequence_foreach( state->items, (GFunc) layout_scan_item, layout );

    if ( width < layout->max_item_w )
    {
        return layout;
    }

    Leaf * leaf = leaf_new( 0, 0, width, options->output_size_limit );
    g_sequence_insert_sorted( layout->leaves, leaf, leaf_compare, NULL );

    g_sequence_foreach( state->items, (GFunc) layout_loop_item, layout );

    return layout;
}

float layout_heuristic( Layout * layout )
{
    return pow( layout->coverage, 4.0 ) * ( layout->area + layout->width + layout->height );
}

Layout * layout_choose( Layout * a, Layout * b, Options * options )
{
    if ( !a ) return b;
    if ( !b ) return a;

    if ( a->places->len > 0 && ( b->coverage == 0 || layout_heuristic( a ) > layout_heuristic( b ) ) )
            return a;

    return b;
}
