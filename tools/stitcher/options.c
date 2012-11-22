#include <string.h>
#include "options.h"
#include "leaf.h"
#include "item.h"

Options * options_new()
{
    Options * options = malloc( sizeof( Options ) );

    options->input_size_limit  = 512;
    options->output_size_limit = 4096;
    options->output_path = NULL;

    options->recursive = TRUE;
    options->add_buffer_pixels = TRUE;
    options->allow_multiple_sheets = TRUE;
    options->copy_large_items = TRUE;

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
