#ifndef __PROGRESS_H__

/*

progress.h

A Progress struct manages the combined measurement and reporting of several ProgressChunks, which each represent a single estimateable chunk of work that needs to be completed. As ProgressChunks are updated, the total progress can be recalculated and printed to stderr.

*/

#include <glib.h>
#include "options.h"

typedef struct Progress Progress;

typedef struct ProgressChunk {
    float estimate, 
          progress;
    Progress * parent;
} ProgressChunk;

struct Progress {
    GPtrArray * chunks;
    unsigned percent;
    gboolean print;
};

#define __PROGRESS_H__

Progress * progress_new( Options * options );
void progress_free( Progress * progress );
void progress_recalculate( Progress * progress );
ProgressChunk * progress_new_chunk( Progress * progress, float estimate );

#endif
