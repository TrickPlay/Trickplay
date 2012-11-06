#ifndef __MAIN_H__
#define __MAIN_H__

#include <glib.h>
#include <gio/gio.h>
#include <magick/MagickCore.h>
#include <string.h>
#include <math.h>

typedef struct Page {
    unsigned int width,
        height,
        area;
} Page;

typedef struct Options {
    unsigned int input_size_limit,
                 output_size_limit;
    
    gboolean recursive,
             add_buffer_pixels,
             allow_multiple_sheets,
             copy_large_images;
    
    GPtrArray  * input_patterns,
               * input_paths,
               * json_to_merge;
    
    GHashTable * input_ids;
} Options;

typedef struct Output {
    unsigned int size_step;
    
    char * path;
    
    Page minimum,
         smallest;
         
    GPtrArray  * large_images,
               * images,
               * infos,
               * subsheets;
    
    GSequence  * items;
} Output;

typedef struct Layout {
    unsigned int width,
        height,
        area;
    float coverage;
    int status;
    GSequence * leaves;
    GPtrArray * places;
} Layout;

enum {
    LAYOUT_FOUND_NONE,
    LAYOUT_FOUND_SOME,
    LAYOUT_FOUND_ALL
};

Options * options_new();
void options_free( Options * options );
gboolean options_allows_id ( Options * options, const char * id );
gboolean options_take_unique_id ( Options * options, const char * id );
void options_take_arguments ( Options * options, int argc, char ** argv, Output * output );

Output * output_new();
void output_free( Output * output );
void output_load_inputs( Output * output, Options * options );
void output_add_subsheet ( Output * output, Layout * layout, const char * png_path, Options * options );
void output_export_files ( Output * output, Options * options );

void layout_free ( Layout * layout );
Layout * layout_new_from_output ( Output * output, unsigned int width, Options * options );
Layout * layout_choose( Layout * a, Layout * b, Options * options );

void error( char * msg );

#endif
