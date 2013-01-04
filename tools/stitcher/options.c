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

    options->recursive = FALSE;
    options->de_duplicate = FALSE;
    options->add_buffer_pixels = TRUE;
    options->print_progress = FALSE;
    options->log_level = 1;

    options->input_patterns = g_ptr_array_new_with_free_func( (GDestroyNotify) g_pattern_spec_free );
    options->input_paths    = g_ptr_array_new_with_free_func( g_free );
    options->json_to_merge  = g_ptr_array_new_with_free_func( g_free );
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

gboolean opt_forget( const gchar * opt, const gchar * value, Options * options, GError ** error )
{
    options_take_unique_id( options, value );
    return TRUE;
}

gboolean opt_filter( const gchar * opt, const gchar * value, Options * options, GError ** error )
{
    g_ptr_array_add( options->input_patterns, g_pattern_spec_new( value ) );
    return TRUE;
}

gboolean opt_json( const gchar * opt, const gchar * value, Options * options, GError ** error )
{
    g_ptr_array_add( options->json_to_merge, strdup( value ) );
    return TRUE;
}

gboolean opt_input( const gchar * opt, const gchar * value, Options * options, GError ** error )
{
    g_ptr_array_add( options->input_paths, strdup( value ) );
    return TRUE;
}

Options * options_new_from_arguments ( int argc, char ** argv )
{
    Options * options = options_new();
    
    GOptionContext * context = g_option_context_new( "- stitch together many source sprites into a single spritesheet");
    g_option_context_set_summary( context, "stitcher will accept a list of directories and/or images, and things that might be convertible to images (ie. SVG). Experiment to see what input formats work for your case." );
    g_option_context_set_description( context, TP_GIT_VERSION );

    GOptionEntry entries[] =
    {
        { G_OPTION_REMAINING, 0, G_OPTION_FLAG_FILENAME,    G_OPTION_ARG_CALLBACK, 
            & opt_input,                         NULL, "INPUT ..." },
        { "no-buffer-pixels",  'B', G_OPTION_FLAG_REVERSE,     G_OPTION_ARG_NONE, 
            & options->add_buffer_pixels,        "Do not place buffer pixels around sprite edges", NULL },
        { "de-duplicate",      'd', 0,                         G_OPTION_ARG_NONE, 
            & options->de_duplicate,             "Only include one copy of images that are the same", NULL },
        { "ignore",            'g', 0,                         G_OPTION_ARG_CALLBACK,
            & opt_forget,                        "Id of a sprite to ignore or forget", "ID" },
        { "input-name-filter", 'i', 0,                         G_OPTION_ARG_CALLBACK, 
            & opt_filter,                        "Inclusive wildcard (?, *) filter applied to the relative paths of files within input directories (default: *)", "FILTER" },
        { "log-level",         'l', 0,                         G_OPTION_ARG_INT, 
            & options->log_level,                "Granularity of message logging, 0-3 (default: 1)", "LEVEL" },
        { "merge-json",        'm', G_OPTION_FLAG_FILENAME,    G_OPTION_ARG_CALLBACK,
            & opt_json,                          "Path to the JSON file of a spritesheet to merge into this one", "PATH" },
        { "output-prefix",     'o', 0,                         G_OPTION_ARG_STRING, 
            & options->output_path,              "Path and prefix for the spritesheet files created", "PATH" },
        { "print-progress",    'p', G_OPTION_FLAG_HIDDEN,      G_OPTION_ARG_NONE, 
            & options->print_progress,           "Print progress increments to stdout", NULL },
        { "recursive",         'r', 0,                         G_OPTION_ARG_NONE, 
            & options->recursive,                "Recursively enter subdirectories", NULL },
        { "size-segregation",  's', 0,                         G_OPTION_ARG_INT, 
            & options->input_size_limit,         "Size segregation threshhold (default: 512)", "INT" },
        { "max-texture-size",  't', 0,                         G_OPTION_ARG_INT, 
            & options->output_size_limit,        "Maximum texture size the spritesheet will try to use (default: 4096)", "INT" },
        { NULL }
    };
    
    GOptionGroup * group = g_option_group_new( "all", NULL, NULL, options, NULL );
    g_option_group_add_entries( group, entries );
    g_option_context_set_main_group( context, group );
    
    if ( !g_option_context_parse( context, &argc, &argv, NULL ) )
    {
        fprintf( stderr, "Could not parse arguments\n" );
        exit( 1 );
    }
    
    g_option_context_free( context );
    
    gboolean errors = FALSE;
    
    if ( options->input_size_limit > 65536 )
    {
        fprintf( stderr, "Segregation size (see --help) cannot be larger than 65,536 x 65,536\n" );
        errors = TRUE;
    }
    
    if ( options->output_size_limit > 65536 )
    {
        fprintf( stderr, "Maximum texture size (see --help) cannot be larger than 65,536 x 65,536\n" );
        errors = TRUE;
    }
    
    options->input_size_limit = MIN( options->input_size_limit, options->output_size_limit );

    if ( options->input_paths->len + options->json_to_merge->len == 0 )
    {
        fprintf( stderr, "No inputs given\n" );
        errors = TRUE;
    }

    if ( options->output_path == NULL )
    {
        if ( options->input_paths->len )
        {
            char * first_input = g_ptr_array_index( options->input_paths, 0 );
            if ( g_file_test( first_input, G_FILE_TEST_IS_DIR ) )
            {
                options->output_path = first_input;
                fprintf( stderr, "Assuming output prefix to be %s\n", options->output_path );
            }
            else
            {
                fprintf( stderr, "Ambiguous output path\n" );
                errors = TRUE;
            }
        }
        else
        {
            fprintf( stderr, "Ambiguous output path\n" );
            errors = TRUE;
        }
    }
    
    if ( errors )
    {
        exit( 1 );
    }

    return options;
}
