
local api = { private = { } }

-------------------------------------------------------------------------------
-- If the base url is an empty string, we try to read the results from
-- json files included in the app in the directory "fake-server"

local base_url = ""

-------------------------------------------------------------------------------

--local base_url = "http://ec2-184-72-169-182.compute-1.amazonaws.com:8080/trickplay-0.1/"

--local base_url = "http://quinnipiac.local:8080/trickplay/"

-------------------------------------------------------------------------------

local function assert_table( v ) assert( type( v ) == "table" ) end
local function assert_string( v ) assert( type( v ) == "string" ) end
local function assert_function( v ) assert( type( v ) == "function" ) end

-------------------------------------------------------------------------------
-- Public
-------------------------------------------------------------------------------

function api:search( params , callback )
    
    assert_table( params )
    assert_function( callback )
    
    self.private:send_request( "application/search" , params , callback )
    
end

function api:price_to_string( price )

    assert( price )

    price = tonumber( price )
    
    -- We return nil when it is free
    
    if price < 0.01 then
        return nil
    end
    
    -- TODO : currency
    
    -- Cents
    
    if price < 1 then
        return string.format( "%d¢" , price * 100 )
    end
    
    -- Dollars
    
    return string.format( "$%2.2f" , price )

end

-------------------------------------------------------------------------------
-- Private
-------------------------------------------------------------------------------

function api.private:send_request( sub_url , params , callback )

    assert_string( sub_url )
    assert_table( params )
    assert_function( callback )
    
    -- Compose the URL
    
    local url = base_url..sub_url
    
    local first = true
    
    for k , v in pairs( params ) do
    
        if first then
            url = url.."?"
            first = nil
        else
            url = url.."&"
        end
        
        url = url..tostring( k ).."="..uri:escape( tostring( v ) )
    
    end
    
    ---------------------------------------------------------------------------
    -- This is for server-less operation; we try to read the result from a file
    
    if base_url == "" then
    
        local name = "fake-server/"..url..".json" 
    
        local results = readfile( name ) or readfile( string.gsub( name , "%?" , "_" ) )
        
        if results then
        
            dolater( callback , json:parse( results ) )
        
            return
        end
    
    end
    
    ---------------------------------------------------------------------------
    -- Create and send the request
    
    local request = URLRequest( url )
    
    request:send()
    
    print( "CALLING" , url )
    
    function request.on_complete( request , response )
    
        local result
    
        -- If the request failed, we concoct a result that looks like a normal
        -- error result from the server.
        
        if response.failed or response.code ~= 200 then
        
            result = { stat = "error" , error = { code = response.code , message = response.status } }
            
        else
        
            result = json:parse( response.body )
            
            -- Same if there is a problem parsing the result
            
            if not result then
            
                result = { stat = "error" , error = { code = 0 , message = "Failed to parse JSON" } }
                
            end
        
        end
        
        assert( result )
        
        if result.stat ~= "ok" then
                        
            print( "SHOP API REQUEST FAILED" )
            dumptable( result )
        
        end

        -- Invoke the callback with the result
        
        dolater( callback , result )
    
    end
    
end

-------------------------------------------------------------------------------

return Encapsulate( api )
