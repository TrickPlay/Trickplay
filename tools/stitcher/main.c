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
    // initialization
    
    g_type_init();
    MagickCoreGenesis( * argv, MagickTrue );

    // setup using command line arguments

    Options * options = options_new_from_arguments( argc, argv );

    State  * state  = state_new();
    state_load_inputs( state, options );
    
    Progress * progress = progress_new( options );
    ProgressChunk * layout_chunk,
                  * comp_chunk,
                  * spacer_chunk = NULL;
                  
    // iterate until all inputs have been given homes
    
    unsigned n_items;
    while (( n_items = g_sequence_get_length( state->items ) ))
    {
        // a null layout used to gather information
        
        Layout * best = layout_new_from_state( state, 0, options );
        
        unsigned min_w = best->max_item_w,
                 max_w = MAX( min_w, MIN( best->item_area * 2 / best->max_item_h, options->output_size_limit ) );
        
        // estimate how long it will take to generate this layout
        
        layout_chunk = progress_new_chunk( progress, (float) n_items * (float) ( max_w - min_w ) / 6000.0f );
        comp_chunk   = progress_new_chunk( progress, sqrt( log10( (float) best->item_area ) * (float) n_items ) );
        if ( spacer_chunk ) spacer_chunk->estimate = 0.0;
        spacer_chunk = progress_new_chunk( progress, ( layout_chunk->estimate + comp_chunk->estimate ) / 6.0 );
    
        // test all plausible layout widths, choosing the most efficient
    
        for ( unsigned i = min_w; i <= max_w; i++ )
        {
            Layout * layout = layout_new_from_state( state, i, options );

            // optimize for efficiency, largeness, and squareness, in that order

            if ( layout->value > best->value )
            {
                layout_free( best );
                best = layout;
            }
            else
            {
                layout_free( layout );
            }
            
            // update the progress estimate
            
            if ( i % 10 == 1 )
            {
                layout_chunk->progress = (float) ( i - min_w + 1 ) / (float) ( max_w - min_w + 1 );
                progress_recalculate( progress );
            }
        }
        
        // if for some reason nothing could be placed on this iteration, iterating again won't help, so exit
        
        if ( !best->places->len )
        {
            fprintf( stderr, "Failed to fit all of the images.\n" );
            exit( 1 );
        }
        
        // save the layout, generating one PNG and part of the JSON
        
        state_add_layout( state, best, comp_chunk, options );
        
        layout_chunk->progress = 1.0;
        comp_chunk->estimate = sqrt( log10( (float) best->area ) * (float) best->places->len );
        comp_chunk->progress = 1.0;
        progress_recalculate( progress );
    }

    state_export_files( state, options );

    // collect garbage

    progress_free( progress );
    options_free( options );
    state_free( state );

    MagickCoreTerminus();

    return 0;
}
