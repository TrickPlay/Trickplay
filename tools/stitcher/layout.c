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
    layout->status = LAYOUT_FOUND_NONE;
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

    return best ?: close ?: fallback ?: NULL;
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
    
    layout->status = leaf ? MAX( layout->status, LAYOUT_FOUND_SOME )
                          : MIN( layout->status, LAYOUT_FOUND_SOME );
    if ( leaf )
    {
        unsigned int covered = (unsigned int) ( layout->coverage * (float) layout->area );
        layout->height = MAX( layout->height, leaf->y + item->h );
        layout->area = layout->width * layout->height;
        layout->coverage = (float) ( covered + item->w * item->h ) / (float) layout->area;
        
        leaf->item = item;
        g_ptr_array_add( layout->places, leaf );
        leaf_cut( leaf, item->w, item->h, layout );
    }
}

Layout * layout_new_from_output ( Output * output, unsigned int width, Options * options )
{
    Layout * layout = layout_new( width );
    layout->status = options->allow_multiple_sheets ? LAYOUT_FOUND_NONE : LAYOUT_FOUND_ALL;
    g_sequence_foreach( output->items, (GFunc) layout_scan_item, layout );
    
    Leaf * leaf = leaf_new( 0, 0, MAX( width, layout->max_item_w ),
        options->output_size_limit * ( options->allow_multiple_sheets ? 1 : 2 ) );
    g_sequence_insert_sorted( layout->leaves, leaf, leaf_compare, NULL );
    
    g_sequence_foreach( output->items, (GFunc) layout_loop_item, layout );
    
    return layout;
}

Layout * layout_choose( Layout * a, Layout * b, Options * options )
{
	if ( !a || !b )
        return a ?: b;
    
    if ( a->height <= options->output_size_limit ) {
        //if ( options->allow_multiple_sheets )
        //{
            if ( b->coverage == 0 || pow( a->coverage, 4.0 ) * a->area > pow( b->coverage, 4.0 ) * b->area )
                return a;
        //}
        //else if ( b->area == 0 || a->area < b->area || ( a->area == b->area && a->width + a->height <= b->width + b->height ) )
        //    return a;
    }
    return b;
}