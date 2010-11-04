
local factory = {}

function factory.make_dropdown( size , color )

    local BORDER_WIDTH=6
    local POINT_HEIGHT=34
    local POINT_WIDTH=60
    local BORDER_COLOR="FFFFFF5C"
    local CORNER_RADIUS=22
    local POINT_CORNER_RADIUS=2
    local H_BORDER_WIDTH = BORDER_WIDTH / 2
    
    local function draw_path( c )
    
        c:new_path()
    
        c:move_to( H_BORDER_WIDTH + CORNER_RADIUS, POINT_HEIGHT - H_BORDER_WIDTH )
        
        c:line_to( ( c.w / 2 ) - ( POINT_WIDTH / 2 ) - POINT_CORNER_RADIUS , POINT_HEIGHT - H_BORDER_WIDTH )
        
        c:curve_to( ( c.w / 2 ) - ( POINT_WIDTH / 2 ) , POINT_HEIGHT - H_BORDER_WIDTH ,
                    ( c.w / 2 ) - ( POINT_WIDTH / 2 ) , POINT_HEIGHT - H_BORDER_WIDTH ,
                     c.w / 2 , H_BORDER_WIDTH  )
        
        c:curve_to( ( c.w / 2 ) + ( POINT_WIDTH / 2 ) , POINT_HEIGHT - H_BORDER_WIDTH,
                    ( c.w / 2 ) + ( POINT_WIDTH / 2 ) , POINT_HEIGHT - H_BORDER_WIDTH,
                    ( c.w / 2 ) + ( POINT_WIDTH / 2 ) + POINT_CORNER_RADIUS , POINT_HEIGHT - H_BORDER_WIDTH )
                    
        c:line_to( c.w - H_BORDER_WIDTH - CORNER_RADIUS , POINT_HEIGHT - H_BORDER_WIDTH )
        
        c:curve_to( c.w - H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH ,
                    c.w - H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH ,
                    c.w - H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH + CORNER_RADIUS )
                    
        c:line_to( c.w - H_BORDER_WIDTH , c.h - H_BORDER_WIDTH - CORNER_RADIUS )
        
        c:curve_to( c.w - H_BORDER_WIDTH , c.h - H_BORDER_WIDTH,
                    c.w - H_BORDER_WIDTH , c.h - H_BORDER_WIDTH,
                    c.w - H_BORDER_WIDTH - CORNER_RADIUS , c.h - H_BORDER_WIDTH )
        
        c:line_to( H_BORDER_WIDTH + CORNER_RADIUS , c.h - H_BORDER_WIDTH )
        
        c:curve_to( H_BORDER_WIDTH , c.h - H_BORDER_WIDTH,
                    H_BORDER_WIDTH , c.h - H_BORDER_WIDTH,
                    H_BORDER_WIDTH , c.h - H_BORDER_WIDTH - CORNER_RADIUS )
        
        c:line_to( H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH + CORNER_RADIUS )
        
        c:curve_to( H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH,
                    H_BORDER_WIDTH , POINT_HEIGHT - H_BORDER_WIDTH,
                    H_BORDER_WIDTH + CORNER_RADIUS, POINT_HEIGHT - H_BORDER_WIDTH )
    
    end

    local c = Canvas{ size = size }

    c:begin_painting()

    draw_path( c )

    -- Fill the whole thing with the color passed in and keep the path
    
    c:set_source_color( color )
    c:fill(true)
    
    -- Now, translate to the center and scale to its height. This will
    -- make the radial gradient elliptical.
    
    c:save()
    c:translate( c.w / 2 , c.h / 2 )
    c:scale( 2 , ( c.h / c.w ) )

    local rr = ( c.w / 2 ) 
    c:set_source_radial_pattern( 0 , 30 , 0 , 0 , 30 , c.w / 2 )
    c:add_source_pattern_color_stop( 0 , "00000000" )
    c:add_source_pattern_color_stop( 1 , "000000F0" )
    c:fill()   
    c:restore()

    -- Draw the glossy glow    

    local R = c.w * 2.2

    c:new_path()
    c.op = "ATOP"
    c:arc( 0 , -( R - 240 ) , R , 0 , 360 )
    c:set_source_linear_pattern( c.w , 0 , 0 , c.h * 0.25 )
    c:add_source_pattern_color_stop( 0 , "FFFFFF20" )
    c:add_source_pattern_color_stop( 1 , "FFFFFF04" )
    c:fill()

    -- Now, draw the path again and stroke it with the border color
    
    draw_path( c )

    c:set_line_width( BORDER_WIDTH )
    c:set_source_color( BORDER_COLOR )
    c.op = "SOURCE"
    c:stroke( true )

    c:finish_painting()
    
    return c
    
