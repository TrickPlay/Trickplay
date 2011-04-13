#ifndef _TRICKPLAY_JSON_H
#define _TRICKPLAY_JSON_H

#include <iostream>

#include "json-glib/json-glib.h"

#if ! JSON_CHECK_VERSION(0,5,0)
#error "NEED JSON-GLIB VERSION 0.5.0 OR GREATER"
#endif

#include "common.h"

#include "JSON_parser.h"

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

    String stringify( lua_State * L, int index, bool pretty = false );
};

// Newer home-brewed JSON stuff

namespace JSON
{
    class Object;
    class Array;
    class Null;

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
        Value( const char *     value );
        Value( const String &   value );
        Value( long long        value );
        Value( int              value );
        Value( double           value );
        Value( bool             value );
        Value( const Object &   value );
        Value( const Array &    value );
        Value( const Value &    value );

        virtual ~Value();

        void clear();

        bool empty() const;

        template < typename T > bool is() const;

        template < typename T > T & as();

        Value & operator = ( const char *   value );
        Value & operator = ( const String & value );
        Value & operator = ( long long      value );
        Value & operator = ( int            value );
        Value & operator = ( double         value );
        Value & operator = ( bool           value );
        Value & operator = ( const Object & value );
        Value & operator = ( const Array &  value );
        Value & operator = ( const Value &  value );

        Type get_type() const;

        friend std::ostream & operator << ( std::ostream & os , const Value & value );

    private:

        Type    type;

        union
        {
            long long   int_value;
            double      double_value;
            String *    string_value;
            bool        boolean_value;
            Object *    object_value;
            Array *     array_value;
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

    template <> String &    Value::as< String       >();
    template <> long long & Value::as< long long    >();
    template <> double &    Value::as< double       >();
    template <> bool &      Value::as< bool         >();
    template <> Object &    Value::as< Object       >();
    template <> Array &     Value::as< Array        >();

    //=============================================================================

    class Null
    {
    };

    //=============================================================================

    class Object
    {
    public:

        Object();
        Object( const Object & source );
        virtual ~Object();

        Value & operator [] ( const String & key );

        typedef std::map< String , Value > Map;

        bool has( const String & key ) const;

        Map::iterator begin();
        Map::const_iterator begin() const;
        Map::iterator end();
        Map::const_iterator end() const;

        friend std::ostream & operator<<( std::ostream & os , const Object & object );

        String stringify() const;

    private:

        Map map;
    };

    //=============================================================================

    class Array
    {
    public:

        Array();
        Array( const Array & source );
        virtual ~Array();

        bool empty() const;

        std::vector< Value >::size_type size() const;

        void clear();

        Value & operator [] ( std::vector< Value >::size_type index );

        Value & append( const Value & value = Value() );

        typedef std::vector< Value > Vector;

        Vector::iterator begin();
        Vector::const_iterator begin() const;
        Vector::iterator end();
        Vector::const_iterator end() const;

        friend std::ostream & operator<<( std::ostream & os , const Array & object );

        String stringify() const;

    private:


        Vector vector;
    };

    //=============================================================================

    class Parser
    {
    public:

        Parser();

        virtual ~Parser();

        static Value parse( const String & json );

        static Value parse( std::istream & stream );

        static Value parse( const char * json , long int length = -1 );

        bool parse_chunk( const char * json , long int length = -1 );

        Value finish();

    private:

        static int parser_callback( void * ctx , int type , const struct JSON_value_struct * value );

        typedef std::pair< Value & , String > StackPair;

        typedef std::list< StackPair > Stack;

        Value       root;

        Stack       stack;

        JSON_parser parser;
    };
};

#endif // _TRICKPLAY_JSON_H
