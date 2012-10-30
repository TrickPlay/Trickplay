#include "leaf.h"
#include <stdlib.h>

/*
GSequence * get_sequence ( GHashTable * table, int key )
{
    gpointer ptr = GINT_TO_POINTER( key + 1 );

    GSequence * seq = g_hash_table_lookup( table, ptr );
    if ( seq == NULL )
        g_hash_table_insert( table, ptr, ( seq = g_sequence_new( NULL ) ) );

    return seq;
}
*/

void g_sequence_remove_sorted ( GSequence * seq, gpointer data, GCompareDataFunc cmp_func, gpointer cmp_data )
{
    gpointer found;
    GSequenceIter * sj, * si = g_sequence_lookup( seq, data, cmp_func, cmp_data );
    if ( si == NULL )
        return;

    sj = si;
    while ( !g_sequence_iter_is_end( sj ) )
    {
        found = g_sequence_get( sj );
        if ( found == data )
            return g_sequence_remove( sj );
        else if ( cmp_func( found, data, cmp_data ) != 0 )
            break;
        sj = g_sequence_iter_next( sj );
    }

    sj = si;
    while ( !g_sequence_iter_is_begin( sj ) )
    {
        sj = g_sequence_iter_prev( sj );
        found = g_sequence_get( sj );
        if ( found == data )
            return g_sequence_remove( sj );
        else if ( cmp_func( found, data, cmp_data ) != 0 )
            break;
    }
}

int leaf_compare ( gconstpointer a, gconstpointer b, gpointer user_data )
{
    Leaf * aa = (Leaf *) a, * bb = (Leaf *) b;
    return user_data == LEAF_AREA_COMPARE   ? aa->area - bb->area :
           user_data == LEAF_WIDTH_COMPARE  ? aa->w    - bb->w    :
           user_data == LEAF_HEIGHT_COMPARE ? aa->h    - bb->h    : 0;
}

Leaf * leaf_new ( int x, int y, int w, int h )
{
    Leaf * leaf = malloc( sizeof( Leaf ) );
    leaf->x = x;
    leaf->y = y;
    leaf->w = w;
    leaf->h = h;
    leaf->area = w * h;

    return leaf;
}

void leaf_cut ( Leaf * leaf, int w, int h, GSequence *leaves_sorted_by_area, const Page *smallest )
{
    gboolean b = leaf->w - w > leaf->h - h;
    if ( leaf->w - w > smallest->width )
        leaf_new( leaf->x + w, leaf->y, leaf->w - w, b ? leaf->h : h );
    if ( leaf->h - h > smallest->height )
        leaf_new( leaf->x, leaf->y + h, b ? w : leaf->w, leaf->h - h );

    g_sequence_remove_sorted( leaves_sorted_by_area, leaf, leaf_compare, LEAF_AREA_COMPARE );
    free( leaf );
}
