local factory = {}

function factory.make_dropdown( size , color )

    local BORDER_WIDTH= 3
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
    c:set_source_radial_pattern( 90 , 210 , 0 , 0 , 60 , c.w / 2 )
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
    
    if c.Image then
       c= c:Image()
    end

    return c
    
end

---------------------------------------------------------------------------
-- Makes a menu item with a white ring around it
---------------------------------------------------------------------------

local icon_map = 
{
	["LEFT SIDE      "] = function() icon = icon_l return icon end, 
        ["RIGHT SIDE    "] = function() icon = icon_r return icon end, 
        ["TOP             "] = function() icon = icon_t return icon end, 
        ["BOTTOM        "] = function() icon = icon_b return icon end, 
        ["HORIZ. CENTER   "] = function() icon = icon_hc return icon end, 
        ["VERT. CENTER    "] = function() icon = icon_vc return icon end, 
        ["HORIZONTALLY	  "] = function() icon = icon_dhc return icon end,  
        ["VERTICALLY 	  "] = function() icon = icon_dvc return icon end 
}

local item_map = 
{
        ["UNDO".."\t\t\t".."[U]"]   = function()  return "undo" end,
     	["REDO".."\t\t\t".."[E]"]   = function()  return "redo" end,
     	["CLONE".."\t\t\t".."[C]"]   = function() return "clone" end,
     	["DELETE".."\t\t     ".."[Del]"]   = function() return "delete" end,
     	["GROUP".."\t\t\t".."[G]"]   = function() return "group" end,
     	["UNGROUP".."\t\t\t"..""]   = function() return "ungroup" end,
	["LEFT SIDE      "] = function() return "left" end, 
        ["RIGHT SIDE    "] = function() return "right" end, 
        ["TOP             "] = function() return "top" end, 
        ["BOTTOM        "] = function() return "bottom" end, 
        ["HORIZ. CENTER   "] = function() return "hcenter" end, 
        ["VERT. CENTER    "] = function() return "vcenter" end, 
        ["HORIZONTALLY	  "] = function() return "hspace" end,  
        ["VERTICALLY 	  "] = function() return "vspace" end,
	["BRING TO FRONT"] = function() return "bring_front" end,
        ["BRING FORWARD "] = function() return "bring_forward" end,
        ["SEND TO BACK "] = function() return "send_back" end,
        ["SEND BACKWARD "] = function() return "send_backward"end,
	["Background Image        "] = function() return "bgimage" end
}

   
function factory.make_text_menu_item( assets , caption )

    local STYLE         = { font = "DejaVu Sans 26px" , color = "FFFFFF" }
    local PADDING_X     = 7 -- The focus ring has this much padding around it
    local PADDING_Y     = 7
    local WIDTH         = 330 + ( PADDING_X * 2 )
    local HEIGHT        = 46  + ( PADDING_Y * 2 )
    local BORDER_WIDTH  = 1
    local BORDER_COLOR  = "FFFFFF"
    local BORDER_RADIUS = 12
    local ITEM_SPACE = "\t\t\t"
    
    local group = Group{}

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
    	if ring.Image then
       		ring= ring:Image()
    	end
        return ring
    end

    local function make_line()
    	local LINE_WIDTH    =7 
    	local LINE_COLOR    = "FFFFFF5C"
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
    	if line.Image then
       		line= line:Image()
    	end
        return line
    end 
    local icon 

    if(icon_map[caption]) then icon = icon_map[caption]() end 

    local text = Text{ text = caption }:set( STYLE )
    text.name = "caption"
    text.reactive = true
    local ring = assets( "menu-item-ring" , make_ring )
    local focus = assets( "assets/button-focus.png" )
    local text_category, line_category
    
    if (caption == "TEXT"..ITEM_SPACE.."[T]") then 
	text_category = Text{ text = "INSERT : "}:set(STYLE)
    elseif (caption == "LEFT SIDE      ") then
	text_category = Text{ text = "ALIGN : "}:set(STYLE)
    elseif (caption == "HORIZONTALLY	  ") then
	text_category = Text{ text = "DISTRIBUTE : "}:set(STYLE)
    elseif (caption ==  "BRING TO FRONT" ) then 
	text_category = Text{ text = "ARRANGE : "}:set(STYLE)
    elseif ( caption == "DELETE".."\t\t     ".."[Del]") then
	line_category = make_line()
    end 
        
    if text_category ~= nil then 
        text_category.reactive = false
	if(icon ~= nil) then 
	group = Group
    	{
        	size = { WIDTH , HEIGHT + text_category.h + PADDING_Y },
        	children =
        	{
		icon:set{position = {280, text_category.h + PADDING_Y + 15}, scale = {0.75, 0.75}},
	    	text_category:set{position = {5, 6}},
            	ring:set{ position = { 0 , text_category.h + PADDING_Y } },
            	focus:set{ position = { 0 , text_category.h + PADDING_Y } , size = { WIDTH , HEIGHT } , opacity = 0 },
            	text:set{ position = { 30 , text_category.h + PADDING_Y + 15 } }
        	}
    	}  
	else 
	group = Group
    	{
        	size = { WIDTH , HEIGHT + text_category.h + PADDING_Y },
        	children =
        	{
	    	text_category:set{position = {5, 6}},
            	ring:set{ position = { 0 , text_category.h + PADDING_Y } },
            	focus:set{ position = { 0 , text_category.h + PADDING_Y } , size = { WIDTH , HEIGHT } , opacity = 0 },
            	text:set{ position = { 30 , text_category.h + PADDING_Y + 15 } }
        	}
    	} 
	end 
    elseif line_category  ~= nil then 
	group = Group
    	{
        	size = { WIDTH , HEIGHT + line_category.h },
        	children =
        	{
		line_category:set{ position = {0,PADDING_Y } }, 
            	ring:set{ position = { 0 , PADDING_Y *2 } },
            	focus:set{ position = { 0 , PADDING_Y *2 } , size = { WIDTH , HEIGHT} , opacity = 0 },
            	text:set{ position = { 30 , PADDING_Y *2 + 15 } }
        	}
    	}
    elseif( icon == nil ) then  
 	group = Group
    	{
        	size = { WIDTH , HEIGHT },
        	children =
        	{
            	ring:set{ position = { 0 , 0} },
            	focus:set{ position = { 0 , 0} , size = { WIDTH , HEIGHT } , opacity = 0 },
            	text:set{ position = { 30 , 15 } }
        	}
    	}
    else
 	group = Group
    	{
        	size = { WIDTH , HEIGHT },
        	children =
        	{
		icon:set{position = {280, 15 }, scale = {0.75, 0.75}},
            	ring:set{ position = { 0 , 0} },
            	focus:set{ position = { 0 , 0} , size = { WIDTH , HEIGHT } , opacity = 0 },
            	text:set{ position = { 30 , 15 } }
        	}
    	}
    end 

    function group.extra.on_focus_in()
         focus.opacity = 255
    end
    
    function group.extra.on_focus_out()
    	 focus.opacity = 0
    end
    
    if(item_map[caption]) then 
         group.name = item_map[caption]()
    end 
    return group
	
end

-------------------------------------------------------------------------------
-- Makes a text menu item with out a ring around it 
-------------------------------------------------------------------------------

function factory.make_text_menu ( assets , caption )

    local STYLE         = { font = "DejaVu Sans 26px" , color = "FFFFFF" }
    local PADDING_X     = 7 -- 7  The focus ring has this much padding around it
    local PADDING_Y     = 7
    local WIDTH         = 330 + ( PADDING_X * 2 )
    local HEIGHT        = 46  + ( PADDING_Y * 2 )
    local BORDER_WIDTH  = 1-- 2
    local BORDER_COLOR  = "FFFFFF"
    local BORDER_RADIUS = 12
      
    local text = Text{ text = caption }:set( STYLE )
    
    text.name = "caption"

    text.reactive = false 

    local group = Group
    {
        size = { WIDTH , HEIGHT },
        children =
        {
            text:set{ position = { 30 , 15 } }
        }
    }
        
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
	if arrow.Image then
  	 arrow= arrow:Image()
        end

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

