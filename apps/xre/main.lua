
dofile( "xre.lua" )

-------------------------------------------------------------------------------

xre = XRE( )

xre:connect( "partner.xcal.tv:4530" , "suite" )

-------------------------------------------------------------------------------

function xre.on_disconnected( xre )

    print( "DISCONNECTED" )
    
    screen:clear()
    
    views = {}
    
    resources = {}
    
    xre_app = {}
    
    collectgarbage()

end

-------------------------------------------------------------------------------

function xre.on_command( xre, command )

    if not pcall( commands[ command.command ] , command ) then

        print( "NO HANDLER FOR COMMAND", command.command )
    
    end
    
end

--=============================================================================

views = {}

resources = {}

xre_app = {}

--=============================================================================
-- Utility

function int_to_color( i )

    local s = string.sub( string.format( "%x" , i ) , -8 )
    
    return { tonumber( string.sub( s , -6 , -5 ) , 16 ),
             tonumber( string.sub( s , -4 , -3 ) , 16 ),
             tonumber( string.sub( s , -2 , -1 ) , 16 ),
             tonumber( string.sub( s , -8 , -7 ) , 16 ) }

end

--=============================================================================
-- Table of functions to handle each XRE command

commands = {}

-------------------------------------------------------------------------------

function commands.CONNECT( command )

    -- The root view will just be the screen
    
    views = {}
    
    views[ 2 ] = { group = screen }
    
    screen.extra.xre_id = 2
    
    xre_app.session_guid = command.sessionGUID
    
    xre_app.key_map_url = command.keyMapURL;
    
    xre_app.version = command.version;
    
    xre_app.id = appId;
    
end

-------------------------------------------------------------------------------

function commands.CONNECT_REJECTED( command )


end

-------------------------------------------------------------------------------

function commands.SHUTDOWN( command )

    xre:disconnect()
    
    exit()
    
end

-------------------------------------------------------------------------------

function commands.NEW( command )

    ---------------------------------------------------------------------------
    -- Table of functions to construct each type of XRE object
    
    local constructors = {}
    
    function constructors.XREView()
    
        -- Create a new view and add it to the views table
        
        local view = { group = Group() }
        
        views[ command.id ] = view
        
        view.group.name = "XREView-"..tostring( command.id )
        
        view.group.extra.xre_id = command.id
        
        set_view_properties( view , command.params )
    
    end
    
    function constructors.XREFont()
    
        resources[ command.id ] = { type = "font" , params = command.params }
    
    end
    
    function constructors.XRERectangle()
            
        resources[ command.id ] = { type = "rectangle" , params = command.params }
        
    end
    
    function constructors.XREText()
    
        resources[ command.id ] = { type = "text" , params = command.params }
    
    end
    
    function constructors.XREImage()
    
        local image = Image{ src = command.params.url , async = true , opacity = 0 }
        
        screen:add( image )
    
        resources[ command.id ] = { type = "image" , params = command.params, image = image }
    
    end
    
    ---------------------------------------------------------------------------

    if not pcall( constructors[ command.klass ] ) then

        print( "DON'T KNOW HOW TO CREATE" , command.klass )
        
    end
    
end

-------------------------------------------------------------------------------

function commands.DELETE( command )

    local view = views[ command.targetId ]
    
    if view then
    
        print( "DELETING" , view.group.name )
    
        view.group:unparent()
        
        views[ command.targetId ] = nil
    
    else
    
        local resource = resources[ command.targetId ]
        
        if resource then
        
            resources[ command.targetId ] = nil
        
        end
        
    end

end

-------------------------------------------------------------------------------

function commands.SET( command )

    if command.targetId == 1 then
    
        -- TODO : setting app properties
    
    else
    
        local view = views[ command.targetId ]
        
        if not view then
            
            print( "SET COMMAND FOR UNKNOWN VIEW" , command.targetId )
            
            return
        
        end
        
        set_view_properties( view , command.props )
            
    end

