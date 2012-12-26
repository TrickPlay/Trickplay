#include <stdlib.h>
#include <stdio.h>
#include "progress.h"

Progress * progress_new( Options * options )
{
    Progress * progress = malloc( sizeof( Progress ) );
    
    progress->chunks = g_ptr_array_new_with_free_func( g_free );
    progress->percent = 0;
    progress->print = options->print_progress;
    
    return progress;
}

void progress_free( Progress * progress )
{
    g_ptr_array_free( progress->chunks, TRUE );
    free( progress );
}

void progress_recalculate( Progress * progress )
{
    float p = 0.0, t = 0.0;
    for ( unsigned i = 0; i < progress->chunks->len; ++i )
    {
        ProgressChunk * chunk = (ProgressChunk *) g_ptr_array_index( progress->chunks, i );
        if ( chunk->estimate )
        {
            p += chunk->progress * chunk->estimate;
            t += chunk->estimate;
        }
    }
    
    p = 100.0 * p / t ;
    
    if ( progress->percent < (int) p )
    {
        progress->percent = MIN( 100, (int) p );
        if ( progress->print )
        {
            fprintf( stdout, "%i\n", progress->percent );
        }
    }
}

ProgressChunk * progress_new_chunk( Progress * progress, float estimate )
{
    ProgressChunk * chunk = malloc( sizeof( ProgressChunk ) );
    chunk->estimate = estimate;
    chunk->progress = 0.0;
    chunk->parent = progress;
    
    g_ptr_array_add( progress->chunks, chunk );
    return chunk;
}
