
-------------------------------------------------------------------------------
dofile( "xml.lua" )
dofile( "upnp.lua" )
-------------------------------------------------------------------------------

servers = nil

local state = { level = "servers" , parent_stack = {} }

-------------------------------------------------------------------------------

local style =
{
    title_text = { font = "DejaVu Sans Mono 60px" , color = "FFFFFF" },
    item_text = { font = "DejaVu Sans Mono 40px" , color = "FFFFFF" },
    focus = { color = "0000AA" }
}


local title = Text{ text = "Searching..." }:set( style.title_text )

local items = Group{ position = { 0 , title.h } , size = { screen.w , screen.h - title.h } }

local focus = Rectangle():set( style.focus )

focus:hide()
screen:add( title , focus , items )
screen:show()


local function add_item( text , extra )

    local item = Text{ text = text }:set( style.item_text )
    
    local others = items.children
    
    local max_y = 0

    for _ , child in ipairs( others ) do
    
        if child.y + child.h > max_y then
        
            max_y = child.y + child.h
            
        end
    
    end

    item.name = tostring( #others + 1 )    
    item.position = { 0 , max_y }
    
    items:add( item )
    item:raise_to_top()
    
    item.extra = extra
end

local function hide_focus()

    focus:hide()
    focus.extra.focused = nil
    screen:grab_key_focus()

end

local show_focus

local function browse_finished( server , id , result )
    
    print( "FINISHED BROWSE" , id )
    
    assert( state.level == "media" )
    
    if id ~= state.action_id then
    
        print( "ACTION IS FOR ANOTHER BROWSE" )
        
        return
    
    end
    
    local empty = true
    
    if result.error == 0 then
    
        -- The xml here is a BrowseResponse that contains an element for
        -- each return value. The one we want is called 'Result' which has
        -- DIDL-Lite
        
        local didl = XMLTree( result.xml ):find( "BrowseResponse/Result.text" )
        
        if didl then
            
            didl = XMLTree( didl )
            
            -- Make sure the root is <DIDL-Lite> and that there are children
            
            if didl:find( "DIDL%-Lite" ) and didl.children then
            
                -- We are didling
                
                for _ , child in ipairs( didl.children ) do
                
                    if child.tag == "container" or child.tag == "item" then
                    
                        local title = child:find( child.tag.."/title.text" )
                        
                        if title then
                        
                            local class = nil
                            local resource = nil
                            
                            if child.tag == "item" then
                            
                                class = child:find( "item/class.text" )
                                resource = child:find( "item/res.text" )
                            
                            end
                            
                            --print( "FOUND" , title )
                        
                            add_item( title ,
                                {
                                    server = server ,
                                    object = child.attributes ,
                                    tag = child.tag,
                                    class = class,
                                    resource = resource
                                } )
                            
                            empty = false
                        end
                    
                    end
                
                end
        
            end
        
        end
    
    end
    
    if not empty then
    
        show_focus()
        
    else
    
        add_item( "<empty>" , { empty = true , server = server } )
        
        show_focus()
    
    end
    
end


show_focus = function()

    if focus.is_visible then
        return
    end
    
    local item = items.children[ 1 ]
    
    if item then
    
        focus:set
        {
            size = { screen.w , item.h } ,
            x = items.x + item.x,
            y = items.y + item.y
        }
        
        focus:show()
        focus:grab_key_focus()
        
        focus.extra.focused = item
        
        function focus.on_key_down( focus , k )
        
            if k == keys.Return or k == keys.Right then
            
                if state.level == "servers" then
                
                    local focused = focus.extra.focused
                    
                    local server = focused.extra.server
                    
                    local action_id = server:browse( 0 )
                    
                    state.level = "media"
                    
                    state.oid = 0
                    
                    state.action_id = action_id
                    
                    hide_focus()
                    
                    items:clear()
                    
                    title.extra.stack = { server.name }
                    
                    title.text = server.name
                    
                    server.on_action_completed = browse_finished
                    
                elseif state.level == "media" then
                
                    local focused = focus.extra.focused
                    
                    if not focused.extra.empty then
                    
                        local server = focused.extra.server
                        
                        if focused.extra.tag == "container" then
                        
                            local action_id = server:browse( focused.extra.object.id )
                            
                            table.insert( state.parent_stack , state.oid )
                            
                            state.oid = focused.extra.object.id
                            
                            state.action_id = action_id
                            
                            hide_focus()
                            
                            items:clear()
                            
                            table.insert( title.extra.stack , focused.text )
                            
                            title.text = table.concat( title.extra.stack , "/" )
                            
                            server.on_action_completed = browse_finished
                            
                        elseif focused.extra.tag == "item" then
                        
                            -- What happens when you hit enter on a media "item"
                            
                            dumptable( focused.extra )

                            local class = focused.extra.class
                            local resource = focused.extra.resource
                           
                            if class and resource then
                            
                                if class == "object.item.imageItem.photo" then
                                
                                    local index = tonumber( focused.name )
                                    local list = items.children
                                    
                                    local urls = {}
                                    
                                    local i = index
                                    
                                    while true do
                                    
                                        table.insert( urls , list[ i ].extra.resource )
                                        
                                        i = i + 1
                                        
                                        if i > #list then
                                            i = 1
                                        end

                                        if i == index then
                                            break
                                        end
                                    
                                    end
                                    
                                    launch_action( nil , "SLIDESHOW" , nil , "image/jpeg" , urls )
                                
                                else
                                
                                    mediaplayer:load( resource )
                                    mediaplayer.on_loaded = function() mediaplayer:play() end
                                
                                end
                            
                            end
                        
                        end
                        
                    end
                
                end
                
            elseif k == keys.Left then
            
                if state.level == "media" then
                
                    local focused = focus.extra.focused
                    
                    local server = focused.extra.server
                    
                    local parent_oid = table.remove( state.parent_stack )
                    
                    if not parent_oid then
                    
                        hide_focus()
                        items:clear()
                                           
                        for _ , server in ipairs( servers ) do                        
                            add_item( server.name , { server = server } )
                        end
                            
                        show_focus()
                        
                        title.text = "Media Servers"
                        title.extra.stack = { }
                        
                        state.level = "servers"
                        state.oid = nil
                        state.action_id = nil
                        
                        server.on_action_completed = nil
                        
                    else
                    
                    
                        local action_id = server:browse( parent_oid )
                        
                        state.oid = parent_oid
                        state.action_id = action_id
                        hide_focus()
                        items:clear()
                        table.remove( title.extra.stack )
                        title.text = table.concat( title.extra.stack , "/" )
                        
                    end
                
                end
            
            elseif k == keys.Up then
            
                local focused = focus.extra.focused
                
                local index = tonumber( focused.name )
                
                if  index > 1 then
                
                    index = index - 1
                    
                    local item = items:find_child( tostring( index ) )
                    
                    if item then
                    
                        focus:set
                        {
                            size = { screen.w , item.h } ,
                            x = items.x + item.x,
                            y = items.y + item.y
                        }
                        
                        focus.extra.focused = item
                        
                    end
                
                end
            
            elseif k == keys.Down then
            
                local focused = focus.extra.focused
                
                local index = tonumber( focused.name )
                
                if  index < #items.children then
                
                    index = index + 1
                    
                    local item = items:find_child( tostring( index ) )
                    
                    if item then
                    
                        focus:set
                        {
                            size = { screen.w , item.h } ,
                            x = items.x + item.x,
                            y = items.y + item.y
                        }
                        
                        focus.extra.focused = item
                        
                    end
                
                end

            end
        
        end
    
    end

end


-------------------------------------------------------------------------------

local function content_directory_browse(
    self ,
    object_id ,
    browse_flag ,
    filter ,
    starting_index ,
    requested_count )

    return self:action( "Browse",
        {
            ObjectID        = object_id or 0,
            BrowseFlag      = browse_flag or "BrowseDirectChildren",
            Filter          = filter or "*",
            StartingIndex   = starting_index or 0,
            RequestedCount  = requested_count or 0
        } )
end

-------------------------------------------------------------------------------

local function server_search_completed( cds )

    servers = cds

    print( "SEARCH DONE!" )

    dumptable( servers )
    
    title.text = "Media Servers"
    
    for _ , server in ipairs( servers ) do
    
        -- Add the 'browse' function to the server
    
        getmetatable( server ).browse = content_directory_browse
        
        --server:populate_actions( function(result) print( result) dumptable( getmetatable( server ) ) end )
        
        add_item( server.name , { server = server } )
        
        show_focus()
        
    end
    
    

end

upnp_service_search(
    "urn:schemas-upnp-org:device:MediaServer:1" ,
    "urn:schemas-upnp-org:service:ContentDirectory:1",
    server_search_completed , 2 )


