#ifndef __OUTPUT_H__

#include <glib.h>

typedef struct Output {
    GPtrArray  * large_items,
               * images,
               * infos,
               * subsheets;

    GSequence  * items;

    GRegex * url_regex;
} Output;

#define __OUTPUT_H__

#include "layout.h"
#include "options.h"

Output * output_new ();
void output_free ( Output * output );
void output_load_inputs ( Output * output, Options * options );
void output_add_layout ( Output * output, Layout * layout, Options * options );
void output_export_files ( Output * output, Options * options );

#endif
