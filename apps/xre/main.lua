
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

    if not epcall( commands[ command.command ] , command ) then

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

    local s = string.sub( string.format( "%8.8x" , i ) , -8 )
    
    return { tonumber( string.sub( s , -6 , -5 ) , 16 ) ,
             tonumber( string.sub( s , -4 , -3 ) , 16 ) ,
             tonumber( string.sub( s , -2 , -1 ) , 16 ) ,
             tonumber( string.sub( s , -8 , -7 ) , 16 ) }

end

function epcall( f , ... )

    if not f then
    
        return false
        
    end
    
    f( ... )
    
    return true

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
        
        local view =
        {
            id = command.id,
            
            group = Group
            {
                name = "XREView-"..tostring( command.id ),
                
                extra =
                {
                    xre_id = command.id
                }
            }
        }
        
        function view:apply_resource_options()
        
            -- The view has resource options but it doesn't have a resource
            -- yet, so we bail.
            
            if not view.resource then
            
                return
                
            end
            
            -- {"textWrap":"NONE","verticalAlign":"CENTER","horizontalAlign":"CENTER","stretch":"NONE","textTruncStyle":"NONE"}
            
            --print( "\t\t\tAPPLYING RESOURCE OPTIONS" , view.id , view.resource , view.resource_id , json:stringify( view.resource_options ) )
            
            -- Get the resource's size. For images, we use their base size
            
            local rw , rh = unpack( view.resource.base_size or view.resource.size )
            
            -- Now, stretch
            
            local stretchers =
            {
                NONE =              function()
                                        -- do nothing
                                    end,
                    
                FIT_WIDTH =         function()                        
                                        local scale = view.group.w / rw
                                        view.resource.size = { rw * scale , rh * scale }
                                    end,
                    
                FIT_HEIGHT =        function()
                                        local scale = view.group.h / rh
                                        view.resource.size = { rw * scale , rh * scale }
                                    end,
                    
                FILL =              function()
                                        view.resource.size = view.group.size
                                    end,
                    
                FIT_BEST =          function()                    
                                        local scale = math.min( view.group.w / rw , view.group.h / rh )
                                        view.resource.size = { rw * scale , rh * scale }
                                    end,
                    
                FILL_WITH_CLIP =    function()
                                        local scale = math.max( view.group.w / rw , view.group.h / rh )
                                        view.resource.size = { rw * scale , rh * scale }
                                    end
            }

            epcall( stretchers[ view.resource_options.stretch ] )
            
            -- Now, align horizontally
            
            local horizontal_aligners =
            {
                LEFT    =   function()
                                view.resource.x = 0
                            end,
                    
                CENTER  =   function()
                                view.resource.x = ( view.group.w - view.resource.w ) / 2
                            end,
                    
                RIGHT   =   function()
                                view.resource.x = view.group.w - view.resource.w
                            end
            }
            
            epcall( horizontal_aligners[ view.resource_options.horizontalAlign ] )
            
            -- Align vertically
            
            local vertical_aligners =
            {
                TOP     =   function()
                                view.resource.y = 0
                            end,
                    
                CENTER  =   function()
                                view.resource.y = ( view.group.h - view.resource.h ) / 2
                            end,
                    
                BOTTOM  =   function()
                                view.resource.y = view.group.h - view.resource.h
                            end
            }
            
            epcall( vertical_aligners[ view.resource_options.verticalAlign ] )
        
            -- TODO : textTruncStyle and textWrap
        end

        views[ command.id ] = view
        
        set_view_properties( view , command.params )
    
    end
    
    function constructors.XREFont()
    
        resources[ command.id ] =
        {
            type = command.klass ,
            params = command.params
        }
    
    end
    
    function constructors.XRERectangle()
            
        resources[ command.id ] =
        {
            type = command.klass ,
            params = command.params
        }
        
    end
    
    function constructors.XREText()
    
        resources[ command.id ] =
        {
            type = command.klass ,
            params = command.params
        }
    
    end
    
    function constructors.XREImage()
    
        local image =
        
            Image
            {
                src = command.params.url ,
                async = true ,
                opacity = 0
            }
            
        screen:add( image )
    
        resources[ command.id ] =
        {
            type = command.klass ,
            params = command.params,
            image = image,
        }
        
        function image.on_loaded( image , failed )
        
            image.on_loaded = nil
            
            -- Since the image is loaded asynchronously, we
            -- have to revisit the view that use it and re-apply
            -- their resource options
            
            for id , view in pairs( views ) do
            
                if view.resource_id == command.id then
                
                    view:apply_resource_options()
                    
                end
                
            end
            
        end
    
    end
    
    function constructors.XREAbsoluteTranslationAnimation()

        -- "params":{"easing":"LINEAR_IN_OUT","duration":1000,"x":422.0,"y":104.0}
        
        resources[ command.id ] = { type = command.klass , params = command.params }
    
    end
    
    function constructors.XREAlphaAnimation()
    
        -- {"easing":"LINEAR_IN_OUT","duration":2000,"alpha":1.0}
        
        resources[ command.id ] = { type = command.klass , params = command.params }
        
    end
    
    function constructors.XRETransformAnimation()
    
        -- {"easing":"LINEAR_IN_OUT","duration":2000,"x":0.0,"y":0.0,"scaleX":1.0,"scaleY":1.0,
        -- "rotation":6.283185307179586,"actionPointX":100.0,"actionPointY":100.0}
        
        resources[ command.id ] = { type = command.klass , params = command.params }
        
    end
      
    function constructors.XREDimensionsAnimation()
    
        -- {"easing":"LINEAR_IN_OUT","duration":2000,"width":200.0,"height":200.0}

        resources[ command.id ] = { type = command.klass , params = command.params }
        
    end
    
    ---------------------------------------------------------------------------

    if not epcall( constructors[ command.klass ] ) then

        print( "DON'T KNOW HOW TO CREATE" , command.klass )
        
    end
    
