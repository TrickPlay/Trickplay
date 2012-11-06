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

    if ( options->allow_multiple_sheets )
    {
        // fit sprites into sheets in the densest way possible, until we run out of sprites
        /*
        while ( TRUE )
        {
            best = (Page) { 0, 0, 0, 0 };

            // iterate to find a good layout

            for ( i = output->minimum.width; i <= options->output_size_limit; i += output->size_step )
                recalculate_layout( i, FALSE, &best );
            status = recalculate_layout( best.width, TRUE, &best );

            if ( status == LAYOUT_FOUND_NONE )
            {
                fprintf( stderr, "Failed to fit all of the images.\n" );
                exit( 1 );
            }

            fprintf( stderr, "Page %i match (%i x %i pixels, %.4g%% coverage): ",
                     j, best.width, best.height, 100.0f * best.coverage );

            output_add_layout( output, g_strdup_printf( "%s-%i.png", output->path, j ) );

            j++;
            if ( status == LAYOUT_FOUND_ALL )
                break;
        }
        */
    }
    else
    {
        if ( output->item_area > options->output_size_limit * options->output_size_limit )
        {
            fprintf( stderr, "Total area of input files is larger than "
                             "output dimensions (%i x %i).\n",
                     options->output_size_limit, options->output_size_limit );
            exit( 1 );
        }

        // iterate to find the best layout
        
        Layout * best = NULL;
        
        unsigned int i;
        for ( i = output->max_item_w; i <= options->output_size_limit; i += 1 )
        {
            Layout * layout = layout_new_from_output( output, i, options );
            Layout * better = layout_choose( layout, best, options );
            
            layout = better != best ? best : layout;
            if ( layout )
                layout_free( layout );
                
            best = better;
        }
        
        if ( !best || best->status != LAYOUT_FOUND_ALL )
        {
            fprintf( stderr, "Can't fit all files within output dimensions (%i x %i).\n",
                     options->output_size_limit, options->output_size_limit );
            exit( 1 );
        }

        output_add_layout( output, best, g_strdup_printf( "%s.png", options->output_path ), options );
    }

    output_export_files( output, options );

    // collect garbage
    
    options_free( options );
    output_free( output );
    
    MagickCoreTerminus();

    return 0;
}

// help message -- out of date

void error( char * msg )
{
	fprintf( stderr, "%s\n"
        "Usage: stitcher /paths/to/inputs [-bcmr] [-i *] [-j *] [-o *] \n"
        "\n"
        "Inputs:\n"
        "                 stitcher will accept a list of directories ang/or images,\n"
        "                 and things that might be convertible to images (ie. SVG).\n"
        "                 Experiment to see what input formats work for your case.\n"
        "\n"
        "Flags:\n"
        "   -h            Show this help and exit.\n"
        "\n"
        "   -b            Place buffer pixels around sprite edges. Add this flag if\n"
        "                 scaled sprites are having issues around their borders.\n"
        "\n"
        "   -c            Copy files that fail the size filter over as single-image\n"
        "                 spritesheets (if they fit within the maximum output size).\n"
        "                 This option must be used in conjunction with -m.\n"
        "\n"
        "   -i [filter]   Filter which files to include. Name filters can use the\n"
        "                 wildcards * (zero or more chars) and ? (one char).\n"
        "                 Multiple space-seperated name filters can be passed.\n"
        "                 Files will be included if they match at least one filter.\n"
        "      [int]      One integer size filter can be passed, such as 256, to\n"
        "                 prevent large images from being included in a spritesheet.\n"
        "\n"
        "   -j [path]     Name the .json files of existing spritesheets to be merged\n"
        "       ...       with the new images.\n"
        "\n"
        "   -m            Divide sprites among multiple spritesheets if they don't fit\n"
        "                 within the maximum dimensions\n"
        "                 (NOTE: -m is not yet supported on the TrickPlay side.)\n"
        "\n"
        "   -o [path]     Set the path of the output files, which will have\n"
        "                 sequential numbers and a .png or .json extension appended.\n"
        "                 Without this option, the path of the first input will be used.\n"
        "      [int]      Pass an integer like 4096 to set the maximum .png size.\n"
        "\n"
        "   -r            Recursively include subdirectories.\n", msg );
	exit( 0 );
}
