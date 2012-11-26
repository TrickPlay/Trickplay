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

gboolean opt_forget( const gchar * option_name, const gchar * value, gpointer * data, GError ** error )
{
    options_take_unique_id( (Options *) data, strdup( value ) );
    return TRUE;
}

gboolean opt_filter( const gchar * option_name, const gchar * value, gpointer * data, GError ** error )
{
    g_ptr_array_add( ((Options *) data)->input_patterns, g_pattern_spec_new( strdup( value ) ) );
    return TRUE;
}

gboolean opt_json( const gchar * option_name, const gchar * value, gpointer * data, GError ** error )
{
    g_ptr_array_add( ((Options *) data)->json_to_merge, strdup( (char *) value ) );
    return TRUE;
}

gboolean opt_input( const gchar * option_name, const gchar * value, gpointer * data, GError ** error )
{
    g_ptr_array_add( ((Options *) data)->input_paths, strdup( (char *) value ) );
    return TRUE;
}

Options * options_new_from_arguments ( int argc, char ** argv )
{
    Options * options = options_new();
    
    GOptionContext * context = g_option_context_new( "- stitch together many source sprites into a single spritesheet");
    g_option_context_set_summary( context, "stitcher will accept a list of directories and/or images, and things that might be convertible to images (ie. SVG). Experiment to see what input formats work for your case." );

    GOptionEntry entries[] =
    {
        { G_OPTION_REMAINING, 0, G_OPTION_FLAG_FILENAME,    G_OPTION_ARG_CALLBACK, 
            & opt_input,                         NULL, "PATH ..." },
        { "no-buffer-pixels", 'B', G_OPTION_FLAG_REVERSE,     G_OPTION_ARG_NONE, 
            & options->add_buffer_pixels,        "Do not place buffer pixels around sprite edges", NULL },
        { "no-copy",        'C', G_OPTION_FLAG_REVERSE,     G_OPTION_ARG_NONE, 
            & options->copy_large_items,         "Do not copy over files that fail the input size filter as stand-alone images", NULL },
        { "forget",         'f', 0,                         G_OPTION_ARG_CALLBACK,
            & opt_forget,                        "Name of a sprite to skip or forget in output", "ID" },
        { "input-filter",   'i', 0,                         G_OPTION_ARG_CALLBACK, 
            & opt_filter,                        "Inclusive wildcard (?, *) filter for files within input directories (default: *)", "FILTER" },
        { "merge-json",     'j', G_OPTION_FLAG_FILENAME,    G_OPTION_ARG_CALLBACK,
            & opt_json,                          "Path to the JSON file of a spritesheet to merge into this one", "PATH" },
        { "no-multiple",    'M', G_OPTION_FLAG_REVERSE,     G_OPTION_ARG_NONE, 
            & options->allow_multiple_sheets,    "Do not allow the tool to output multiple images", NULL },
        { "output-path",    'o', 0,                         G_OPTION_ARG_STRING, 
            & options->output_path,              "Output path for the files *.json and *.png (default: first input path)", "PATH" },
        { "no-recursive",   'R', G_OPTION_FLAG_REVERSE,     G_OPTION_ARG_NONE, 
            & options->recursive,                "Do not recursively enter subdirectories", NULL },
        { "input-size",     's', 0,                         G_OPTION_ARG_INT, 
            & options->input_size_limit,         "Limit on the maximum size of input images (default 512)", "INT" },
        { "output-size",    'S', 0,                         G_OPTION_ARG_INT, 
            & options->output_size_limit,        "Limit on the maximum size of output images (default: 4096)", "INT" },
        { NULL }
    };
    
    GOptionGroup * group = g_option_group_new( "all", NULL, NULL, options, NULL );
    g_option_group_add_entries( group, entries );
    g_option_context_set_main_group( context, group );
    
    if ( !g_option_context_parse( context, &argc, &argv, NULL ) )
    {
        fprintf( stderr, "Could not parse arguments.\n" ); // this doesn't seem to be working right
        exit( 1 );
    }
    
    g_message( "buffer %i", options->add_buffer_pixels );
    
    g_option_context_free( context );

    if ( options->input_paths->len + options->json_to_merge->len == 0 )
        fprintf( stderr, "No inputs given.\n" );

    if ( options->output_path == NULL )
    {
        if ( options->input_paths->len > 0 )
        {
            options->output_path = g_ptr_array_index( options->input_paths, 0 );
        //else if ( options->json_to_merge->len > 0 )
        //    options->output_path = g_ptr_array_index( options->json_to_merge, 0 );
        }
        else
        {
            fprintf( stderr, "Ambiguous output path.\n" );
            exit( 1 );
        }
    }

    return options;
}
