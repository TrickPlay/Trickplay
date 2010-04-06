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
#include "lua.hpp"
//-----------------------------------------------------------------------------
#include "trickplay/trickplay.h"
//-----------------------------------------------------------------------------
typedef std::string                             String;
typedef std::map<std::string, std::string>       StringMap;
typedef std::multimap<std::string, std::string>  StringMultiMap;
typedef std::list<String>                       StringList;
typedef std::set<String>                        StringSet;
typedef std::pair<String, String>                StringPair;
typedef std::list<StringPair>                   StringPairList;


#endif // _TRICKPLAY_COMMON_H
