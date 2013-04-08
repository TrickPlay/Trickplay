#ifndef _TRICKPLAY_JSON_H
#define _TRICKPLAY_JSON_H

#include <iostream>
#include "common.h"

#include "JSON_parser.h"

namespace JSON
{
class Object;
class Array;
class Null;
class Value;

//.........................................................................
// A static pointer that represents a Json null in Lua
// (as a light user data)

gpointer null();

//.........................................................................
// Converts the JSON::Value to a Lua table and pushes the table
// onto the stack. In case of a problem, pushes nil.

void to_lua( lua_State* L , const Value& value );

//.........................................................................
// Converts the value on the stack at index to a JSON::Value.
// If there is a problem it will return a value that is Null.

Value to_json( lua_State* L , int index );

//.........................................................................
// Parses the json_string to a Lua value and pushes the result onto
// the stack. If anything goes wrong, it pushes a nil and returns
// false.

bool parse( lua_State* L , const gchar* json_string );

//.........................................................................
// Converts the Lua value at index to a JSON string. If anything goes
// wrong, the resulting string will be empty.

String stringify( lua_State* L , int index , bool pretty = false );

//.........................................................................
// Our own JSON stuff

class Value
{
public:

    enum Type
    {
        T_NULL ,
        T_STRING ,
        T_INT ,
        T_DOUBLE ,
        T_BOOL ,
        T_OBJECT ,
        T_ARRAY
    };

    Value( );
    Value( const char*      value );
    Value( const String&    value );
    Value( long long        value );
    Value( int              value );
    Value( double           value );
    Value( bool             value );
    Value( const Object&    value );
    Value( const Array&     value );
    Value( const Value&     value );

    virtual ~Value();

    void clear();

    bool empty() const;

    template < typename T > bool is() const;

    template < typename T > T& as();

    template < typename T > const T& as() const;

    Value& operator = ( const char*    value );
    Value& operator = ( const String& value );
    Value& operator = ( long long      value );
    Value& operator = ( int            value );
    Value& operator = ( double         value );
    Value& operator = ( bool           value );
    Value& operator = ( const Object& value );
    Value& operator = ( const Array&   value );
    Value& operator = ( const Value&   value );

    Type get_type() const;

    friend std::ostream& operator << ( std::ostream& os , const Value& value );

    String stringify() const;

    double as_number() const;

private:

    Type    type;

    union
    {
        long long   int_value;
        double      double_value;
        String*     string_value;
        bool        boolean_value;
        Object*     object_value;
        Array*      array_value;
    }
    value;
};

template <> bool Value::is< Null        >() const;
template <> bool Value::is< String      >() const;
template <> bool Value::is< int         >() const;
template <> bool Value::is< long long   >() const;
template <> bool Value::is< double      >() const;
template <> bool Value::is< bool        >() const;
template <> bool Value::is< Object      >() const;
template <> bool Value::is< Array       >() const;

template <> String&     Value::as< String       >();
template <> long long& Value::as< long long    >();
template <> double&     Value::as< double       >();
template <> bool&       Value::as< bool         >();
template <> Object&     Value::as< Object       >();
template <> Array&      Value::as< Array        >();

template <> const String&       Value::as< String       >() const;
template <> const long long&    Value::as< long long    >() const;
template <> const double&       Value::as< double       >() const;
template <> const bool&         Value::as< bool         >() const;
template <> const Object&       Value::as< Object       >() const;
template <> const Array&        Value::as< Array        >() const;

//=============================================================================

class Null
{
};

//=============================================================================

class Object
{
public:

    Object();
    Object( const Object& source );
    virtual ~Object();

    Value& operator []( const String& key );

    Value& at( const String& key );

    typedef std::map< String , Value > Map;

    bool has( const String& key ) const;

    Map::iterator find( const String& key );
    Map::const_iterator find( const String& key ) const;

    Map::iterator begin();
    Map::const_iterator begin() const;
    Map::iterator end();
    Map::const_iterator end() const;

    friend std::ostream& operator<<( std::ostream& os , const Object& object );

    String stringify() const;

    Map::size_type size() const;

    void clear();

private:

    Map map;
};

//=============================================================================

class Array
{
public:

    Array();
    Array( const Array& source );
    virtual ~Array();

    bool empty() const;

    std::vector< Value >::size_type size() const;

    void clear();

    Value& operator []( std::vector< Value >::size_type index );

    Value& append( const Value& value = Value() );

    template < typename T > T& append();

    typedef std::vector< Value > Vector;

    Vector::iterator begin();
    Vector::const_iterator begin() const;
    Vector::iterator end();
    Vector::const_iterator end() const;

    friend std::ostream& operator<<( std::ostream& os , const Array& object );

    String stringify() const;

private:


    Vector vector;
};

template <> Object&     Array::append< Object       >();
template <> Array&      Array::append< Array        >();

//=============================================================================

class Parser
{
public:

    Parser();

    virtual ~Parser();

    static Value parse( const String& json );

    static Value parse( std::istream& stream );

    static Value parse( const char* json , long int length = -1 );

    bool parse_chunk( const char* json , long int length = -1 );

    Value finish();

private:

    static int parser_callback( void* ctx , int type , const struct JSON_value_struct* value );

    typedef std::pair< Value* , String > StackPair;

    typedef std::list< StackPair > Stack;

    Value       root;

    Stack       stack;

    JSON_parser parser;
};
};

#endif // _TRICKPLAY_JSON_H
