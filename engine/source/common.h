#ifndef _TRICKPLAY_COMMON_H
#define _TRICKPLAY_COMMON_H
//-----------------------------------------------------------------------------
#include <map>
#include <string>
#include <set>
#include <list>
#include <vector>
#include <memory>
//-----------------------------------------------------------------------------
#include "glib.h"
#if (GLIB_MAJOR_VERSION == 2) && (GLIB_MINOR_VERSION < 32)
#define G_ASYNC_QUEUE_TIMEOUT_POP(queue,timeout,type,event) do { GTimeVal tv; g_get_current_time( &tv ); g_time_val_add( &tv, timeout ); event = (type) g_async_queue_timed_pop( queue, &tv ); } while(0)
#else
#define G_ASYNC_QUEUE_TIMEOUT_POP(queue,timeout,type,event) event = (type)g_async_queue_timeout_pop(queue,timeout)
#endif
//-----------------------------------------------------------------------------
#include "json-glib/json-glib.h"
#include "clutter/clutter.h"
#define TRICKPLAY_PRIORITY CLUTTER_PRIORITY_REDRAW
//-----------------------------------------------------------------------------
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
//-----------------------------------------------------------------------------
#include "trickplay/trickplay.h"
//-----------------------------------------------------------------------------
typedef std::string                             String;
typedef std::map<std::string, std::string>      StringMap;
typedef std::multimap<std::string, std::string> StringMultiMap;
typedef std::list<String>                       StringList;
typedef std::set<String>                        StringSet;
typedef std::pair<String, String>               StringPair;
typedef std::list<StringPair>                   StringPairList;
typedef std::vector<String>                     StringVector;
typedef std::vector<StringPair>                 StringPairVector;


#endif // _TRICKPLAY_COMMON_H
