
#include "lb.h"
#include "user_data.h"
#include "typed_array.h"
#include "typed_array.lb.h"

//=============================================================================

ArrayBuffer::ArrayBuffer( gulong _length )
    :
    data( g_new0( guint8 , _length ) ),
    length( _length )
{
}

//.............................................................................

ArrayBuffer::~ArrayBuffer()
{
    g_free( data );
}

//.............................................................................

bool ArrayBuffer::is_array_buffer( lua_State* L , int index )
{
    return LB_GET_ARRAYBUFFER( L , index ) != 0;
}

//.............................................................................

ArrayBuffer* ArrayBuffer::from_lua( lua_State* L , int index )
{
    return LB_GET_ARRAYBUFFER( L , index );
}

//.............................................................................

void ArrayBuffer::push( lua_State* L )
{
    if ( UserData* ud = UserData::get_from_client( this ) )
    {
        ud->push_proxy();

        if ( ! lua_isnil( L , -1 ) )
        {
            return;
        }

        lua_pop( L , 1 );
    }

    UserData* ud = UserData::make( L , "ArrayBuffer" );

    luaL_getmetatable( L , "ARRAYBUFFER_METATABLE" );

    if ( lua_isnil( L , -1 ) )
    {
        lua_pop( L , 1 );
        lua_getglobal( L , "ArrayBuffer" );
        lua_pop( L , 1 );
        luaL_getmetatable( L , "ARRAYBUFFER_METATABLE" );
    }

    lua_setmetatable( L , -2 );

    this->ref();

    ud->initialize_with_client( this );
}

//=============================================================================
// Bad one

TypedArray::TypedArray()
    :
    type( T_INT8 ),
    bpe( bytes_per_element( T_INT8 ) ),
    length( 0 ),
    offset( 0 ),
    buffer( 0 ),
    bad( true )
{
}

//.............................................................................
// New typed array with a new buffer to hold _length elements.

TypedArray::TypedArray( Type _type , gulong _length )
    :
    type( _type ),
    bpe( bytes_per_element( _type ) ),
    length( _length ),
    offset( 0 ),
    buffer( new ArrayBuffer( bpe* _length ) ),
    bad( false )
{
}

//.............................................................................
// New typed array with a new buffer to hold _source->length elements.
// All elements from the source array are converted and copied into this one.

TypedArray::TypedArray( Type _type , TypedArray* _source )
    :
    type( _type ),
    bpe( bytes_per_element( _type ) ),
    length( _source->length ),
    offset( 0 ),
    buffer( new ArrayBuffer( bpe * _source->length ) ),
    bad( false )
{
    if ( ! copy_from( _source ) )
    {
        bad = true;
    }
}

//.............................................................................
// New typed array that references an existing buffer. The offset is in bytes from
// the beginning of the buffer. Length is the number of elements for this typed array.

TypedArray::TypedArray( Type _type , ArrayBuffer* _buffer , gulong _offset , gulong _length )
    :
    type( _type ),
    bpe( bytes_per_element( _type ) ),
    length( _length ),
    offset( _offset ),
    buffer( _buffer ),
    bad( false )
{
    g_assert( buffer );

    buffer->ref();

    // The offset must be a multiple of our element size

    if ( offset && ( offset % bpe != 0 ) )
    {
        bad = true;
        return;
    }

    gulong buffer_length = buffer->get_length();

    if ( offset > buffer_length )
    {
        bad = true;
        return;
    }

    if ( offset + ( length * bpe ) > buffer_length )
    {
        bad = true;
        return;
    }

    if ( length == 0 )
    {
        // The length of the buffer minus the offset must be a multiple
        // of our element size

        if ( ( buffer_length - offset ) % bpe != 0 )
        {
            bad = true;
            return;
        }

        length = ( buffer_length - offset ) / bpe;
    }
    else
    {
        // See if our data goes beyond the end of the source buffer

        if ( ( offset + ( length * bpe ) ) > buffer_length )
        {
            bad = true;
            return;
        }
    }
}

//.............................................................................

TypedArray::~TypedArray()
{
    if ( buffer )
    {
        buffer->unref();
    }
}

//.............................................................................

guint8* TypedArray::get( gulong index )
{
    if ( bad || index >= length )
    {
        return 0;
    }

    g_assert( buffer );

    return buffer->get_data() + offset + ( bpe * index );
}