local code_map =
{
        [ "Text" ] = function()  size = {800, 800} color =  {0, 25, 25, 255} return size, color end,
        [ "Image" ] = function()  size = {800, 550} color =  {0, 25, 25, 255}  return size, color end,
        [ "Rectangle" ] = function()  size = {800, 650} color =  {0, 25, 25, 255} return size, color end,
        [ "Clone" ] = function()  size = {800, 600} color =  {0, 25, 25, 255} return size, color end,
        [ "Group" ] = function()  size = {800, 510} color =  {0, 25, 25, 255} return size, color end,
	[ "Video" ] =  function()  size = {1500, 860} color =  {0, 25, 25, 255} return size, color end,
	[ "Widget" ] =  function()  size = {800, 800} color =  {0, 25, 25, 255} return size, color end,
}

local color_map =
{
        [ "Text" ] = function()  size = {530, 680} color = {25,25,25,100}  return size, color end,
        [ "Image" ] = function()  size = {530, 680} color ={25,25,25,100}  return size, color end,
        [ "Rectangle" ] = function()  size = {530, 680} color = {25,25,25,100}   return size, color end,
        [ "Clone" ] = function()  size = {530, 680} color = {25,25,25,100}   return size, color end,
        [ "Group" ] = function()  size = {530, 680} color = {25,25,25,100}   return size, color end,
        [ "Video" ] = function()  size = {500, 525} color = {25,25,25,100}   return size, color end,

        [ "Button" ] = function()  size = {530, 680} color = {25,25,25,100}  return size, color end,
        [ "TextInputField" ] = function()  size = {530, 680} color = {25,25,25,100}  return size, color end,
        [ "DialogBox" ] = function()  size = {530, 680} color = {25,25,25,100}  return size, color end,
        [ "ToastBox" ] = function()  size = {530, 680} color = {25,25,25,100}  return size, color end,
        [ "RadioButton" ] = function()  size = {530, 680} color = {25,25,25,100}  return size, color end,
        [ "CheckBox" ] = function()  size = {530, 680} color = {25,25,25,100}  return size, color end,
        [ "ButtonPicker" ] = function()  size = {530, 680} color = {25,25,25,100}  return size, color end,
        [ "LoadingDots" ] = function()  size = {530, 680} color = {25,25,25,100}  return size, color end,
        [ "LoadingBar" ] = function()  size = {530, 680} color = {25,25,25,100}  return size, color end,
        [ "MenuBar" ] = function()  size = {530, 680} color = {25,25,25,100}  return size, color end,
        [ "3D_List" ] = function()  size = {530, 680} color = {25,25,25,100}  return size, color end,
        [ "ScrollImage" ] = function()  size = {530, 680} color = {25,25,25,100}  return size, color end,
        [ "TabBar" ] = function()  size = {530, 680} color = {25,25,25,100}  return size, color end,
        [ "OSK" ] = function()  size = {530, 680} color = {25,25,25,100}  return size, color end,

        [ "widgets" ] = function() size = {500, 600} color = {25,25,25,100}  return size, color end,
        [ "Code" ] = function(file_list_size)  code_map[file_list_size]() return size, color end,
        [ "guidew" ] = function()  color =  {25,25,25,100} size = {700, 230} return size, color end,
        [ "msgw" ] = function(file_list_size) size = {900, file_list_size + 180} color = {25,25,25,100}  return size, color end,
        [ "file_ls" ] = function(file_list_size) size = {800, file_list_size + 180} color = {25,25,25,100}  return size, color end
}

-------------------------------------------------------------------------------
-- Makes a popup window background 
-------------------------------------------------------------------------------

function factory.make_popup_bg(o_type, file_list_size)

    local size, color = color_map[o_type](file_list_size)
    
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
    if(o_type ~= "msgw" and o_type ~= "Code") then 
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

    if c.Image then
  	 c= c:Image()
    end
    return c
end 


-------------------------------------------------------------------------------
-- Makes a messsage window button item 
-------------------------------------------------------------------------------

function factory.make_msgw_button_item( assets , caption)

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
        if ring.Image then
  	    ring= ring:Image()
    	end
        return ring
    end
    
    local text = Text{ text = caption }:set( STYLE )
    
    text.name = "caption"

    text.reactive = true

    local ring = make_ring ()
    
    local focus = assets( "assets/button-focus.png" )


    if ring.Image then
  	 ring= ring:Image()
    end

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
	group:grab_key_focus(group)
	--print (caption, "button group grab key focus")
    end
    
    function group.extra.on_focus_out()
        focus.opacity = 0
    end
	
--group.name = name -- (savefile, cancel, yes, no, openfile, reopenfile, open_imagefile, reopenImg, open_videofile)

    return group, text

end

function factory.make_msgw_widget_item( assets , caption)

    local STYLE         = { font = "DejaVu Sans 30px" , color = "FFFFFF" }
    local PADDING_X     = 7 
    local PADDING_Y     = 7
    local WIDTH         = 230
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
	if ring.Image then
  	 ring= ring:Image()
        end

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
	group:grab_key_focus(group)
	--print (caption, "button group grab key focus")
    end
    
    function group.extra.on_focus_out()
        focus.opacity = 0
    end
	
--group.name = name -- (savefile, cancel, yes, no, openfile, reopenfile, open_imagefile, reopenImg, open_videofile)

    return group, text

end


-------------------------------------------------------------------------------
-- Makes a scroll bar item
-------------------------------------------------------------------------------


function factory.make_y_scroll_box()
    local PADDING_X     = 5 --7
    local PADDING_Y     = 5 --7
    local WIDTH         = 50
    local HEIGHT        = screen.h - 90 - 70 -- 90 is the menu bar height  
    local BORDER_WIDTH  = 1
    local BORDER_COLOR  = "FFFFFF"
    local BORDER_RADIUS = 1
    
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
	if ring.Image then
  	 ring= ring:Image()
        end

        return ring
    end
    ring = make_ring ()

    ring.name = "scroll_box"
    return ring
end


function factory.make_x_scroll_box()
    local PADDING_X     = 5 
    local PADDING_Y     = 5
    local WIDTH         = screen.w - 70 
    local HEIGHT        = 50
    local BORDER_WIDTH  = 1
    local BORDER_COLOR  = "FFFFFF"
    local BORDER_RADIUS = 1
    
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
	if ring.Image then
  	 ring= ring:Image()
        end
        return ring
    end
    ring = make_ring ()
    ring.name = "xscroll_box"
    return ring
end


function factory.make_msgw_scroll_box()

    local PADDING_X     = 7 
    local PADDING_Y     = 7
    local WIDTH         = 50
    local HEIGHT        = 500 
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
	if ring.Image then
  	 ring= ring:Image()
        end
        return ring
    end
    ring = make_ring ()
    return ring
end

function factory.make_x_scroll_bar(canvas_sz)

    local PADDING_X     = 5 
    local PADDING_Y     = 5
    local WIDTH         = screen.w - 70 
    local HEIGHT        = 50 
    local S_HEIGHT      = 42
    local BORDER_WIDTH  = 1
    local BORDER_COLOR  = "FFFFFF"
    local BORDER_RADIUS = 12

    local S_WIDTH       = WIDTH / (canvas_sz/screen.w)
    
    local function make_scroll_bar()
        local ring = Canvas{ size = { S_WIDTH , S_HEIGHT } }
        ring:begin_painting()
        ring:set_source_color( BORDER_COLOR )
        ring:round_rectangle(
            PADDING_X + BORDER_WIDTH / 2,
            PADDING_Y + BORDER_WIDTH / 2,
            S_WIDTH - BORDER_WIDTH - PADDING_X * 2 ,
            S_HEIGHT - BORDER_WIDTH - PADDING_Y * 2 ,
            BORDER_RADIUS )
	ring:fill()
        ring:finish_painting()
	if ring.Image then
  	 ring= ring:Image()
        end
        return ring
    end

    local scroll_bar = make_scroll_bar ()
    
    scroll_bar.name = "xscroll_bar"
    scroll_bar.reactive = true 
    
    return scroll_bar
end

