
// This has to be the first include or it will conflict with
// unistd.h

#include "ossp/uuid.h"

#include "util.h"

static String make_uuid( unsigned int mode )
{
    uuid_t * u = 0;

    uuid_create( & u );
    uuid_make( u , mode );

    char buffer[ UUID_LEN_STR + 1 ];

    size_t len = UUID_LEN_STR + 1;

    void * up = & buffer[0];

    uuid_rc_t r = uuid_export( u , UUID_FMT_STR , & up , & len );

    uuid_destroy( u );

    if ( r == UUID_RC_OK )
    {
        return String( buffer );
    }

    return String();
}

String Util::make_v1_uuid()
{
    return make_uuid( UUID_MAKE_V1 );
}

String Util::make_v4_uuid()
{
    return make_uuid( UUID_MAKE_V4 );
}
