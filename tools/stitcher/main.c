#include <glib.h>
#include <glib-object.h>
#include <magick/MagickCore.h>
#include "options.h"
#include "output.h"
#include "layout.h"

int main ( int argc, char ** argv )
{
    g_type_init();
    MagickCoreGenesis( * argv, MagickTrue );

    Options * options = options_new_from_arguments( argc, argv );

    Output  * output  = output_new();
    output_load_inputs( output, options );

    while ( g_sequence_get_length( output->items ) )
    {
        Layout * best = layout_new( 0 );
    
        for ( unsigned i = 0; i <= options->output_size_limit; i++ )
        {
            Layout * layout = layout_new_from_output( output, i, options );
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
        
        if ( !best->items_placed )
        {
            fprintf( stderr, "Failed to fit all of the images.\n" );
            exit( 1 );
        }
        
        output_add_layout( output, best, options );
    }

    output_export_files( output, options );

    // collect garbage

    options_free( options );
    output_free( output );

    MagickCoreTerminus();

    return 0;
}
