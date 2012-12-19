#include <glib.h>
#include <glib-object.h>
#include <magick/MagickCore.h>
#include "options.h"
#include "state.h"
#include "layout.h"

int main ( int argc, char ** argv )
{
    g_type_init();
    MagickCoreGenesis( * argv, MagickTrue );

    Options * options = options_new_from_arguments( argc, argv );

    State  * state  = state_new();
    state_load_inputs( state, options );

    while ( g_sequence_get_length( state->items ) )
    {
        Layout * best = layout_new( 0, 0 );
    
        for ( unsigned i = 0; i <= options->output_size_limit; i++ )
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
        }
        
        if ( !best->places->len )
        {
            fprintf( stderr, "Failed to fit all of the images.\n" );
            exit( 1 );
        }
        
        state_add_layout( state, best, options );
    }

    state_export_files( state, options );

    // collect garbage

    options_free( options );
    state_free( state );

    MagickCoreTerminus();

    return 0;
}