function factory.make_y_scroll_bar(canvas_sz)

    local PADDING_X     = 5 
    local PADDING_Y     = 5
    local WIDTH         = 50
    local SCROLL_Y_POS  = 90
    local HEIGHT        = screen.h - SCROLL_Y_POS -70
    local S_WIDTH       = 42
    local BORDER_WIDTH  = 1
    local BORDER_COLOR  = "FFFFFF"
    local BORDER_RADIUS = 12
    
    local S_HEIGHT = HEIGHT / (canvas_sz/screen.h)

    local function make_scroll_bar()
        local ring = Canvas{ size = { S_WIDTH , S_HEIGHT } }
        ring:begin_painting()
        ring:set_source_color( BORDER_COLOR )
        ring:round_rectangle(
            PADDING_X + BORDER_WIDTH / 2,
            PADDING_Y + BORDER_WIDTH / 2,
            S_WIDTH - BORDER_WIDTH - PADDING_X * 2 ,
            S_HEIGHT - BORDER_WIDTH - PADDING_Y * 2 ,
            BORDER_RADIUS )
	ring:fill()
        ring:finish_painting()
	if ring.Image then
  	 ring= ring:Image()
        end
        return ring
    end

    local scroll_bar = make_scroll_bar ()
    
    scroll_bar.name = "scroll_bar"
    scroll_bar.reactive = true 
    
    return scroll_bar
end

function factory.make_msgw_scroll_bar(file_list_size)

    local PADDING_X     = 7 
    local PADDING_Y     = 7
    local WIDTH         = 50
    local HEIGHT        = 500 
    local S_HEIGHT      = 2*HEIGHT - file_list_size 
    local S_WIDTH       = 42
    local BORDER_WIDTH  = 1
    local BORDER_COLOR  = "FFFFFF"
    local BORDER_RADIUS = 12
    
    local function make_scroll_bar()
        local ring = Canvas{ size = { S_WIDTH , S_HEIGHT } }
        ring:begin_painting()
        ring:set_source_color( BORDER_COLOR )
        ring:round_rectangle(
            PADDING_X + BORDER_WIDTH / 2,
            PADDING_Y + BORDER_WIDTH / 2,
            S_WIDTH - BORDER_WIDTH - PADDING_X * 2 ,
            S_HEIGHT - BORDER_WIDTH - PADDING_Y * 2 ,
            BORDER_RADIUS )
	ring:fill()
        ring:finish_painting()
	if ring.Image then
  	 ring= ring:Image()
        end
        return ring
    end

    local scroll_bar = make_scroll_bar ()
    
    scroll_bar.name = "scroll_bar"
    scroll_bar.reactive = true 
    
    function scroll_bar:on_button_down(x,y,button,num_clicks)
	dragging = {scroll_bar, x- scroll_bar.x, y - scroll_bar.y }
        return true
    end 

    function scroll_bar:on_button_up(x,y,button,num_clicks)
	 if(dragging ~= nil) then 
	      local actor , dx , dy = unpack( dragging )
	      if (actor.extra.h_y < y-dy and y-dy < actor.extra.l_y) then 	
	           scroll_bar.y = y - dy 
	      end 
	      dragging = nil
	 end 
         return true
    end 

    return scroll_bar
end


-------------------------------------------------------------------------------
-- Makes an x(close) box
-------------------------------------------------------------------------------

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

    if c.Image then
  	 c= c:Image()
    end
    return c
end 

-------------------------------------------------------------------------------
-- Makes a focus(green) ring 
-------------------------------------------------------------------------------
function factory.draw_focus_ring()
        local ring = Canvas{ size = {650, 60} }
        ring:begin_painting()
        ring:set_source_color("1b911b")
        ring:round_rectangle( 7 + 1/2, 7 + 1/2, 635, 45, 12)
    	ring:set_line_width (4)
        ring:stroke()
        ring:finish_painting()
	if ring.Image then
  	 ring= ring:Image()
        end

        return ring
end

function factory.draw_small_focus_ring()
        local ring = Canvas{ size = {375, 60} }
        ring:begin_painting()
        ring:set_source_color("1b911b")
        ring:round_rectangle( 7 + 1/2, 7 + 1/2, 365, 45, 12)
    	ring:set_line_width (4)
        ring:stroke()
        ring:finish_painting()
	if ring.Image then
  	 ring= ring:Image()
        end
        return ring
end

--[[
	round_rectangle ( 
        PADDING_X + BORDER_WIDTH /2,
        PADDING_Y + BORDER_WIDTH /2,
        w - BORDER_WIDTH - PADDING_X * 2 ,
        h - BORDER_WIDTH - PADDING_Y * 2 ,
        BORDER_RADIUS )
]]--

function factory.draw_tiny_focus_ring()
        local ring = Canvas{ size = {150, 50} }
        ring:begin_painting()
        ring:set_source_color("1b911b")
        ring:round_rectangle( 4, 4, 142, 42, 12)
    	ring:set_line_width (4)
        ring:stroke()
        ring:finish_painting()
	if ring.Image then
  	 ring= ring:Image()
        end
        return ring
end

-------------------------------------------------------------------------------
-- Makes a focus(white, input) ring 
-------------------------------------------------------------------------------
function factory.draw_ring()
	local ring = Canvas{ size = {650, 60} }
        ring:begin_painting()
        ring:set_source_color( "FFFFFFC0" )
        ring:round_rectangle( 7 + 1/2, 7 + 1/2, 635, 45, 12)
    	ring:set_line_width (4)
        ring:stroke()
        ring:finish_painting()
	if ring.Image then
  	 ring= ring:Image()
        end
        return ring
end

function factory.draw_small_ring()
	local ring = Canvas{ size = {375, 60} }
        ring:begin_painting()
        ring:set_source_color( "FFFFFFC0" )
        ring:round_rectangle( 7 + 1/2, 7 + 1/2, 365, 45, 12)
    	ring:set_line_width (4)
        ring:stroke()
        ring:finish_painting()
	if ring.Image then
  	 ring= ring:Image()
        end
        return ring
end


function factory.draw_tiny_ring()
	local ring = Canvas{ size = {150, 50} }
        ring:begin_painting()
        ring:set_source_color( "FFFFFFC0" )
        ring:round_rectangle( 4, 4, 142, 42, 12 )
    	ring:set_line_width (4)
        ring:stroke()
        ring:finish_painting()
	if ring.Image then
  	 ring= ring:Image()
        end
        return ring
end

-------------------------------------------------------------------------------
-- Makes a line for categorizing menu items 
-------------------------------------------------------------------------------
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
	if line.Image then
  	 line= line:Image()
        end
        return line
end 


-------------------------------------------------------------------------------
-- Makes a popup window contents (attribute name, input text, input button)
-------------------------------------------------------------------------------
function factory.make_text_popup_item(assets, inspector, v, item_n, item_v, item_s) 
    local STYLE = {font = "DejaVu Sans 26px" , color = "FFFFFF" }
    local TEXT_SIZE     = 26
    local PADDING_X     = 7
    local PADDING_Y     = 7   
    local PADDING_B     = 15 
    local WIDTH         = 450
    local HEIGHT        = TEXT_SIZE  + ( PADDING_Y * 2 )
    local BORDER_WIDTH  = 1
    local BORDER_COLOR  = {255,255,255,255}
    local FOCUS_COLOR  = {0,255,0,255}
    local LINE_COLOR    = {255,255,255,255}  --"FFFFFF"
    local BORDER_RADIUS = 12
    local LINE_WIDTH    = 1
    local input_box_width     
    local item_group 
 
    local function text_reactive()
	for i, c in pairs(g.children) do
	     if(c.type == "Text") then 
	          c.reactive = true
	     end 
        end
    end 

    local function make_focus_ring(w, h)
        local ring = Canvas{ size = {w, h} }
        ring:begin_painting()
        ring:set_source_color( FOCUS_COLOR )
        ring:round_rectangle(
            PADDING_X + BORDER_WIDTH /2,
            PADDING_Y + BORDER_WIDTH /2,
            w - BORDER_WIDTH - PADDING_X * 2 ,
            h - BORDER_WIDTH - PADDING_Y * 2 ,
            BORDER_RADIUS )
    	--ring:set_line_width (4)
        ring:stroke()
        ring:finish_painting()
	if ring.Image then
  	 ring= ring:Image()
        end

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
	if ring.Image then
  	 ring= ring:Image()
        end
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
	if line.Image then
  	 line= line:Image()
        end
        return line
    end 

    -- item group 
    local group = Group {}
    group:clear()
    	
    -- item group's children 
    local text, input_text, ring, focus, line, button

    if(item_n == "title")then 
    	text = Text {text = item_v}:set(STYLE)
	text.position = {WIDTH/2 - text.w/2, 8} 
    	group:add(text)
    elseif(item_n == "caption") then
    	text = Text {text = item_v}:set(STYLE)
	text.position = {PADDING_X, 0}
    	group:add(text)
        group.size = {WIDTH, HEIGHT - PADDING_Y}