end

---------------------------------------------------------------------------
-- Makes a menu item with a white ring around it
---------------------------------------------------------------------------

function factory.make_text_menu_item( assets , caption )

    local STYLE         = { font = "DejaVu Sans 26px" , color = "FFFFFF" }
    local PADDING_X     = 7 -- The focus ring has this much padding around it
    local PADDING_Y     = 7  
    local WIDTH         = 300 + ( PADDING_X * 2 )
    local HEIGHT        = 46  + ( PADDING_Y * 2 )
    local BORDER_WIDTH  = 2
    local BORDER_COLOR  = "FFFFFF"
    local BORDER_RADIUS = 12
    
    local function make_ring()
        local ring = Canvas{ size = { WIDTH , HEIGHT } }
        ring:begin_painting()
        ring:set_source_color( BORDER_COLOR )
        ring:round_rectangle(
            PADDING_X + BORDER_WIDTH / 2,
            PADDING_Y + BORDER_WIDTH / 2,
            WIDTH - BORDER_WIDTH - PADDING_X * 2 ,
            HEIGHT - BORDER_WIDTH - PADDING_Y * 2 ,
            BORDER_RADIUS )
        ring:stroke()
        ring:finish_painting()
        return ring
    end
    
    local text = Text{ text = caption }:set( STYLE )
    
    local ring = assets( "menu-item-ring" , make_ring )
    
    local focus = assets( "assets/button-focus.png" )

    local group = Group
    {
        size = { WIDTH , HEIGHT },
        children =
        {
            ring:set{ position = { 0 , 0 } },
            focus:set{ position = { 0 , 0 } , size = { WIDTH , HEIGHT } , opacity = 0 },
            text:set{ position = { ( WIDTH - text.w ) / 2 , ( HEIGHT - text.h ) / 2 } }
        }
    }
    
    function group.extra.on_focus_in()
        focus.opacity = 255
    end
    
    function group.extra.on_focus_out()
        focus.opacity = 0
    end
    
    function group.extra.set_caption( _ , caption )
        text.text = caption
        text:set{ position = { ( WIDTH - text.w ) / 2 , ( HEIGHT - text.h ) / 2 } }
    end
    
    return group

end

-------------------------------------------------------------------------------
-- Makes a text menu item with two white arrows
-------------------------------------------------------------------------------