//.............................................................................
// Copy elements from a source array of any type. dest_offset is
// number of elements in this array.

bool TypedArray::copy_from( TypedArray* source , gulong dest_offset )
{
    g_assert( source );

    if ( ( dest_offset + source->length ) > length )
    {
        return false;
    }

    TypedArray* real_source = source;

    // If this array and the source array share the same buffer,
    // we have to copy from the source to a temporary array and then
    // from the temporary array into this one.

    if ( source->buffer == buffer )
    {
        real_source = new TypedArray( source->type , source );
    }

    guint8* src = real_source->get( 0 );
    guint8* dst = get( dest_offset );

    if ( ! src || ! dst )
    {
        if ( real_source != source )
        {
            delete real_source;
        }

        return false;
    }

    for ( gulong i = 0; i < real_source->length; ++i )
    {
        switch ( real_source->type )
        {
            case T_INT8:
            {
                gint8* s = ( gint8* ) src;

                switch ( type )
                {
                    case T_INT8:    * ( ( gint8* ) dst ) = * s; break;

                    case T_UINT8:   * ( ( guint8* ) dst ) = * s; break;

                    case T_INT16:   * ( ( gint16* ) dst ) = * s; break;

                    case T_UINT16:  * ( ( guint16* ) dst ) = * s; break;

                    case T_INT32:   * ( ( gint32* ) dst ) = * s; break;

                    case T_UINT32:  * ( ( guint32* ) dst ) = * s; break;

                    case T_FLOAT32: * ( ( gfloat* ) dst ) = * s; break;

                    case T_FLOAT64: * ( ( gdouble* ) dst ) = * s; break;
                }

                break;
            }

            case T_UINT8:
            {
                guint8* s = ( guint8* ) src;

                switch ( type )
                {
                    case T_INT8:    * ( ( gint8* ) dst ) = * s; break;

                    case T_UINT8:   * ( ( guint8* ) dst ) = * s; break;

                    case T_INT16:   * ( ( gint16* ) dst ) = * s; break;

                    case T_UINT16:  * ( ( guint16* ) dst ) = * s; break;

                    case T_INT32:   * ( ( gint32* ) dst ) = * s; break;

                    case T_UINT32:  * ( ( guint32* ) dst ) = * s; break;

                    case T_FLOAT32: * ( ( gfloat* ) dst ) = * s; break;

                    case T_FLOAT64: * ( ( gdouble* ) dst ) = * s; break;
                }

                break;
            }

            case T_INT16:
            {
                gint16* s = ( gint16* ) src;

                switch ( type )
                {
                    case T_INT8:    * ( ( gint8* ) dst ) = * s; break;

                    case T_UINT8:   * ( ( guint8* ) dst ) = * s; break;

                    case T_INT16:   * ( ( gint16* ) dst ) = * s; break;

                    case T_UINT16:  * ( ( guint16* ) dst ) = * s; break;

                    case T_INT32:   * ( ( gint32* ) dst ) = * s; break;

                    case T_UINT32:  * ( ( guint32* ) dst ) = * s; break;

                    case T_FLOAT32: * ( ( gfloat* ) dst ) = * s; break;

                    case T_FLOAT64: * ( ( gdouble* ) dst ) = * s; break;
                }

                break;
            }

            case T_UINT16:
            {
                guint16* s = ( guint16* ) src;

                switch ( type )
                {
                    case T_INT8:    * ( ( gint8* ) dst ) = * s; break;

                    case T_UINT8:   * ( ( guint8* ) dst ) = * s; break;

                    case T_INT16:   * ( ( gint16* ) dst ) = * s; break;

                    case T_UINT16:  * ( ( guint16* ) dst ) = * s; break;

                    case T_INT32:   * ( ( gint32* ) dst ) = * s; break;

                    case T_UINT32:  * ( ( guint32* ) dst ) = * s; break;

                    case T_FLOAT32: * ( ( gfloat* ) dst ) = * s; break;

                    case T_FLOAT64: * ( ( gdouble* ) dst ) = * s; break;
                }

                break;
            }

            case T_INT32:
            {
                gint32* s = ( gint32* ) src;

                switch ( type )
                {
                    case T_INT8:    * ( ( gint8* ) dst ) = * s; break;

                    case T_UINT8:   * ( ( guint8* ) dst ) = * s; break;

                    case T_INT16:   * ( ( gint16* ) dst ) = * s; break;

                    case T_UINT16:  * ( ( guint16* ) dst ) = * s; break;

                    case T_INT32:   * ( ( gint32* ) dst ) = * s; break;

                    case T_UINT32:  * ( ( guint32* ) dst ) = * s; break;

                    case T_FLOAT32: * ( ( gfloat* ) dst ) = * s; break;

                    case T_FLOAT64: * ( ( gdouble* ) dst ) = * s; break;
                }

                break;
            }

            case T_UINT32:
            {
                guint32* s = ( guint32* ) src;

                switch ( type )
                {
                    case T_INT8:    * ( ( gint8* ) dst ) = * s; break;

                    case T_UINT8:   * ( ( guint8* ) dst ) = * s; break;

                    case T_INT16:   * ( ( gint16* ) dst ) = * s; break;

                    case T_UINT16:  * ( ( guint16* ) dst ) = * s; break;

                    case T_INT32:   * ( ( gint32* ) dst ) = * s; break;

                    case T_UINT32:  * ( ( guint32* ) dst ) = * s; break;

                    case T_FLOAT32: * ( ( gfloat* ) dst ) = * s; break;

                    case T_FLOAT64: * ( ( gdouble* ) dst ) = * s; break;
                }

                break;
            }

            case T_FLOAT32:
            {
                gfloat* s = ( gfloat* ) src;

                switch ( type )
                {
                    case T_INT8:    * ( ( gint8* ) dst ) = * s; break;

                    case T_UINT8:   * ( ( guint8* ) dst ) = * s; break;

                    case T_INT16:   * ( ( gint16* ) dst ) = * s; break;

                    case T_UINT16:  * ( ( guint16* ) dst ) = * s; break;

                    case T_INT32:   * ( ( gint32* ) dst ) = * s; break;

                    case T_UINT32:  * ( ( guint32* ) dst ) = * s; break;

                    case T_FLOAT32: * ( ( gfloat* ) dst ) = * s; break;

                    case T_FLOAT64: * ( ( gdouble* ) dst ) = * s; break;
                }

                break;
            }

            case T_FLOAT64:
            {
                gdouble* s = ( gdouble* ) src;

                switch ( type )
                {
                    case T_INT8:    * ( ( gint8* ) dst ) = * s; break;

                    case T_UINT8:   * ( ( guint8* ) dst ) = * s; break;

                    case T_INT16:   * ( ( gint16* ) dst ) = * s; break;

                    case T_UINT16:  * ( ( guint16* ) dst ) = * s; break;

                    case T_INT32:   * ( ( gint32* ) dst ) = * s; break;

                    case T_UINT32:  * ( ( guint32* ) dst ) = * s; break;

                    case T_FLOAT32: * ( ( gfloat* ) dst ) = * s; break;

                    case T_FLOAT64: * ( ( gdouble* ) dst ) = * s; break;
                }

                break;
            }
        }

        src += real_source->bpe;
        dst += bpe;
    }

    if ( real_source != source )
    {
        delete real_source;
    }

    return true;
}

