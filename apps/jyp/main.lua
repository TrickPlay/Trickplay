local frame_src = Image{src = "assets/frame.png"}
local focus_src = Image{src = "assets/frame_focus.png"}

frame_src:hide()
focus_src:hide()

screen:add(frame_src,focus_src)

function CircularValueIterator( t , index )

    return
        function()
            local v
            index , v = next( t , index )
            if index == nil then
                index , v = next( t , index )
            end
            return v
        end
end


local function IdleFunctionTimeline( props )

    local mt = {}
    mt.__index = mt

    local old_idle = idle.on_idle

    function mt.start( props )

        local interval  = type(props.interval)  == "number" and props.interval  or error("Expecting number, got "..type(props.interval), 2)
        local functions = type(props.functions) == "table"  and props.functions or error("Expecting table, got " ..type(props.functions),2)

        --Trick.assert_number( interval )
        assert( interval > 0 )
        --Trick.assert_table( functions )

        old_idle = idle.on_idle

        local start = Stopwatch()

        local progress

        function idle.on_idle( idle , seconds )
            if old_idle then
                pcall( old_idle , idle , seconds )
            end
            progress = math.min( 1 , start.elapsed / interval )
            for _ , f in ipairs( functions ) do
                pcall( f , progress )
            end
            if progress == 1 then
                if props.on_completed then
                    pcall( props.on_completed , props )
                end
                idle.on_idle = old_idle
            end
        end
    end

    function mt.stop( props )

        idle.on_idle = old_idle

    end

    return setmetatable( props , mt )
end


-------------------------------------------------------------------------------

screen:show()

dolater(function()

    local section   = {}

    --local assets    = ui.assets

    --local factory   = ui.factory

    local group = nil

    ---------------------------------------------------------------------------

    local start_lights
    local stop_lights
    local photo_focus_in
    local photo_focus_out
    local photo_move_right
    local photo_move_left

    local function build_ui()

        if group then
            group.opacity = 255
            return
        end

        local image = Image{ src = "assets/background.jpg" }

        image.anchor_point = image.center

        local scale = screen.w / image.w

        local photo_group = Group()

        local lights =
        {
            Image{ src = "assets/background_lights_01.jpg" },
            Image{ src = "assets/background_lights_02.jpg" },
            Image{ src = "assets/background_lights_03.jpg" },
            Image{ src = "assets/background_lights_04.jpg" },
            Image{ src = "assets/background_lights_05.jpg" },
        }

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
                },
                Group
                {
                    position = { 0 , 0 },
                    children = lights
                },
                Image
                {
                    src = "assets/logo.png",
                    x = 40,
                    y = 160
                },
                photo_group
            }
        }

        -- Arrange the light images

        for i = 1 , # lights do
            lights[ i ]:lower_to_bottom()
        end

        local next_light = --[[Trick.]]CircularValueIterator( lights )
        local light = next_light()

        local DIM_PER_SEC = 255 / 2
        local opacity = 255

        function start_lights()
            function idle:on_idle( seconds )
                opacity = math.max( 0  , opacity - ( DIM_PER_SEC * seconds ) )
                if opacity == 0 then
                    light:lower_to_bottom()
                    light.opacity = 255
                    light = next_light()
                    opacity = 255
                else
                    light.opacity = opacity
                end
            end
        end

        function stop_lights()
            idle.on_idle = nil
        end

        -----------------------------------------------------------------------

        local function make_photo_tile( src )

            local FRAME_PADDING = 70

            local photo = Image{ src = src }

            local frame = Clone{source=frame_src}--assets( "showcase/jyp/assets/frame.png" )
            local focus = Clone{source=focus_src}--assets( "showcase/jyp/assets/frame_focus.png" )

            local scale = math.max( ( frame.w - FRAME_PADDING ) / photo.w ,
                ( frame.h - FRAME_PADDING ) / photo.h )

            local group = Group
            {
                size = { frame.w , frame.h },

                anchor_point = { frame.w / 2 , frame.h / 2 },

                children =
                {
                    photo:set
                    {
                        anchor_point = photo.center,
                        x = frame.w / 2,
                        y = frame.h / 2,
                        scale = { scale , scale }
                    },
                    frame,
                    focus:set{ opacity = 0 }
                }
            }

            function group.extra.on_focus_in()
                focus.opacity = 255
                --frame.opacity = 0
            end

            function group.extra.on_focus_out()
                focus.opacity = 0
                --frame.opacity = 255
            end

            return group

        end

        -----------------------------------------------------------------------

        local photos =
        {
            make_photo_tile( "assets/pictures/jypark1.jpg" ),
            make_photo_tile( "assets/pictures/jypark2.jpg" ),
            make_photo_tile( "assets/pictures/jypark3.jpg" ),
            make_photo_tile( "assets/pictures/jypark4.jpg" ),
            make_photo_tile( "assets/pictures/jypark6.jpg" ),
            make_photo_tile( "assets/pictures/jypark7.jpg" )
        }

        local settings =
        {
            -- x , y , scale , z , opacity

            { 0.50 , 0.60 , 1.00 ,  0 , 1.0 }, -- front

            { 0.72 , 0.47 , 0.65 , -1 , 0.8}, -- right 1
            { 0.65 , 0.35 , 0.55 , -2 , 0.6 }, -- right 2

            { 0.50 , 0.25 , 0.45 , -3 , 0.5 }, -- center

            { 0.35 , 0.35 , 0.55 , -2 , 0.6 }, -- left 2
            { 0.28 , 0.47 , 0.65 , -1 , 0.8 }  -- left 1
        }

        for i , photo in ipairs( photos ) do
            local s = settings[ i ]
            photo.children[ 1 ].opacity = 255 * s[ 5 ]
            photo_group:add( photo:set
            {
                x = screen.w * s[ 1 ],
                y = screen.h * s[ 2 ],
                scale = { s[ 3 ] , s[ 3 ] },
                z = s[ 4 ]
            } )
        end

        local front_photo = 1

        function photo_focus_in()
            photos[ front_photo ]:on_focus_in()
        end

        function photo_focus_out()
            photos[ front_photo ]:on_focus_out()
        end

        local timeline = nil

        local function photo_index( index , delta )
            local result = index + delta
            if result < 1 then
                result = # photos
            elseif result > # photos then
                result = 1
            end
            return result
        end

        local function photo_move( d )

            if timeline then
                return
            end

            local functions = {}

            for i = 1 , # photos do
                local this_one = photos[ i ]
                local other_one = photos[ photo_index( i , d ) ]

                local x_interval = Interval( this_one.x , other_one.x )
                local y_interval = Interval( this_one.y , other_one.y )
                local z_interval = Interval( this_one.z , other_one.z )
                local scale_interval = Interval( this_one.scale[ 1 ] , other_one.scale[ 1 ] )
                local p_interval = Interval( this_one.children[ 1 ].opacity , other_one.children[ 1 ].opacity )

                local o_interval
                if i == front_photo then
                    o_interval = Interval( 255 , 0 )
                elseif i == photo_index( front_photo , -d ) then
                    o_interval = Interval( 0 , 255 )
                end


                local function doit( progress )
                    this_one.x = x_interval:get_value( progress )
                    this_one.y = y_interval:get_value( progress )
                    this_one.z = z_interval:get_value( progress )
                    local scale = scale_interval:get_value( progress )
                    this_one.scale = { scale , scale }
                    if o_interval then
                        this_one.children[3].opacity = o_interval:get_value( progress )
                    end
                    this_one.children[1].opacity = p_interval:get_value( progress )
                end

                table.insert( functions , doit )
            end

            timeline = IdleFunctionTimeline{ interval = 450 , functions = functions }

            ---[[ Quick and dirty fix for the raise_to_top issue that was
            --    introduced when a change in clutter caused z values to
            --    no longer influence draw order
            local p, z
            for z_i = -3,0 do
                for i,v in ipairs(photos) do
                    p = photos[ photo_index( i , d ) ]
                    if p.z == z_i then
                        z = v.z
                        v:raise_to_top()
                        v.z = z
                    end
                end
            end
            --]]

            function timeline.on_completed( )
                timeline = nil
            end