function factory.make_text_side_selector( assets , caption , chosen )

    local STYLE         = { font = "DejaVu Sans 26px" , color = "FFFFFF" }
    local PADDING_X     = 8 -- The focus ring has this much padding around it
    local PADDING_Y     = 7  
    local WIDTH         = 300 + ( PADDING_X * 2 )
    local HEIGHT        = 46  + ( PADDING_Y * 2 )
    local ARROW_COLOR   = "FFFFFF"
    local ARROW_WIDTH   = HEIGHT / 4
    local ARROW_HEIGHT  = HEIGHT / 3
    local ANIMATION_DURATION = 150
    
    local function make_arrow()
        local arrow = Canvas{ size = { ARROW_WIDTH , ARROW_HEIGHT } }
        arrow:begin_painting()
        arrow:set_source_color( ARROW_COLOR )
        arrow:move_to( 0 , ARROW_HEIGHT / 2 )
        arrow:line_to( ARROW_WIDTH , 0 )
        arrow:line_to( ARROW_WIDTH , ARROW_HEIGHT )
        arrow:fill()
        arrow:finish_painting()
        return arrow
    end
    
    local l_arrow = assets( "menu-item-arrow" , make_arrow )
    local r_arrow = assets( "menu-item-arrow" , make_arrow )
    
    l_arrow.anchor_point = l_arrow.center
    r_arrow.anchor_point = r_arrow.center
    
    r_arrow.z_rotation = { 180 , 0 , 0 }
    
    local focus = assets( "assets/button-focus.png" )
    
    local slider = Group()

    local group = Group
    {
        size = { WIDTH , HEIGHT },

        children =
        {
            l_arrow:set{ position = { PADDING_X + ARROW_WIDTH / 2 , HEIGHT / 2 } , opacity = 128 },
            r_arrow:set{ position = { WIDTH - PADDING_X - ARROW_WIDTH / 2 , HEIGHT / 2 } , opacity = 128 },

            focus:set
            {
                position =
                {
                    PADDING_X + ARROW_WIDTH * 2,
                    0
                } ,
                size =
                {
                    WIDTH - ( PADDING_X * 2 + ARROW_WIDTH * 4 ),
                    HEIGHT
                } ,
                opacity = 0
            },
            
            slider:set
            {
                position = { PADDING_X * 2 + ARROW_WIDTH * 2 , 0 },
                size = { WIDTH - PADDING_X * 4 - ARROW_WIDTH * 4 , HEIGHT },
                clip = { 0 , 0 , WIDTH - PADDING_X * 4 - ARROW_WIDTH * 4 , HEIGHT },
            }
        }
    }

    local choices = caption
    local current_choice = 1
    
    if type( choices ) == "string" then
        choices = { choices }
    end

    if chosen and chosen >= 1 and chosen <= #choices then
        current_choice = chosen
    end
    
    
    for i = 1 , # choices do
    
        local text = Text{ text = choices[ i ] }:set( STYLE )
        
        text.y = ( slider.h - text.h ) / 2
        
        if i == current_choice then
            text.x = ( ( slider.w - text.w ) / 2  )
        else
            text.x = ( ( slider.w - text.w ) / 2  ) + slider.w
        end
        
        slider:add( text )
    
    end
    
    local animating = false
    
    function group.extra.on_focus_in()
        focus.opacity = 255
        l_arrow.opacity = 255
        r_arrow.opacity = 255
    end
    
    function group.extra.on_focus_out()
        focus.opacity = 0
        l_arrow.opacity = 128
        r_arrow.opacity = 128
    end
    
    function group.extra.on_show_next()

        if # choices < 2 or animating then
            return
        end
        
        local children = slider.children
        
        local next_choice = current_choice + 1
        if next_choice > # children then
            next_choice = 1
        end
        
        local this_one = children[ current_choice ]
        local next_one = children[ next_choice ]
        
        next_one.x = ( ( slider.w - next_one.w ) / 2  ) + slider.w 
        
        local this_interval = Interval( this_one.x , this_one.x - slider.w )
        local next_interval = Interval( next_one.x , next_one.x - slider.w )
        
        local timeline = Timeline{ duration = ANIMATION_DURATION }
        
        function timeline.on_new_frame( timeline , elapsed , progress )
            this_one.x = this_interval:get_value( progress )
            next_one.x = next_interval:get_value( progress )
        end
                
        function timeline.on_completed( )
            animating = false
        end
        
        current_choice = next_choice
        
        animating = true
        
        timeline:start()
        
        return current_choice
    end

    function group.extra.on_show_previous()

        if # choices < 2 or animating then
            return
        end
        
        local children = slider.children
        
        local next_choice = current_choice - 1
        if next_choice < 1 then
            next_choice = # choices
        end
        
        local this_one = children[ current_choice ]
        local next_one = children[ next_choice ]
        
        next_one.x = ( ( slider.w - next_one.w ) / 2  ) - slider.w 
        
        local this_interval = Interval( this_one.x , this_one.x + slider.w )
        local next_interval = Interval( next_one.x , next_one.x + slider.w )
        
        local timeline = Timeline{ duration = ANIMATION_DURATION }
        
        function timeline.on_new_frame( timeline , elapsed , progress )
            this_one.x = this_interval:get_value( progress )
            next_one.x = next_interval:get_value( progress )
        end
                
        function timeline.on_completed( )
            animating = false
        end
        
        current_choice = next_choice
        
        animating = true
        
        timeline:start()
        
        return current_choice
    end
    
    return group

end
    
-------------------------------------------------------------------------------
-- Makes an app tile with a polaroid-style frame
-------------------------------------------------------------------------------
    
