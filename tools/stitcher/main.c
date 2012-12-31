#include <glib.h>
#include <glib-object.h>
#include <magick/MagickCore.h>
#include "options.h"
#include "state.h"
#include "progress.h"
#include "layout.h"
#include <time.h>
#include <math.h>

int main ( int argc, char ** argv )
{
    g_type_init();
    MagickCoreGenesis( * argv, MagickTrue );

    Options * options = options_new_from_arguments( argc, argv );

    State  * state  = state_new();
    state_load_inputs( state, options );
    
    Progress * progress = progress_new( options );
    ProgressChunk * layout_chunk,
                  * comp_chunk,
                  * spacer_chunk = NULL;
    
    unsigned n_items;
    while (( n_items = g_sequence_get_length( state->items ) ))
    {
        Layout * best = layout_new_from_state( state, 0, options );
        
        unsigned min_w = best->max_item_w,
                 max_w = MAX( min_w, MIN( best->item_area * 2 / best->max_item_h, options->output_size_limit ) );
        
        layout_chunk = progress_new_chunk( progress, (float) n_items * (float) ( max_w - min_w ) / 6000.0f );
        comp_chunk   = progress_new_chunk( progress, sqrt( log10( (float) best->item_area ) * (float) n_items ) );
        if ( spacer_chunk ) spacer_chunk->estimate = 0.0;
        spacer_chunk = progress_new_chunk( progress, ( layout_chunk->estimate + comp_chunk->estimate ) / 6.0 );
    
        for ( unsigned i = min_w; i <= max_w; i++ )
        {
            Layout * layout = layout_new_from_state( state, i, options );
            Layout * better = layout_choose( layout, best, options );

            if ( layout == better )
            {
                layout_free( best );
                best = layout;
            }
            else
            {
                layout_free( layout );
            }
            
            if ( i % 10 == 1 )
            {
                layout_chunk->progress = (float) ( i - min_w + 1 ) / (float) ( max_w - min_w + 1 );
                progress_recalculate( progress );
            }
        }
        
        if ( !best->places->len )
        {
            fprintf( stderr, "Failed to fit all of the images.\n" );
            exit( 1 );
        }
        
        state_add_layout( state, best, comp_chunk, options );
        
        comp_chunk->estimate = sqrt( log10( (float) best->area ) * (float) best->places->len );
        comp_chunk->progress = 1.0;
        progress_recalculate( progress );
    }

    state_export_files( state, options );

    // collect garbage

    options_free( options );
    state_free( state );

    MagickCoreTerminus();

    return 0;
}
