
#include <cstring>
#include <sstream>
#include <iomanip>

#include "json.h"
#include "lb.h"
#include "util.h"

namespace JSON
{


//-----------------------------------------------------------------------------
// This is a static we use as a light user data to represent a JSON null.
// Its address will never change, so equality testing works. It is also the
// readonly property JSON.null

gpointer null()
{
    static char n = 0;

    return & n;
}


//-----------------------------------------------------------------------------
// Converts a JSON node to Lua and pushes it on the stack

void to_lua( lua_State* L , const Value& value )
{
    LSG;

    switch ( value.get_type() )
    {
        case Value::T_OBJECT:
        {
            lua_newtable( L );
            const Object& object( value.as<Object>() );

            for ( Object::Map::const_iterator it = object.begin(); it != object.end(); ++it )
            {
                lua_pushlstring( L , it->first.data() , it->first.size() );
                to_lua( L , it->second );
                lua_rawset( L , -3 );
            }

            break;
        }

        case Value::T_ARRAY:
        {
            lua_newtable( L );
            const Array& array( value.as<Array>() );
            int i = 1;

            for ( Array::Vector::const_iterator it = array.begin(); it != array.end(); ++it , ++i )
            {
                to_lua( L , *it );
                lua_rawseti( L , -2 , i );
            }

            break;
        }

        case Value::T_BOOL:
            lua_pushboolean( L , value.as<bool>() );
            break;

        case Value::T_DOUBLE:
            lua_pushnumber( L , value.as<double>() );
            break;

        case Value::T_INT:
            lua_pushinteger( L , value.as<long long>() );
            break;

        case Value::T_NULL:
            lua_pushlightuserdata( L, JSON::null() );
            break;

        case Value::T_STRING:
        {
            const String& s( value.as<String>() );
            lua_pushlstring( L , s.data() , s.size() );
            break;
        }
    }

    LSG_CHECK( 1 );
}

//-----------------------------------------------------------------------------
// Converts the Lua value at index to a JSON::Value


Value to_json( lua_State* L , int index )
{
    LSG;

    Value result;

    if ( index < 0 )
    {
        index = lua_gettop( L ) + index + 1;
    }

    switch ( lua_type( L , index ) )
    {
        case LUA_TNUMBER:

            if ( lua_tointeger( L, index ) == lua_tonumber( L, index ) )
            {
                result.as< long long >() = lua_tointeger( L, index );
            }
            else
            {
                result = lua_tonumber( L, index );
            }

            break;

        case LUA_TBOOLEAN:

            result.as<bool>() = lua_toboolean( L, index );

            break;

        case LUA_TSTRING:
        {
            size_t len = 0;
            const char* s = lua_tolstring( L , index , & len );
            result = String( s , len );
            break;
        }

        case LUA_TTABLE:

            // If it has a length, we treat it as an array

            // Unfortunately, this means that a Lua empty table will be
            // converted to an empty object. Should it be an empty array?
            //
            // If in Lua it is {} , should it be {} or [] in JSON?

            if ( lua_rawlen( L, index ) > 0 )
            {
                Array& array( result.as< Array >() );

                lua_pushnil( L );

                while ( lua_next( L, index ) )
                {
                    array.append( to_json( L , lua_gettop( L ) ) );

                    lua_pop( L, 1 );
                }
            }
            else
            {
                Object& object( result.as< Object >() );

                lua_pushnil( L );

                while ( lua_next( L, index ) )
                {
                    if ( lua_really_isstring( L, -2 ) )
                    {
                        size_t len = 0;
                        const char* key = lua_tolstring( L , -2 , & len );
                        object[ String( key , len ) ] = to_json( L, lua_gettop( L ) );
                    }

                    lua_pop( L, 1 );
                }
            }

            break;

        default:

            break;
    }

    LSG_CHECK( 0 );

    return result;
}

//-----------------------------------------------------------------------------

bool parse( lua_State* L, const gchar* json_string )
{
    LSG;

    bool result = false;

    int top = lua_gettop( L );

    Value root( Parser::parse( json_string ) );

    if ( root.is<Object>() || root.is<Array>() )
    {
        to_lua( L, root );

        result = true;
    }

    if ( lua_gettop( L ) == top )
    {
        lua_pushnil( L );
    }

    LSG_CHECK( 1 );

    return result;
}

//-----------------------------------------------------------------------------

String stringify( lua_State* L, int index, bool pretty )
{
    String result;

    Value root( to_json( L , index ) );

    if ( root.is<Object>() )
    {
        result = root.as<Object>().stringify();
    }
    else if ( root.is<Array>() )
    {
        result = root.as<Array>().stringify();
    }

    return result;
}

//-----------------------------------------------------------------------------

static String encode_string( const String& string )
{
    // Convert to UTF16 using GLib

    GError* error = 0;

    long written = 0;

    gunichar2* utf16 = g_utf8_to_utf16( string.data() , string.size() , 0 , & written , & error );

    if ( error )
    {
        g_warning( "INVALID UTF8 SEQUENCE : %s" , error->message );

        g_clear_error( & error );

        return String( "\"\"" );
    }

    FreeLater free_later( utf16 );

    // Now spit out the results

    std::stringstream result;

    result << "\"";

    gunichar2* s = utf16;

    for ( long i = 0; i < written; ++i , ++s )
    {
        switch ( *s )
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
            {
                if ( *s >= 32 && *s < 127 )
                {
                    result << char( *s );
                }
                else
                {
                    result << "\\u" << std::setw( 4 ) << std::setfill( '0' ) << std::hex << *s;
                }

                break;
            }
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

Value::Value( const char* _value )
    :
    type( T_STRING )
{
    value.string_value = new String( _value ? _value : "" );
}

Value::Value( const String& _value )
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

Value::Value( const Object& _value )
    :
    type( T_OBJECT )
{
    value.object_value = new Object( _value );
}

Value::Value( const Array& _value )
    :
    type( T_ARRAY )
{
    value.array_value = new Array( _value );
}

Value::Value( const Value& _value )
    :
    type( _value.type ),
    value( _value.value )
{
    switch ( type )
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
    switch ( type )
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


template <> String& Value::as< String >()
{
    if ( type != T_STRING )
    {
        clear();

        type = T_STRING;

        value.string_value = new String();
    }

    return * value.string_value;
}

template <> long long& Value::as< long long >()
{
    if ( type != T_INT )
    {
        clear();

        type = T_INT;
    }

    return value.int_value;
}

template <> double& Value::as< double >()
{
    if ( type != T_DOUBLE )
    {
        clear();

        type = T_DOUBLE;
    }

    return value.double_value;
}

template <> bool& Value::as< bool >()
{
    if ( type != T_BOOL )
    {
        clear();

        type = T_BOOL;
    }

    return value.boolean_value;
}

template <> Object& Value::as< Object >()
{
    if ( type != T_OBJECT )
    {
        clear();

        type = T_OBJECT;

        value.object_value = new Object();
    }

    return * value.object_value;
}

template <> Array& Value::as< Array >()
{
    if ( type != T_ARRAY )
    {
        clear();

        type = T_ARRAY;

        value.array_value = new Array();
    }

    return * value.array_value;
}


template <> const String& Value::as< String >() const
{
    static const String dummy;

    return ( type == T_STRING ? * value.string_value : dummy );
}

template <> const long long& Value::as< long long >() const
{
    static const long long dummy = 0;

    return ( type == T_INT ? value.int_value : dummy );
}

template <> const double& Value::as< double >() const
{
    static const double dummy = 0;

    return ( type == T_DOUBLE ? value.double_value : dummy );
}

template <> const bool& Value::as< bool >() const
{
    static const bool dummy = false;

    return ( type == T_BOOL ? value.boolean_value : dummy );
}

template <> const Object& Value::as< Object >() const
{
    static const Object dummy;

    return ( type == T_OBJECT ? * value.object_value : dummy );
}

template <> const Array& Value::as< Array >() const
{
    static const Array dummy;

    return ( type == T_ARRAY ? * value.array_value : dummy );
}

Value& Value::operator = ( const char* _value )
{
    as< String >() = _value ? _value : "";

    return * this;
}

Value& Value::operator = ( const String& _value )
{
    as< String >() = _value;

    return * this;
}

Value& Value::operator = ( long long _value )
{
    as< long long >() = _value;

    return * this;
}

Value& Value::operator = ( int _value )
{
    as< long long >() = _value;

    return * this;
}

Value& Value::operator = ( double _value )
{
    as< double >() = _value;

    return * this;
}

Value& Value::operator = ( bool _value )
{
    as< bool >() = _value;

    return * this;
}

Value& Value::operator = ( const Object& _value )
{
    as< Object >() = _value;

    return * this;
}

Value& Value::operator = ( const Array& _value )
{
    as< Array >() = _value;

    return * this;
}

Value& Value::operator = ( const Value& _value )
{
    clear();

    type = _value.type;
    value = _value.value;

    switch ( type )
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

double Value::as_number() const
{
    switch ( type )
    {
        case T_DOUBLE:
            return value.double_value;

        case T_INT:
            return value.int_value;

        case T_BOOL:
            return value.boolean_value ? 1 : 0;

        default:
            return 0;
    }
}

std::ostream& operator << ( std::ostream& os , const Value& value )
{
    switch ( value.get_type() )
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

String Value::stringify() const
{
    std::stringstream os;

    os << * this;

    return os.str();
}

//=============================================================================

Object::Object()
{
}

Object::Object( const Object& source )
    :
    map( source.map )
{
}

Object::~Object()
{
}

Value& Object::operator []( const String& key )
{
    return map[ key ];
}

Value& Object::at( const String& key )
{
    return map[ key ];
}

bool Object::has( const String& key ) const
{
    return map.find( key ) != map.end();
}

Object::Map::iterator Object::find( const String& key )
{
    return map.find( key );
}

Object::Map::const_iterator Object::find( const String& key ) const
{
    return map.find( key );
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

std::ostream& operator<<( std::ostream& os , const Object& object )
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

Object::Map::size_type Object::size() const
{
    return map.size();
}

void Object::clear()
{
    map.clear();
}

//=============================================================================

Array::Array()
{
}

Array::Array( const Array& source )
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

Value& Array::operator []( std::vector< Value >::size_type index )
{
    return vector[ index ];
}

Value& Array::append( const Value& value )
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

std::ostream& operator<<( std::ostream& os , const Array& object )
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

template <> Object& Array::append< Object > ()
{
    return append().as<Object>();
}

template <> Array& Array::append< Array >( )
{
    return append().as<Array>();
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

Value Parser::parse( const String& json )
{
    return parse( json.c_str() );
}

Value Parser::parse( std::istream& stream )
{
    Parser parser;

    char buffer[512];

    while ( ! stream.eof() )
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

Value Parser::parse( const char* json , long int length )
{
    Parser parser;

    parser.parse_chunk( json , length );

    return parser.finish();
}

bool Parser::parse_chunk( const char* json , long int length )
{
    if ( length <= 0 )
    {
        for ( const char* p = json; *p; ++p )
        {
            if ( ! JSON_parser_char( parser , ( unsigned char ) *p ) )
            {
                stack.clear();
                root.clear();
                return false;
            }
        }
    }
    else
    {
        const char* p = json;

        for ( long int i = 0; i < length; ++i , ++p )
        {
            if ( ! JSON_parser_char( parser , ( unsigned char ) *p ) )
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

int Parser::parser_callback( void* ctx , int type , const struct JSON_value_struct* value )
{
    Parser* self = ( Parser* ) ctx;

    Stack& stack( self->stack );

    Value new_value;

    switch ( type )
    {
        case JSON_T_ARRAY_BEGIN:

            if ( stack.empty() )
            {
                self->root = Array();

                stack.push_back( StackPair( & self->root , String() ) );

                return 1;
            }

            new_value = Array();

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
                self->root = Object();

                stack.push_back( StackPair( & self->root , String() ) );

                return 1;
            }

            new_value = Object();
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

            if ( ! stack.back().first->is< Object >() )
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

    Value* top_value = stack.back().first;

    Value* to_push = 0;

    if ( top_value->is< Array >() )
    {
        to_push = & ( top_value->as< Array >().append( new_value ) );
    }
    else if ( top_value->is< Object >() )
    {
        String& key( stack.back().second );

        to_push = & ( top_value->as< Object >()[ key ] = new_value );
    }
    else
    {
        return 0;
    }

    if ( to_push->is< Array >() || to_push->is< Object >() )
    {
        stack.push_back( StackPair( to_push , String() ) );
    }

    return 1;
}
}
