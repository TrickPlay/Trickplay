local factory = {}
function factory.make_dropdown( size , color )

    local BORDER_WIDTH= 3--6
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
		    BORDER_WIDTH + CORNER_RADIUS, POINT_HEIGHT - H_BORDER_WIDTH )
    

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
    local PADDING_X     = 7 -- 7  The focus ring has this much padding around it
    local PADDING_Y     = 7
    local WIDTH         = 330 + ( PADDING_X * 2 )
    local HEIGHT        = 46  + ( PADDING_Y * 2 )
    local BORDER_WIDTH  = 1-- 2
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
    
    text.name = "caption"

    text.reactive = true

    local ring = assets( "menu-item-ring" , make_ring )
    
    local focus = assets( "assets/button-focus.png" )

    local group = Group
    {
        size = { WIDTH , HEIGHT },
        children =
        {
            ring:set{ position = { 0 , 0 } },
            focus:set{ position = { 0 , 0 } , size = { WIDTH , HEIGHT } , opacity = 0 },
            text:set{ position = { 30 , 15 } }
        }
    }
    
    function group.extra.on_focus_in()
        focus.opacity = 255
    end
    
    function group.extra.on_focus_out()
        focus.opacity = 0
    end
    
    return group

end

-------------------------------------------------------------------------------
-- Makes a text menu item with two white arrows
-------------------------------------------------------------------------------

function factory.make_text_side_selector( assets , caption )

    local STYLE         = { font = "DejaVu Sans 26px" , color = "FFFFFF" }
    local PADDING_X     = 7 -- The focus ring has this much padding around it
    local PADDING_Y     = 7  
    local WIDTH         = 300 + ( PADDING_X * 2 )
    local HEIGHT        = 46  + ( PADDING_Y * 2 )
    local ARROW_COLOR   = "FFFFFF"
    local ARROW_WIDTH   = HEIGHT / 4
    local ARROW_HEIGHT  = HEIGHT / 3
    
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
    
    local text = Text{ text = caption }:set( STYLE )
    
    local l_arrow = assets( "menu-item-arrow" , make_arrow )
    local r_arrow = assets( "menu-item-arrow" , make_arrow )
    
    l_arrow.anchor_point = l_arrow.center
    r_arrow.anchor_point = r_arrow.center
    
    r_arrow.z_rotation = { 180 , 0 , 0 }
    
    local focus = assets( "assets/button-focus.png" )

    local group = Group
    {
        size = { WIDTH , HEIGHT },
        children =
        {
            l_arrow:set{ position = { PADDING_X + ARROW_WIDTH / 2 , HEIGHT / 2 } },
            r_arrow:set{ position = { WIDTH - PADDING_X - ARROW_WIDTH / 2 , HEIGHT / 2 } },
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
            text:set{ position = { ( WIDTH - text.w ) / 2 , ( HEIGHT - text.h ) / 2 } }
        }
    }
    
    function group.extra.on_focus_in()
        focus.opacity = 255
    end
    
    function group.extra.on_focus_out()
        focus.opacity = 0
    end
    
    return group

end
    
-------------------------------------------------------------------------------
-- Makes an app tile with a polaroid-style frame
-------------------------------------------------------------------------------
    
function factory.make_app_tile( assets , caption , app_id )

    local STYLE         = { font = "DejaVu Sans 24px" , color = "FFFFFF" }
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
        return Image{ src = "assets/generic-app-icon.jpg" }
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