--[[
	if(item_v == "Scale") then 
             group.size = {WIDTH/4, HEIGHT}
	else
             group.size = {WIDTH, HEIGHT - PADDING_Y}
	end 
]]
    elseif (item_n =="line") then 
        line = make_line()
	if(item_s =="hide") then 
		line.opacity = 0 
        end 
	group:add(line)
        group.size = {WIDTH, LINE_WIDTH + PADDING_Y}
    elseif (item_n == "button") then 
	group.name = item_v
	group.reactive = true

	if v.extra then 
	   if is_in_list(v.extra.type, widgets) == true  then
		WIDTH = WIDTH + 33
	   end 
	end
		
	if(item_v == "view code") then 
	     button = make_ring(WIDTH, HEIGHT + PADDING_Y)
	else 
	     button = make_ring(WIDTH/2 - 3, HEIGHT + PADDING_Y)
	end 
	button.name = "button"
        button.position  = {0, 0}
        button.reactive = true

	function button:on_key_down(key)
             local si = inspector:find_child("si")

    	     if is_this_widget(v) == true  then
                item_group = (inspector:find_child("si")).content
             else 
         	item_group = inspector:find_child("item_group")
    	     end 
             if key == keys.Return then
                  if (item_v == "view code") then 
		      screen:remove(inspector)
		      input_mode = S_SELECT
		      current_inspector = nil
		      --editor.n_selected(v, true)
		      for i, c in pairs(g.children) do
	     		  editor.n_selected(c)
		      end
                      screen:grab_key_focus(screen) 
		      editor.view_code(v)
		      text_reactive()
	              return true
		  elseif (item_v == "apply") then 
		      editor.n_selected(v, true)
		      inspector_apply (v, inspector) 
		      --org_obj, new_obj = inspector_apply (v, inspector) 
		      screen:remove(inspector)
		      input_mode = S_SELECT
		      current_inspector = nil
                      screen:grab_key_focus(screen) 
		      text_reactive()
		      for i, c in pairs(g.children) do
	     		  editor.n_selected(c)
		      end
	              return true
		  elseif (item_v == "cancel") then 
		      screen:remove(inspector)
		      input_mode = S_SELECT
		      current_inspector = nil
		      editor.n_selected(v, true)
                      screen:grab_key_focus(screen) 
		      text_reactive()
		      for i, c in pairs(g.children) do
	     		  editor.n_selected(c)
		      end
	              return true
		  end 
 	     elseif (key == keys.Tab and shift == false) or key == keys.Down then 
                  group.extra.on_focus_out()
		  for i, v in pairs(attr_t_idx) do
			if(item_n == v or item_v == v) then 
			     if(attr_t_idx[i+1] == nil) then return true end  -- 0203
			     while(item_group:find_child(attr_t_idx[i+1]) == nil) do 
				 i = i + 1
			     end 
			     if(item_group:find_child(attr_t_idx[i+1])) then
			     	local n_item = attr_t_idx[i+1]
				item_group:find_child(n_item).extra.on_focus_in()	
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
			     while(item_group:find_child(attr_t_idx[i-1]) == nil) do 
				 i = i - 1
			     end 
			     if(item_group:find_child(attr_t_idx[i-1])) then
			     	local p_item = attr_t_idx[i-1]
				item_group:find_child(p_item).extra.on_focus_in()	
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
		      input_mode = S_SELECT
		      current_inspector = nil
                      screen:grab_key_focus(screen) 
		      editor.view_code(v)
		      text_reactive()
	     elseif (item_v == "apply") then 
		      inspector_apply (v, inspector) 
		      screen:remove(inspector)
		      input_mode = S_SELECT
		      current_inspector = nil
                      screen:grab_key_focus(screen) 
		      text_reactive()
		      editor.n_selected(v, true)
	     elseif (item_v == "cancel") then 
		      screen:remove(inspector)
		      input_mode = S_SELECT
		      current_inspector = nil
                      screen:grab_key_focus(screen) 
		      text_reactive()
		      editor.n_selected(v, true)
	     end 
	     for i, c in pairs(g.children) do
	     	editor.n_selected(c)
	     end

             return true
	end 

    	group:add(button)

	local focus = assets( "assets/button-focus.png" )
        focus.name = "focus"
        focus:set{ position = { 0 , 0 } , size = { group.w , group.h } , opacity = 0 }
        group:add(focus)

    	--text = Text {text = string.upper(item_v)}:set(STYLE)
    	text = Text {text = item_s}:set(STYLE)
        text.position  = {(button.w - text.w)/2, (button.h - text.h)/2}
    	group:add(text)

        function group.extra.on_focus_in()
             current_focus = group
	     button:grab_key_focus(button)
	     button.opacity = 0 
             focus.opacity = 255
        end

        function group.extra.on_focus_out()
             focus.opacity = 0
	     button.opacity = 255 
        end

    elseif(item_n == "focus") then  -- Attribute with button picker 
	group:clear()
	group.name = "focusChanger"
	group.reactive = true
	local focus_changer = factory.draw_focus_changer()

	local focus_map = {[keys.Up] = "U",  [keys.Down] = "D", [keys.Return] = "E", [keys.Left] = "L", [keys.Right] = "R", 
	                   [keys.RED] = "Red", [keys.GREEN] = "G", [keys.YELLOW] = "Y", [keys.BLUE] = "B"}

	if v.extra.focus then 
		for m, n in pairs (v.extra.focus) do
		     focus_changer:find_child("text"..focus_map[m]).text = n
		end 	
	
	end 	

	local space = WIDTH - PADDING_X  
        focus_changer.position  = {WIDTH - space , 5}

        group:add(focus_changer)
	return group
    elseif(item_n == "items") then 
	group:clear()
	group.name = "itemsList"
	group.reactive = true

	local space = WIDTH - PADDING_X  

	local text = Text {name = "attr", text = item_s}:set(STYLE)
        text.position  = {WIDTH - space , 5}
    	group:add(text)

	local plus_minus = factory.draw_plus_minus()
	local plus = plus_minus:find_child("plus")
	local minus = plus_minus:find_child("minus")
	plus_minus.position = {text.x + text.w + PADDING_X, 5}
	plus.reactive = true 
	minus.reactive = true 

	function plus:on_button_down()
		table.insert(v.items, "item"..tostring(table.getn(v.items)+1)) 
		screen:remove(inspector)
		input_mode = S_SELECT
		current_inspector = nil
                screen:grab_key_focus(screen) 
		text_reactive()
		editor.n_selected(v, true)
		editor.inspector(v, inspector.x, inspector.y, si.content.y) --scroll position !!
		return true
	end 

	function minus:on_button_down()
		table.remove(v.items)
		screen:remove(inspector)
		input_mode = S_SELECT
		current_inspector = nil
                screen:grab_key_focus(screen) 
		text_reactive()
		editor.n_selected(v, true)
		editor.inspector(v, inspector.x, inspector.y, math.abs(si.content.y))
		return true 
	end 

	group:add(plus_minus)

	local list_focus = Rectangle{ name="Focus", size={ 355, 45}, color={0,255,0,0}, anchor_point = { 355/2, 45/2}, border_width=5, border_color={0,255,0,255}, }
	local items_list = widget.threeDlist{num_rows = table.getn(v.items), num_cols = 1, item_w = 300, item_h = 40, grid_gap=5, focus=list_focus}
	--items.focus = nil
        items_list.position = {text.w, text.y + text.h + PADDING_Y}
        items_list.name = "items_list"
	items_list:find_child("Focus").opacity = 0 

	for i,j in pairs(v.items) do 
