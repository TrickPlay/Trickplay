
// This has to be the first include or it will conflict with
// unistd.h

#include "ossp/uuid.h"

#include "util.h"

static String make_uuid( unsigned int mode )
{
    String result;

    uuid_t * u = 0;

    if ( UUID_RC_OK == uuid_create( & u ) )
    {
        if ( UUID_RC_OK == uuid_make( u , mode ) )
        {
            char buffer[ UUID_LEN_STR + 1 ];

            size_t len = UUID_LEN_STR + 1;

            void * up = & buffer[0];

            if ( UUID_RC_OK == uuid_export( u , UUID_FMT_STR , & up , & len ) )
            {
                result = buffer;
            }
        }

        uuid_destroy( u );
    }

    return result;
}

String Util::make_v1_uuid()
{
    return make_uuid( UUID_MAKE_V1 );
}

String Util::make_v4_uuid()
{
    return make_uuid( UUID_MAKE_V4 );
}