function factory.make_popup_bg(o_type, file_list_size)

    local size, color

   -- Set canvas size and color according to o_type 
    if(o_type == "Text") then 
         size = {500, 870}
    	 color = "472446" -- bora
    elseif(o_type == "Image") then
         size = {500, 770}
    	 color = "5a252b" -- ppat
    elseif(o_type == "Rectangle") then
         size = {500, 755}
    	 color = "2c420c" -- ssuk
    elseif(o_type == "Clone" or o_type == "Group") then
         size = {500, 500}
    	 color = "6d2b17" -- bam
    elseif(o_type == "Video") then
         size = {500, 500}
    	 color = "6d2b17" -- bam
    else 
	 size = {900, file_list_size + 180} 
	 color = "5a252b"
    end 

    local BORDER_WIDTH= 3 
    local POINT_HEIGHT=34
    local POINT_WIDTH=60
    local BORDER_COLOR="FFFFFF"
    local CORNER_RADIUS=22
    local POINT_CORNER_RADIUS=2
    local H_BORDER_WIDTH = BORDER_WIDTH / 2

    local XBOX_SIZE = 25
    local PADDING = 10

    local function draw_path( c )

        c:new_path()

        c:move_to( H_BORDER_WIDTH + CORNER_RADIUS, POINT_HEIGHT - H_BORDER_WIDTH )

        c:line_to( ( c.w )- H_BORDER_WIDTH - CORNER_RADIUS, POINT_HEIGHT - H_BORDER_WIDTH )
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

    c:set_source_color(color) -- "050505")
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

  -- Draw title line
    if(o_type ~= "msgw" ) then 
         c:new_path()
         c:move_to (0, 74)
         c:line_to (c.w, 74)
         c:set_line_width (3)
         c:set_source_color( BORDER_COLOR )
         c:stroke (true)
         c:fill (true)
    end

         c:finish_painting()
         c.position = {0,0}

    return c
end 

function factory.make_msgw_button_item( assets , caption )

    local STYLE         = { font = "DejaVu Sans 30px" , color = "FFFFFF" }
    local PADDING_X     = 7 
    local PADDING_Y     = 7
    local WIDTH         = 180
    local HEIGHT        = 60 
    local BORDER_WIDTH  = 1
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
    
    text.name = "caption"

    text.reactive = true

    local ring = make_ring ()
    
    local focus = assets( "assets/button-focus.png" )

    local group = Group
    {
        size = { WIDTH , HEIGHT },
        children =
        {
            ring:set{ position = { 0 , 0 } },
            focus:set{ position = { 0 , 0 } , size = { WIDTH , HEIGHT } , opacity = 0 },
            text:set{ position = { (WIDTH  -text.w)/2, (HEIGHT - text.h)/2} }
        }
    }
    
    function group.extra.on_focus_in()
        focus.opacity = 255
    end
    
    function group.extra.on_focus_out()
        focus.opacity = 0
    end
    
    return group

end

function factory.make_xbox()
    local BORDER_WIDTH= 3 
    local BORDER_COLOR="FFFFFF5C"

    local XBOX_SIZE = 25
    local PADDING = 10

    local c = Canvas{ size = {XBOX_SIZE + PADDING, XBOX_SIZE + PADDING} }

    c:begin_painting()
    c:new_path()

  -- Draw x button
    local x=0 
    local y=0

    c:move_to ( x, y)
    c:line_to ( x + XBOX_SIZE, y + XBOX_SIZE)
    c:move_to ( x + XBOX_SIZE, y)
    c:line_to ( x, y + XBOX_SIZE)

  -- Draw x button box
    c:move_to ( x, y)
    c:line_to ( x + XBOX_SIZE, y)
    c:move_to ( x + XBOX_SIZE, y)
    c:line_to ( x + XBOX_SIZE, y + XBOX_SIZE)
    c:move_to ( x + XBOX_SIZE, y + XBOX_SIZE)
    c:line_to ( x, y + XBOX_SIZE)
    c:move_to ( x, y + XBOX_SIZE)
    c:line_to ( x, y)

    c:set_line_width (3)
    c:set_source_color( BORDER_COLOR )
    c:stroke (true)
    c:fill (true)

    c:finish_painting()

    return c
end 

