#ifndef __STATE_H__

/*

state.h

A State represents and manages the current state of the stitcher process. Inputs are loaded based on an Options instance and converted into Items which, during the layout process, are stitched into JSON + PNG subsheets. At the end, these subsheets are exported together as the complete spritesheet.

*/

#include <glib.h>

typedef struct State
{
    GPtrArray*   segregated,
                 * images,
                 * infos,
                 * subsheets;

    GSequence*   items;

    GHashTable* unique;

    GRegex* url_regex;
} State;

#define __STATE_H__

#include "layout.h"
#include "options.h"
#include "progress.h"

State* state_new();
void state_free( State* state );
void state_load_inputs( State* state, Options* options );
void state_add_layout( State* state, Layout* layout, ProgressChunk* chunk, Options* options );
void state_export_files( State* state, Options* options );

#endif
