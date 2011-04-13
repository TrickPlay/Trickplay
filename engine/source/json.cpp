
#include <cstring>
#include <sstream>
#include <iomanip>

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

            if ( lua_objlen( L, index ) > 0 )
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


namespace JSON
{
    static String encode_string( const String & string )
    {
        std::stringstream result;

        result << "\"";

        for ( String::const_iterator it = string.begin(); it != string.end(); ++it )
        {
            switch( *it )
            {
                case '"':
                    result << "\\\"";
                    break;
                case '\\':
                    result << "\\\\";
                    break;
                case '/':
                    result << "\\/";
                    break;
                case '\b':
                    result << "\\b";
                    break;
                case '\f':
                    result << "\\f";
                    break;
                case '\n':
                    result << "\\n";
                    break;
                case '\r':
                    result << "\\r";
                    break;
                case '\t':
                    result << "\\t";
                    break;
                default:
                    if ( *it >= 0 && ( *it < 32 || *it == 127 ) )
                    {
                        result << "\\u" << std::setw(4) << std::setfill( '0' ) << std::hex <<  int( *it ) ;
                    }
                    else if ( *it >= 32 && *it < 127 )
                    {
                        result << * it;
                    }
                    else
                    {
                        unsigned char b1 = *it;

                        int length = ( b1 & 0xE0 ) == 0xE0 ? 2 : 1;

                        unsigned int x = b1 & 0x1F;

                        ++it;

                        for ( int i = 0; i < length && it != string.end(); ++i , ++it )
                        {
                            x = ( x << 6 ) + ( ( ( unsigned char ) *it ) & 0x3F );
                        }

                        --it;

                        result << "\\u" ;
                        result << std::setw(4) << std::setfill( '0' ) << std::hex << x;
                    }
                    break;
            }

            if ( it == string.end() )
            {
                break;
            }
        }

        result << "\"";

        return result.str();
    }

    //=============================================================================

    Value::Value( )
    :
        type( T_NULL )
    {
        memset( & value , 0 , sizeof( value ) );
    }

    Value::Value( const char * _value )
    :
        type( T_STRING )
    {
        value.string_value = new String( _value ? _value : "" );
    }

    Value::Value( const String & _value )
    :
        type( T_STRING )
    {
        value.string_value = new String( _value );
    }

    Value::Value( long long _value )
    :
        type( T_INT )
    {
        value.int_value = _value ;
    }

    Value::Value( int _value )
    :
        type( T_INT )
    {
        value.int_value = _value ;
    }

    Value::Value( double _value )
    :
        type( T_DOUBLE )
    {
        value.double_value = _value;
    }

    Value::Value( bool _value )
    :
        type( T_BOOL )
    {
        value.boolean_value = _value;
    }

    Value::Value( const Object & _value )
    :
        type( T_OBJECT )
    {
        value.object_value = new Object( _value );
    }

    Value::Value( const Array & _value )
    :
        type( T_ARRAY )
    {
        value.array_value = new Array( _value );
    }

    Value::Value( const Value & _value )
    :
        type( _value.type ),
        value( _value.value )
    {
        switch( type )
        {
            case T_STRING:
                value.string_value = new String( * value.string_value );
                break;
            case T_OBJECT:
                value.object_value = new Object( * value.object_value );
                break;
            case T_ARRAY:
                value.array_value = new Array( * value.array_value );
                break;
            default:
                break;
        }
    }

    Value::~Value()
    {
        clear();
    }

    void Value::clear()
    {
        switch( type )
        {
            case T_STRING:
                delete value.string_value;
                break;
            case T_OBJECT:
                delete value.object_value;
                break;
            case T_ARRAY:
                delete value.array_value;
                break;
            default:
                break;
        }

        memset( & value , 0 , sizeof( value ) );

        type = T_NULL;
    }

    bool Value::empty() const
    {
        return type == T_NULL;
    }

    template <> bool Value::is< Null >() const
    {
        return type == T_NULL;
    }

    template <> bool Value::is< String >() const
    {
        return type == T_STRING;
    }

    template <> bool Value::is< int >() const
    {
        return type == T_INT;
    }

    template <> bool Value::is< long long >() const
    {
        return type == T_INT;
    }

    template <> bool Value::is< double >() const
    {
        return type == T_DOUBLE;
    }

    template <> bool Value::is< bool >() const
    {
        return type == T_BOOL;
    }

    template <> bool Value::is< Object >() const
    {
        return type == T_OBJECT;
    }

    template <> bool Value::is< Array >() const
    {
        return type == T_ARRAY;
    }


    template <> String & Value::as< String >()
    {
        if ( type != T_STRING )
        {
            clear();

            type = T_STRING;

            value.string_value = new String();
        }

        return * value.string_value;
    }

    template <> long long & Value::as< long long >()
    {
        if ( type != T_INT )
        {
            clear();

            type = T_INT;
        }

        return value.int_value;
    }

