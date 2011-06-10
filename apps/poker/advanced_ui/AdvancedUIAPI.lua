local log = print
-- Load the AdvancedUI Classes into a class table
local class_table = dofile("advanced_ui/AdvancedUIClasses.lua")
local controller , CACHE_LOCAL_PROPERTIES = ...

assert(controller)
assert(class_table)

---------------------------------------------------------------------------
-- CACHE_LOCAL_PROPERTIES
--
-- If true, we cache local values of properties. Otherwise, we cache them
-- when we get them from the remote.
-- For example, if you set thing.color = "blue" and the remote end treats
-- that as "0000FF". Then, with this set to true, when you read thing.color
-- you would get "blue". With it set to false, you would get "0000FF".
-- So, false means more round trips to the remote, but more consistency.

---------------------------------------------------------------------------
-- The factory itself. We also add a reference to it in each proxy's metatable

local factory = {}

---------------------------------------------------------------------------
-- For each class in the class table, we create a convenience function that
-- creates a remote object and returns a proxy of the correct type.
-- So, if you have a class called Rectangle, you can call factory:Rectangle
-- to construct a new one.

for k , _ in pairs( class_table ) do
    factory[ k ] =
        function( factory , properties )
            return factory:create_remote( k , properties )
        end
end

---------------------------------------------------------------------------
-- Every local proxy we create is kept here, keyed by its id

local proxies = {}

---------------------------------------------------------------------------
-- This is how we talk to the remote end

local function send_request( end_point , payload )
    assert( type( end_point ) == "string" )

    payload = payload or {}

    payload.method = end_point
    --[[
    print("send_request payload:", payload)
    if type(payload) == "table" then
        dumptable(payload)
    end
    --]]
    result = controller:advanced_ui( payload )
    --[[
    print("send_request result:", result)
    if type(result) == "table" then
        dumptable(result)
    end
    --]]
    return result
end

---------------------------------------------------------------------------
-- Connect a streaming web request to receive events
--[[
do
    local request = URLRequest{ url = base_url.."/events" , timeout = 0 }
    
    function request:on_complete( )
        -- TODO: what do we do?
        log( "** DISCONNECED FROM EVENTS" )          
    end
    
    local body = ""
    
    local function deliver_event( event )
        
        event = json:parse( event )
        if event then
            local proxy = proxies[ event.id ]
            if proxy then
                proxy:__event( event.event , event.args )
            end
        end
        return ""
    end
    
    function request:on_response_chunk( response )
        if response.body then
            -- Append the new chunk and parse out the newline delimited chunks
            body = string.gsub( body..response.body , "([^\n]*\n)" , deliver_event )
        end
    end

    request:stream()
end
--]]

---------------------------------------------------------------------------
-- This is a table that contains the metatables for each class. It starts
-- out empty and gets populated when new instances are created.
--
-- To create a new instance, you get its metatable by calling
--  proxy_metatables[ T ]
-- If such a metatable is not there, the __index function below gets called,
-- which creates the metatable for this type, stores it in proxy_metatables
-- and returns it.

local proxy_metatables = {}

do

    local mt = {}
    
    setmetatable( proxy_metatables , mt )


    function mt:__index( T )
    
        -- Get the tables of getters, setters and functions for this type
        -- from the class table.
    
        local get , set , call , event = class_table[ T ]()
        
        if not get or not set or not call or not event then
            error( string.format( "Invalid type '%s'" , T ) )
        end
        
        -- Create the metatable for the proxy object
        
        local proxy =
        {
            factory = factory
        }
        
        -- Store it
        
        rawset( proxy_metatables , T , proxy )
        
        -----------------------------------------------------------------------
        -- This is the __newindex metamethod for this proxy.
        
        function proxy:__newindex( key , value )
            
            -- See if there is a setter function for this property

            local setter = rawget( set , key )
            if type( setter ) == "function" then
                setter( self , value )
                return
            end

            -- Setting it to nil means deleting the property
        
            if value == nil then
                -- See if it is an event function
                if rawget( self.__events , key ) then
                    rawset( self.__events , key , nil )
                    return
                end
                
                -- Clear it from the cache 
                --rawset( self.__pcache , key , nil )
                
                -- Tell the remote to delete it
                local payload = { id = self.id , properties = { [ key ] = true } }
                send_request( "delete" , payload )
                return
            end
            
            -- If it is a function, we store it in __events
            
            if type( value ) == "function" then
                rawset( self.__events , key , value )
                return
            end
            
            -- It cannot be a user data or thread 
            
            assert( type( value ) ~= "userdata" )
            assert( type( value ) ~= "thread" )
            
            -- Otherwise, set the remote property
            
            local payload = { id = self.id , properties = { [ key ] = value } }
            
            send_request( "set" , payload )

            --[[
            if CACHE_LOCAL_PROPERTIES then
                -- Put the local value in the cache
                rawset( self.__pcache , key , value )
            else
                -- Remove any value from the cache. We'll populate it
                -- as soon as we get it back from the remote.
                rawset( self.__pcache , key , nil )
            end
            --]]
        end
        
        -----------------------------------------------------------------------
        -- Returns the value of a property for this proxy.

        function proxy:__index( key )
            
            -- See if it is a property that has a getter
            
            value = rawget( get , key )
            if type( value ) == "function" then
                return value( self , key )
            end

            -- See if it is already in the metatable
            -- The 'factory' property is the only one so far.
            
            local value = rawget( proxy , key )                
            if value ~= nil then
                return value
            end
            
            -- See if it is a function
            
            value = rawget( call , key )
            if value ~= nil then
                return value
            end
            
            -- See if it is an event
            
            value = rawget( self.__events , key )
            if value ~= nil then
                return value
            end
            
            -- See if we have it cached
            --[[
            value = rawget( self.__pcache , key )
            if value ~= nil then
                return value
            end
            --]]
            
            -- OK, just fetch its value from the remote
        
            local payload = { id = self.id , properties = { [ key ] = true } }
            local result = send_request( "get" , payload ).properties[ key ]
            
            -- And cache it
            
            --rawset( self.__pcache , key , result )
            
            return result
        end
        
        -----------------------------------------------------------------------
        
        function proxy.__has_setter( key )
            return type( rawget( set , key ) ) == "function"
        end
        
        -----------------------------------------------------------------------
        -- Calls an event handler function on the proxy. If there is a local
        -- filter for that event, it is called to filter the arguments
        
        function proxy:__event( name , args )
            local handler = rawget( self.__events , name )
            if type( handler ) == "function" then
                local filter = rawget( event , name )
                if type( filter ) == "function" then
                    handler( self , filter( self , unpack( args ) ) )
                else
                    handler( self , unpack( args ) )
                end
            end
        end
        
        -----------------------------------------------------------------------
        -- Calls a remote function

        function proxy:__call( function_name , ... )
            local payload = { id = self.id , call = function_name , args = {...} }
            local result = send_request( "call" , payload ).result
            if result == json.null then
                return nil
            end
            return result
        end
    
        return proxy
    end
    