//.............................................................................
// Create a new sub-array with the same type as this one and
// sharing the same buffer.

TypedArray* TypedArray::subarray( glong begin , glong end )
{
    if ( begin < 0 )
    {
        begin = length + begin;
    }

    if ( end < 0 )
    {
        end = length + end + 1;
    }

    if ( begin < 0 )
    {
        begin = 0;
    }
    else if ( gulong( begin ) > length )
    {
        begin = length;
    }

    if ( end < 0 )
    {
        end = 0;
    }
    else if ( gulong( end ) > length )
    {
        end = length;
    }

    glong new_length = end - begin;

    if ( new_length <= 0 )
    {
        TypedArray* result = new TypedArray( type , buffer , offset + ( begin * bpe ) );

        result->bad = false;
        result->length = 0;

        return result;
    }
    else
    {
        return new TypedArray( type , buffer , offset + ( begin * bpe ) , new_length );
    }
}

//.............................................................................

TypedArray* TypedArray::from_lua_table( lua_State* L , int index , Type type )
{
    g_assert( lua_istable( L , index ) );

    gulong length = 0;

    lua_pushnil( L );

    while ( lua_next( L , index ) )
    {
        if ( lua_isnumber( L , -1 ) )
        {
            ++length;
        }

        lua_pop( L , 1 );
    }

    TypedArray* result = new TypedArray( T_FLOAT32 , length );

    gfloat* src = ( gfloat* ) result->get( 0 );

    lua_pushnil( L );

    while ( lua_next( L , index ) )
    {
        if ( lua_isnumber( L , -1 ) )
        {
            * src = lua_tonumber( L , -1 );
            ++src;
        }

        lua_pop( L , 1 );
    }

    if ( type != T_FLOAT32 )
    {
        TypedArray* source = result;

        result = new TypedArray( type , source );

        delete source;
    }

    return result;
}