    template <> double & Value::as< double >()
    {
        if ( type != T_DOUBLE )
        {
            clear();

            type = T_DOUBLE;
        }

        return value.double_value;
    }

    template <> bool & Value::as< bool >()
    {
        if ( type != T_BOOL )
        {
            clear();

            type = T_BOOL;
        }

        return value.boolean_value;
    }

    template <> Object & Value::as< Object >()
    {
        if ( type != T_OBJECT )
        {
            clear();

            type = T_OBJECT;

            value.object_value = new Object();
        }

        return * value.object_value;
    }

    template <> Array & Value::as< Array >()
    {
        if ( type != T_ARRAY )
        {
            clear();

            type = T_ARRAY;

            value.array_value = new Array();
        }

        return * value.array_value;
    }

    Value & Value::operator = ( const char * _value )
    {
        as< String >() = _value ? _value : "";

        return * this;
    }

    Value & Value::operator = ( const String & _value )
    {
        as< String >() = _value;

        return * this;
    }

    Value & Value::operator = ( long long _value )
    {
        as< long long >() = _value;

        return * this;
    }

    Value & Value::operator = ( int _value )
    {
        as< long long >() = _value;

        return * this;
    }

    Value & Value::operator = ( double _value )
    {
        as< double >() = _value;

        return * this;
    }

    Value & Value::operator = ( bool _value )
    {
        as< bool >() = _value;

        return * this;
    }

    Value & Value::operator = ( const Object & _value )
    {
        as< Object >() = _value;

        return * this;
    }

    Value & Value::operator = ( const Array & _value )
    {
        as< Array >() = _value;

        return * this;
    }

    Value & Value::operator = ( const Value & _value )
    {
        clear();

        type =_value.type;
        value = _value.value;

        switch( type )
        {
            case T_STRING:
                value.string_value = new String( * value.string_value );
                break;
            case T_OBJECT:
                value.object_value = new Object( * value.object_value );
                break;
            case T_ARRAY:
                value.array_value = new Array( * value.array_value );
                break;
            default:
                break;
        }

        return * this;
    }

    Value::Type Value::get_type() const
    {
        return type;
    }

    std::ostream & operator << ( std::ostream & os , const Value & value )
    {
        switch( value.get_type() )
        {
            case Value::T_NULL:
                os << "null";
                break;
            case Value::T_STRING:
                os << encode_string( * value.value.string_value );
                break;
            case Value::T_INT:
                os << value.value.int_value;
                break;
            case Value::T_DOUBLE:
                os << value.value.double_value;
                break;
            case Value::T_BOOL:
                os << ( value.value.boolean_value ? "true" : "false" );
                break;
            case Value::T_OBJECT:
                os << ( * value.value.object_value );
                break;
            case Value::T_ARRAY:
                os << ( * value.value.array_value );
                break;
        }
        return os;
    }

    //=============================================================================

    Object::Object()
    {
    }

    Object::Object( const Object & source )
    :
        map( source.map )
    {
    }

    Object::~Object()
    {
    }

    Value & Object::operator [] ( const String & key )
    {
        return map[ key ];
    }

    bool Object::has( const String & key ) const
    {
        return map.find( key ) != map.end();
    }

    Object::Map::iterator Object::begin()
    {
        return map.begin();
    }

    Object::Map::const_iterator Object::begin() const
    {
        return map.begin();
    }

    Object::Map::iterator Object::end()
    {
        return map.end();
    }

    Object::Map::const_iterator Object::end() const
    {
        return map.end();
    }

    std::ostream & operator<<( std::ostream & os , const Object & object )
    {
        bool first = true;
        os << "{";
        for ( Object::Map::const_iterator it = object.begin(); it != object.end(); ++it )
        {
            if ( first )
            {
                first = false;
            }
            else
            {
                os << ",";
            }
            os << encode_string( it->first ) << ":" << it->second;
        }
        os << "}";
        return os;
    }

    String Object::stringify() const
    {
        std::stringstream os;

        os << * this;

        return os.str();
    }

    //=============================================================================

    Array::Array()
    {
    }

    Array::Array( const Array & source )
    :
        vector( source.vector )
    {
    }

    Array::~Array()
    {
    }

    bool Array::empty() const
    {
        return vector.empty();
    }

    std::vector< Value >::size_type Array::size() const
    {
        return vector.size();
    }

    void Array::clear()
    {
        vector.clear();
    }

    Value & Array::operator [] ( std::vector< Value >::size_type index )
    {
        return vector[ index ];
    }

    Value & Array::append( const Value & value )
    {
        vector.push_back( value );

        return vector.back();
    }

    Array::Vector::iterator Array::begin()
    {
        return vector.begin();
    }

    Array::Vector::const_iterator Array::begin() const
    {
        return vector.begin();
    }

    Array::Vector::iterator Array::end()
    {
        return vector.end();
    }