function factory.make_app_tile( assets , caption , app_id )

    local STYLE         = { font = "DejaVu Sans 24px" , color = "000000FF" }
    local PADDING_X     = 17 -- The focus ring has this much padding around it
    local PADDING_Y     = 17.5
    local FRAME_SHADOW  = 1
    local WIDTH         = 300 + ( PADDING_X * 2 )
    local HEIGHT        = 200 + ( PADDING_Y * 2 )
    local ICON_PADDING  = 6
    local ICON_WIDTH    = 300 - ICON_PADDING * 2
    local CAPTION_X     = PADDING_X + ICON_PADDING + FRAME_SHADOW + 1
    local CAPTION_Y     = HEIGHT - PADDING_Y - 37
    local CAPTION_WIDTH = 300 - ( FRAME_SHADOW * 2 ) - ( ICON_PADDING * 2 )
    
    local function make_icon( app_id )
        local icon = Image()
        if icon:load_app_icon( app_id , "launcher-icon.png" ) then
            return icon
        end
        return "assets/generic-app-icon.jpg"
    end
    
    local text = Text{ text = caption }:set( STYLE )
    
    local focus = assets( "assets/app-icon-focus.png" )
    
    local white_frame = assets( "assets/icon-overlay-white-text-label.png" )

    local black_frame = assets( "assets/icon-overlay-black-text-label.png" )
    
    local icon = assets( app_id , make_icon )
    
    local scale = ICON_WIDTH / icon.w
    
    icon.w = ICON_WIDTH
    icon.h = icon.h * scale
    
    local group = Group
    {
        size = { WIDTH , HEIGHT },
        children =
        {
            focus:set{ position = { 0 , 0 }, size = { WIDTH , HEIGHT }, opacity = 0 },
            icon:set
            {
                position = { PADDING_X + ICON_PADDING + FRAME_SHADOW , PADDING_Y + ICON_PADDING + FRAME_SHADOW } 
            },
            black_frame:set
            {
                position = { PADDING_X + FRAME_SHADOW , PADDING_Y + FRAME_SHADOW } ,
                size = { WIDTH - PADDING_X * 2 , HEIGHT - PADDING_Y * 2 },
                opacity = 0
            },
            white_frame:set
            {
                position = { PADDING_X + FRAME_SHADOW , PADDING_Y + FRAME_SHADOW } ,
                size = { WIDTH - PADDING_X * 2 , HEIGHT - PADDING_Y * 2 }
            },
            text:set
            {
                position = { CAPTION_X , CAPTION_Y },
                width = CAPTION_WIDTH,
                ellipsize = "END"
            }
        }
    }
    
    function group.extra.on_focus_in()
        focus.opacity = 255
        black_frame.opacity = 255
        white_frame.opacity = 0
        text.color = "FFFFFFFF"
    end
    
    function group.extra.on_focus_out()
        focus.opacity = 0
        black_frame.opacity = 0
        white_frame.opacity = 255
        text.color = "000000FF"
    end
    
    return group

end

-------------------------------------------------------------------------------
-- Makes a store app tile with a polaroid-style frame
-------------------------------------------------------------------------------
    
function factory.make_store_tile( assets , caption , url )

    local STYLE         = { font = "DejaVu Sans 24px" , color = "000000FF" }
    local PADDING_X     = 17 -- The focus ring has this much padding around it
    local PADDING_Y     = 17.5
    local FRAME_SHADOW  = 1
    local WIDTH         = 300 + ( PADDING_X * 2 )
    local HEIGHT        = 200 + ( PADDING_Y * 2 )
    local ICON_PADDING  = 6
    local ICON_WIDTH    = 300 - ICON_PADDING * 2
    local ICON_REAL_W   = 480 -- From the store
    local CAPTION_X     = PADDING_X + ICON_PADDING + FRAME_SHADOW + 1
    local CAPTION_Y     = HEIGHT - PADDING_Y - 37
    local CAPTION_WIDTH = 300 - ( FRAME_SHADOW * 2 ) - ( ICON_PADDING * 2 )
        
    local text = Text{ text = caption }:set( STYLE )
    
    local focus = assets( "assets/app-icon-focus.png" )
    
    local white_frame = assets( "assets/icon-overlay-white-text-label.png" )

    local black_frame = assets( "assets/icon-overlay-black-text-label.png" )
    
    local icon = Image{ src = url , async = true }
    
    local scale = ICON_WIDTH / ICON_REAL_W
    
    icon.scale = { scale , scale }
    
    local group = Group
    {
        size = { WIDTH , HEIGHT },
        children =
        {
            focus:set{ position = { 0 , 0 }, size = { WIDTH , HEIGHT }, opacity = 0 },
            icon:set
            {
                position = { PADDING_X + ICON_PADDING + FRAME_SHADOW , PADDING_Y + ICON_PADDING + FRAME_SHADOW } 
            },
            black_frame:set
            {
                position = { PADDING_X + FRAME_SHADOW , PADDING_Y + FRAME_SHADOW } ,
                size = { WIDTH - PADDING_X * 2 , HEIGHT - PADDING_Y * 2 },
                opacity = 0
            },
            white_frame:set
            {
                position = { PADDING_X + FRAME_SHADOW , PADDING_Y + FRAME_SHADOW } ,
                size = { WIDTH - PADDING_X * 2 , HEIGHT - PADDING_Y * 2 }
            },
            text:set
            {
                position = { CAPTION_X , CAPTION_Y },
                width = CAPTION_WIDTH,
                ellipsize = "END"
            }
        }
    }
    
    function group.extra.on_focus_in()
        focus.opacity = 255
        black_frame.opacity = 255
        white_frame.opacity = 0
        text.color = "FFFFFFFF"
    end
    
    function group.extra.on_focus_out()
        focus.opacity = 0
        black_frame.opacity = 0
        white_frame.opacity = 255
        text.color = "000000FF"
    end
    
    return group