--            photos[ front_photo ]:on_focus_out()
            front_photo = photo_index( front_photo , -d )
--            photos[ front_photo ]:on_focus_in()

            timeline:start()
        end

        function photo_move_right()
            photo_move( -1 )
        end

        function photo_move_left()
            photo_move( 1 )
        end

        -----------------------------------------------------------------------

        screen:add( group )

        group:raise_to_top()

    end

    ---------------------------------------------------------------------------

    local ANIMATE_IN_DURATION   = 150
    local ANIMATE_OUT_DURATION  = 200

    local GROUP_HIDDEN_Z        = -5000

    local function animate_in()

        group:set
        {
            opacity = 0,
        }

        --ui:lower( group )

        local functions =
        {
            function( progress )
                group.opacity = 255 * progress
            end
        }

        local timeline = FunctionTimeline{ duration = ANIMATE_IN_DURATION , functions = functions }

        function timeline.on_completed()
            start_lights()
        end

        timeline:start()

    end

    ---------------------------------------------------------------------------

    local function animate_out()

        stop_lights()

        local functions =
        {
            function( progress )
                group.opacity = 255 * ( 1 - progress )
            end
        }


        local timeline = FunctionTimeline{ duration = ANIMATE_OUT_DURATION , functions = functions }

        timeline:start()
    end

    ---------------------------------------------------------------------------

    local function play_video()

        if mediaplayer:load( "assets/video.mp4" ) ~= 0 then
            print( "FAILED TO LOAD VIDEO" )
            return
        end

        function mediaplayer.on_loaded()
            mediaplayer:play()
            function mediaplayer.on_end_of_stream()
                mediaplayer:seek( 0 )
                mediaplayer:play()
            end
        end

        local old_key_down = group.on_key_down
        local old_idle = idle.on_idle

        idle.on_idle = nil

        local function go_back()
            screen:animate
            {
                duration = 500 ,
                opacity = 255 ,
                on_completed =
                    function()
                        group.on_key_down = old_key_down
                        mediaplayer:reset()
                        idle.on_idle = old_idle
                    end
            }
        end

        function mediaplayer.on_error()
            go_back()
        end

        screen:animate{ duration = 1000 , opacity = 0 }

        function group.on_key_down()
            mediaplayer:pause()
            go_back()
        end

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

        photo_focus_in()

        group:grab_key_focus()

        function group:on_key_down( k )
            if k == keys.Up then
                photo_focus_out()
                --ui:on_exit_section( section )
            elseif k == keys.Right then
                photo_move_right()
            elseif k == keys.Left then
                photo_move_left()
            elseif k == keys.OK then
                play_video()
            end
        end

        return true

    end

    function section.on_default_action( section )

        --ui:on_section_full_screen( section )

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

    build_ui()
    section:on_enter()
end)

