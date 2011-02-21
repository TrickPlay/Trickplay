
local filters =
{
    [ "dora" ] =
        
        function( match )
            if ( match.title and string.find( string.lower( match.title ) , "dora" , 1 , true ) )
                return "com.trickplay.crittertwins"
            end
        end
}

local last_match = 0
local stopwatch  = Stopwatch()

local function show_toast( key , app_id )
    print( "SHOW TOAST FOR" , key )
end

function app.on_audio_match( app , matches )
    
    if type( matches ) ~= "table" then
        return
    end
    
    for i = 1 , # matches do
        local match = matches[ i ]
        for k , f in pairs( filters ) do
            local app_id = f( match )
            if app_id and apps.is_app_installed( app_id ) then
                show_toast( k , app_id )
                return
            end
        end
    end
    
end
