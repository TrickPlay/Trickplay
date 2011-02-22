
local filters =
{
    dora =
    {
        match =
        
            function( match )
                if ( match.title and string.find( string.lower( match.title ) , "dora" , 1 , true ) ) then
                    return true
                end
            end,
            
        app_id = "com.trickplay.crittertwins",
        
        title = "Dora The Explorer",
        
        prompt = "Press the RED button to play Dora The Explorer memory!",
        
        image = ""
    }
}

local last_match = 0
local stopwatch  = Stopwatch()
local toast = nil

local function make_toast()
    if toast then
        return
    end
    
    local TOAST_SIZE            = { 400 , 300 }
    local TOAST_ANIMATE_TIME    = 1000
    local TOAST_UP_TIME         = 7000
    
    toast = Group
    {
        size = TOAST_SIZE,
        x = screen.w - TOAST_SIZE[ 1 ],
        y = screen.h,
        opacity = 0,
        children =
        {
            Rectangle
            {
                size = TOAST_SIZE,
                color = "FFFFFF60",
                border_width = 4,
                border_color = "000000"
            }
            ,
            Text
            {
                name = "title",
                font = "DejaVu Sans 30px",
                color = "FFFFFF",
                position = { 6 , 6 }
            }
        }
    }
    
    function screen.on_key_up( s , key )
        if toast.is_visible and toast.extra.app_id and key == keys.RED then
            apps:launch( toast.extra.app_id )
        end
    end
    
    function toast.extra.populate( filter )
        toast:find_child( "title" ).text = filter.title
        toast.extra.app_id = filter.app_id
    end
    
    function toast.extra.animate_in()
        toast:raise_to_top()
        toast:show()
        toast:animate{
            duration = TOAST_ANIMATE_TIME ,
            y = screen.h - TOAST_SIZE[2],
            opacity = 255,
            on_completed =
                function()
                    local timer = Timer( TOAST_UP_TIME )
                    function timer.on_timer()
                        toast:animate_out()
                        return false
                    end
                    timer:start()
                end
            }
    end
    
    function toast.extra.animate_out()
        toast:animate{
            duration = TOAST_ANIMATE_TIME ,
            y = screen.h ,
            opacity = 0,
            on_completed =
                function()
                    toast:hide()
                end
            }
    end
    
    toast:hide()
    
    screen:add( toast )
end

local function show_toast( match , filter )
    
    print( "SHOW TOAST" )
    print( "\t" , filter.title )
    print( "\t" , filter.prompt )
    print( "\t" , ">" , filter.app_id )

    -- We need to create the toast, if it doesn't exist

    make_toast()
    
    -- If a toast is already up, leave it alone
    
    if toast.is_visible then
        return
    end
    
    -- Populate the toast with this info
    
    toast.extra.populate( filter )
    
    -- Bring it in
    
    toast.extra.animate_in()
    
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