function factory.draw_focus_ring(w, h)
        local ring = Canvas{ size = {w, h} }
        ring:begin_painting()
        ring:set_source_color("1b911b")
        ring:round_rectangle(
            PADDING_X + BORDER_WIDTH /2,
            PADDING_Y + BORDER_WIDTH /2,
            w - BORDER_WIDTH - PADDING_X * 2 ,
            h - BORDER_WIDTH - PADDING_Y * 2 ,
            BORDER_RADIUS )
    	ring:set_line_width (4)
        ring:stroke()
        ring:finish_painting()
        return ring
end


function factory.draw_ring()
	local ring = Canvas{ size = {650, 60} }
        ring:begin_painting()
        ring:set_source_color( "1b911b" )
        ring:round_rectangle( 7 + 1/2, 7 + 1/2, 635, 45, 12)
    	ring:set_line_width (4)
        ring:stroke()
        ring:finish_painting()
        return ring
end

function factory.draw_line()
    local PADDING_Y     = 7   
    local WIDTH         = 900
    local LINE_WIDTH    = 5
	local LINE_COLOR    = "FFFFFF"


	local line = Canvas{ size = {WIDTH, LINE_WIDTH + PADDING_Y} }
        line:begin_painting()
        line:new_path()
        line:move_to (0,0)
        line:line_to (WIDTH, 0)
    	line:set_line_width (LINE_WIDTH)
        line:set_source_color(LINE_COLOR)
    	line:stroke (true)
    	line:fill (true)
        line:finish_painting()
        return line
end 