--hjk
             local item = widget.textField{wwidth = 350, wheight = 40, text = j, font = "DejaVu Sans 26px", border_width = 2}
	     item.name = "item_text"..tostring(i)
	     --local item = Group {}
	     --item:add(Rectangle{size = {300,40}, color = {0,0,0,0}, border_color = {255, 255, 255, 255}, border_width = 2})
	     --item:add(Text{name = "item_text"..tonumber(i), text = j, reative = true, cursor_visible = false, editable =true, wrap = "CHAR"}:set(STYLE))

	     function item:on_button_down()
   		current_focus.extra.on_focus_out()
	        current_focus = group
--[[
		for i,j in pairs(items.children) do 
		     if(j.name ~= item.name and j.on_focus_out)then 
			 j.on_focus_out()
		     end 
		end 
]]
		item.on_focus_in()
		return true
	     end 
 
	    function item:on_key_down(key)
	       local si = inspector:find_child("si")
    	       if is_this_widget(v) == true  then
                    item_group = si.content
               else 
         	    item_group = inspector:find_child("item_group")
    	       end 

	       if (key == keys.Tab and shift == false) or key == keys.Down then
		  item.on_focus_out()
		  local next_i = tonumber(string.sub(item.name, 10, -1)) + 1
		  if (item_group:find_child("item_text"..tostring(next_i))) then
			item_group:find_child("item_text"..tostring(next_i)).extra.on_focus_in()
		  	si.seek_to(0,item_group:find_child("item_text"..tostring(next_i)).y) 
			print("SEEK_TO: FROM-",item.parent.y,"TO-",item_group:find_child("item_text"..tostring(next_i)).y)
		  else 	
		     for i, v in pairs(attr_t_idx) do
 		        if("itemsList" == v) then 
			  local function there()
		          	while(item_group:find_child(attr_t_idx[i+1]) == nil) do 
		               		i = i + 1
			       		if(attr_t_idx[i+1] == nil) then return true end  
		          	end 
			
		          	if(item_group:find_child(attr_t_idx[i+1])) then
		               		local n_item = attr_t_idx[i+1]
			       		if item_group:find_child(n_item).extra.on_focus_in then 
			           		item_group:find_child(n_item).extra.on_focus_in()	
		  			        si.seek_to(0,item_group:find_child(n_item).y) 
					        print("SEEK_TO: FROM-",item.parent.y,"TO-",item_group:find_child(n_item).y)
			       		else
				   		there()
			       		end 
		          	end
			  end 
			  there()
		        end 
    		     end
		  end
	       elseif key == keys.Up or (key == keys.Tab and shift == true )then 
		     item.on_focus_out()
		     local prev_i = tonumber(string.sub(item.name, 10, -1)) - 1
		     if (item_group:find_child("item_text"..tostring(prev_i))) then
			item_group:find_child("item_text"..tostring(prev_i)).extra.on_focus_in()
		  	si.seek_to(0,item_group:find_child("item_text"..tostring(prev_i)).y) 
			print("SEEK_TO: FROM-",item.parent.y,"TO-",item_group:find_child("item_text"..tostring(prev_i)).y)
		     else 	
		      for i, v in pairs(attr_t_idx) do
			if("itemsList" == v) then 
			     if(attr_t_idx[i-1] == nil) then return true end 
			     while(item_group:find_child(attr_t_idx[i-1]) == nil) do 
				 i = i - 1
			     end 
			     if(item_group:find_child(attr_t_idx[i-1])) then
			     	local p_item = attr_t_idx[i-1]
				item_group:find_child(p_item).extra.on_focus_in()	
		  	        si.seek_to(0,item_group:find_child(p_item).y) 
			        print("SEEK_TO: FROM-",item.parent.y,"TO-",item_group:find_child(p_item).y)
				break
			     end
			end 
    		    end
		    end 
	       end 
	     end 

	     items_list:replace(i,1,item)
	end

	function group.extra.on_focus_in()
	         current_focus = group
		 a = items_list.tiles[1][1]
		 a.on_focus_in()
		 a:grab_key_focus()
        end

        function group.extra.on_focus_out()
		for i,j in pairs(items_list.children) do 
		     if j.on_focus_out then 
			 j.on_focus_out()
		     end 
		end 
		return true
        end 