end

---------------------------------------------------------------------------
-- Creates a local proxy. The metatable and property cache can be omitted

local function create_local( id , T , proxy_metatable , property_cache )

    -- If it already exists, return it
    
    local proxy = rawget( proxies , id )
    
    if proxy ~= nil then
        return proxy
    end

    -- Get the metatable for it
    
    proxy_metatable = proxy_metatable or proxy_metatables[ T ]
    
    assert( type( proxy_metatable ) == "table" )
    
    -- Create the property cache table for it
    --[[
    if CACHE_LOCAL_PROPERTIES then
        
        -- Use what was passed in or a new table.
        
        property_cache = property_cache or {}
        
    else
        -- When we are NOT caching local properties, we ignore what was
        -- passed in for the property cache and create an empty one.
        
        property_cache = {}
        
    end
    --]]
    
    -- Here it is
    
    proxy = setmetatable(
    {
        id = id ,
        type = T ,
        --__pcache = property_cache,
        __events = {}
    }
    , proxy_metatable )
    
    -- Store it
    
    rawset( proxies , id , proxy )
    
    return proxy
end

---------------------------------------------------------------------------
-- The metatable for the factory

local mt = {}

mt.__index = mt

---------------------------------------------------------------------------
-- Creates an object of the given type (and with the given initial properties)
-- on the remote end. Then, creates and returns a local proxy for it.

function mt:create_remote( T , properties )
    if T == "Controller" then
        return nil
    end

    local proxy = proxy_metatables[ T ]

    -- Bulk properties are simple properties that do not require a
    -- function call to be set. We set the initial values of all these
    -- in one go when we create the remote object.
    
    -- Function properties are those which are set via a setter function.
    -- We take these out and set them one by one after the proxy has been
    -- created - because they could have side-effects.
    
    local bulk_properties = {}
    local function_properties = {}

    if type( properties ) == "table" then
        local has_setter = proxy.__has_setter
        for k , v in pairs( properties ) do
            if k ~= "id" and k ~= "type" then
                if ( not has_setter( k ) ) and ( type( v ) ~= "function" ) then
                    assert( type( v ) ~= "userdata" )
                    assert( type( v ) ~= "thread" )
                    rawset( bulk_properties , k , v )
                else
                    rawset( function_properties , k , v )
                end
            end
        end
    end
    
    -- Create the remote object with the initial properties

    local payload = { type = T , properties = bulk_properties }
    
    local id = send_request( "create" , payload ).id
    
    -- Create the local proxy
    
    local result = create_local( id , T , proxy , bulk_properties )
    
    -- Now, set the function properties
    
    if function_properties ~= nil then
        for k , v in pairs( function_properties ) do
            result[ k ] = v
        end
    end
    
    return result
end

---------------------------------------------------------------------------
-- Creates a local proxy to wrap the object of the given type and id.

function mt:create_local( id , T )

    return create_local( id , T )

end

---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- List every proxy !

function mt:list()
    dumptable(proxies)
end

---------------------------------------------------------------------------

setmetatable( factory , mt )

---------------------------------------------------------------------------
-- Give the controller Container like abilities

controller.screen = factory:create_local(0, "Controller") 

---------------------------------------------------------------------------

return factory
