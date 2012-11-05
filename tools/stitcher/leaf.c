#include "leaf.h"

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

int leaf_compare ( gconstpointer a, gconstpointer b, gpointer user_data __attribute__ ((unused)) )
{
    Leaf * aa = (Leaf *) a,
         * bb = (Leaf *) b;
    return aa->area - bb->area;
}

Leaf * leaf_new ( unsigned int x, unsigned int y, unsigned int w, unsigned int h )
{
    Leaf * leaf = malloc( sizeof( Leaf ) );
    leaf->x = x;
    leaf->y = y;
    leaf->w = w;
    leaf->h = h;
    leaf->area = w * h;
    leaf->item = NULL;

    return leaf;
}

void leaf_cut ( Leaf * leaf, unsigned int w, unsigned int h, GSequence * leaves, Output * output )
{
    gboolean b = leaf->w - w > leaf->h - h;
    if ( leaf->w - w > output->smallest.width )
        g_sequence_insert_sorted( leaves, leaf_new( leaf->x + w, leaf->y, leaf->w - w, b ? leaf->h : h ), leaf_compare, NULL );
    if ( leaf->h - h > output->smallest.height )
        g_sequence_insert_sorted( leaves, leaf_new( leaf->x, leaf->y + h, b ? w : leaf->w, leaf->h - h ), leaf_compare, NULL );

    g_sequence_remove_sorted( leaves, leaf, leaf_compare, NULL );
}

char * leaf_tostring ( Leaf * leaf, Options * options )
{
    unsigned int a = options->add_buffer_pixels ? 1 : 0;
    return g_strdup_printf(
        "\n\t\t{ \"x\": %i, \"y\": %i, \"w\": %i, \"h\": %i, \"id\": \"%s\" }",
        leaf->x + a, leaf->y + a, leaf->item->w - 2*a, leaf->item->h - 2*a, leaf->item->id );
}
