
local Trick = { version = 1 }

-------------------------------------------------------------------------------
-- Type assertion functions
-------------------------------------------------------------------------------

local function assert_type( v , t )
    if ( type( v ) ~= t ) then
        error( "Expecting "..t..", got "..type( v ) , 3 )
    end
end

function Trick.assert_table( v )    assert_type( v , "table" ) end
function Trick.assert_function( v ) assert_type( v , "function" ) end
function Trick.assert_string( v )   assert_type( v , "string" ) end
function Trick.assert_nil( v )      assert_type( v , "nil" ) end
function Trick.assert_number( v )   assert_type( v , "number" ) end
function Trick.assert_boolean( v )  assert_type( v , "boolean" ) end
function Trick.assert_thread( v )   assert_type( v , "thread" ) end

-------------------------------------------------------------------------------
-- Type checking
-------------------------------------------------------------------------------

function Trick.is_table( v )    return type( v ) == "table" end
function Trick.is_function( v ) return type( v ) == "function" end
function Trick.is_string( v )   return type( v ) == "string" end
function Trick.is_nil( v )      return type( v ) == "nil" end
function Trick.is_number( v )   return type( v ) == "number" end
function Trick.is_boolean( v )  return type( v ) == "boolean" end
function Trick.is_thread( v )   return type( v ) == "thread" end

-------------------------------------------------------------------------------
-- Returns a new table with all keys and values from t for which filter(k,v)
-- returns true.
-------------------------------------------------------------------------------

function Trick.filter_table( t , filter )
    Trick.assert_table( t )
    Trick.assert_function( filter )
    local result = {}
    for k , v in pairs( t ) do
        if filter( k , v ) then
            result[ k ] = v
        end
    end
    return result
end

-------------------------------------------------------------------------------
-- Returns a new table with all keys from t for which filter(k,v)
-- returns true.
-------------------------------------------------------------------------------

function Trick.filter_keys( t , filter )
    Trick.assert_table( t )
    Trick.assert_function( filter )
    local result = {}
    for k , v in pairs( t ) do
        if filter( k , v ) then
            table.insert( result , k )
        end
    end
    return result
end

-------------------------------------------------------------------------------
-- Returns a new table with all values from t for which filter(k,v)
-- returns true.
-------------------------------------------------------------------------------

function Trick.filter_values( t , filter )
    Trick.assert_table( t )
    Trick.assert_function( filter )
    local result = {}
    for k , v in pairs( t ) do
        if filter( k , v ) then
            table.insert( result , v )
        end
    end
    return result
end

-------------------------------------------------------------------------------
-- Removes all keys and values from table t where the value equals the one
-- passed in. 
-------------------------------------------------------------------------------

function Trick.remove_table_values( t , value )    
    local keys = Trick.filter_keys( t , function(k,v) return v == value end )
    for i = 1 , # keys do
        t[ keys[ i ] ] = nil
    end
    return t
end

-------------------------------------------------------------------------------
-- Iterates over all keys and values of t calling f( k , v ) on each one
-------------------------------------------------------------------------------

function Trick.foreach( t , f )
    Trick.assert_table( t )
    Trick.assert_function( f )
    for k , v in pairs( t ) do
        f( k , v )
    end
end

-------------------------------------------------------------------------------
-- Returns an iterator; a function that when called will return the next key
-- and value from the table. The only difference is that when it reaches the
-- end of the table, it starts over at the beginning. It will only return nil
-- if the table is empty.
-------------------------------------------------------------------------------

function Trick.CircularIterator( t , index )
    Trick.assert_table( t )
    return
        function()
            local v
            index , v = next( t , index )
            if index == nil then
                index , v = next( t , index )
            end
            return index , v
        end    
end

-------------------------------------------------------------------------------
-- Same as above, but only returns values.
-------------------------------------------------------------------------------

function Trick.CircularValueIterator( t , index )
    Trick.assert_table( t )
    return
        function()
            local v
            index , v = next( t , index )
            if index == nil then
                index , v = next( t , index )
            end
            return v
        end    
end

-------------------------------------------------------------------------------
-- Creates a list of functions that can be called by calling the list.
-- Has add and remove methods. When a function is added, an integer 'id' is
-- returned. A function can be removed by its id or its value. If removed by
-- value, all instances of the function are removed.
-- You can assign a function list to TrickPlay callbacks, like this:
-- screen.on_key_down = FunctionList( f1 , f2 )
-------------------------------------------------------------------------------

function Trick.FunctionList( ... )

    local filter_values = Trick.filter_values
    local remove_table_values = Trick.remove_table_values

    local list = filter_values( { ... } ,
        function(k,v) return type(v) == "function" end )
    
    local next_id = # list + 1
    
    local mt = {}
    mt.__index = mt
    
    function mt.__call( _ , ... )
        for _ , f in pairs( list ) do
            f( ... )
        end
    end
    
    function mt:add( f )
        Trick.assert_function( f )
        local n = next_id
        next_id = next_id + 1
        list[ n ] = f
        return n
    end
    
    function mt:remove( id_or_f )
        if type( id_or_f ) == "function" then
            remove_table_values( list , id_or_f )
        else
            list[ id_or_f ] = nil
        end
    end
    
    function mt:clear( )
        list = {}
    end
    
    return setmetatable( {} , mt )
end    

-------------------------------------------------------------------------------

function Trick.Encapsulate( attributes )

    Trick.assert_table( attributes )
    
    local public = attributes
        
    ---------------------------------------------------------------------------
    
    assert( public.private == nil )
    
    ---------------------------------------------------------------------------
    -- Move and check the readonly part of the object
    
    local readonly = nil
    
    if public.readonly then
        readonly = public.readonly
        public.readonly = nil
        Trick.assert_table( readonly )
    end

    ---------------------------------------------------------------------------    

    return setmetatable(
        {} , 
        {
            -- The index metamethod either returns the property from the public part
            -- or looks for a corresponding function in the readonly part.
    
            __index =
                
                function( t , k )
                    local v = rawget( public , k )
                    if v == nil and readonly then
                        local f = rawget( readonly , k )
                        if type( f ) == "function" then
                            v = f()
                        end
                    end
                    return v
                end,
                
            -- newindex just asserts
                
            __newindex =
            
                function( )
                    assert( false )
                end,
        } )
    
end

-------------------------------------------------------------------------------

return Trick