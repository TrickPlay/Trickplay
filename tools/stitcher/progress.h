#ifndef __PROGRESS_H__

#include <glib.h>

typedef struct {
    float estimate, 
          progress;
} ProgressChunk;

typedef struct {
    GPtrArray * chunks;
    unsigned percent;
} Progress;

#define __PROGRESS_H__

Progress * progress_new();
void progress_free( Progress * progress );
void progress_recalculate( Progress * progress );
ProgressChunk * progress_new_chunk( Progress * progress, unsigned estimate );

#endif