//.............................................................................
// Makes one base on parameters on the Lua stack

TypedArray* TypedArray::make( lua_State* L , Type type )
{
    // The newly created user data is at the top of the stack

    int args = lua_gettop( L ) - 1;

    if ( args < 1 )
    {
        return new TypedArray;
    }

    // Constructor that takes a simple length

    if ( lua_isnumber( L , 1 ) )
    {
        int length = lua_tointeger( L , 1 );

        if ( length < 0 )
        {
            length = 0;
        }

        return new TypedArray( type , length );
    }

    // Constructor that takes a Lua table of elements

    if ( lua_istable( L , 1 ) )
    {
        TypedArray* source = TypedArray::from_lua_table( L , 1 );

        TypedArray* result = new TypedArray( type , source );

        delete source;

        return result;
    }

    if ( lua_isuserdata( L , 1 ) )
    {
        // This could be an ArrayBuffer with an optional offset and a length
        // or
        // Another TypedArray

        if ( is_typed_array( L , 1 ) )
        {
            TypedArray* source = from_lua( L , 1 );

            if ( ! source )
            {
                return new TypedArray;
            }

            return new TypedArray( type , source );
        }

        if ( ArrayBuffer::is_array_buffer( L , 1 ) )
        {
            int offset = 0;
            int length = 0;

            if ( args > 1 )
            {
                offset = lua_tonumber( L , 2 );

                if ( offset < 0 )
                {
                    offset = 0;
                }

                if ( args > 2 )
                {
                    length = lua_tonumber( L , 3 );

                    if ( length < 0 )
                    {
                        length = 0;
                    }
                }
            }

            ArrayBuffer* buffer = ArrayBuffer::from_lua( L , 1 );

            if ( ! buffer )
            {
                return new TypedArray;
            }

            return new TypedArray( type , buffer , offset , length );
        }
    }

    // Return a bad one

    return new TypedArray;
}

//.............................................................................

void TypedArray::dump()
{
    const char* t;

    switch ( type )
    {
        case T_INT8:    t = "Int8"; break;

        case T_UINT8:   t = "Uint8"; break;

        case T_INT16:   t = "Int16"; break;

        case T_UINT16:  t = "Uint16"; break;

        case T_INT32:   t = "Int32"; break;

        case T_UINT32:  t = "Uint32"; break;

        case T_FLOAT32: t = "Float32"; break;

        case T_FLOAT64: t = "Float64"; break;
    }

    g_debug( "Type          : %s"  , t );
    g_debug( "BPE           : %u bytes"  , bpe );
    g_debug( "Length        : %lu elements" , length );
    g_debug( "Offset        : %lu bytes" , offset );
    g_debug( "Buffer        : %p"  , buffer );
    g_debug( "Buffer size   : %lu bytes" , buffer ? buffer->get_length() : 0 );
    g_debug( "Bad           : %s" , bad ? "true" : "false" );
    g_debug( "Contents" );

    if ( guint8* src = get( 0 ) )
    {
        for ( gulong i = 0; i < length; ++i )
        {
            switch ( type )
            {
                case T_INT8:    g_debug( "%lu: %d" , i , * ( ( gint8* ) src ) ); break;

                case T_UINT8:   g_debug( "%lu: %u" , i , * ( ( guint8* ) src ) ); break;

                case T_INT16:   g_debug( "%lu: %" G_GINT16_FORMAT  "" , i , * ( ( gint16* ) src ) ); break;

                case T_UINT16:  g_debug( "%lu: %" G_GUINT16_FORMAT "" , i , * ( ( guint16* ) src ) ); break;

                case T_INT32:   g_debug( "%lu: %" G_GINT32_FORMAT  "" , i , * ( ( gint32* ) src ) ); break;

                case T_UINT32:  g_debug( "%lu: %" G_GUINT32_FORMAT "" , i , * ( ( guint32* ) src ) ); break;

                case T_FLOAT32: g_debug( "%lu: %f" , i , * ( ( gfloat* ) src ) ); break;

                case T_FLOAT64: g_debug( "%lu: %f" , i , * ( ( gdouble* ) src ) ); break;
            }

            src += bpe;
        }
    }
}