--[[

	function items:on_button_down (x,y,b,n)
	        print("oipiop")
   		current_focus.extra.on_focus_out()
	        current_focus = group
		group.on_focus_in()
		return true
	end 
]]

	group:add(items_list) 
	return group

    elseif(item_n == "skin") then  -- Attribute with button picker 
	group:clear()
	group.name = item_n
	group.reactive = true

        local space = WIDTH - PADDING_X  

	--text = Text {name = "attr", text = string.upper(item_s)}:set(STYLE)
	text = Text {name = "attr", text = item_s}:set(STYLE)
        text.position  = {WIDTH - space , 5}
    	group:add(text)
	
	local selected
	for i,j in pairs(skins) do 
	    if(item_v == j)then 
		selected = i 
	    end
	end


        local skin_picker = widget.buttonPicker{skin = "custom", items = skins, font = "DejaVu Sans 26px", selected_item = selected}
	skin_picker.wheight = 45
	skin_picker.wwidth = 210
        skin_picker.position = {text.x + text.w + 50 , 5}
	skin_picker.name = "skin_picker"

        group:add(skin_picker) 
	
	unfocus = skin_picker:find_child("unfocus")
	function unfocus:on_button_down (x,y,b,n)
	        print("oipiop")
   		current_focus.extra.on_focus_out()
	        current_focus = group
		skin_picker.on_focus_in()
	        skin_picker:grab_key_focus()
		return true
	end 

        left_arrow = skin_picker:find_child("left_un")
	left_arrow.reactive = true 
	function left_arrow:on_button_down(x, y, b, n)
		current_focus.extra.on_focus_out()
	        current_focus = group
		skin_picker.on_focus_in()
	        skin_picker:grab_key_focus()
		skin_picker.press_left()
		return true 
	end 

	right_arrow = skin_picker:find_child("right_un")
	right_arrow.reactive = true 
	function right_arrow:on_button_down(x, y, b, n)
		current_focus.extra.on_focus_out()
	        current_focus = group
		skin_picker.on_focus_in()
	        skin_picker:grab_key_focus()
		skin_picker.press_right()
		return true 
	end 

	function skin_picker:on_key_down(key)
	     local si = inspector:find_child("si")
    	     if is_this_widget(v) == true  then
                item_group = (inspector:find_child("si")).content
             else 
         	item_group = inspector:find_child("item_group")
    	     end 
	       if key == keys.Left then 
		     skin_picker.press_left()
	       elseif key == keys.Right then  
		     skin_picker.press_right()
	       elseif (key == keys.Tab and shift == false) or key == keys.Down then
		     skin_picker.on_focus_out()
		     for i, v in pairs(attr_t_idx) do
		     if(item_n == v or item_v == v) then 
		          while(item_group:find_child(attr_t_idx[i+1]) == nil) do 
		               i = i + 1
			       if(attr_t_idx[i+1] == nil) then return true end  
		          end 
		          if(item_group:find_child(attr_t_idx[i+1])) then
		               local n_item = attr_t_idx[i+1]
			       item_group:find_child(n_item).extra.on_focus_in()	
			       si.seek_to(0, item_group:find_child(n_item).y)
			       print("SEEK_TO: FROM-",skin_picker.parent.y,"TO-",item_group:find_child(n_item).y)
			       break
		          end
		     end 
    		     end
	       elseif key == keys.Up or (key == keys.Tab and shift == true )then 
		     skin_picker.on_focus_out()
		      for i, v in pairs(attr_t_idx) do
			if(item_n == v or item_v == v) then 
			     if(attr_t_idx[i-1] == nil) then return true end 
			     while(item_group:find_child(attr_t_idx[i-1]) == nil) do 
				 i = i - 1
			     end 
			     if(item_group:find_child(attr_t_idx[i-1])) then
			     	local p_item = attr_t_idx[i-1]
				item_group:find_child(p_item).extra.on_focus_in()	
				si.seek_to(0, item_group:find_child(p_item))
			        print("SEEK_TO: FROM-",skin_picker.parent.y,"TO-",item_group:find_child(p_item).y)
				break
			     end
			end 
    		    end
	       end 
	end 


	group:add(skin_picker)

        function group.extra.on_focus_in()
		 group:find_child("skin_picker").extra.on_focus_in()
	         group:find_child("skin_picker"):grab_key_focus()
        end

        function group.extra.on_focus_out()
		 group:find_child("skin_picker").extra.on_focus_out()
        end 


        return group
    else 	---- Attributes with focusable ring 
        group:clear()
	group.name = item_n
	group.reactive = true

        local space = WIDTH - PADDING_X  
	local text

        if(item_n == "name" or item_n == "text" or item_n == "src" or item_n == "source") then 
	     input_box_width = WIDTH - ( PADDING_X * 2) 
	elseif item_n == "anchor_point" then 
	     text = Text {name = "attr", text = item_s}:set(STYLE)
             text.position  = {WIDTH - space , 0}
    	     group:add(text)
	     local anchor_pnt = factory.draw_anchor_point(v)
	     anchor_pnt.position = {300, 0}
	     group:add(anchor_pnt)
             return group
	elseif item_n == "message" then 
	     input_box_width = WIDTH 
	     
        else  
    	     text = Text {name = "attr", text = item_s}:set(STYLE)
             text.position  = {WIDTH - space , PADDING_Y}
    	     group:add(text)

	     input_box_width = WIDTH/4 - 10 + ( PADDING_X * 2) 
	     space = space - string.len(item_s) * 20
             if (item_n =="font" or item_n == "label") then
	          input_box_width = WIDTH - 100 - ( PADDING_X * 2) 
             elseif(item_n == "wrap_mode" or item_n =="duration" or item_n =="fade_duration") then 
	          input_box_width = WIDTH - 250 - ( PADDING_X * 2) 
             elseif(string.find(item_n,"color")) then 
	          input_box_width = WIDTH - 350 - ( PADDING_X * 2) 
	     end
        end 

	local y_space = 0

        ring = make_ring(input_box_width, HEIGHT + 5 ) 
	ring.name = "ring"
	if (text) then 
	     ring.position = {text.x+text.w+5, y_space}
	else 
	     ring.position = {WIDTH = space, y_space}
	end
        ring.opacity = 255
        group:add(ring)

        focus = make_focus_ring(input_box_width, HEIGHT + 5)
        focus.name = "focus"
	if (text) then 
	     focus.position = {text.x+text.w+5, y_space}
	else 
             focus.position = {WIDTH - space , y_space}
	end

        focus.opacity = 0
	group:add(focus)

	space = space - PADDING_B

	if(item_v == "CHAR" or item_v == "WORD" or item_v =="WORD_CHAR") then item_v = string.lower(item_v) end 

    	input_text = Text {name = "input_text", text =item_v, editable=true,
        reactive = true, wants_enter = false, cursor_visible = false}:set(STYLE)

	if (text) then 
             input_text.position  = {text.x+text.w+20, PADDING_Y + y_space}
	else 
             input_text.position  = {WIDTH - space , PADDING_Y + y_space}
	end


	function input_text:on_button_down(x,y,button,num_clicks)
 	       current_focus.extra.on_focus_out()
	       current_focus = group
	       group.extra.on_focus_in()
               return true
        end

	function group:on_button_down(x,y,button,num_clicks)
 	       current_focus.extra.on_focus_out()
	       current_focus = group
	       group.extra.on_focus_in()
               return true
        end

	
  	function input_text:on_key_down(key)
	    local si = inspector:find_child("si")
    	    if is_this_widget(v) == true  then
                item_group = (inspector:find_child("si")).content
            else 
         	item_group = inspector:find_child("item_group")
    	    end 
	    if key == keys.Return or
                 (key == keys.Tab and shift == false) or 
                 key == keys.Down then
	       	 group.extra.on_focus_out()
		 for i, v in pairs(attr_t_idx) do
		     if(item_n == v or item_v == v) then 
		          while(item_group:find_child(attr_t_idx[i+1]) == nil) do 
		               i = i + 1
			       if(attr_t_idx[i+1] == nil) then return true end 
		          end 
		          if item_group:find_child("skin") then 
	                  end 	
		          if(item_group:find_child(attr_t_idx[i+1])) then
		               local n_item = attr_t_idx[i+1]
			       item_group:find_child(n_item).extra.on_focus_in()	
			       if (si) then 
				    si.seek_to(0, item_group:find_child(n_item).y)
			            print("SEEK_TO: FROM-",input_text.parent.y,"TO-",item_group:find_child(n_item).y)
			       end
			       break
		          end
		     end 
    		end
	     elseif key == keys.Up or (key == keys.Tab and shift == true )then 
		    group.extra.on_focus_out()
 		    for i, v in pairs(attr_t_idx) do
			if(item_n == v or item_v == v) then 
			     if(attr_t_idx[i-1] == nil) then return true end  
			     local function here ()
			     while(item_group:find_child(attr_t_idx[i-1]) == nil) do 
				 i = i - 1
			     end 
			     if(item_group:find_child(attr_t_idx[i-1])) then
			     	local p_item = attr_t_idx[i-1]
				if item_group:find_child(p_item).extra.on_focus_in then 	
				     item_group:find_child(p_item).extra.on_focus_in()	
			             if (si) then 
				          si.seek_to(0, item_group:find_child(p_item).y)
			                  print("SEEK_TO: FROM-",input_text.parent.y,"TO-",item_group:find_child(p_item).y)
			             end
				else 
				     i = i -1
				     here()
				end 
			     end
			     end 
			     here()
			end 
    		    end
             end
	     --return true
   	end 

	
    	group:add(input_text)

        function group.extra.on_focus_in()
	         current_focus = group
             	 ring.opacity = 0
                 input_text.cursor_visible = true
                 focus.opacity = 255
	         input_text:grab_key_focus(input_text)
        end

        function group.extra.on_focus_out()
                  focus.opacity = 0
                  input_text.cursor_visible = false
                  ring.opacity = 255
        end 
    end

--[[
	if v.extra then 
            if is_in_list(v.extra.type, widgets) == true  then
    		--inspector:find_child("si").reactive = true
	    end 
        end 
]]
    return group
end
 
