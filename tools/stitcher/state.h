#ifndef __STATE_H__

#include <glib.h>

typedef struct State {
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
#include "progress.h"

State * state_new ();
void state_free ( State * state );
void state_estimate_inputs( State * state, Options * options );
void state_load_inputs ( State * state, Options * options );
void state_add_layout ( State * state, Layout * layout, ProgressChunk * chunk, Options * options );
void state_export_files ( State * state, Options * options );

#endif
