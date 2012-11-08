#include <string.h>
#include "options.h"
#include "leaf.h"
#include "item.h"

Options * options_new()
{
    Options * options = malloc( sizeof( Options ) );
    
    options->input_size_limit  = 4096;
    options->output_size_limit = 4096;
    options->output_path = NULL;
    
    options->recursive = FALSE;
    options->add_buffer_pixels = FALSE;
    options->allow_multiple_sheets = FALSE;
    options->copy_large_items = FALSE;
    
    options->input_patterns = g_ptr_array_new_with_free_func( (GDestroyNotify) g_pattern_spec_free );
    options->input_paths    = g_ptr_array_new();
    options->json_to_merge  = g_ptr_array_new();
    options->input_ids      = g_hash_table_new_full( g_str_hash, g_str_equal, g_free, NULL );
    
    return options;
}

void options_free( Options * options )
{
    g_ptr_array_free( options->input_patterns, TRUE );
    g_ptr_array_free( options->input_paths, TRUE );
    g_ptr_array_free( options->json_to_merge, TRUE );
    g_hash_table_destroy( options->input_ids );
    
    free( options );
}

gboolean options_allows_id ( Options * options, const char * id )
{
    unsigned int i, length = options->input_patterns->len;
    if ( length == 0 )
        return TRUE;
    
    for ( i = 0; i < length; i++ )
        if ( g_pattern_match_string( g_ptr_array_index( options->input_patterns, i ), id ) )
            return TRUE;
    
    return FALSE;
}

gboolean options_take_unique_id ( Options * options, const char * id )
{
    if ( g_hash_table_lookup( options->input_ids, (char *) id ) )
        return FALSE;
    
    id = strdup( id );
    g_hash_table_insert( options->input_ids, (char *) id, (char *) id );
    return TRUE;
}

enum {
    INPUT_PATHS,
    SET_FORGET = 'f',
    SET_INPUT  = 'i',
    SET_JSON_MERGE = 'j',
    SET_OUTPUT = 'o',
    NO_ARGS,
};

Options * options_new_from_arguments ( int argc, char ** argv )
{
    Options * options = options_new();
    
    int state = INPUT_PATHS;

    for ( int i = 1; i < argc; i++ )
    {
        char * arg = argv[i];
        size_t l = strlen( arg );
        if ( (char) arg[0] == '-' )
            for ( size_t j = 1; j < l; j++ )
                switch( (char) arg[j] )
                {
                    case 'f':
                    case 'i':
                    case 'j':
                    case 'o':
                        state = arg[j];
                        break;

                    case 'b':
                        options->add_buffer_pixels = TRUE;
                        state = NO_ARGS;
                        break;

                    case 'c':
                        options->copy_large_items = TRUE;
                        state = NO_ARGS;
                        break;

                    case 'm':
                        options->allow_multiple_sheets = TRUE;
                        state = NO_ARGS;
                        break;

                    case 'r':
                        options->recursive = TRUE;
                        state = NO_ARGS;
                        break;

                    case 'h':
                        system( g_strdup_printf( "man -l %s.man", argv[0] ) );
                        exit(0);
                        break;

                    default:
                        fprintf( stderr, "Unknown flag '-%s'.\n", (char *) &arg[j] );
                        break;
                }
        else
        {
            gboolean arg_is_int = TRUE;
            for ( size_t j = 0; j < l; j++ )
                if ( !g_ascii_isdigit( arg[j] ) )
                    arg_is_int = FALSE;
            
            switch( state )
            {
                case SET_FORGET:
                    options_take_unique_id( options, arg );
                    break;

                case SET_INPUT:
                    if ( arg_is_int )
                        options->input_size_limit = strtoul( arg, NULL, 0 );
                    else
                        g_ptr_array_add( options->input_patterns, g_pattern_spec_new( arg ) );
                    break;

                case SET_OUTPUT:
                    if ( arg_is_int )
                        options->output_size_limit = strtoul( arg, NULL, 0 );
                    else
                        options->output_path = arg;
                    break;

                case SET_JSON_MERGE:
                    g_ptr_array_add( options->json_to_merge, arg );
                    break;

                case INPUT_PATHS:
                {
                    char * lc = &arg[ strlen( arg ) - 1 ];
                    if ( * lc == '/' )
                         * lc = '\0';
                    g_ptr_array_add( options->input_paths, arg );
                    break;
                }

                default:
                    fprintf( stderr, "Ambiguous argument %s.\n", arg );
                    break;
            }
        }
    }
    
    if ( options->input_paths->len + options->json_to_merge->len == 0 )
        fprintf( stderr, "No inputs given.\n" );

    if ( options->output_path == NULL )
    {
        if ( options->input_paths->len > 0 )
            options->output_path = g_ptr_array_index( options->input_paths, 0 );
        //else if ( options->json_to_merge->len > 0 )
        //    options->output_path = g_ptr_array_index( options->json_to_merge, 0 );
        else
            fprintf( stderr, "Ambiguous output path.\n" );
    }
    
    return options;
}

/*

                        error("\n"
        "Help & Examples:\n"
        "\n"
        "stitcher assets/ui\n"
        "       Will pick up all of the images in the directory assets/ui and create two\n"
        "       files, assets/ui.png (one PNG of all the input images packed together) and\n"
        "       assets/ui.json, a JSON map to each of the packed images. Load this map into\n"
        "       TrickPlay as:\n"
        "           ui = SpriteSheet { map = 'assets/ui.json' }\n"
        "       Then create sprites from it:\n"
        "           sprite = Sprite { sheet = ui, id = 'button-press.png' }\n"
        "       Sprites behave just as if they were loaded from the original image.\n"
        "\n"
        "stitcher assets/ui special-image.jpg -i *.png nav/bg-?.jpg 256\n"
        "       Load all PNGs plus JPGs whose filenames match 'nav/bg-?.jpg', and filter\n"
        "       out images bigger than 256 pixels on a side. 'special-image.jpg' doesn't\n"
        "       match either filter, but will be included since it was named directly.\n"
        "\n"
        "stitcher assets/ui -o sprites/ui 512 -m\n"
        "       Output the JSON map as sprites/ui.json. In addition, spritesheets created\n"
        "       will not be larger than 512 x 512 pixels; instead, extra images will flow\n"
        "       to second and third spritesheets. \n"
        "       (NOTE: -m is not yet supported on the TrickPlay side.)\n"
        "\n"
        "stitcher assets/ui -i 256 -o 512 -bcm\n"
        "       -b creates a 1-pixel buffer around each sprite to prevent scaling problems,\n"
        "       while -c copies over all images that fail the input size filter, 256, as\n"
        "       stand-alone single-image spritesheets.\n"
        "\n"
        "stitcher assets/ui -j assets/old-ui-1.json assets/old-ui-2.json\n"
        "       -j merges existing spritesheets into the output. This can be used when a\n"
        "       previously created spritesheet, for example, needs to be updated.\n");
*/