    Array::Vector::const_iterator Array::end() const
    {
        return vector.end();
    }

    std::ostream & operator<<( std::ostream & os , const Array & object )
    {
        bool first = true;
        os << "[";
        for ( Array::Vector::const_iterator it = object.begin(); it != object.end(); ++it )
        {
            if ( first )
            {
                first = false;
            }
            else
            {
                os << ",";
            }
            os << *it;
        }
        os << "]";
        return os;
    }

    String Array::stringify() const
    {
        std::stringstream os;

        os << * this;

        return os.str();
    }

    //=============================================================================

    Parser::Parser()
    {
        JSON_config config;

        init_JSON_config( & config );

        config.callback = parser_callback;
        config.callback_ctx = this;
        config.allow_comments = 1;
        config.depth = -1;

        parser = new_JSON_parser( & config );
    }

    Parser::~Parser()
    {
        delete_JSON_parser( parser );
    }

    Value Parser::parse( const String & json )
    {
        return parse( json.c_str() );
    }

    Value Parser::parse( std::istream & stream )
    {
        Parser parser;

        char buffer[512];

        while( ! stream.eof() )
        {
            stream.read( buffer , sizeof( buffer ) );

            if ( stream.bad() )
            {
                return Value();
            }

            if ( 0 == stream.gcount() )
            {
                break;
            }

            if ( ! parser.parse_chunk( buffer , stream.gcount() ) )
            {
                return Value();
            }
        }

        return parser.finish();
    }

    Value Parser::parse( const char * json , long int length )
    {
        Parser parser;

        parser.parse_chunk( json , length );

        return parser.finish();
    }

    bool Parser::parse_chunk( const char * json , long int length )
    {
        if ( length <= 0 )
        {
            for ( const char * p = json; *p; ++p )
            {
                if ( ! JSON_parser_char( parser , *p ) )
                {
                    stack.clear();
                    root.clear();
                    return false;
                }
            }
        }
        else
        {
            const char * p = json;

            for ( long int i = 0; i < length; ++i , ++p )
            {
                if ( ! JSON_parser_char( parser , *p ) )
                {
                    stack.clear();
                    root.clear();
                    return false;
                }
            }
        }

        return true;
    }

    Value Parser::finish()
    {
        Value result;

        if ( JSON_parser_done( parser ) )
        {
            result = root;
        }

        stack.clear();

        root.clear();

        return result;
    }

    int Parser::parser_callback( void * ctx , int type , const struct JSON_value_struct * value )
    {
        Parser * self = ( Parser * ) ctx;

        Stack & stack( self->stack );

        Value new_value;

        switch( type )
        {
            case JSON_T_ARRAY_BEGIN:

                if ( stack.empty() )
                {
                    self->root.as< Array >();

                    stack.push_back( StackPair( self->root , String() ) );

                    return 1;
                }

                new_value.as< Array >();

                break;

            case JSON_T_ARRAY_END:

                if ( stack.empty() )
                {
                    return 0;
                }
                stack.pop_back();
                return 1;
                break;

            case JSON_T_OBJECT_BEGIN:

                if ( stack.empty() )
                {
                    self->root.as< Object >();

                    stack.push_back( StackPair( self->root , String() ) );

                    return 1;
                }

                new_value.as< Object >();
                break;

            case JSON_T_OBJECT_END:

                if ( stack.empty() )
                {
                    return 0;
                }
                stack.pop_back();
                return 1;
                break;

            case JSON_T_INTEGER:

                new_value.as< long long >() = value->vu.integer_value;
                break;

            case JSON_T_FLOAT:

                new_value.as< double >() = value->vu.float_value;
                break;

            case JSON_T_NULL:

                break;

            case JSON_T_TRUE:

                new_value.as< bool >() = true;
                break;

            case JSON_T_FALSE:

                new_value.as< bool >() = false;
                break;

            case JSON_T_STRING:

                new_value.as< String >().assign( value->vu.str.value , value->vu.str.length );
                break;

            case JSON_T_KEY:

                if ( stack.empty() )
                {
                    return 0;
                }
                if ( ! stack.back().first.is< Object >() )
                {
                    return 0;
                }
                stack.back().second.assign( value->vu.str.value , value->vu.str.length );
                return 1;
                break;

            default:
                return 0;
        }

        if ( stack.empty() )
        {
            return 0;
        }

        Value & top_value( stack.back().first );

        Value * to_push = 0;

        if ( top_value.is< Array >() )
        {
            to_push = & ( top_value.as< Array >().append( new_value ) );
        }
        else if ( top_value.is< Object >() )
        {
            String & key( stack.back().second );

            to_push = & ( top_value.as< Object >()[ key ] = new_value );
        }
        else
        {
            return 0;
        }

        if ( to_push->is< Array >() || to_push->is< Object >() )
        {
            stack.push_back( StackPair( * to_push , String() ) );
        }

        return 1;
    }
}