function factory.make_text_popup_item(assets, inspector, v, item_n, item_v, item_s) 
    local STYLE = {font = "DejaVu Sans 26px" , color = "FFFFFF" }
    local TEXT_SIZE     = 26
    local PADDING_X     = 7
    local PADDING_Y     = 7   
    local PADDING_B     = 15 
    local WIDTH         = 450
    local HEIGHT        = TEXT_SIZE  + ( PADDING_Y * 2 )
    local BORDER_WIDTH  = 1
    local BORDER_COLOR  = "FFFFFF"
    local LINE_COLOR    = "FFFFFF"
    local BORDER_RADIUS = 12
    local LINE_WIDTH    = 1

    local input_box_width     
 
    local function make_focus_ring(w, h)
        local ring = Canvas{ size = {w, h} }
        ring:begin_painting()
        ring:set_source_color("1b911b")
        ring:round_rectangle(
            PADDING_X + BORDER_WIDTH /2,
            PADDING_Y + BORDER_WIDTH /2,
            w - BORDER_WIDTH - PADDING_X * 2 ,
            h - BORDER_WIDTH - PADDING_Y * 2 ,
            BORDER_RADIUS )
    	ring:set_line_width (4)
        ring:stroke()
        ring:finish_painting()
        return ring
    end

    local function make_ring(w, h)
	local ring = Canvas{ size = {w, h} }
        ring:begin_painting()
        ring:set_source_color( BORDER_COLOR )
        ring:round_rectangle(
            PADDING_X + BORDER_WIDTH /2,
            PADDING_Y + BORDER_WIDTH /2,
            w - BORDER_WIDTH - PADDING_X * 2 ,
            h - BORDER_WIDTH - PADDING_Y * 2 ,
            BORDER_RADIUS )
        ring:stroke()
        ring:finish_painting()
        return ring
    end

    local function make_line()
	local line = Canvas{ size = {WIDTH, LINE_WIDTH + PADDING_Y} }
        line:begin_painting()
        line:new_path()
        line:move_to (0,0)
        line:line_to (WIDTH, 0)
    	line:set_line_width (LINE_WIDTH)
        line:set_source_color(LINE_COLOR)
    	line:stroke (true)
    	line:fill (true)
        line:finish_painting()
        return line
    end 

    local group = Group {}
    local text, input_text, ring, focus, line, button

    if(item_n == "title" or item_n == "caption") then
    	text = Text {text = item_v}:set(STYLE)
	text.position = {PADDING_X, 0}
    	group:add(text)
        group.size = {WIDTH, HEIGHT}
    elseif (item_n =="line") then 
        line = make_line()
	group:add(line)
        group.size = {WIDTH, LINE_WIDTH + PADDING_Y}
    elseif (item_n == "button") then 
	group.name = item_v
	group.reactive = true

	if(item_v == "view code") then 
	     button = make_ring(WIDTH, HEIGHT + PADDING_Y)
	else 
	     button = make_ring(WIDTH/2 - 3, HEIGHT + PADDING_Y)
	end 
	button.name = "button"
        button.position  = {0, 0}
        button.reactive = true

	function button:on_key_down(key)
             if key == keys.Return then
                  if (item_v == "view code") then 
		      screen:remove(inspector)
		      current_inspector = nil
		      editor.n_selected(v)
                      screen.grab_key_focus(screen) 
		      -- org_obj, new_obj = inspector_apply (v, inspector) 
		      editor.view_code()
	              return true
		  elseif (item_v == "apply") then 
		      org_obj, new_obj = inspector_apply (v, inspector) 
		      screen:remove(inspector)
		      current_inspector = nil
		      editor.n_selected(v)
                      screen.grab_key_focus(screen) 
	              return true
		  elseif (item_v == "cancel") then 
		      screen:remove(inspector)
		      current_inspector = nil
		      editor.n_selected(v)
                      screen.grab_key_focus(screen) 
	              return true
		  end 
 	     elseif (key == keys.Tab and shift == false) or key == keys.Down then 
                  group.extra.on_focus_out()
		  for i, v in pairs(attr_t_idx) do
			if(item_n == v or item_v == v) then 
			     while(inspector:find_child(attr_t_idx[i+1]) == nil) do 
				 i = i + 1
			     end 
			     if(inspector:find_child(attr_t_idx[i+1])) then
			     	local n_item = attr_t_idx[i+1]
				inspector:find_child(n_item).extra.on_focus_in()	
				break
			     end
			end 
    		  end
		  return true
	     elseif key == keys.Up or 
		    (key == keys.Tab and shift == true )then 
		  group.extra.on_focus_out()
		  for i, v in pairs(attr_t_idx) do
			if(item_n == v or item_v == v) then 
			     while(inspector:find_child(attr_t_idx[i-1]) == nil) do 
				 i = i - 1
			     end 
			     if(inspector:find_child(attr_t_idx[i-1])) then
			     	local p_item = attr_t_idx[i-1]
				inspector:find_child(p_item).extra.on_focus_in()	
				break
			     end
			end 
    		  end
		  return true
            end
        end

	function button:on_button_down ()
 	     current_focus.extra.on_focus_out()
	     current_focus = group
	     group.extra.on_focus_in()
	     if (item_v == "view code") then 
		      screen:remove(inspector)
		      current_inspector = nil
		      editor.n_selected(v)
                      screen.grab_key_focus(screen) 
		      -- org_obj, new_obj = inspector_apply (v, inspector) 
		      editor.view_code()
	     elseif (item_v == "apply") then 
		      org_obj, new_obj = inspector_apply (v, inspector) 
		      screen:remove(inspector)
		      current_inspector = nil
		      editor.n_selected(v)
                      screen.grab_key_focus(screen) 
	     elseif (item_v == "cancel") then 
		      screen:remove(inspector)
		      current_inspector = nil
		      editor.n_selected(v)
                      screen.grab_key_focus(screen) 
	     end 

             return true;
	end 
    	group:add(button)

	local focus = assets( "assets/button-focus.png" )
        focus.name = "focus"
        focus:set{ position = { 0 , 0 } , size = { group.w , group.h } , opacity = 0 }
        group:add(focus)

    	text = Text {text = string.upper(item_v)}:set(STYLE)
        text.position  = {(button.w - text.w)/2, (button.h - text.h)/2}
    	group:add(text)

    	--next_text = Text {name = "next_attr", text = n_item_n, opacity = 0}:set(STYLE)
    	--group:add(next_text)


        function group.extra.on_focus_in()
             current_focus = group
	     button:grab_key_focus()
	     button.opacity = 0 
             focus.opacity = 255
        end

        function group.extra.on_focus_out()
             focus.opacity = 0
	     button.opacity = 255 
        end

    else 
	group.name = item_n
	group.reactive = true

        local space = WIDTH - PADDING_X  

        if(item_n == "name" or item_n == "text" or item_n == "src") then 
	     input_box_width = WIDTH - ( PADDING_X * 2) 
	else 
    	     text = Text {name = "attr", text = string.upper(item_s)}:set(STYLE)
             text.position  = {WIDTH - space , 0}
    	     group:add(text)

	     input_box_width = WIDTH/4 - 10 + ( PADDING_X * 2) 
	     space = space - string.len(item_s) * 20
             if (item_n =="font" or item_n == "color") then 
	          input_box_width = WIDTH - 100 - ( PADDING_X * 2) 
	     elseif (item_n == "base_size") then 
	          input_box_width = WIDTH - 200 - ( PADDING_X * 2) 
             elseif(item_n == "wrap_mode" or item_n == "border_color") then 
	          input_box_width = WIDTH - 250 - ( PADDING_X * 2) 
	     end
        end 
	print("item name ", item_n)
	print ("input_box_width", input_box_width)
        print("space", space)

    	--next_text = Text {name = "next_attr", text = n_item_n, opacity = 0}:set(STYLE)
    	--group:add(next_text)

        ring = make_ring(input_box_width, HEIGHT + 5) 
	ring.name = "ring"
	ring.position = {WIDTH - space , 0}
        ring.opacity = 255
        group:add(ring)

        focus = make_focus_ring(input_box_width, HEIGHT + 5)
        focus.name = "focus"
        focus.position = {WIDTH - space , 0}
        focus.opacity = 0
	group:add(focus)

	space = space - PADDING_B

	if(item_v == "CHAR" or item_v == "WORD" or item_v =="WORD_CHAR") then item_v = string.lower(item_v) end 

    	input_text = Text {name = "input_text", text =item_v, editable=true,
        reactive = true, wants_enter = false, cursor_visible = false}:set(STYLE)

        input_text.position  = {WIDTH - space , PADDING_Y}

	function input_text:on_button_down(x,y,button,num_clicks)
 	       current_focus.extra.on_focus_out()
	       current_focus = group
	       group.extra.on_focus_in()
               return true;
        end



  	function input_text:on_key_down(key)
	       if key == keys.Return or
                  (key == keys.Tab and shift == false) or 
                  key == keys.Down then
	       	     group.extra.on_focus_out()
		     for i, v in pairs(attr_t_idx) do
			if(item_n == v or item_v == v) then 
			     while(inspector:find_child(attr_t_idx[i+1]) == nil) do 
				 i = i + 1
			     end 
			     if(inspector:find_child(attr_t_idx[i+1])) then
			     	local n_item = attr_t_idx[i+1]
				inspector:find_child(n_item).extra.on_focus_in()	
				break
			     end
			end 
    		     end
	       elseif key == keys.Up or 
		      (key == keys.Tab and shift == true )then 
		    group.extra.on_focus_out()
 		    for i, v in pairs(attr_t_idx) do
			if(item_n == v or item_v == v) then 
			     while(inspector:find_child(attr_t_idx[i-1]) == nil) do 
				 i = i - 1
			     end 
			     if(inspector:find_child(attr_t_idx[i-1])) then
			     	local p_item = attr_t_idx[i-1]
				inspector:find_child(p_item).extra.on_focus_in()	
				break
			     end
			end 
    		    end
               end
   	end 

	
    	group:add(input_text)

        function group.extra.on_focus_in()
	     current_focus = group
             ring.opacity = 0
             input_text.cursor_visible = true
             focus.opacity = 255
	     input_text:grab_key_focus()
        end

        function group.extra.on_focus_out()
             focus.opacity = 0
             input_text.cursor_visible = false
             ring.opacity = 255
        end 
    end
    print ("group width", group.w)
    return group
end
 
return factory
