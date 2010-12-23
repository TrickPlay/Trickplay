
#include "json.h"
#include "lb.h"

//-----------------------------------------------------------------------------
// This is a static we use as a light user data to represent a JSON null.
// Its address will never change, so equality testing works. It is also the
// readonly property JSON.null

gpointer JSON::null()
{
    static char n = 0;

    return & n;
}

//-----------------------------------------------------------------------------
// Adds a member of an object to a Lua table at the top of the stack

void object_member_to_lua( JsonObject * object, const gchar *member_name, JsonNode * member_node, gpointer user_data)
{
    g_assert( object );
    g_assert( member_name );
    g_assert( member_node );
    g_assert( user_data );

    lua_State * L = ( lua_State * ) user_data;

    lua_pushstring( L, member_name );
    JSON::to_lua( L, member_node );
    lua_rawset( L, -3 );
}

//-----------------------------------------------------------------------------
// Adds an element of an array to a Lua table at the top of the stack

void array_element_to_lua( JsonArray * array, guint index, JsonNode * element_node, gpointer user_data)
{
    g_assert( array );
    g_assert( element_node );
    g_assert( user_data );

    lua_State * L = ( lua_State * ) user_data;

    JSON::to_lua( L, element_node );
    lua_rawseti( L, -2, index + 1 );
}

//-----------------------------------------------------------------------------
// Converts a JSON node to Lua and pushes it on the stack

void JSON::to_lua( lua_State * L, JsonNode * node )
{
    LSG;

    switch( JSON_NODE_TYPE( node ) )
    {
        case JSON_NODE_OBJECT:
        {
            lua_newtable( L );

            json_object_foreach_member( json_node_get_object( node ), object_member_to_lua, L );

            break;
        }

        case JSON_NODE_ARRAY:
        {
            lua_newtable( L );

            json_array_foreach_element( json_node_get_array( node ), array_element_to_lua, L );

            break;
        }

        case JSON_NODE_VALUE:
        {
            switch( json_node_get_value_type( node ) )
            {
                case G_TYPE_BOOLEAN:
                {
                    lua_pushboolean( L, json_node_get_boolean( node ) );
                    break;
                }

                case G_TYPE_DOUBLE:
                {
                    lua_pushnumber( L, json_node_get_double( node ) );
                    break;
                }

                case G_TYPE_INT:
                case G_TYPE_INT64:
                {
                    lua_pushinteger( L, json_node_get_int( node ) );
                    break;
                }

                case G_TYPE_STRING:
                {
                    lua_pushstring( L, json_node_get_string( node ) );
                    break;
                }

                default:
                {
                    g_warning( "INVALID JSON VALUE TYPE : %s", json_node_type_name( node ) );
                    lua_pushlightuserdata( L, JSON::null() );
                    break;
                }
            }

            break;
        }

        case JSON_NODE_NULL:
        {
            lua_pushlightuserdata( L, JSON::null() );
            break;
        }

        default:
        {
            g_assert( false );
        }
    }

    (void)LSG_END(1);
}

//-----------------------------------------------------------------------------
// Converts the Lua value at index to a JsonNode

JsonNode * JSON::to_json( lua_State * L, int index )
{
    LSG;

    JsonNode * result = NULL;

    switch( lua_type( L, index ) )
    {
        case LUA_TNUMBER:

            result = json_node_new( JSON_NODE_VALUE );

            if ( lua_tointeger( L, index ) == lua_tonumber( L, index ) )
            {
                json_node_set_int( result, lua_tointeger( L, index ) );
            }
            else
            {
                json_node_set_double( result, lua_tonumber( L, index ) );
            }

            break;

        case LUA_TBOOLEAN:

            result = json_node_new( JSON_NODE_VALUE );

            json_node_set_boolean( result, lua_toboolean( L, index ) );

            break;

        case LUA_TSTRING:

            result = json_node_new( JSON_NODE_VALUE );

            json_node_set_string( result, lua_tostring( L, index ) );

            break;

        case LUA_TTABLE:

            // If it has a length, we treat it as an array

            if ( lua_rawlen( L, index ) > 0 )
            {
                JsonArray * array = json_array_new();

                lua_pushnil( L );

                while ( lua_next( L, index ) )
                {
                    json_array_add_element( array, JSON::to_json( L, lua_gettop( L ) ) );

                    lua_pop( L, 1 );
                }

                result = json_node_new( JSON_NODE_ARRAY );

                json_node_take_array( result, array );
            }
            else
            {
                JsonObject * object = json_object_new();

                lua_pushnil( L );

                while( lua_next( L, index ) )
                {
                    if ( lua_isstring( L, -2 ) )
                    {
                        json_object_set_member( object, lua_tostring( L, -2 ), JSON::to_json( L, lua_gettop( L ) ) );
                    }

                    lua_pop( L, 1 );
                }

                result = json_node_new( JSON_NODE_OBJECT );

                json_node_take_object( result, object );
            }

            break;

        default:

            break;
    }


    if ( ! result )
    {
        result = json_node_new( JSON_NODE_NULL );
    }

    LSG_END(0);

    return result;
}

//-----------------------------------------------------------------------------

bool JSON::parse( lua_State * L, const gchar * json_string )
{
    LSG;

    bool result = false;

    int top = lua_gettop( L );

    JsonParser * parser = json_parser_new();

    GError * error = NULL;

    if ( ! json_parser_load_from_data( parser, json_string, -1, & error ) )
    {
        g_warning( "FAILED TO PARSE JSON : %s", error->message );

        g_clear_error( &error );
    }
    else
    {
        JsonNode * root = json_parser_get_root( parser );

        if ( ! root )
        {
            g_warning( "FAILED TO PARSE JSON : INVALID ROOT ELEMENT '%s'", json_string );
        }
        else
        {
            JsonNodeType type = JSON_NODE_TYPE( root );

            if ( type != JSON_NODE_OBJECT && type != JSON_NODE_ARRAY )
            {
                g_warning( "FAILED TO PARSE JSON : INVALID ROOT ELEMENT '%s'", json_string );
            }
            else
            {
                JSON::to_lua( L, root );

                result = true;
            }
        }
    }

    g_object_unref( G_OBJECT( parser ) );


    if ( lua_gettop( L ) == top )
    {
        lua_pushnil( L );
    }

    (void)LSG_END(1);

    return result;
}

//-----------------------------------------------------------------------------

String JSON::stringify( lua_State * L, int index, bool pretty )
{
    String result;

    JsonNode * root = JSON::to_json( L, index );

    g_assert( root );

    switch ( json_node_get_node_type( root ) )
    {
        case JSON_NODE_OBJECT:
        case JSON_NODE_ARRAY:

            {
                JsonGenerator * g = json_generator_new();

                g_object_set( G_OBJECT( g ), "pretty", gboolean( pretty ), NULL );

                json_generator_set_root( g, root );

                gsize length = 0;

                gchar * json = json_generator_to_data( g, & length );

                g_object_unref( G_OBJECT( g ) );

                result = String( json, length );
            }

            break;

        default:

            break;
    }

    json_node_free( root );

    return result;
}
