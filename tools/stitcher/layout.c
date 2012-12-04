#include <math.h>
#include "layout.h"
#include "leaf.h"
#include "item.h"

Layout * layout_new ( unsigned int width )
{
    Layout * layout = malloc( sizeof( Layout ) );

    layout->width = width;
    layout->height = 0;
    layout->area = 0;
    layout->coverage = 0.0f;
    layout->items_placed = 0;
    layout->items_skipped = 0;
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
        if ( leaf->w >= item->w && leaf->h >= item->h )
        {
            growth = MAX( layout->height, leaf->y + item->h ) - layout->height;
            if ( leaf->w == item->w || leaf->h == item->h )
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

    if(best) return best;
    if(close) return close;
    if(fallback) return fallback;
    return NULL;
}

void layout_scan_item( Item * item, Layout * layout )
{
    layout->min_item_w = MIN( layout->min_item_w, item->w );
    layout->min_item_h = MIN( layout->min_item_h, item->h );
    layout->max_item_w = MAX( layout->max_item_w, item->w );
    layout->item_area += item->area;
}

void layout_loop_item( Item * item, Layout * layout )
{
    Leaf * leaf = layout_leaf_for_item( layout, item );

    if ( leaf )
    {
        unsigned int covered = (unsigned int) ( layout->coverage * (float) layout->area );
        layout->height = MAX( layout->height, leaf->y + item->h );
        layout->area = layout->width * layout->height;
        layout->coverage = (float) ( covered + item->w * item->h ) / (float) layout->area;

        leaf->item = item;
        g_ptr_array_add( layout->places, leaf );
        leaf_cut( leaf, item->w, item->h, layout );
        layout->items_placed += 1;
    }
    else
    {
        layout->items_skipped += 1;
    }
}

Layout * layout_new_from_output ( Output * output, unsigned int width, Options * options )
{
    Layout * layout = layout_new( width );
    g_sequence_foreach( output->items, (GFunc) layout_scan_item, layout );

    if ( width < layout->max_item_w )
    {
        return layout;
    }

    Leaf * leaf = leaf_new( 0, 0, width, options->output_size_limit );
    g_sequence_insert_sorted( layout->leaves, leaf, leaf_compare, NULL );

    g_sequence_foreach( output->items, (GFunc) layout_loop_item, layout );

    return layout;
}

float layout_heuristic( Layout * layout )
{
    return pow( layout->coverage, 4.0 ) * ( layout->area + layout->width + layout->height );
}

Layout * layout_choose( Layout * a, Layout * b, Options * options )
{
    if(!a) return b;
    if(!b) return a;

    if ( a->height <= options->output_size_limit && a->items_placed > 0
        && ( b->coverage == 0 || layout_heuristic( a ) > layout_heuristic( b ) ) )
            return a;

    return b;
}
