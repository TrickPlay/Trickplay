#include <stdlib.h>
#include <stdio.h>
#include "progress.h"

Progress * progress_new()
{
    Progress * progress = malloc( sizeof( Progress ) );
    
    progress->chunks = g_ptr_array_new_with_free_func( g_free );
    progress->percent = 0;
    
    return progress;
}

void progress_free( Progress * progress )
{
    g_ptr_array_free( progress->chunks, TRUE );
    free( progress );
}

void progress_recalculate( Progress * progress )
{
    float p = 0.0;
    for ( unsigned i = 0; i < progress->chunks->len; ++i )
    {
        ProgressChunk * chunk = (ProgressChunk *) g_ptr_array_index( progress->chunks, i );
        if ( chunk->estimate )
        {
            p += chunk->progress / chunk->estimate;
        }
    }
    
    if ( progress->percent < (int) p )
    {
        progress->percent = MIN( 100, (int) p );
        fprintf( stdout, "%3i%%\b\b\b\b\b\b", progress->percent );
    }
}

ProgressChunk * progress_new_chunk( Progress * progress, unsigned estimate )
{
    ProgressChunk * chunk = malloc( sizeof( ProgressChunk ) );
    chunk->estimate = estimate;
    chunk->progress = 0.0;
    
    g_ptr_array_add( progress->chunks, chunk );
    return chunk;
}