end


-------------------------------------------------------------------------------
-- Makes a featured app tile
-------------------------------------------------------------------------------

function factory.make_featured_app_tile( assets , caption , description , icon_url )

    local STYLE                 = { font = "DejaVu Sans bold 34px" , color = "FFFFFF" }
    local DESC_STYLE            = { font = "DejaVu Sans 26px" , color = "FFFFFF" }
    local FRAME_X_OFFSET        = 15
    local FRAME_Y_OFFSET        = 23
    local FRAME_X_PADDING       = 7
    local FRAME_Y_PADDING       = 12
    local LABEL_COLOR           = "000000CC"
    local LABEL_HEIGHT          = 67
    local LABEL_BORDER_WIDTH    = 2
    local LABEL_BORDER_COLOR    = "CCCCCCAA"
    local TEXT_TOP_OFFSET       = 10
    local TEXT_LEFT_OFFSET      = 30
    local LABEL_BOTTOM_OFFSET   = -( LABEL_HEIGHT - 2 )
    local SLIDER_HEIGHT         = LABEL_HEIGHT * 2
    local DESC_TOP_OFFSET       = 47
    local SLIDE_DURATION        = 150
    
    local text = Text{ text = caption }:set( STYLE )
    
    local desc = Text{ text = description }:set( DESC_STYLE )

    local frame = assets( "assets/featured-app-overlay-frame.png" )
    
    local focus = assets( "assets/featured-app-focus.png" )
    
    local icon = Image
    {
        src = icon_url ,
        async = true,
    }
    
    local slider = Group()
    
    local group = Group
    {
        children =
        {
            focus:set{ opacity = 0 },
            
            icon:set
            {
                x = FRAME_X_OFFSET + FRAME_X_PADDING,
                y = FRAME_Y_OFFSET
            },
            
            slider:set
            {
                x = FRAME_X_OFFSET + FRAME_X_PADDING,
                y = FRAME_Y_OFFSET + frame.h + LABEL_BOTTOM_OFFSET - FRAME_Y_PADDING,
                size = { frame.w - FRAME_X_PADDING * 2 , LABEL_HEIGHT + SLIDER_HEIGHT },
                clip = { 0 , 0 , frame.w - FRAME_X_PADDING * 2 , LABEL_HEIGHT },
                
                children =
                {
                    Rectangle
                    {
                        color = LABEL_COLOR ,
                        size = { frame.w - FRAME_X_PADDING * 2 , LABEL_HEIGHT * 4 },
                        border_width = LABEL_BORDER_WIDTH,
                        border_color = LABEL_BORDER_COLOR,
                        position = { 0 , 0 }
                    },
                    
                    text:set
                    {
                        position = { TEXT_LEFT_OFFSET , TEXT_TOP_OFFSET }    
                    },
                    
                    desc:set
                    {
                        position = { TEXT_LEFT_OFFSET , TEXT_TOP_OFFSET + DESC_TOP_OFFSET },
                        h = SLIDER_HEIGHT,
                        w = frame.w - FRAME_X_PADDING * 2 - TEXT_LEFT_OFFSET * 2  ,
                        wrap = true,
                        ellipsize = "END"
                    }
                    
                }
                            
            },
            
            frame:set
            {
                position = { FRAME_X_OFFSET , FRAME_Y_OFFSET }
            },
        }
    }
    
    local y_interval = Interval( slider.y , slider.y - SLIDER_HEIGHT )
    
    local clip_interval = Interval( LABEL_HEIGHT , LABEL_HEIGHT + SLIDER_HEIGHT )

    local timeline 

    function group.extra.on_focus_in()

        focus.opacity = 255
        
        local start = 0
        
        if timeline then
            timeline:pause()
            start = timeline.duration - timeline.elapsed
            timeline = nil
        end

        timeline = Timeline{ duration = SLIDE_DURATION }
        
        function timeline.on_new_frame( timeline , elapsed , progress )
            slider.y = y_interval:get_value( progress )
            slider.clip = { 0 , 0 , frame.w - FRAME_X_PADDING * 2 , clip_interval:get_value( progress ) }
        end
        
        function timeline.on_completed( )
            timeline = nil
        end
        
        timeline:start()
        timeline:advance( start )
        
    end
    
    function group.extra.on_focus_out()
        focus.opacity = 0

        local start = 0
        
        if timeline then
            timeline:pause()
            start = timeline.duration - timeline.elapsed
            timeline = nil
        end
        
        timeline = Timeline{ duration = SLIDE_DURATION }
        
        function timeline.on_new_frame( timeline , elapsed , progress )
            slider.y = y_interval:get_value( 1 - progress )
            slider.clip = { 0 , 0 , frame.w - FRAME_X_PADDING * 2 , clip_interval:get_value( 1 - progress ) }
        end
        
        function timeline.on_completed( )
            timeline = nil
        end
        
        timeline:start()
        timeline:advance( start )
    end
    
    return group
    
