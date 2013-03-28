#ifndef _TRICKPLAY_STORAGE_H
#define _TRICKPLAY_STORAGE_H

extern "C"
{
#include "tcutil.h"
#include "tchdb.h"
}

#include "common.h"

namespace Storage
{
class LocalHash
{
public:
    LocalHash();
    ~LocalHash();

    String name;

    void connect();

    String get( String& key );
    void   put( String& key, String& value );
    void   del( String& key );

    // Remove all key/value pairs from the DB
    void nuke();

    // Transaction stuff
    void begin();
    void commit();
    void abort();

    // Flush to backing store
    void flush();

    // Count number of key/value pairs in the DB
    uint64_t count();

protected:
    TCHDB* db;
};


// Count the number of records in the database
uint64_t count( LocalHash& db );
};

#endif // _TRICKPLAY_STORAGE_H
