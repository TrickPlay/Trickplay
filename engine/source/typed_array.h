#ifndef _TRICKPLAY_TYPED_ARRAY_H
#define _TRICKPLAY_TYPED_ARRAY_H

#include "common.h"
#include "util.h"

//=============================================================================

class ArrayBuffer : public RefCounted
{
public:

    ArrayBuffer( gulong length );

    static bool is_array_buffer( lua_State* L , int index );

    static ArrayBuffer* from_lua( lua_State* L , int index );

    void push( lua_State* L );

    inline guint8* get_data()
    {
        return data;
    }

    inline gulong get_length() const
    {
        return length;
    }

protected:

    ~ArrayBuffer();

private:

    guint8*     data;
    gulong      length;
};

//=============================================================================

class TypedArray
{
public:

    enum Type
    {
        T_INT8 ,
        T_UINT8 ,
        T_INT16 ,
        T_UINT16 ,
        T_INT32 ,
        T_UINT32 ,
        T_FLOAT32 ,
        T_FLOAT64
    };

    inline static gulong bytes_per_element( Type type )
    {
        switch ( type )
        {
            case T_INT8:    return sizeof( gint8 );

            case T_UINT8:   return sizeof( guint8 );

            case T_INT16:   return sizeof( gint16 );

            case T_UINT16:  return sizeof( guint16 );

            case T_INT32:   return sizeof( gint32 );

            case T_UINT32:  return sizeof( guint32 );

            case T_FLOAT32: return sizeof( gfloat );

            case T_FLOAT64: return sizeof( gdouble );
        }

        return 0; // warnings
    }

    // Bad one

    TypedArray();

    // New typed array with a new buffer to hold _length elements.

    TypedArray( Type type , gulong length );

    // New typed array with a new buffer to hold _source->length elements.
    // All elements from the source array are converted and copied into this one.

    TypedArray( Type type , TypedArray* source );

    // New typed array that references an existing buffer. The offset is in bytes from
    // the beginning of the buffer. Length is the number of elements for this typed array.

    TypedArray( Type type , ArrayBuffer* buffer , gulong offset = 0 , gulong length = 0 );


    ~TypedArray();

    // Gets a pointer to the element at the given index, or returns NULL.

    guint8* get( gulong index );

    // Copy elements from a source array of any type. dest_offset is
    // number of elements in this array (where the copy starts).

    bool copy_from( TypedArray* source , gulong dest_offset = 0 );

    // Create a new sub-array with the same type as this one and
    // sharing the same buffer. (A slice of this array)

    TypedArray* subarray( glong begin , glong end = -1 );

    static bool is_typed_array( lua_State* L , int index );

    static TypedArray* from_lua( lua_State* L , int index );

    // Creates a new array with the numbers from the Lua
    // table at index.

    static TypedArray* from_lua_table( lua_State* L , int index , Type type = T_FLOAT32 );

    // Makes one base on parameters on the Lua stack

    static TypedArray* make( lua_State* L , Type type );

    // Dumps debug information about the array and its contents.

    void dump();

    // A replacement __index metamethod for typed arrays.

    static int metatable_index( lua_State* L );

    // A replacement __newindex metamethod for typed arrays.

    static int metatable_newindex( lua_State* L );

    // Replaces the __index and __newindex metamethods for the
    // Lua TypedArray at the top of the stack.

    static void update_metatable( lua_State* L );

    inline Type get_type() const
    {
        return type;
    }

    inline guint get_bpe() const
    {
        return bpe;
    }

    inline gulong get_length() const
    {
        return length;
    }

    inline gulong get_offset() const
    {
        return offset;
    }

    inline ArrayBuffer* get_buffer() const
    {
        return buffer;
    }

    inline bool is_bad() const
    {
        return bad;
    }

    inline gulong get_byte_length() const
    {
        return length * bpe;
    }

    static void destroy( void* array )
    {
        delete( TypedArray* ) array;
    }

private:

    Type            type;
    guint           bpe;    // Size in bytes of each element
    gulong          length; // Number of elements, not bytes
    gulong          offset; // Bytes from the beginning of the buffer
    ArrayBuffer*    buffer;
    bool            bad;
};

//=============================================================================

#endif // _TRICKPLAY_TYPED_ARRAY_H
