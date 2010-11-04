
return
function( ui )

    local section   = {}
    
    local assets    = ui.assets
    
    local factory   = ui.factory
    
    local group = nil
    
    ---------------------------------------------------------------------------
    -- To get around bug # 192
    
    local keepers = {}
    
    local function hangon( thing )
        keepers[ thing ] = true
    end
    
    local function letgo( thing )
        keepers[ thing ] = nil
    end
    
    ---------------------------------------------------------------------------
    
    local function build_ui()

        if group then
--            group:raise_to_top()
            group.opacity = 255
            return
        end
            
        local image = Image{ src = "showcase/background.jpg" }
        
        image.anchor_point = image.center
        
        local scale = screen.w / image.w
        
        
        group = Group
        {
            size = screen.size,
            position = { 0 , 0 },
            clip = { 0 , 0 , screen.w , screen.h },
            
            children =
            {
                image:set
                {
                    position = screen.center,
                    scale = { scale , scale }
                }
            }
        }
        
        screen:add( group )
        
        group:raise_to_top()
        
    end
    
    ---------------------------------------------------------------------------
    
    local ANIMATE_IN_DURATION   = 300
    local ANIMATE_OUT_DURATION  = 200
    
    local GROUP_HIDDEN_Z        = -5000
    
    local function animate_in()
    
        group:set
        {
            opacity = 0,
            --z = GROUP_HIDDEN_Z
        }
        
        ui:lower( group )
        
        local interval = Interval( group.z , 0 )
        
        local functions =
        {
            function( progress )
                --group.z = interval:get_value( progress )
                group.opacity = 255 * progress
            end
        }
        
        local timeline = FunctionTimeline{ duration = ANIMATE_IN_DURATION , functions = functions }
        
        hangon( timeline )
        
        function timeline.on_completed( timeline )
            letgo( timeline )
        end
        
        timeline:start()        
    
    end
    
    ---------------------------------------------------------------------------
    
    local function animate_out()
    
        local interval = Interval( group.z , GROUP_HIDDEN_Z )
        
        local functions =
        {
            function( progress )
                --group.z = interval:get_value( progress )
                group.opacity = 255 * ( 1 - progress )
            end
        }
        
        local timeline = FunctionTimeline{ duration = ANIMATE_OUT_DURATION , functions = functions }
        
        hangon( timeline )
        
        function timeline.on_completed( timeline )
            letgo( timeline )
        end
        
        timeline:start()        
        
    
    end
    
    ---------------------------------------------------------------------------
    -- When the menu bar shows us
    ---------------------------------------------------------------------------
    
    function section.on_show( section )
        
        -- Build the UI if we have not done so already
    
        build_ui()
                    
        -- Animate the tiles and invoke the callback when done
        
        animate_in( )
    
    end
    
    ---------------------------------------------------------------------------
    -- Arrow down from the menu bar
    ---------------------------------------------------------------------------
    
    function section.on_enter( section )
    
        return false
    
    end
    
    function section.on_default_action( section )
    
        ui:on_section_full_screen( section )
        
        return true
    
    end

    function section.on_hide( section )
    
        animate_out()
        
    end
    
    function section.on_clear( section )
    
        if group then
            group:unparent()
            group = nil
        end
    
    end
    
    ---------------------------------------------------------------------------

    return section
    
end
    