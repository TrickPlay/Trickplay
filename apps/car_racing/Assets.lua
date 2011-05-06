
local assets = {}
local group = Group()
local queue = {}
local exceptions = {
    ["assets/world/road.png"] = {tile={false,true}, h=20*200},
    ["assets/billboards/pole.png"] = {tile={false,true}, h=19*20},
    ["assets/signs/sign-lg-frame-2.png"] = {tile={true,false}, w=4.5*60},
}

screen:add( group )
group:hide()

--[[---------------------------------------------------------------------------

    queue
    Adds a single path or a table of paths to the queue.

]]

function assets:queue( src )

    if type( src ) == "string" then
        table.insert( queue , src )
    elseif type( src ) == "table" then
        for i = 1 , # src do
            table.insert( queue , src[ i ] )
        end
    end
        
end        

--[[---------------------------------------------------------------------------

    load
    Loads the assets in the queue. If a progress function is provided, it calls
    it for every asset loaded, passing the percent complete and the src of the
    asset. If a finished function is provided, it gets called once when all
    assets have been loaded.
    
]]

function assets:load( progress , finished )

    local function internal_load( queue , progress , finished )
    
        local count = # queue
    
        if count == 0 then
            if finished then
                dolater( finished )
            end
            return
        end
        
        local loaded = 0
        
        for i = 1 , count do
            
            local image = Image
            {
                name = queue[ i ],
                src = queue[ i ],
                async = true
            }
            if exceptions[queue[ i ]] ~= nil then
                image:set(exceptions[queue[ i ]])
            end
            
            function image.on_loaded( image , failed )
                image.on_loaded = nil
                group:add( image )
                loaded = loaded + 1
                if progress then
                    pcall( progress , loaded / count , image.src , failed )
                end
                if ( loaded == count ) and finished then
                    dolater( finished )
                end
            end
        end
        
    end
    
    local queue_copy = {}
    
    for i = 1 , # queue do
        queue_copy[ i ] = queue[ i ]
    end
    
    queue = {}
    
    dolater( internal_load , queue_copy , progress , finished )

end

--[[---------------------------------------------------------------------------

    queue_app_contents
    Queues everything in app.contents that matches the given top_dir - or
    "assets" if top_dir is not provided. 

]]

function assets:queue_app_contents( top_dir )

    top_dir = top_dir or "assets"
    local pattern = "^"..top_dir.."/.*"
    local contents = app.contents
    for i = 1 , # contents do
        if string.match( contents[ i ] , pattern ) then
            self:queue( contents[ i ] )
        end
    end
    
end

--[[---------------------------------------------------------------------------

    Clone
    Creates a clone of the given asset and returns it.

]]

function assets:source_from_src(src)
    assert( type( src ) == "string" , "Assets:source_from_src missing src" )
    return group:find_child( src )
end

function assets:Clone( props )
    
    local source =  assets:source_from_src(props.src)
    assert( source ~= nil , string.format( "Assets:Clone could not find '%s'" , props.src ) )
    local clone = Clone{ source = source }
    local real_props = {}
    -- Create a copy so we can remove the 'src' property without changing the
    -- table 'props' that was passed in.
    for k , v in pairs( props ) do
        if k ~= "src" then
            real_props[ k ] = v
        end
    end
    return clone:set( real_props )    

end


--[[---------------------------------------------------------------------------

    clear_screen
    Removes everything from the screen except our special assets group.

]]

function assets:clear_screen()
    screen:clear()
    screen:add( group )
end

--[[---------------------------------------------------------------------------

    drop
    Removes assets that match the given pattern.(untested)
]]

function assets:drop( pattern )
    
    if not pattern then
        group:clear()
    else
        assert( type( pattern ) == "string" , "Assets:drop pattern is not a string" )
        local children = group.children
        local to_drop = {}
        for i = 1 , # children do
            if string.match( children[ i ] , pattern ) then
                table.insert( to_drop , children[ i ] )
            end
        end
        for i = 1 , # to_drop do
            to_drop[ i ]:unparent()
        end
    end
end

-------------------------------------------------------------------------------

return assets
