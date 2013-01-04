#ifndef __PROGRESS_H__

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
