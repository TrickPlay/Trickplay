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
//-----------------------------------------------------------------------------
#include "json-glib/json-glib.h"
#define CLUTTER_VERSION_MIN_REQUIRED CLUTTER_VERSION_CUR_STABLE
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
