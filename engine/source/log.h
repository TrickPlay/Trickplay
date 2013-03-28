#ifndef _TRICKPLAY_LOG_H
#define _TRICKPLAY_LOG_H

#include "glib.h"

/*
    tplog and tplog2 are silent in production builds.
    You can also turn them off selectively using

    #define TP_LOG_ON  false
    #define TP_LOG2_ON false

    tpinfo and tpwarn are always on.

    You can set the "domain" by defining TP_LOG_DOMAIN before you
    include this file. If you do, the messages will be prefixed with [<domain>].
*/

void _tplog( const char* domain , GLogLevelFlags level , const char* format , ... );

#ifndef TP_LOG_DOMAIN
#define TP_LOG_DOMAIN ((gchar*)0)
#endif

#define tpwarn(...)     _tplog( TP_LOG_DOMAIN , G_LOG_LEVEL_WARNING     , __VA_ARGS__ )
#define tpinfo(...)     _tplog( TP_LOG_DOMAIN , G_LOG_LEVEL_INFO        , __VA_ARGS__ )


#ifdef TP_PRODUCTION

#define tplog(...)      while(0){}
#define tplog2(...)     while(0){}

#else

#if defined(TP_LOG_ON) && ! TP_LOG_ON
#define tplog(...)      while(0){}
#else
#define tplog(...)      _tplog( TP_LOG_DOMAIN , G_LOG_LEVEL_DEBUG       , __VA_ARGS__ )
#endif

#if defined(TP_LOG2_ON) && ! TP_LOG2_ON
#define tplog2(...)     while(0){}
#else
#define tplog2(...)     _tplog( TP_LOG_DOMAIN , G_LOG_LEVEL_DEBUG       , __VA_ARGS__ )
#endif

#endif

#endif // _TRICKPLAY_LOG_H