end

-------------------------------------------------------------------------------

function commands.CALL( command )

end

-------------------------------------------------------------------------------

function commands.REDIRECT( command )

end

-------------------------------------------------------------------------------

function commands.RESTART( command )

    --xre:connect( xre_uri )

end

--=============================================================================

function set_view_properties( view , props )

    ---------------------------------------------------------------------------
    -- Table of functions to set individual properties on a view
    
    local setters = {}
    
    function setters.visible( view , value )
    
        if value then
        
            view.group:show()
            
        else
        
            view.group:hide()
            
        end
    
    end
    
    function setters.dimensions( view , value )
    
        view.group.size = { value[ 1 ] , value[ 2 ] }
    
    end
    
    function setters.alpha( view , value )
    
        view.group.opacity = value * 255
    
    end
    
    function setters.parent( view , value )
    
        local parent = views[ value ]
        
        if not parent then
        
            print( "INVALID PARENT" , value )
            
            return
        
        end
        
        parent.group:add( view.group )
    
    end
    
    function setters.clip( view , value )
    
        if value then
        
            view.group.clip = { 0 , 0 , view.group.w , view.group.h }
            
        else
        
            view.group.clip = nil
            
        end
    
    end
    
    function setters.resource( view , value )
    
        -- Remove previous children
        
        view.group:clear()
        
        local resource = resources[ value ]
        
        if not resource then
        
            print( "INVALID RESOURCE" , value )
        
            return
            
        end
        
        if resource.type == "image" then
        
            view.group:add( Clone{ source = resource.image , opacity = 255 } )
        
        elseif resource.type == "rectangle" then
        
            local rectangle =
            
                Rectangle
                {
                    border_width = resource.params.borderThickness,
                    color = int_to_color( resource.params.color ),
                    border_color = int_to_color( resource.params.borderColor ),
                    size = view.group.size
                }
                
            view.group:add( rectangle )
            
        elseif resource.type == "text" then
        
            -- TODO: find the font resource and use it
            
            --local font = resources[ resource.params.font ]
            
            local text =
            
                Text
                {
                    font = "Sans "..tostring( resource.params.size ).."px",
                    text = resource.params.text,
                    color = int_to_color( resource.params.color ),
                    size = view.group.size,
                    clip = { 0 , 0 , view.group.w , view.group.h }
                }
                
            view.group:add( text )
        
        end
    
    end
    
    function setters.matrix( view , value )
    
        view.group.x = value[ 13 ]
        view.group.y = value[ 14 ]
        view.group.z = value[ 15 ]
    
    end
    
    function setters.painting( view , value )
    
        -- TODO : value is a boolean telling us whether this
        -- view should be updating itself on the screen or not
    
    end
    
    function setters.ignoreMouse( view , ignore )
    
        view.group.reactive = not ignore
    
    end
    
    function setters.resourceOptions( view , options )
    
        -- TODO
    
    end
    
    function setters.onMouseDown( view , props )
    
        function view.group.on_button_down( group )
        
            local event =
            {
                name = "onMouseDown",
                handler = group.extra.xre_id,
                source = group.extra.xre_id,
                phase = "STANDARD",
                params = {}
            }
            
            xre:send_event( event )
            
        end
    
    end

    ---------------------------------------------------------------------------

    for name , value in pairs( props ) do
    
        if not pcall( setters[ name ] , view , value ) then
    
            print( "NO SETTER FOR PROPERTY" , name )
        
        end
    
    end

end

--[[

function screen.on_key_down( screen , key )
    
    if key == keys.BackSpace then
    
        local event =
        {
            name = "onKeyDown",
            handler = 2,
            source = 2,
            phase = "STANDARD",
            virtualKeyCode = "ESCAPE",
--            rawCode = keys.Escape,
            params = {}
        }
    
        xre:send_event( event )
    
    end
    
end
 
]]