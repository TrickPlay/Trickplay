
-- Use it like this:
--
-- local Encapsulate = dofile( "Encapsulate.lua" )
--
-- local foo = Encapsulate( bar )
--

return
function ( attributes )

    assert( type( attributes ) == "table" )
    
    local object = { public = attributes }
        
    ---------------------------------------------------------------------------
    -- Move and check the private part of the object
    
    if object.public.private then
        object.private = object.public.private
        object.public.private = nil
        assert( type( object.private ) == "table" )
    end

    ---------------------------------------------------------------------------
    -- Move and check the readonly part of the object
    
    local readonly = nil
    
    if object.public.readonly then
        readonly = object.public.readonly
        object.public.readonly = nil
        assert( type( readonly ) == "table" )
    end

    ---------------------------------------------------------------------------
    -- This changes 'self' in all functions found in table ft to the object
    -- above.
    
    local function proxy_functions( ft )
        if ft then
            for k , v in pairs( ft ) do
                if type( v ) == "function" then
                    rawset( ft , k , function( t , ...) return v( object , ...) end )
                end
            end
        end
    end
    
    ---------------------------------------------------------------------------
    
    proxy_functions( object.public )
    proxy_functions( object.private )
    
    ---------------------------------------------------------------------------    

    local mt =
    {
        -- The index metamethod either returns the property from the public part
        -- or looks for a corresponding function in the readonly part.

        __index =
            
            function( t , k )
                local v = rawget( object.public , k )
                if v == nil and readonly then
                    local f = rawget( readonly , k )
                    if type( f ) == "function" then
                        v = f( object )
                    end
                end
                return v
            end,
            
        -- newindex just asserts
            
        __newindex =
        
            function( )
                assert( false )
            end,
    }
    
    object.this = setmetatable( {} , mt )
    
    return object.this    
end
