
local filters =
{
    dora =
    {
        match   =
        
            function( match )
                if ( match.title and string.find( string.lower( match.title ) , "dora" , 1 , true ) ) then
                    return true
                end
            end,
            
        app_id  = "com.trickplay.dora",
        title   = "Dora The Explorer",
        prompt  = 'Press the <span color="red">RED</span> button to play!',
        image   = "audio-detection/dora.png"
    }
}



local function show_toast( match , filter )

    if not screen.toast then
        return
    end
    
    if screen:toast( filter.title , filter.prompt , Bitmap( filter.image ) ) then
        function screen.on_toast()
            apps:launch( filter.app_id )    
        end
    else
        screen.on_toast = nil
    end
end

function app.on_audio_match( app , matches )

    if type( matches ) ~= "table" then
        return
    end
    
    for i = 1 , # matches do
        local match = matches[ i ]
        for key , filter in pairs( filters ) do
            if filter.match and filter.match( match ) then
                local app_id = filter.app_id
                if app_id and apps:is_app_installed( app_id ) then
                    show_toast( match , filter )
                    return
                end
            end
        end
    end
    
end
