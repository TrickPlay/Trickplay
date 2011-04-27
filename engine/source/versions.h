#ifndef _TRICKPLAY_VERSIONS_H
#define _TRICKPLAY_VERSIONS_H

#include "common.h"

void dump_versions();

// The key is the library name. The value is a list of versions, as follows:
// First entry is the run time version (what we are running against)
// Second entry is compile time version (what we were built against)
// Third entry is an additional description

typedef std::vector< String > StringVector;
typedef std::map< String , StringVector > VersionMap;

VersionMap get_versions();

#endif // _TRICKPLAY_VERSIONS_H