end

-------------------------------------------------------------------------------

function commands.DELETE( command )

    local view = views[ command.targetId ]
    
    if view then
    
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
        
        if view then
        
            set_view_properties( view , command.props )
        
        else
        
            local resource = resources[ command.targetId ]
            
            if resource then
                
                -- Not sure if these props should completely replace
                -- existing props or if individual members of 'props'
                -- should be set
                
                if command.props then
                
                    resource.props = command.props
                    
                    -- Hack to propagate setting the text
                    
                    if command.props.text ~= nil then
                    
                        for id , view in pairs( views ) do
                        
                            if view.resource and view.resource_id == command.targetId then
                            
                                view.resource.text = command.props.text
                            
                            end
                        
                        end
                    
                    end
                    
                end
            
            else
            
                print( "SET COMMAND FOR UNKNOWN TARGET" , command.targetId )
            
            end
        
        end
            
    end

end

-------------------------------------------------------------------------------

function commands.CALL( command )

    local methods = {}
    
    function methods.activate()
    
        local view = views[ command.targetId ]
        
        if view then
        
            view.group:grab_key_focus()
            
        end
    
    end
    
    function methods.animate()
    
        -- "method":"animate","params":[2368],"targetId":2362    
        
        local view = views[ command.targetId ]
        
        -- params is an array, so there could be multiple
        
        assert( #command.params == 1 )
        
        local animation_id = command.params[ 1 ]
            
        local animation = resources[ animation_id ]
        
        local function animation_completed()
        
            if animation.props and animation.props.onComplete then
               
                local event =
                {
                    name = "onComplete",
                    handler = animation_id,
                    source = animation_id,
                    phase = "STANDARD",
                    params =
                    {
                    }        
                }
                
                xre:send_event( event )
                
            end
        
        end
        
        if view and animation then
        
            if animation.type == "XREAbsoluteTranslationAnimation" then
            
                view.group:animate
                {
                    mode = animation.params.easing,
                    duration = animation.params.duration,
                    x = animation.params.x,
                    y = animation.params.y,
                    on_completed = animation_completed
                }

            elseif animation.type == "XREAlphaAnimation" then
            
                view.group:animate
                {
                    mode = animation.params.easing,
                    duration = animation.params.duration,
                    opacity = 255 * animation.params.alpha,
                    on_completed = animation_completed
                }

            elseif animation.type == "XRETransformAnimation" then
            
            -- {"easing":"LINEAR_IN_OUT","duration":2000,"x":0.0,"y":0.0,"scaleX":1.0,"scaleY":1.0,"rotation":6.283185307179586,"actionPointX":100.0,"actionPointY":100.0}
                        
                view.group.z_rotation = { view.group.z_rotation[1] , animation.params.actionPointX , animation.params.actionPointY }
            
                view.group:animate
                {
                    mode = animation.params.easing,
                    duration = animation.params.duration,
                    x = view.group.x + animation.params.x,
                    y = view.group.y + animation.params.y,
                    scale = { animation.params.scaleX or 1 , animation.params.scaleY or 1 },
                    z_rotation = math.deg( animation.params.rotation ) + view.group.z_rotation[1] or 0,
                    on_completed = animation_completed
                }
                
            elseif animation.type == "XREDimensionsAnimation" then

                view.group:animate
                {
                    mode = animation.params.easing,
                    duration = animation.params.duration,
                    w = animation.params.width,
                    h = animation.params.height,
                    on_completed = animation_completed
                }
                
            end
        
        end
    
    end

    if not epcall( methods[ command.method ] ) then
    
        print( "UNHANDLED COMMAND '"..command.method.."'" )
    
    end
    
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
        
        view:apply_resource_options()
        
        if view.resource then
        
            local resource = resources[ view.resource_id ]
            
            if resource.type == "XRERectangle" then
            
                view.resource.size = view.group.size
            
            end
        
        end
    
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
    
    function setters.resource( view , resource_id )
    
        -- Find the resource
        
        local resource = resources[ resource_id ]
        
        if not resource then
        
            print( "INVALID RESOURCE" , resource_id )
        
            return
            
        end
        
        -- Remove a previous resource
        
        if view.resource then
        
            view.resource:unparent()
            
            view.resource_id = nil
            
            view.resource = nil
        
        end
        
        
        if resource.type == "XREImage" then
        
            view.resource =
            
                Clone
                {
                    name = "XREImage-"..tostring( resource_id ),
                    source = resource.image,
                    opacity = 255,
                    --size = view.group.size
                }
            
        
        elseif resource.type == "XRERectangle" then
        
            view.resource =
            
                Rectangle
                {
                    name = "XRERectangle-"..tostring( resource_id ),
                    border_width = resource.params.borderThickness,
                    color = int_to_color( resource.params.color ),
                    border_color = int_to_color( resource.params.borderColor ),
                    size = view.group.size
                }
                            
            
        elseif resource.type == "XREText" then
        
            -- TODO: find the font resource and use it
            
            --local font = resources[ resource.params.font ]
            
            view.resource =
            
                Text
                {
                    name = "XREText-"..tostring( resource_id ),
                    font = "Sans "..tostring( resource.params.size ).."px",
                    text = resource.params.text,
                    color = int_to_color( resource.params.color ),
                    --size = view.group.size,
                    --clip = { 0 , 0 , view.group.w , view.group.h }
                }
                
            view.group.clip = { 0 , 0 , view.group.w , view.group.h }
                        
        end
    
        -- Now add the resource to the group
        
        if view.resource then
                
            view.group:add( view.resource )
            
            -- The resource is the 'background' of the view - so we lower
            -- it to the bottom, so it is under child views.
            
            view.resource:lower_to_bottom()
            
            -- Set its id
            
            view.resource_id = resource_id
            
            -- Apply resource options
            
            view:apply_resource_options()
            
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
    
        view.resource_options = options
        
        view:apply_resource_options()
    
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
    
    function setters.onKeyDown( view , props )
    
        function view.group.on_key_down( group , key , unicode )
        
            local event =
            {
                name = "onKeyDown",
                handler = group.extra.xre_id,
                source = group.extra.xre_id,
                phase = "STANDARD",
                params =
                {
                    virtualKeyCode = string.upper( keys[ key ] ),
                    shift = false,
                    control = false,
                    rawCode = string.byte( string.upper( keys[ key ] ) ),
                    alt = false
                }        
            }
            
            xre:send_event( event )
        
        end
    
    end


    function setters.onKeyUp( view , props )
    
        function view.group.on_key_up( group , key , unicode )
        
            local event =
            {
                name = "onKeyUp",
                handler = group.extra.xre_id,
                source = group.extra.xre_id,
                phase = "STANDARD",
                params =
                {
                    virtualKeyCode = string.upper( keys[ key ] ),
                    shift = false,
                    control = false,
                    rawCode = string.byte( string.upper( keys[ key ] ) ),
                    alt = false
                }        
            }
            
            xre:send_event( event )
        
        end
    
    end

    ---------------------------------------------------------------------------

    for name , value in pairs( props ) do
    
        if not epcall( setters[ name ] , view , value ) then
    
            print( "NO SETTER FOR PROPERTY" , name )
        
        end
    
    end

end


function screen.on_key_down( screen , key , u )
    
    print( keys[ key ] , key , u )
    
    if key == keys.BackSpace then
    
        local event =
        {
            name = "onPreviewKeyDown",
            handler = 2,
            source = 2,
            phase = "PREVIEW",
            params =
            {
                virtualKeyCode = "ESCAPE",
                shift = false,
                control = false,
                rawCode = 27,
                alt = false
            }
        }
    
        xre:send_event( event )
    
    end
    
end
 