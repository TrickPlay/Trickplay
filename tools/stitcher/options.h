#ifndef __OPTIONS_H__
#define __OPTIONS_H__

#include <glib.h>

typedef struct Options {
    unsigned int input_size_limit,
                 output_size_limit,
                 log_level;

    char * output_path;

    gboolean recursive,
             de_duplicate,
             add_buffer_pixels;

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
