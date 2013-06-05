#include "leaf.h"

// because the comparison given to g_sequence_lookup cannot, on its own, distinguish between leaves of equal area

void g_sequence_remove_sorted( GSequence* seq, gpointer data, GCompareDataFunc cmp_func, gpointer cmp_data )
{
    gpointer found;
    GSequenceIter* sj, * si = g_sequence_lookup( seq, data, cmp_func, cmp_data );

    if ( si == NULL )
    {
        return;
    }

    sj = si;

    while ( !g_sequence_iter_is_end( sj ) )
    {
        found = g_sequence_get( sj );

        if ( found == data )
        {
            g_sequence_remove( sj );
            return;
        }
        else if ( cmp_func( found, data, cmp_data ) != 0 )
        {
            break;
        }

        sj = g_sequence_iter_next( sj );
    }

    sj = si;

    while ( !g_sequence_iter_is_begin( sj ) )
    {
        sj = g_sequence_iter_prev( sj );
        found = g_sequence_get( sj );

        if ( found == data )
        {
            g_sequence_remove( sj );
            return;
        }
        else if ( cmp_func( found, data, cmp_data ) != 0 )
        {
            break;
        }
    }
}

int leaf_compare( gconstpointer a, gconstpointer b, gpointer user_data __attribute__( ( unused ) ) )
{
    Leaf* aa = ( Leaf* ) a,
          * bb = ( Leaf* ) b;
    return ( int ) aa->area - ( int ) bb->area;
}

Leaf* leaf_new( unsigned int x, unsigned int y, unsigned int w, unsigned int h )
{
    Leaf* leaf = malloc( sizeof( Leaf ) );

    leaf->x = x;
    leaf->y = y;
    leaf->w = w;
    leaf->h = h;
    leaf->area = w * h;
    leaf->item = NULL;

    return leaf;
}

// splits a leaf as if taking a (w x h) chunk out of its top-left corner, making up to two new leaves if they would be large enough

void leaf_cut( Leaf* leaf, unsigned int w, unsigned int h, Layout* layout )
{
    gboolean b = leaf->w - w > leaf->h - h;

    if ( leaf->w - w > layout->min_item_w )
    {
        g_sequence_insert_sorted( layout->leaves, leaf_new( leaf->x + w, leaf->y, leaf->w - w, b ? leaf->h : h ), leaf_compare, NULL );
    }

    if ( leaf->h - h > layout->min_item_h )
    {
        g_sequence_insert_sorted( layout->leaves, leaf_new( leaf->x, leaf->y + h, b ? w : leaf->w, leaf->h - h ), leaf_compare, NULL );
    }

    g_sequence_remove_sorted( layout->leaves, leaf, leaf_compare, NULL );
}
