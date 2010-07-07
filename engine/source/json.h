#ifndef _TRICKPLAY_JSON_H
#define _TRICKPLAY_JSON_H

#include "json-glib/json-glib.h"

#if ! JSON_CHECK_VERSION(0,5,0)
#error "NEED JSON-GLIB VERSION 0.5.0 OR GREATER"
#endif

#include "common.h"

namespace JSON
{
    //.........................................................................
    // A static pointer that represents a Json null in Lua
    // (as a light user data)

    gpointer null();

    //.........................................................................
    // Converts the JsonNode to a Lua table and pushes the table
    // onto the stack. In case of a problem, pushes nil.

    void to_lua( lua_State * L, JsonNode * node );

    //.........................................................................
    // Converts the value on the stack at index to a JsonNode. In
    // case of a problem, will return a valid JsonNode that contains
    // a NULL.

    JsonNode * to_json( lua_State * L, int index );

    //.........................................................................
    // Parses the json_string to a Lua value and pushes the result onto
    // the stack. If anything goes wrong, it pushes a nil and returns
    // false.

    bool parse( lua_State * L, const gchar * json_string );

    //.........................................................................
    // Converts the Lua value at index to a JSON string. If anything goes
    // wrong, the resulting string will be empty.

    String stringify( lua_State * L, int index );
};

#endif // _TRICKPLAY_JSON_H