function factory.draw_anchor_point(v, inspector)
    local h_pos = 0
    local v_pos = 0
    local cur_posint = left_top
    local center, left_top, left_mid, left_bottom, mid_top, mid_bottom, right_top, right_mid, right_bottom
 
    local function find_current_anchor (v)
        if(v.anchor_point == nil) then 
	     return h_pos, v_pos
        end 
        if (v.anchor_point[1] < v.w/2) then h_pos = 0
        elseif (v.anchor_point[1] > v.w/2) then h_pos = 2 
        else h_pos = 1
        end 

        if (v.anchor_point[2] < v.h/2) then v_pos = 0 
        elseif (v.anchor_point[2] > v.h/2) then v_pos = 2 
        else v_pos = 1 
        end 
    end 

    local function mark_current_anchor()
	if(h_pos == 0 and v_pos == 0) then 
		left_top.color = {200,0,0,200}
		cur_point = left_top
		anchor_pnt.extra.anchor_point = {0, 0}
	elseif(h_pos == 0 and v_pos == 1) then 
		left_mid.color = {200,0,0,200} 
		cur_point = left_mid
		anchor_pnt.extra.anchor_point = {0, v.h/2}
	elseif(h_pos == 0 and v_pos == 2) then 
		left_bottom.color = {200,0,0,200}
		cur_point = left_bottom
		anchor_pnt.extra.anchor_point = {0, v.h}
	elseif(h_pos == 1 and v_pos == 0) then 
		mid_top.color = {200,0,0,200} 
		cur_point = mid_top
		anchor_pnt.extra.anchor_point = {v.w/2, 0}
	elseif(h_pos == 1 and v_pos == 1) then 
		center.color = {200,0,0,200} 
		cur_point = center
		anchor_pnt.extra.anchor_point = {v.w/2, v.h/2}
	elseif(h_pos == 1 and v_pos == 2) then 
		mid_bottom.color = {200,0,0,200} 
		cur_point = mid_bottom
		anchor_pnt.extra.anchor_point = {v.w/2, v.h}
	elseif(h_pos == 2 and v_pos == 0) then 
		right_top.color = {200,0,0,200} 
		cur_point = right_top
		anchor_pnt.extra.anchor_point = {v.w, 0}
	elseif(h_pos == 2 and v_pos == 1) then 
		right_mid.color = {200,0,0,200} 
		cur_point = right_mid
		anchor_pnt.extra.anchor_point = {v.w, v.h/2}
	elseif(h_pos == 2 and v_pos == 2) then 
		right_bottom.color = {200,0,0,200} 
		cur_point = right_bottom
		anchor_pnt.extra.anchor_point = {v.w, v.h}
	end 
    end 

    function create_point_on_button_down(point)
	function point:on_button_down(x,y,button,num)
		cur_point.color = {25,25,25,250}
		-- point.color = {200,0,0,200} 
		if(point.name == "center") then h_pos = 1 v_pos = 1
		elseif(point.name == "left_top") then h_pos = 0 v_pos = 0
		elseif(point.name == "left_mid") then h_pos = 0 v_pos = 1
		elseif(point.name == "left_bottom") then h_pos = 0 v_pos = 2
		elseif(point.name == "mid_top") then h_pos = 1 v_pos = 0
		elseif(point.name == "mid_bottom") then h_pos = 1 v_pos = 2
		elseif(point.name == "right_top") then h_pos = 2 v_pos = 0
		elseif(point.name == "right_mid") then h_pos = 2 v_pos = 1
		elseif(point.name == "right_bottom") then h_pos = 2 v_pos = 2
		end 
		
                mark_current_anchor()
		cur_point = point
	end 
    end

    find_current_anchor (v)

    local object = Rectangle
	{
		name="rect0",
		color={155,155,155,255},
		size = {50,50},
		position = {4,6},
		opacity = 255
	}

     center = Rectangle
	{
		name="center",
		color={25,25,25,250},
		size = {15,15},
		position = {22.25,23},
		opacity = 255
	}

     center.reactive = true
     create_point_on_button_down(center)

     mid_top = Rectangle
	{
		name="mid_top",
		color={25,25,25,250},
		size={15,15},
		position = {22.25,0},
		opacity = 255
	}

    mid_top.reactive = true
    create_point_on_button_down(mid_top)

    mid_bottom = Rectangle
	{
		name="mid_bottom",
		color={25,25,25,250},
		size={15,15},
		position = {22.25,46},
		opacity = 255
	}

    mid_bottom.reactive = true
    create_point_on_button_down(mid_bottom)

    right_mid = Rectangle
	{
		name="right_mid",
		color={25,25,25,250},
		size={15,15},
		position = {44.5,23},
		opacity = 255
	}

    right_mid.reactive = true
    create_point_on_button_down(right_mid)

    right_top = Rectangle
	{
		name="right_top",
		color={25,25,25,250},
		size={15,15},
		position = {44.5,0},
		opacity = 255
	}
    right_top.reactive = true
    create_point_on_button_down(right_top)

    left_mid = Rectangle
	{
		name="left_mid",
		color={25,25,25,250},
		size={15,15},
		position = {0,23},
		opacity = 255
	}

     left_mid.reactive = true
     create_point_on_button_down(left_mid)

     right_bottom = Rectangle
	{
		name="right_bottom",
		color={25,25,25,250},
		size={15,15},
		position = {44.5,46},
		opacity = 255
	}

     right_bottom.reactive = true
     create_point_on_button_down(right_bottom)

     left_bottom = Rectangle
	{
		name="left_bottom",
		color={25,25,25,250},
		size={15,15},
		position = {0,46},
		opacity = 255
	}

     left_bottom.reactive = true
     create_point_on_button_down(left_bottom)

     left_top = Rectangle
	{
		name="left_top",
		color={25,25,25,250},
		size={15,15},
		position = {0,0},
		opacity = 255
	}

     left_top.reactive = true
     create_point_on_button_down(left_top)

     anchor_pnt = Group
	{
		name="anchor",
		size={59.5,61},
		position = {0,0},
		children = {object,center,mid_top,mid_bottom,right_mid,right_top,left_mid,right_bottom,left_bottom,left_top},
		scale = {1,1,0,0},
		opacity = 255
	}
 
       mark_current_anchor()

    return anchor_pnt
end 






function factory.draw_anchor_pointer() 

sero = Rectangle
	{
		name="sero",
		border_color={255,255,255,192},
		border_width=0,
		color={255,0,0,255},
		size = {5,30},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {12.5,0},
		opacity = 255
	}

garo = Rectangle
	{
		name="garo",
		border_color={255,255,255,192},
		border_width=0,
		color={255,0,0,255},
		size = {30,5},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {0,12},
		opacity = 255
	}

anchor_point = Group
	{
		name="mouse_pointer",
		size={30,30},
		position = {0,0},
		children = {sero, garo},
		scale = {1,1,0,0},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		opacity = 255
	}

	anchor_point.anchor_point = {anchor_point.w/2, anchor_point.h/2}
	anchor_point.scale = {0.5, 0.5}
	return anchor_point
end 

function factory.draw_mouse_pointer() 

sero = Rectangle
	{
		name="sero",
		border_color={255,255,255,192},
		border_width=0,
		color={255,255,255,255},
		size = {5,30},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {12.5,0},
		opacity = 255
	}

garo = Rectangle
	{
		name="garo",
		border_color={255,255,255,192},
		border_width=0,
		color={255,255,255,255},
		size = {30,5},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {0,12},
		opacity = 255
	}

mouse_pointer = Group
	{
		name="mouse_pointer",
		size={30,30},
		position = {300,300},
		children = {sero, garo},
		scale = {1,1,0,0},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		opacity = 255
	}

	mouse_pointer.anchor_point = {mouse_pointer.w/2, mouse_pointer.h/2}
	return mouse_pointer
end 

function factory.draw_plus_minus()

local l_col = {150,150,150,200}
local l_wid = 4
local l_scale = 0.9

rect1 = Rectangle
	{
		color = l_col,
		border_color = {255,255,255,255},
		border_width = 0,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rect1",
		position = {13,4,0},
		size = {l_wid,25},
		opacity = 255,
	}


rect2 = Rectangle
	{
		color = l_col,
		border_color = {255,255,255,255},
		border_width = 0,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rect2",
		position = {2,12,0},
		size = {25,l_wid},
		opacity = 255,
	}


rect0 = Rectangle
	{
		color = {25,25,25,0},
		border_color = l_col,
		border_width = l_wid,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rect0",
		position = {0,0,0},
		size = {29,29},
		opacity = 255,
	}


plus = Group
	{
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "plus",
		position = {0,0,0},
		size = {29,29},
		opacity = 255,
		children = {rect1,rect2,rect0},
	}


rect5 = Rectangle
	{
		color = l_col,
		border_color = {255,255,255,255},
		border_width = 0,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rect5",
		position = {2,12,0},
		size = {25, l_wid},
		opacity = 255,
	}


rect4 = Rectangle
	{
		color = {255,255,255,0},
		border_color = l_col,
		border_width = l_wid,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rect4",
		position = {0,0,0},
		size = {29,29},
		opacity = 255,
	}


minus = Group
	{
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "minus",
		position = {36,0,0},
		size = {29,29},
		opacity = 255,
		children = {rect5,rect4},
	}


plus_minus = Group
	{
		scale = {l_scale,l_scale,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "plus_minus",
		position = {0,0,0},
		size = {65,29},
		opacity = 255,
		children = {plus, minus},
	}

return plus_minus
end 

function factory.draw_focus_changer()



bnd = Rectangle
	{
		color = {255,255,255,0},
		border_color = {255,255,255,255},
		border_width = 2,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "bnd",
		position = {0,0,0},
		size = {434,580},
		opacity = 10,
	}


text11 = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 26px",
		text = "Change Focus",
		editable = true,
		wants_enter = true,
		wrap = true,
		cursor_visible=false,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text11",
		position = {0,2,0},
		size = {300,30},
		opacity = 255,
	}


text8 = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 26px",
		text = "U",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text8",
		position = {15,12,0},
		size = {30,30},
		opacity = 255,
	}


