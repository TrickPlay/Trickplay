#include <glib.h>
#include <glib-object.h>
#include <magick/MagickCore.h>
#include "options.h"
#include "output.h"
#include "layout.h"

Layout * place_attempt(Output *output, Options *options)
{
    Layout * best = layout_new( 0 );

    unsigned int i;
    for ( i = 0; i <= options->output_size_limit; i++ )
    {
        Layout * layout = layout_new_from_output( output, i, options );
        Layout * better = layout_choose( layout, best, options );

        if(layout == better)
        {
            layout_free( best );
            best = layout;
        }
        else
        {
            layout_free( layout );
        }
    }

    if ( !options->allow_multiple_sheets && (!best || best->items_skipped != 0) )
    {
        fprintf( stderr, "Can't fit all files within output dimensions (%i x %i).\n",
                 options->output_size_limit, options->output_size_limit );
        exit( 1 );
    }
    else if ( options->allow_multiple_sheets && best->items_placed == 0 )
    {
        fprintf( stderr, "Failed to fit all of the images.\n" );
        exit( 1 );
    }


    output_add_layout( output, best, options );

    return best;
}

int main ( int argc, char ** argv )
{
    g_type_init();
    MagickCoreGenesis( * argv, MagickTrue );

    Options * options = options_new_from_arguments( argc, argv );

    Output  * output  = output_new();
    output_load_inputs( output, options );

    if ( options->allow_multiple_sheets )
    {
        // fit sprites into sheets in the densest way possible, until we run out of sprites

        while ( place_attempt(output, options)->items_skipped )
        {
            continue;
        }
    }
    else
    {
        place_attempt(output,options);
    }

    output_export_files( output, options );

    // collect garbage

    options_free( options );
    output_free( output );

    MagickCoreTerminus();

    return 0;
}