//.............................................................................

int TypedArray::metatable_index( lua_State* L )
{
    if ( lua_isnumber( L , 2 ) )
    {
        TypedArray* self( lb_get_self( L , TypedArray* ) );

        guint8* src = self->get( lua_tointeger( L , 2 ) );

        if ( ! src )
        {
            lua_pushnil( L );
        }
        else
        {
            switch ( self->type )
            {
                case TypedArray::T_INT8:    lua_pushinteger( L , * ( ( gint8* ) src ) ); break;

                case TypedArray::T_UINT8:   lua_pushinteger( L , * ( ( guint8* ) src ) ); break;

                case TypedArray::T_INT16:   lua_pushinteger( L , * ( ( gint16* ) src ) ); break;

                case TypedArray::T_UINT16:  lua_pushinteger( L , * ( ( guint16* ) src ) ); break;

                case TypedArray::T_INT32:   lua_pushinteger( L , * ( ( gint32* ) src ) ); break;

                case TypedArray::T_UINT32:  lua_pushinteger( L , * ( ( guint32* ) src ) ); break;

                case TypedArray::T_FLOAT32: lua_pushnumber( L , * ( ( gfloat* ) src ) ); break;

                case TypedArray::T_FLOAT64: lua_pushnumber( L , * ( ( gdouble* ) src ) ); break;
            }
        }

        return 1;
    }
    else
    {
        return lb_index( L );
    }
}

//.............................................................................

int TypedArray::metatable_newindex( lua_State* L )
{
    if ( lua_isnumber( L , 2 ) )
    {
        TypedArray* self( lb_get_self( L , TypedArray* ) );

        guint8* src = self->get( lua_tointeger( L , 2 ) );

        if ( ! src )
        {
            luaL_error( L , "Invalid index" );
        }
        else
        {
            lua_Number n = luaL_checknumber( L , 3 );

            switch ( self->type )
            {
                case TypedArray::T_INT8:    * ( ( gint8* ) src )   = n; break;

                case TypedArray::T_UINT8:   * ( ( guint8* ) src )  = n; break;

                case TypedArray::T_INT16:   * ( ( gint16* ) src )  = n; break;

                case TypedArray::T_UINT16:  * ( ( guint16* ) src ) = n; break;

                case TypedArray::T_INT32:   * ( ( gint32* ) src )  = n; break;

                case TypedArray::T_UINT32:  * ( ( guint32* ) src ) = n; break;

                case TypedArray::T_FLOAT32: * ( ( gfloat* ) src )  = n; break;

                case TypedArray::T_FLOAT64: * ( ( gdouble* ) src ) = n; break;
            }
        }

        return 0;
    }
    else
    {
        return lb_newindex( L );
    }
}

//.............................................................................

void TypedArray::update_metatable( lua_State* L )
{
    lua_getmetatable( L , -1 );
    lua_pushliteral( L , "__index" );
    lua_pushcfunction( L , metatable_index );
    lua_rawset( L , -3 );
    lua_pushliteral( L , "__newindex" );
    lua_pushcfunction( L , metatable_newindex );
    lua_rawset( L , -3 );
    lua_pop( L , 1 );
}

//.............................................................................

bool TypedArray::is_typed_array( lua_State* L , int index )
{
    return LB_GET_TYPEDARRAY( L , index ) != 0;
}

//.............................................................................

TypedArray* TypedArray::from_lua( lua_State* L , int index )
{
    return LB_GET_TYPEDARRAY( L , index );
}
