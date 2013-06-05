#include "log.h"
#include "common.h"

void _tplog( const char* domain , GLogLevelFlags level , const char* format , ... )
{
    if ( domain )
    {
        va_list args;
        va_start( args, format );
        gchar* message = g_strdup_vprintf( format , args );
        va_end( args );
        g_log( G_LOG_DOMAIN , level , "[%s] %s" , domain , message );
        g_free( message );
    }
    else
    {
        va_list args;
        va_start( args, format );
        g_logv( G_LOG_DOMAIN , level , format , args );
        va_end( args );
    }
}
