-------------------------------------------------------------------------------
dofile( "xml.lua" )
-------------------------------------------------------------------------------
--[[
    
    This function creates a UPnP client and starts a search for the given device
    type. Every time a matching device is found, it fetches its description.
    Then, it looks through the description for a service with the given type.
    When the service is found, it creates a 'Service' object. When the search
    is finished, it calls the 'callback' with a table of Service objects.
    
    Each Service object has the following properties:
    
        name - The device's friendlyName
        
    And the following functions:
    
        action( name , args , callback )
        
            Arguments:
        
                name - A string, like 'Browse'
                
                args - A table with arguments and values, like { ObjectID = 0 , foo = "bar" }
                
                callback - An optional callback to call when the action is finished.
                
                    The callback should have this prototype:
                    
                        callback( service , action_id , error_code , xml )
                        
                            service - The service object for the action
                            action_id - The action id
                            error_code - The error code of the action (0 means success)
                            xml - The xml (as a string) for the result of the action.
                            
                    If a callback is not provided, the service's "on_action_completed"
                    will be called with the same parameters.
                
            Returns:
            
                0 - If the action invocation failed immediately (callback will not be called)
                
                action_id - An integer key for this invocation
]]

local DEBUG = false

function upnp_service_search( device_type , service_type , callback , timeout )

    -- If there is no UPnP client, we just post a call to the callback
    -- with an empty table and bail
    
    if not UPnPClient then
        
        dolater( callback , {} )
        
        return
        
    end
    
    -- Handy way to turn printing on and off

    local print = choose( DEBUG , print , function() end )

    -- Make sure the timeout is sane
    
    timeout = timeout or 0

    -- The client
    
    local client = UPnPClient()

    -- Table to hold the servers we find
    
    local servers = {}
    
    -- State
    
    local search_completed = false
    
    local requests_left = 0
    
    -- Start the search
    
    client:search( device_type , timeout )
    
    ---------------------------------------------------------------------------
    -- When the search is finished and all the requests for device descriptions
    -- have come back, we invoke the user's callback
    ---------------------------------------------------------------------------
    
    local function maybe_invoke_callback()
    
        if not ( search_completed and requests_left == 0 ) then return end
        
        -- This is a table that maps an action id (an invocation of an action)
        -- to its corresponding service object and callback
        
        local action_map = {}

        -- Iterate over the servers and create a list of service objects.
        
        local services = {}
        
        for location , server in pairs( servers ) do
        
            local mt = {}
            
            local service = { name = server.name }
            
            table.insert( services , setmetatable( service , mt ) )

            mt.__index = mt
            
            mt.action = function( self , action , args , callback )
            
                args = args or {}
            
                local id = client:send_action( server.control_url , server.service_type , action , args )
                    
                if id > 0 then
                
                    action_map[ id ] = { service , callback }
                
                end
                
                return id                    
            
            end
