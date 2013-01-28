#ifndef __OPTIONS_H__
#define __OPTIONS_H__

/*

options.h

The Options struct is a representation of the arguments passed to stitcher via command line, and is not meant to be changed after creation.

It also manages the uniqueness of Item ids.

*/

#include <glib.h>

typedef struct Options {
    unsigned int input_size_limit,
                 output_size_limit,
                 log_level;

    char * output_path;

    gboolean recursive,
             de_duplicate,
             add_buffer_pixels,
             print_progress;

    GPtrArray  * input_patterns,
               * input_paths,
               * json_to_merge;

    GHashTable * input_ids;
} Options;

Options * options_new ();
Options * options_new_from_arguments ( int argc, char ** argv );
void options_free ( Options * options );
gboolean options_allows_id ( Options * options, const char * id );
gboolean options_take_unique_id ( Options * options, const char * id );

#endif
