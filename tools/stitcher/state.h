#ifndef __STATE_H__

#include <glib.h>
#include "progress.h"

typedef struct State {
    Progress * progress;
    ProgressChunk * import_chunk,
                  * layout_chunk,
                  * export_chunk;
    
    GPtrArray  * segregated,
               * images,
               * infos,
               * subsheets;

    GSequence  * items;
    
    GHashTable * unique;

    GRegex * url_regex;
} State;

#define __STATE_H__

#include "layout.h"
#include "options.h"

State * state_new ();
void state_free ( State * state );
void state_load_inputs ( State * state, Options * options );
void state_add_layout ( State * state, Layout * layout, Options * options );
void state_export_files ( State * state, Options * options );

#endif