rectU = Rectangle
	{
		color = {255,255,255,0},
		border_color = {255,255,255,255},
		border_width = 2,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rectU",
		position = {0,0,0},
		size = {50,50},
		opacity = 255,
	}


gU = Group
	{
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "gU",
		position = {188,45,0},
		size = {50,50},
		opacity = 255,
		reactive = true,
		children = {text8,rectU},
	}


textU = Text
	{
		color = {255,255,255,255},
		font = "Highway Gothic Narrow 22px",
		text = "",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "textU",
		position = {188,95,0},
		size = {100,30},
		opacity = 255,
	}


text13 = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 26px",
		text = "L",
		editable = true,
		wants_enter = true,
		wrap = true,
		cursor_visible=false,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text13",
		position = {14,5,0},
		size = {30,30},
		opacity = 255,
	}


rectL = Rectangle
	{
		color = {255,255,255,0},
		border_color = {255,255,255,255},
		border_width = 2,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rectL",
		position = {0,0,0},
		size = {50,50},
		opacity = 255,
	}


gL = Group
	{
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "gL",
		position = {30,177,0},
		size = {50,50},
		opacity = 255,
		children = {text13,rectL},
	}


textL = Text
	{
		color = {255,255,255,255},
		font = "Highway Gothic Narrow 22px",
		text = "",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "textL",
		position = {30,227,0},
		size = {100,30},
		opacity = 255,
	}

text10 = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 26px",
		text = "E",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text10",
		position = {14,7,0},
		size = {30,30},
		opacity = 255,
	}


rectE = Rectangle
	{
		color = {255,255,255,0},
		border_color = {255,255,255,255},
		border_width = 2,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rectE",
		position = {0,0,0},
		size = {50,50},
		opacity = 255,
	}


gE = Group
	{
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "gE",
		position = {188,177,0},
		size = {50,50},
		opacity = 255,
		children = {text10,rectE},
	}


textE = Text
	{
		color = {255,255,255,255},
		font = "Highway Gothic Narrow 22px",
		text = "",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "textE",
		position = {188,227,0},
		size = {100,30},
		opacity = 255,
	}


text14 = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 26px",
		text = "R",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text14",
		position = {14,9,0},
		size = {30,30},
		opacity = 255,
	}


rectR = Rectangle
	{
		color = {255,255,255,0},
		border_color = {255,255,255,255},
		border_width = 2,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rectR",
		position = {0,0,0},
		size = {50,50},
		opacity = 255,
	}


gR = Group
	{
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "gR",
		position = {346,175,0},
		size = {50,50},
		opacity = 255,
		children = {text14,rectR},
	}



textR = Text
	{
		color = {255,255,255,255},
		font = "Highway Gothic Narrow 22px",
		text = "",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "textR",
		position = {346,225,0},
		size = {100,30},
		opacity = 255,
	}


text12 = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 26px",
		text = "D",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text12",
		position = {12,6,0},
		size = {30,30},
		opacity = 255,
	}


rectD = Rectangle
	{
		color = {255,255,255,0},
		border_color = {255,255,255,255},
		border_width = 2,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rectD",
		position = {0,0,0},
		size = {50,50},
		opacity = 255,
	}


gD = Group
	{
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "gD",
		position = {188,309,0},
		size = {50,50},
		opacity = 255,
		children = {text12,rectD},
	}

textD = Text
	{
		color = {255,255,255,255},
		font = "Highway Gothic Narrow 22px",
		text = "",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "textD",
		position = {188,359,0},
		size = {100,30},
		opacity = 255,
	}


text16 = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 26px",
		text = "R",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text16",
		position = {12,10,0},
		size = {30,30},
		opacity = 255,
	}


rectRed = Rectangle
	{
		color = {255,255,255,0},
		border_color = {255,255,255,255},
		border_width = 2,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rectRed",
		position = {0,0,0},
		size = {50,50},
		opacity = 255,
	}


gRed = Group
	{
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "gRed",
		position = {30,443,0},
		size = {50,50},
		opacity = 255,
		children = {text16,rectRed},
	}

textRed = Text
	{
		color = {255,255,255,255},
		font = "Highway Gothic Narrow 22px",
		text = "",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "textRed",
		position = {30,493,0},
		size = {100,30},
		opacity = 255,
	}

text17 = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 26px",
		text = "G",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text17",
		position = {12,7,0},
		size = {30,30},
		opacity = 255,
	}


rectG = Rectangle
	{
		color = {255,255,255,0},
		border_color = {255,255,255,255},
		border_width = 2,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rectG",
		position = {0,0,0},
		size = {50,50},
		opacity = 255,
	}


gG = Group
	{
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "gG",
		position = {135,441,0},
		size = {50,50},
		opacity = 255,
		children = {text17,rectG},
	}


textG = Text
	{
		color = {255,255,255,255},
		font = "Highway Gothic Narrow 22px",
		text = "",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "textG",
		position = {135,491,0},
		size = {100,30},
		opacity = 255,
	}


text18 = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 26px",
		text = "Y",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text18",
		position = {14,10,0},
		size = {30,30},
		opacity = 255,
	}


rectY = Rectangle
	{
		color = {255,255,255,0},
		border_color = {255,255,255,255},
		border_width = 2,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rectY",
		position = {0,0,0},
		size = {50,50},
		opacity = 255,
	}


gY = Group
	{
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "gY",
		position = {240,443,0},
		size = {50,50},
		opacity = 255,
		children = {text18,rectY},
	}


textY = Text
	{
		color = {255,255,255,255},
		font = "Highway Gothic Narrow 22px",
		text = "",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "textY",
		position = {240,493,0},
		size = {100,30},
		opacity = 255,
	}



text19 = Text
	{
		color = {255,255,255,255},
		font = "DejaVu Sans 26px",
		text = "B",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text19",
		position = {14,8,0},
		size = {30,30},
		opacity = 255,
	}


rectB = Rectangle
	{
		color = {255,255,255,0},
		border_color = {255,255,255,255},
		border_width = 2,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "rectB",
		position = {0,0,0},
		size = {50,50},
		opacity = 255,
	}


gB = Group
	{
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "gB",
		position = {346,443,0},
		size = {50,50},
		opacity = 255,
		children = {text19,rectB},
	}


textB = Text
	{
		color = {255,255,255,255},
		font = "Highway Gothic Narrow 22px",
		text = "",
		wants_enter = true,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "textB",
		position = {346,493,0},
		size = {100,30},
		opacity = 255,
	}


focus = Group
	{
		name = "focusChanger",
		position = {0,0,0},
		reactive = true,
	}

focus:add(bnd,text11,gU,textU,gL,textL,gE,textE,gR,textR, gD, textD, gRed, textRed, gG, textG, gY, textY, gB, textB)
	
local focus_map  = {["gU"] = function() end,}

function focus.extra.on_focus_in()
	 current_focus.extra.on_focus_out()
	 current_focus = focus
	 for i,j in pairs(focus.children) do
		if j.type == "Group" then 
		     local focus_t= j.name:sub(2,-1)
		     j:find_child("rect"..focus_t).border_color = {255,255,255,255}
		end 
	 end 
end 

function focus.extra.on_focus_out(call_by_inspector)
	focus_type = ""
	input_mode = S_POPUP
        for i,j in pairs(focus.children) do
		if j.type == "Group" then 
		     local focus_t= j.name:sub(2,-1)
		     j:find_child("rect"..focus_t).border_color = {255,255,255,255}
		end 
	end 

end 

function make_on_button_down_f(v)
     function v:on_button_down(x,y,b,n)
           focus.on_focus_in()
	   focus_type = v.name:sub(2,-1)
	   v:find_child("rect"..focus_type).border_color = {0,255,0,255} -- 
	   if (focus:find_child("text"..focus_type).text ~= "") then
		focus:find_child("text"..focus_type).text = ""
	   end 
	   --dolater : add F to mouse pointer 
	   input_mode = S_FOCUS
	   return true 
	end 
end 



for i,j in pairs (focus.children) do 
     j.reactive = true 
     if (j.type == "Group") then 
          make_on_button_down_f(j)
     end
end


return focus

end 


return factory