--[[
            -- This function fetches the service description XML (SCPD)
            -- and uses it to add functions to the service object
            -- corresponding to the service description.
            -- So, if the SCPD has an action called 'Browse', this will add
            -- a function called 'Browse' to this object's metatable.
            --
            -- It is experimental for now.
            
            mt.populate_actions = function( self , callback )
            
                -- Fetch the SCPD XML
                
                if not server.scpd_url then
                    return false
                end
                
                local function respond( success )
                    if callback then
                        callback( self , success )
                    end
                end
                
                local request = URLRequest( server.scpd_url )
                
                request:send()
                
                -- When the SCPD comes back
                
                function request.on_complete( request , response )
                
                    -- Make sure the response is ok and parse the XML
                
                    if response.failed or response.code ~= 200 then
                        print( "FAILED TO FETCH SCPD" )
                        respond( false )
                        return
                    end
                    
                    local scpd = XMLTree( response.body )
                    
                    if not scpd then
                        print( "FAILED TO PARSE SCPD" )
                        respond( false )
                        return
                    end
                    
                    -- Look for the list of actions
                    
                    local actions = scpd:find( "scpd/actionList.children" )
                    
                    if not actions then
                        print( "  FAILED TO FIND ACTION LIST" )
                        respond( false )
                        return 
                    end
                    
                    -- Look for the state variables. We end up building a table
                    -- that has the name of each state variable as the key
                    -- and its data type as the value. We are ignoring default
                    -- values and possible values. The gist of this is that for
                    -- integer state variables, UPnP doesn't like to receive
                    -- 'nothing' - it expects an integer.
                    
                    local sv = {}
                    
                    local state_v = scpd:find( "scpd/serviceStateTable.children" )
                    
                    if state_v then
                    
                        for _ , v in ipairs( state_v ) do
                        
                            local name = v:find( "stateVariable/name.text" )
                            local type = v:find( "stateVariable/dataType.text" )
                            
                            if name and type then
                                
                                sv[ name ] = type
                            
                            end
                        
                        end
                    
                    end
                    
                    -- Now iterate over the action list
                    
                    for _ , action in ipairs( actions ) do
                    
                        -- Get the action's name
                        
                        local name = action:find( "action/name.text" )
                        
                        if name then
                        
                            -- Get the action's argument list

                            local args = action:find( "action/argumentList.children" )
                            
                            local in_args = {}
                            local out_args = {}
                            local defaults = {}
                            
                            if args then
                            
                                -- For each argument, get its name, direction
                                -- and related state variable.
                            
                                for _ , arg in ipairs( args ) do
                                
                                    local name = arg:find( "argument/name.text" )
                                    local dir = arg:find( "argument/direction.text" )
                                    local v = arg:find( "argument/relatedStateVariable.text" )
                                    
                                    if name then
                                    
                                        if dir == "in" then
                                            
                                            table.insert( in_args , name )
                                            
                                            -- Hack. If the argument has a related
                                            -- state variable and that variable's
                                            -- data type is not 'string', we
                                            -- use a default value of 0 for the
                                            -- argument.
                                            
                                            if v and sv[v] ~= "string" then
                                                defaults[ name ] = 0
                                            end
                                            
                                        elseif dir == "out" then
                                            table.insert( out_args , name )
                                        end
                                        
                                    end
                                
                                end
                            
                            end
                            
                            -- Now that we have the names (and positions) of the
                            -- arguments, we add a function to the metatable.
                            -- The name of the function is the name of the action.
                            
                            getmetatable( self )[ name ] = function( self , ... )
                                
                                -- Collect all the arguments passed in into a table
                                
                                local values = {...}
                                
                                local args = {}
                                
                                -- If only one value was passed in and it is a
                                -- table, we use it as the argument table. This
                                -- lets the caller do something like:
                                -- Browse( { ObjectId = 0 , foo = "bar" } )
                                
                                if ( #values == 1 ) and ( type( values[ 1 ] ) == "table" ) then
                                    args = values[ 1 ]
                                else
                                    
                                    -- Otherwise, we match the list of arguments
                                    -- this function takes to the values passed
                                    -- in. 
                                    for i , k in ipairs( in_args ) do
                                        args[ k ] = values[ i ]
                                    end
                                end
                                
                                -- For any arguments that are missing, we use
                                -- the value from the 'defaults' table.
                                
                                for i , k in ipairs( in_args ) do
                                    if args[ k ] == nil then
                                        args[ k ] = defaults[ k ]
                                    end
                                end
                                
                                return self:action( name , args )
                            
                            end
                        
                        end
                    
                    end
                    
                    respond( true )
                    
                end
                
                return true
            
            end
]]                    
        end

        -------------------------------------------------------------------
        -- When an action completes, we look for an entry in the action_map
        -- table for this action id. The table will have the 'service' that
        -- called the action as its first element and *may* have a callback
        -- as its second element. If the callback is nil, we use
        -- service.on_action_completed.
        -------------------------------------------------------------------
        
        function client.on_action_completed( client , id , error_code , xml )
        
            print( "ACTION" , id , "COMPLETED WITH ERROR CODE" , error_code )
            
            local service , callback = unpack( action_map[ id ] )

            action_map[ id ] = nil
            
            callback = callback or service.on_action_completed
            
            if service and callback then
            
                pcall( callback , service , id , error_code , xml )
            
            end
        
        end
        
        -- Now hand the list of services to the caller
        
        callback( services )
        
    end
        
    ---------------------------------------------------------------------------
    -- When we get a search result
    ---------------------------------------------------------------------------

    function client.on_search_result( client , search_id , location )
    
        -- Location is the URL to the device description XML doc
        
        -- If we already have it, bail        
        
        if servers[ location ] then return end
        
        print( "FOUND DEVICE" , location )

        -- Parse the base URL. If it is no good, bail
        
        local base_url = string.match( location , "(%a+://[^/]+/).*" )
            
        if not base_url then
            
            print( "  FAILED TO PARSE BASE URL" )
            return
                
        end
        
        -- Add an entry to our servers table using the location as the key

        servers[ location ] = { base_url = base_url }
        
        -- Now, fetch the device description XML
        
        requests_left = requests_left + 1
        
        local request = URLRequest( location )

        request:send()
        
        -----------------------------------------------------------------------
        -- When we get a device description
        -----------------------------------------------------------------------
        
        function request.on_complete( request , response )
        
            print( "GOT DEVICE DESCRIPTION FOR" , location )
            
            local good = false
            
            requests_left = requests_left - 1
            
            -- Make sure the request succeeded
            
            if response.failed or response.code ~= 200 then
            
                print( "  REQUEST FAILED" , response.code , response.status )
                
            else
            
                -- Now, parse the device description
                
                local root = XMLTree( response.body )
                
                if not root then
                
                    print( "  FAILED TO PARSE DEVICE DESCRIPTION" )
                    
                else
                    -- Get the name of the server
                    --
                    -- Get its list of services
                    --
                    -- Look through the list of services to find the service type
                    -- and get its control URL
                
                    local name = root:find( "root/device/friendlyName.text" ) or "Unknown"
                    
                    local services = root:find( "root/device/serviceList.children" ) or {}
                    
                    local control_url = nil
                    
                    local scpd_url = nil
                    
                    
                    for _ , service in ipairs( services ) do
                    
                        if service:find( "service/serviceType.text" ) == service_type then
                        
                            control_url = service:find( "service/controlURL.text" )
                            
                            scpd_url = service:find( "service/SCPDURL.text" )
                            
                            break
                        
                        end
                    
                    end
                    
                    if not control_url then
                    
                        print( "  FAILED TO FIND SERVICE AND ITS CONTROL URL" )
                        
                    else
                    
                        local function concat_url( base , rest )
                            if base == nil or rest == nil then return nil end
                            return base..string.match( rest , "^/?(.*)$" )
                        end
                    
                        good = true
                        
                        local server = servers[ location ]
                        
                        server.name = name
                        server.service_type = service_type
                        server.control_url = concat_url( server.base_url , control_url )                        
                        server.scpd_url = concat_url( server.base_url , scpd_url )
                        
                        dumptable( server )
                    end
                    
                end
            
            end
            
            if not good then
            
                print( "  DROPPING SERVER FROM THE LIST" )
                
                servers[ location ] = nil
                
            end
            
            maybe_invoke_callback()
        
        end
    
    end

    ---------------------------------------------------------------------------
    -- When the search is finished
    ---------------------------------------------------------------------------
    
    function client.on_search_completed( client , search_id )
    
        search_completed = true
        
        maybe_invoke_callback()
    
    end

end