end

-------------------------------------------------------------------------------
-- Makes a tile for the floor of the main app shop screen
-------------------------------------------------------------------------------

function factory.make_shop_floor_tile( assets , icon_url )

    local FRAME_X_PADDING = 4
    local FRAME_Y_PADDING = 0
    local FRAME_BOTTOM    = 2
    local FRAME_BORDER_W  = 10
    local ICON_WIDTH      = 480
    local ICON_HEIGHT     = 270

    local frame = assets( "assets/icon-overlay-white-no-label.png" )
    
    local focus = assets( "assets/icon-overlay-black-no-label.png" )
    
    local icon = Image{ src = icon_url , async = true , size = { ICON_WIDTH , ICON_HEIGHT } }
    
    local scale = ( frame.w - ( FRAME_X_PADDING * 2 ) - ( FRAME_BORDER_W * 2 ) ) / 480
    
    local inner = Group
    {
        size = frame.size ,
        
        children =
        {
            icon:set
            {
                anchor_point = { ICON_WIDTH / 2 , ICON_HEIGHT / 2 },
                x = frame.center[ 1 ],
                y = frame.center[ 2 ] - FRAME_BOTTOM,
                scale = { scale , scale }
            },
            
            frame ,
            
            focus:set{ opacity = 0 }
        }
    }
    
    local group = Group
    {
        anchor_point = frame.center,
        
        children =
        {
            Clone
            {
                source = inner,
                x_rotation = { 180 , frame.h , 0 },
                opacity = 0.1 * 255,
                position = { 0 , -6 }
            },
--[[            
            Rectangle
            {
                size = inner.size,
                position = { 0 , inner.h - 6  },
                color = "000000DD"
            },
]]
            inner,            
        }
    }

    function group.extra.on_focus_in()
        focus.opacity = 255
        frame.opacity = 0 
    end
    
    function group.extra.on_focus_out()
        focus.opacity = 0
        frame.opacity = 255 
    end
    
    function group.extra.set_focus_opacity( group , opacity )
        focus.opacity = opacity
        frame.opacity = 255 - opacity
    end
    
    return group

end

-------------------------------------------------------------------------------
-- Makes a star
-------------------------------------------------------------------------------

function factory.make_star( size , percent_filled , empty_color , full_color )

    local function star_path( canvas , center , radius )
        local x = 0
        local y = -radius
        canvas:save()
        canvas:translate( unpack( center ) )
        canvas:move_to( x , y )
        for i = 1 , 5 do
            canvas:rotate( 72 * 3 )
            canvas:line_to( x , y )
        end
        canvas:restore()
    end

    local c = Canvas{ size = { size , size } }
    
    local r = size / 2
    
    c:begin_painting()
    
    if percent_filled == 0 then
        star_path( c , { r , r } , r )
        c:set_source_color( empty_color )
        c:fill()
    elseif percent_filled == 1 then
        star_path( c , { r , r } , r )
        c:set_source_color( full_color )
        c:fill()
    else
        star_path( c , { r , r } , r )
        c:set_source_color( empty_color )
        c:fill()
        c.op = "ATOP"
        c:rectangle( 0 , 0 , size * percent_filled , size )
        c:set_source_color( full_color )
        c:fill()
    end
    
    c:finish_painting()
    
    function c.extra.on_focus_in()
    end
    
    function c.extra.on_focus_out()
    end
    
    return c

end


return factory

