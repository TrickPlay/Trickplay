
dofile( "Json.lua" )

STORE_URL="http://store.trickplay.com"

app_list = nil

-------------------------------------------------------------------------------

function get_app_base_url( index )

    assert( app_list )

    return STORE_URL.."/"..app_list[ index ].id.."/"..tostring( app_list[ index ].release )
    
end

function get_app_zip_url( index )

    assert( app_list )
    
    return get_app_base_url( index ).."/app.zip" 

end

function get_app_icon_url( index )

    assert( app_list )
    
    return get_app_base_url( index ).."/launcher-icon.png" 

end

-------------------------------------------------------------------------------
-- Make the initial request for an app list

local apps_request = URLRequest( STORE_URL.."/apps.json" )

function apps_request.on_complete( request , response )

    if response.failed then
    
        print( "THE REQUEST FOR THE APP LIST FAILED" )
    
    else
    
        local ok , list = pcall( Json.Decode , response.body )
        
        if not ok then
        
            -- list is not really the list but the error message from pcall
            
            print( "FAILED TO DECODE THE APP LIST : "..list )
            
        else
        
            app_list = list
            
            print( "APP LIST HAS" , #app_list , "ITEMS" )
            
        end
    
    end

end

apps_request:send()

-------------------------------------------------------------------------------

function test()

    local icon = Image{ src = get_app_icon_url( 1 ) }
    
    screen:add( icon )

    screen:show()
end
