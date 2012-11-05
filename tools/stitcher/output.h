#ifndef __OUTPUT_H__

#include <glib.h>

typedef struct Output {
    unsigned int size_step,
                 max_item_w,
                 item_area;
         
    GPtrArray  * large_items,
               * images,
               * infos,
               * subsheets;
    
    GSequence  * items;
} Output;

#define __OUTPUT_H__

#include "layout.h"
#include "options.h"

Output * output_new ();
void output_free ( Output * output );
void output_load_inputs ( Output * output, Options * options );
void output_add_layout ( Output * output, Layout * layout, const char * png_path, Options * options );
void output_export_files ( Output * output, Options * options );

#endif