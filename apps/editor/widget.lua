
     local widget = {}
     skin_list = { ["default"] = {
				   ["button"] = "assets/smallbutton.png", 
				   ["button_focus"] = "assets/smallbuttonfocus.png", 
				   ["toast_icon"] = "assets/voice-1.png", 
			           ["buttonpicker"] = "assets/smallbutton.png",
     				   ["buttonpicker_focus"] = "assets/smallbuttonfocus.png",
				   ["buttonpicker_left_un"] = "assets/left.png",
				   ["buttonpciker_left_sel"] = "assets/leftfocus.png",
				   ["buttonpicker_right_un"] = "assets/right.png",
        			   ["buttonpicker_right_sel"] = "assets/rightfocus.png",
				   ["checkbox_sel"] = "assets/checkmark.png", 
				   ["loading_dot"]  = nil
				  },

	            ["custom"] = {},
		    ["skin_type1"] = { 
				   ["button"] = "assets/button-red.png", 
				   ["button_focus"] = "assets/button-focus.png", 
				   --["toast_icon"] = "assets/button-yellow-circle.png", 
				   ["toast_icon"] = "assets/voice-2.png", 
				   ["toast"] = "assets/background-blue-6.jpg", 
				   ["textinput"] = "", 
				   ["textinput_focus"] = "", 
				   ["dialogbox"] = "", 
			           ["dialogbox_x"] ="", 
				   ["icon"] = "", 
			           ["buttonpicker"] = "assets/button-red.png",
     				   ["buttonpicker_focus"] = "assets/button-focus.png",
				   ["buttonpicker_left_un"] = "assets/left.png",
				   ["buttonpciker_left_sel"] = "assets/leftfocus.png",
				   ["buttonpicker_right_un"] = "assets/right.png",
        			   ["buttonpicker_right_sel"] = "assets/rightfocus.png",
				   ["radiobutton"] = "", 
				   ["radiobutton_sel"] = "", 
				   ["checkbox"] = "", 
				   ["checkbox_sel"] = "assets/checkmark.png", 
				   ["loadingdot"] = "assets/checkmark.png", 
				  },
 
		    ["skin_type2"] = { 
				   ["button"] = "assets/button-blue.png", 
				   ["button_focus"] = "assets/button-focus.png", 
				   ["textinput"] = "", 
				   ["textinput_focus"] = "", 
				   ["dialogbox"] = "", 
			           ["dialogbox_x"] ="", 
				   ["toast"] = "assets/background-red-6.jpg", 
				   ["toast_icon"] = "assets/voice-3.png", 
				   ["icon"] = "", 
			           ["buttonpicker"] = "assets/button-red.png",
     				   ["buttonpicker_focus"] = "assets/button-focus.png",
				   ["buttonpicker_left_un"] = "assets/left.png",
				   ["buttonpciker_left_sel"] = "assets/leftfocus.png",
				   ["buttonpicker_right_un"] = "assets/right.png",
        			   ["buttonpicker_right_sel"] = "assets/rightfocus.png",
				   ["radiobutton"] = "", 
				   ["radiobutton_sel"] = "", 
				   ["checkbox"] = "", 
				   ["checkbox_sel"] = "assets/checkmark.png", 
				   ["loadingdot"] = "assets/left.png", 
				  },
		    ["skin_type3"] = { 
				   ["button"] = "assets/button-blue.png", 
				   ["button_focus"] = "assets/smallbuttonfocus.png", 
				  },
		    ["skin_type4"] = { 
				   ["button"] = "assets/button-blue.png", 
				   ["button_focus"] = "assets/smallbuttonfocus.png", 
				  },
		    ["skin_type5"] = { 
				   ["button"] = "assets/button-blue.png", 
				   ["button_focus"] = "assets/smallbuttonfocus.png", 
				  },
		    ["skin_type6"] = { 
				   ["button"] = "assets/button-blue.png", 
				   ["button_focus"] = "assets/smallbuttonfocus.png", 
				  },

		  }

--[[
Function: change_all_skin

Changes all widgets' skins to 'skin_name' 

Arguments:
	skin_name - name of skin  
]]

function widget.change_all_skin(skin_name)
    for i = 1, table.getn(g.children), 1 do
	if g.children[i].skin then 
	     g.children[i].skin = skin_name
	end 
    end 
end

--[[
Function: change_button_skin

Changes all buttons' skins to 'skin_name' 

Arguments:
	skin_name - Name of the skin  
]]


function widget.change_button_skin(skin_name)
    for i = 1, table.getn(g.children), 1 do
	if g.children[i].extra.type == "Button" then 
	     g.children[i].skin = skin_name
	end 
    end 
end 

-------------
-- Util
-------------

-- Localized string table

local strings = dofile( "localized:strings.lua" ) or {}

local function missing_localized_string( t , s )
     rawset(t,s,s) 
     return s
end

setmetatable( strings , { __index = missing_localized_string } )

-- Asset() 

local function make_image( k )
    return Image{ src = k }
end

local list = {}
local _mt = {}
_mt.__index = _mt

function _mt.__call( t , k , f )
    local asset = rawget( list , k )
    if not asset then
        asset = ( f or make_image )( k )
        assert( asset , "Failed to create asset "..k )
        asset:set{ opacity = 0 }
        rawset( list , k , asset )
        screen:add( asset )
    end
    return Clone{ source = asset , opacity = 255 }
end


function _mt.__newindex( t , k , v )
    assert( false , "You cannot add assets to the asset cache" )
end

local assets = setmetatable( {} , _mt )

-------------------
-- UI Factory
-------------------

-- make_xbox() : make closing box 

local function make_xbox()
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
         c = c:Image()
    end
    
    return c
end 


-- make_dialogBox_bg() : make message window background 

--make_dialogBox_bg(p.wwidth, p.wheight, p.border_width, p.border_color, p.f_color, p.padding_x, p.padding_y, p.border_radius) 
local function make_dialogBox_bg(w,h,bw,bc,fc,px,py,br)

    local size = {w, h} 
    local color = fc --"6d2b17"
    local BORDER_WIDTH= bw
    local POINT_HEIGHT=34
    local POINT_WIDTH=60
    local BORDER_COLOR=bc
    local CORNER_RADIUS=br --22
    local POINT_CORNER_RADIUS=2
    local H_BORDER_WIDTH = BORDER_WIDTH / 2

    local XBOX_SIZE = 25
    local PADDING = px -- 10

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

    c:set_source_color(color) 
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
    c:new_path()
    c:move_to (0, 74)
    c:line_to (c.w, 74)
    c:set_line_width (3)
    c:set_source_color( BORDER_COLOR )
    c:stroke (true)
    c:fill (true)
  --  end

    c:finish_painting()
    if c.Image then
         c = c:Image()
    end
    c.position = {0,0}

    return c
end 




-- make_toastb_group_bg() : make toast box background  

local function make_toastb_group_bg(w,h,bw,bc,fc,px,py,br)

    local size = {w, h} 
    local color = fc --"6d2b17"
    local BORDER_WIDTH= bw
    local POINT_HEIGHT=34
    local POINT_WIDTH=60
    local BORDER_COLOR=bc
    local CORNER_RADIUS=br --22
    local POINT_CORNER_RADIUS=2
    local H_BORDER_WIDTH = BORDER_WIDTH / 2

    local XBOX_SIZE = 25
    local PADDING = px -- 10

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

    c:set_source_color(color) 
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
    if c.Image then
         c = c:Image()
    end
    c.position = {0,0}

    return c
end 

-- make_ring() : make ring for button or text input field 

local function make_ring(w,h,bc,bw,px,py,br)
        local ring = Canvas{ size = {w, h} }
        ring:begin_painting()
        ring:set_source_color(bc)
        ring:round_rectangle(
            px + bw / 2,
            py + bw / 2,
            w - bw - px * 2 ,
            h - bw - py * 2 ,
            br )
        ring:stroke()
        ring:finish_painting()
    	if ring.Image then
            ring = ring:Image()
    	end
        return ring
end 

local function create_select_circle(radius, color)
-- make circle image
-- Determines kappa, necessary for circle with bezier curves
kappa = 4*((math.pow(2,.5)-1)/3)

----circle canvas size
c = Canvas { size = {radius*4, radius*4} }
--- sets x and y of circle

center_x = radius*2
center_y = radius*2

-- Start point of circle creation

c:begin_painting()
c:new_path()

c:move_to( center_x, center_y-radius )

c:curve_to(  center_x+kappa*radius , center_y-radius ,
			center_x+radius , center_y-kappa*radius ,
			center_x+radius , center_y
			 )

c:curve_to(  center_x+radius , center_y+kappa*radius ,
			center_x+kappa*radius , center_y+radius ,
			center_x , center_y+radius
			)
			 
c:curve_to(  center_x-kappa*radius , center_y+radius ,
			center_x-radius , center_y+radius*kappa ,
			center_x-radius , center_y
			 )

c:curve_to(  center_x-radius , center_y-radius*kappa,
			center_x-radius*kappa , center_y-radius ,
			center_x , center_y-radius
			 )
			 		 
-- Sets color and fill
c:set_source_color( color )
c:fill(true)

c:stroke(stroke_bool)
-- Finishes painting on Canvas
c:finish_painting()
if c.Image then
  c = c:Image()
end

return c
end


local function create_circle(radius, color)

-- Determines kappa, necessary for circle with bezier curves
kappa = 4*((math.pow(2,.5)-1)/3)

----circle canvas size
c = Canvas { size = {radius*4, radius*4} }
--- sets x and y of circle

center_x = radius*2
center_y = radius*2

-- Start point of circle creation

c:begin_painting()
c:new_path()

c:move_to( center_x, center_y-radius )

c:curve_to(  center_x+kappa*radius , center_y-radius ,
			center_x+radius , center_y-kappa*radius ,
			center_x+radius , center_y
			 )

c:curve_to(  center_x+radius , center_y+kappa*radius ,
			center_x+kappa*radius , center_y+radius ,
			center_x , center_y+radius
			)
			 
c:curve_to(  center_x-kappa*radius , center_y+radius ,
			center_x-radius , center_y+radius*kappa ,
			center_x-radius , center_y
			 )

c:curve_to(  center_x-radius , center_y-radius*kappa,
			center_x-radius*kappa , center_y-radius ,
			center_x , center_y-radius
			 )
			 		 
c:set_source_color( color )
c:fill(false)
c:stroke(false)
-- Finishes painting on Canvas
c:finish_painting()
if c.Image then
  c = c:Image()
end

return c
end


--[[
Function: button

Creates a button widget

Arguments:
	Table of button properties
	
		skin - Modify the skin for the button by changing this value
    	bwidth  - Width of the button
    	bheight - Height of the button
    	border_color - Border color of the button
    	f_color - Focus color of the button
    	border_width - Border width of the button
    	text - Caption of the button
    	font - Font of the button text
    	color - Color of the button text
    	padding_x - Padding of the button image on the X axis
    	padding_y - Padding of the button image on the Y axis
    	border_radius - Radius of the border for the button
	on_pressed - Function that is called by on_focus_in() or on_key_down() event
	on_release - Function that is called by on_focus_out()


Return:
 	b_group - The group containing the button 

Extra Function:
	on_focus_out() - Releases the button focus
	on_focus_in() - Grabs the button focus
	
]]

function widget.button(table) 

 --default parameters
    local p = {
    	font = "DejaVu Sans 30px",
    	color = {255,255,255,255}, --"FFFFFF",
    	skin = "default", 
    	wwidth = 180,
    	wheight = 60, 

    	label = "Button", 
    	f_color = {27,145,27,255}, --"1b911b", 

    	border_color = {255,255,255,255}, --"FFFFFF"
    	border_width = 1,
    	padding_x = 0,
    	padding_y = 0,
    	border_radius = 12,
	on_pressed = nil, 
	on_released = nil, 
    }

 --overwrite defaults
    if table ~= nil then 
        for k, v in pairs (table) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local ring, focus_ring, text, button, focus 

    local b_group = Group
    {
        name = "button", 
        size = { p.wwidth , p.wheight},
        position = {100, 100, 0},  
        reactive = true,
        extra = {type = "Button"}
    } 

    local create_button = function() 
    

	if(p.skin ~= "custom") then 
		p.button_image = assets(skin_list[p.skin]["button"])
		p.focus_image  = assets(skin_list[p.skin]["button_focus"])
	end
        b_group:clear()
        b_group.size = { p.wwidth , p.wheight}
        ring = make_ring(p.wwidth, p.wheight, p.border_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
        ring:set{name="ring", position = { 0 , 0 }, opacity = 255 }

        focus_ring = make_ring(p.wwidth, p.wheight, p.f_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
        focus_ring:set{name="focus_ring", position = { 0 , 0 }, opacity = 0}

	if(p.skin ~= "custom") then 
            button = assets(skin_list[p.skin]["button"])
            button:set{name="button", position = { 0 , 0 } , size = { p.wwidth , p.wheight } , opacity = 255}
            focus = assets(skin_list[p.skin]["button_focus"])
            focus:set{name="focus", position = { 0 , 0 } , size = { p.wwidth , p.wheight } , opacity = 0}
	else 
	     button = Image{}
	     focus = Image{}
	end 
        text = Text{name = "text", text = p.label, font = p.font, color = p.color} --reactive = true 
        text:set{name = "text", position = { (p.wwidth  -text.w)/2, (p.wheight - text.h)/2}}

        b_group:add(ring, focus_ring, button, focus, text)

        if (p.skin == "custom") then button.opacity = 0 
        else ring.opacity = 0 end 

    end 

    create_button()

    function b_group.extra.on_focus_in() 
        if (p.skin == "custom") then 
	     ring.opacity = 0
	     focus_ring.opacity = 255
        else
	     button.opacity = 0
             focus.opacity = 255
        end 
	if p.on_pressed then 
		p.on_pressed()
	end 

	b_group:grab_key_focus(b_group)
    end
    
    function b_group.extra.on_focus_out() 
        if (p.skin == "custom") then 
	     ring.opacity = 255
	     focus_ring.opacity = 0
             focus.opacity = 0
        else
	     button.opacity = 255
             focus.opacity = 0
	     focus_ring.opacity = 0
        end
	if p.on_released then 
		p.on_released()
	end 
 
    end
	
    mt = {}
    mt.__newindex = function (t, k, v)
        if k == "bsize" then  
	    p.wwidth = v[1] p.wheight = v[2]  
        else 
           p[k] = v
        end
        create_button()
    end 

    mt.__index = function (t,k)
        if k == "bsize" then 
	    return {p.wwidth, p.wheight}  
        else 
	    return p[k]
        end 
    end 

    setmetatable (b_group.extra, mt) 

    return b_group 
end


--[[
Function: textField

Creates a text field widget

Arguments:
	Table of text field properties

		skin - Modify the skin used for the text field by changing this value
    	bwidth  - Width of the text field
    	bheight - Height of the text field 
    	border_color - Border color of the text field
    	f_color - Focus color of the text field
    	border_width - Border width of the text field 
    	text - Caption of the text field  
    	text_indent - Size of the text indentiation 
    	font - Font of the text in the text field
    	color - Color of the text in the text field
    	padding_x - Padding of the button image on the X axis
    	padding_y - Padding of the button image on the Y axis
    	border_radius - Radius of the border for the button image 

Return:
 	t_group - The group contaning the text field
 	
Extra Function:
	on_focus_out() - Releases the text field focus
	on_focus_in() - Grabs the text field focus
	
]]


function widget.textField(table) 
 --default parameters
    local p = {
    	skin = "custom", 
    	wwidth = 200 ,
    	wheight = 60 ,
    	text = "" ,
    	text_indent = 20 ,
    	border_width  = 3 ,
    	border_color  = {255,255,255,255}, --"FFFFFFC0" , 
    	f_color  = {27,145,27,255}, --"1b911b" , 
    	font = "DejaVu Sans 30px"  , 
    	color =  {255,255,255,255}, -- "FFFFFF" , 
    	padding_x = 0 ,
    	padding_y = 0 ,
    	border_radius = 12 ,

    }
 --overwrite defaults
    if table ~= nil then 
        for k, v in pairs (table) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local box, focus_box, box_img, focus_img, text

    local t_group = Group
    {
       name = "t_group", 
       size = { p.wwidth , p.wheight},
       position = {200, 200, 0},  
       reactive = true, 
       extra = {type = "TextInputField"} 
    }
 

    local create_textInputField= function()
 	

	if(p.skin ~= "custom") then 
             p.box_image   = assets(skin_list[p.skin]["textinput"])
	     p.focus_image = assets(skin_list[p.skin]["textinput_focus"])
	end 

    	t_group:clear()
        t_group.size = { p.wwidth , p.wheight}

    	box = make_ring(p.wwidth, p.wheight, p.border_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
    	box:set{name="box", position = { 0 , 0 } }

    	focus_box = make_ring(p.wwidth, p.wheight, p.f_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
    	focus_box:set{name="focus_box", position = { 0 , 0 }, opacity = 0}

	if(p.skin ~= "custom") then 
    	     box_img = assets(skin_list[p.skin]["textinput"])
    	     box_img:set{name="box_img", position = { 0 , 0 } , size = { p.wwidth , p.wheight } , opacity = 0 }
    	     focus_img = assets(skin_list[p.skin]["textinput_focus"])
    	     focus_img:set{name="focus_img", position = { 0 , 0 } , size = { p.wwidth , p.wheight } , opacity = 0 }
	else 
	     box_img = Image{}
	     focus_img = Image{}
	end 

    	text = Text{text = p.text, editable = true, cursor_visible = true, reactive = true, font = p.font, color = p.color}
    	text:set{name = "text", position = {p.text_indent, (p.wheight - text.h)/2} }
    	t_group:add(box, focus_box, box_img, focus_img, text)

    	if (p.skin == "custom") then box_img.opacity = 0
    	else box.opacity = 0 box_img.opacity = 255 end 

     end 

     create_textInputField()

     function t_group.extra.on_focus_in()
          if (p.skin == "custom") then 
	     box.opacity = 0
	     focus_box.opacity = 255
          else
	     box_img.opacity = 0
             focus_img.opacity = 255
          end 
          text:grab_key_focus()
	  text.cursor_visible = true
     end

     function t_group.extra.on_focus_out()
          if (p.skin == "custom") then 
	     box.opacity = 255
	     focus_box.opacity = 0
             focus_img.opacity = 0
          else
	     box_img.opacity = 255
	     focus_box.opacity = 0
             focus_img.opacity = 0
          end 
	  text.cursor_visible = false
     end

     mt = {}
     mt.__newindex = function (t, k, v)
	if k == "bsize" then  
	    p.wwidth = v[1] p.wheight = v[2]  
        else 
           p[k] = v
        end
        create_textInputField()
     end 

     mt.__index = function (t,k)
        if k == "bsize" then 
	    return {p.wwidth, p.wheight}  
        else 
	    return p[k]
        end 
     end 
  
     setmetatable (t_group.extra, mt) 

     return t_group
end 

--[[
Function: dialogBox

Creates a Dialog box widget

Arguments:
	Table of Dialog box properties

		skin - Modify the skin used for the dialog box by changing this value
    	bwidth  - Width of the dialog box 
    	bheight - Height of the dialog box
    	f_color - Fill color of the dialog box
    	border_color - Border color of the dialog box
    	f_color - Focus color of the dialog box
    	border_width - Border width of the dialog box  
    	label - Title in the dialog box
    	font - Font of the text in the dialog box
    	color - Color of the dialog box text 
    	padding_x - Padding of the dialog box on the X axis
    	padding_y - Padding of the dialog box on the Y axis
    	border_radius - The radius of the border of the dialog box

Return:
 	db_group - group containing the dialog box
]]

function widget.dialogBox(table) 
 
--default parameters
   local p = {
	skin = "custom", 
	wwidth = 900 ,
	wheight = 500 ,
	label = "Dialog Box Title" ,
	font = "DejaVu Sans 30px" , 
	color = {255,255,255,255} , --"FFFFFF" , 
	border_width  = 3 ,
	border_color  = {255,255,255,255}, --"FFFFFFC0" , 
	f_color  = {25,25,25,100},
	padding_x = 0 ,
	padding_y = 0 ,
	border_radius = 22 ,
    }

 --overwrite defaults
    if table ~= nil then 
        for k, v in pairs (table) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local db_group_cur_y = 6
    local d_box, x_box, title, d_box_img, x_box_img

    local  db_group = Group {
    	  name = "dialogBox",  
    	  position = {200, 200, 0}, 
          reactive = true, 
          extra = {type = "DialogBox"} 
    }


    local create_dialogBox  = function ()
   
        db_group:clear()
        db_group.size = { p.wwidth , p.wheight - 34}

        d_box = make_dialogBox_bg(p.wwidth, p.wheight, p.border_width, p.border_color, p.f_color, p.padding_x, p.padding_y, p.border_radius) 
	d_box.y = d_box.y - 34
	d_box:set{name="d_box"} 

        x_box = make_xbox()
        x_box:set{name = "x_box", position  = {p.wwidth - 50, db_group_cur_y}}

        title= Text{text = p.label, font= p.font, color = p.color}     
        title:set{name = "title", position = {(p.wwidth - title.w - 50)/2 , db_group_cur_y - 5}}

	if(p.skin ~= "custom") then 
        	d_box_img = assets(skin_list[p.skin]["dialogbox"])
        	d_box_img:set{name="d_box_img", size = { p.wwidth , p.wheight } , opacity = 0}
        	x_box_img = assets(skin_list[p.skin]["dialogbox_x"])
        	x_box_img:set{name="x_box_img", size = { p.wwidth , p.wheight } , opacity = 0}
	else 
		d_box_img = Image{} 
        	x_box_img = Image{} 
	end

	db_group:add(d_box, x_box, title, d_box_img, x_box_img)

	if (p.skin == "custom") then d_box_img.opacity = 0
        else d_box.opacity = 0 end 

     end 

     mt = {}
     mt.__newindex = function (t, k, v)
	 if k == "bsize" then  
	    p.wwidth = v[1] 
	    p.wheight = v[2]  
        else 
           p[k] = v
        end
        create_dialogBox()
     end 

     mt.__index = function (t,k)
	if k == "bsize" then 
	    return {p.wwidth, p.wheight}  
        else 
	    return p[k]
        end 
     end 

     setmetatable (db_group.extra, mt) 
     return db_group
end 

--[[
Function: toastBox

Creates a Toast box widget

Arguments:
	Table of Toast box properties
	
		skin - Modify the skin used for the toast widget by changing this value
		title - Title of the Toast box
		message - Message displayed in the Toast box
    	font - Font used for text in the Toast box
    	color - Color of the text in the Toast box
    	bwidth  - Width of the Toast box 
    	bheight - Height of the Toast box 
    	border_color - Border color of the Toast box
    	f_color - Fill color of the Toast box
    	f_color - Focus color of the Toast box  
    	border_width - Border width of the Toast box 
    	padding_x - Padding of the toast box on the X axis 
    	padding_y - Padding of the toast box on the Y axis
    	border_radius - Radius of the border for the Toast box 
	    fade_duration - Time in milleseconds that the Toast box spends fading away
	    duration - Time in milleseconds that the Toast box spends in view before fading out

Return:
 		tb_group - Group containing the Toast box

Extra Function:
		start_timer() - Start the timer of the Toast box
]]



function widget.toastBox(table) 

 --default parameters
    local p = {
 	skin = "custom",  
	wwidth = 600,
	wheight = 200,
	label = "Toast Box Title",
	message = "Toast box message ... ",
	font = "DejaVu Sans 30px", 
	color = {255,255,255,255},  --"FFFFFF", 
	border_width  = 3,
	border_color  = {255,255,255,255}, -- "FFFFFFC0", 
	f_color  = {25,25,25,100},
	padding_x = 0,
	padding_y = 0,
	border_radius = 22,
	fade_duration = 2000,
	duration = 5000
    }


 --overwrite defaults
    if table ~= nil then 
        for k, v in pairs (table) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local t_box, icon, title, message, t_box_img  
    local tb_group = Group {
    	  name = "toastb_group",  
    	  position = {200, 200, 0}, 
          reactive = true, 
          extra = {type = "ToastBox"} 
     }

    local tb_group_cur_y = 10
    local tb_group_cur_x = 20
    local tb_group_timer = Timer()
    local tb_group_timeline = Timeline ()
    

    local create_toastBox = function()

    	tb_group:clear()
        tb_group.size = { p.wwidth , p.wheight}

    	t_box = make_toastb_group_bg(p.wwidth, p.wheight, p.border_width, p.border_color, p.f_color, p.padding_x, p.padding_y, p.border_radius) 
    	t_box:set{name="t_box"}

        
    	if(p.skin == "custom") then 
		icon = assets("assets/voice-1.png")
    	else 
		icon = assets(skin_list[p.skin]["toast_icon"])
    	end 
    
    	icon:set{size = {100, 100}, name = "icon", position  = {tb_group_cur_x, tb_group_cur_y}} --30,30

    	title= Text{text = p.label, font= "DejaVu Sans 32px", color = "FFFFFF"}     
    	title:set{name = "title", position = {(p.wwidth - title.w - tb_group_cur_x)/2 , tb_group_cur_y+20 }}  --,50

    	message= Text{text = p.message, font= "DejaVu Sans 28px", color = "FFFFFF"}     
    	message:set{name = "message", position = {icon.w + tb_group_cur_x, tb_group_cur_y*3 + title.h }} 

	if(p.skin ~= "custom") then 
    	     t_box_img = assets(skin_list[p.skin]["toast"])
    	     t_box_img:set{name="t_box_img", size = { p.wwidth , p.wheight } , opacity = 255}
	else 
	     t_box_img = Image{}
	end 

	t_box.y = t_box.y -30
	tb_group.h = tb_group.h - 30

    	tb_group:add(t_box, t_box_img, icon, title, message)

    	if (p.skin == "custom") then t_box_img.opacity = 0
    	else t_box.opacity = 0 end 

    	tb_group_timer.interval = p.duration 
    	tb_group_timeline.duration = p.fade_duration
    	tb_group_timeline.direction = "FORWARD"
    	tb_group_timeline.loop = false

     	function tb_group_timeline.on_new_frame(t, m, p)
		tb_group.opacity = 255 * (1-p) 
     	end  

     	function tb_group_timeline.on_completed()
		tb_group.opacity = 0
		tb_group.extra.clean()
     	end 

     	function tb_group_timer.on_timer(tb_group_timer)
		tb_group_timeline:start()
        	tb_group_timer:stop()
     	end 
     end 

     create_toastBox()

       
     function tb_group.extra.start_timer() 
	tb_group_timer:start()
     end 
    
     mt = {}
     mt.__newindex = function (t, k, v)
        if k == "bsize" then  
	    p.wwidth = v[1] p.wheight = v[2]  
        else 
           p[k] = v
        end
        create_toastBox()
     end 

     mt.__index = function (t,k)
        if k == "bsize" then 
	    return {p.wwidth, p.wheight}  
        else 
	    return p[k]
        end 
     end 
 
     setmetatable (tb_group.extra, mt) 

     return tb_group
end 

--[[
Function: buttonPicker

Creates a button picker widget

Arguments:
	Table of Button picker properties

	skin - Modify the skin for the Button picker by changing this value
    	bwidth - Width of the Button picker 
    	bheight - Height of the Button picker 
        items - A table containing the items for the Button picker
    	font - Font of the Button picker items
    	color - Color of the Button picker items
		selected_item - The number of the selected item 
		rotate_func - Table of functions that is called by selected item number   

Return:
 		bp_group - Group containing the button picker 

Extra Function:
		on_focus_in() - Grab focus of button picker 
		on_focus_out() - Release focus of button picker
		press_left() - Left key press event, apply the selection of button picker
		press_right() - Right key press event, apply the selection of button picker
		press_up() - Up key press event, apply the selection of button picker
		press_down() - Down key press event, apply the selection of button picker
		press_enter() - Enter key press event, apply the selection of button picker
		insert_item(item) - Add an item to the items table 
		remove_item(item) - Remove an item from the items table 
]]
function widget.buttonPicker(table) 
    local w_scale = 1
    local h_scale = 1

 --default parameters 
    local p = {
	skin = "default", 
	wwidth =  180,
	wheight = 60,
	items = {"item1", "item2", "item3"},
	font = "DejaVu Sans 30px" , 
	color = {255,255,255,255}, --"FFFFFF", 
	rotate_func = {}, 
        selected_item = 1, 
    }

 --overwrite defaults
     if table ~= nil then 
        for k, v in pairs (table) do
	    p[k] = v 
        end 
     end 
     
 --the umbrella Group
     local unfocus, focus, left_un, left_sel, right_un, right_sel
     local items = Group{name = "items"}

     bp_group = Group
     {
	name = "buttonPicker", 
	position = {300, 300, 0}, 
        reactive = true, 
	extra = {type = "ButtonPicker"}
     }

     local index 

     local padding = 10 
     --local pos = {26, 0} -- left arrow 
     local pos = {0, 0}    -- focus, unfocus 
     local t = nil

     local create_buttonPicker = function() 

	index = p.selected_item 
	bp_group:clear()
        bp_group.size = { p.wwidth , p.wheight}

	ring = make_ring(p.wwidth, p.wheight, "FFFFFF", 1, 7, 7, 12)
        ring:set{name="ring", position = {pos[1] , pos[2]}, opacity = 255 }

        focus_ring = make_ring(p.wwidth, p.wheight, {0, 255, 0, 255}, 1, 7, 7, 12)
        focus_ring:set{name="focus_ring", position = {pos[1], pos[2]}, opacity = 0}


	if p.skin == "custom" then 
     	    unfocus = assets(skin_list["default"]["buttonpicker"])
     	    focus = assets(skin_list["default"]["buttonpicker_focus"])
            left_un   = assets(skin_list["default"]["buttonpicker_left_un"])
	    left_sel  = assets(skin_list["default"]["buttonpciker_left_sel"])
	    right_un  = assets(skin_list["default"]["buttonpicker_right_un"])
            right_sel = assets(skin_list["default"]["buttonpicker_right_sel"])
	else 
     	    unfocus = assets(skin_list[p.skin]["buttonpicker"])
     	    focus = assets(skin_list[p.skin]["buttonpicker_focus"])
	    left_un   = assets(skin_list[p.skin]["buttonpicker_left_un"])
	    left_sel  = assets(skin_list[p.skin]["buttonpciker_left_sel"])
	    right_un  = assets(skin_list[p.skin]["buttonpicker_right_un"])
            right_sel = assets(skin_list[p.skin]["buttonpicker_right_sel"])
 	end 

	left_un.scale = {w_scale, h_scale}
	left_sel.scale = {w_scale, h_scale}
	right_un.scale = {w_scale, h_scale}
	right_sel.scale = {w_scale, h_scale}

	left_un:set{name = "left_un", position = {pos[1] - left_un.w*w_scale - padding, pos[2] + p.wheight/5}, opacity = 255, reactive = true}
	left_sel:set{position = {pos[1] - left_un.w*w_scale - padding, pos[2] + p.wheight/5}, opacity = 0}
	right_un:set{name = "right_un", position = {pos[1] + focus_ring.w + padding, pos[2] + p.wheight/5}, opacity = 255, reactive = true}
	right_sel:set{position = {right_un.x, right_un.y},  opacity = 0}

     	unfocus:set{name = "unfocus",  position = {pos[1], pos[2]}, size = {p.wwidth, p.wheight}, opacity = 255, reactive = true}
	focus:set{name = "focus",  position = {pos[1], pos[2]}, size = {p.wwidth, p.wheight}, opacity = 0}

     	for i, j in pairs(p.items) do 
               items:add(Text{name="item"..tostring(i), text = j, font=p.font, color =p.color, opacity = 255})     
     	end 

	local j_padding

	for i, j in pairs(items.children) do 
	  if i == p.selected_item then  -- i == 1
               j.position = {p.wwidth/2 - j.width/2, p.wheight/2 - j.height/2}
	       j_padding = 5 * j.x -- 5 는 진정한 해답이 아니고.. 이걸 바꿔 줘야함.. 그리고 박스 크기가 문자열과 비례해서 적당히 커줘야하고.. ^^;;;
	  else 
               --j.position = {p.wwidth/2 - j.width/2 + j_padding, p.wheight/2 - j.height/2}
	  end 
     	end 

	for i, j in pairs(items.children) do 
	  if i > p.selected_item then  -- i == 1
               j.position = {p.wwidth/2 - j.width/2 + j_padding, p.wheight/2 - j.height/2}
	  end 
     	end 

	for i, j in pairs(items.children) do 
	  if i < p.selected_item then  -- i == 1
               j.position = {p.wwidth/2 - j.width/2 + j_padding, p.wheight/2 - j.height/2}
	  end 
     	end 

	items.clip = { 0, 0, p.wwidth, p.wheight }

   	bp_group:add(ring, focus_ring, unfocus, focus, right_un, right_sel, left_un, left_sel, items) 

	if(p.skin == "custom") then unfocus.opacity = 0 
        else ring.opacity = 0 end 

        t = nil
     end 
 
     create_buttonPicker()

     function bp_group.extra.on_focus_in()
	if(p.skin == "custom") then 
             ring.opacity = 0 
	     focus_ring.opacity = 255
        else 
             unfocus.opacity = 0
	     focus.opacity   = 255
	end 

     end
     function bp_group.extra.on_focus_out()
	if(p.skin == "custom") then 
             ring.opacity = 255 
	     focus_ring.opacity = 0
	else 
            unfocus.opacity = 255
	    focus.opacity   = 0
	end 
     end

     function bp_group.extra.press_left()
            local prev_i = index

            local next_i = (index-2)%(#p.items)+1

	    index = next_i

	    local j = (bp_group:find_child("items")):find_child("item"..tostring(index))
	    local prev_old_x = p.wwidth/2 - j.width/2
	    local prev_old_y = p.wheight/2 - j.height/2
	    local next_old_x = p.wwidth/2 - j.width/2 + focus.w
	    local next_old_y = p.wheight/2 - j.height/2
	    local prev_new_x = p.wwidth/2 - j.width/2 - focus.w
	    local prev_new_y = p.wheight/2 - j.height/2
	    local next_new_x = p.wwidth/2 - j.width/2
	    local next_new_y = p.wheight/2 - j.height/2



	    if t ~= nil then
	       t:stop()
	       t:on_completed()
	    end
	    t = Timeline
	    {
	       duration = 300,
	       direction = "FORWARD",
	       loop = false
	    }

	    function t.on_new_frame(t,msecs,p)
			if msecs <= 100 then
				left_sel.opacity = 255* msecs/100
			elseif msecs <= 200 then
				left_sel.opacity = 255
			else 
				left_sel.opacity = 255*(1- (msecs-200)/100)
			end
			items:find_child("item"..tostring(prev_i)).x = prev_old_x + p*(prev_new_x - prev_old_x)
			items:find_child("item"..tostring(prev_i)).y = prev_old_y + p*(prev_new_y - prev_old_y)
			items:find_child("item"..tostring(next_i)).x = next_old_x + p*(next_new_x - next_old_x)
			items:find_child("item"..tostring(next_i)).y = next_old_y + p*(next_new_y - next_old_y)
	    end
	    function t.on_completed()
			items:find_child("item"..tostring(prev_i)).x = prev_new_x
			items:find_child("item"..tostring(prev_i)).y = prev_new_y
			items:find_child("item"..tostring(next_i)).x = next_new_x
			items:find_child("item"..tostring(next_i)).y = next_new_y
			p.selected_item = next_i
			if p.rotate_func then
	       		     p.rotate_func(next_i)
	    		end

			t = nil
	    end
	   
	    t:start()
	end

	function bp_group.extra.press_right()
	    local prev_i = index
	    --local next_i = (index+1-1)%(table.getn(p.items)) + 1
            local next_i = (index)%(#p.items)+1
	    index = next_i

	    local j = (bp_group:find_child("items")):find_child("item"..tostring(index))
	    local prev_old_x = p.wwidth/2 - j.width/2
	    local prev_old_y = p.wheight/2 - j.height/2
	    local next_old_x = p.wwidth/2 - j.width/2 - focus.w
	    local next_old_y = p.wheight/2 - j.height/2
	    local prev_new_x = p.wwidth/2 - j.width/2 + focus.w
	    local prev_new_y = p.wheight/2 - j.height/2
	    local next_new_x = p.wwidth/2 - j.width/2
	    local next_new_y = p.wheight/2 - j.height/2

	    if t ~= nil then
		t:stop()
		t:on_completed()
     	    end

	    t = Timeline {
	        duration = 300,
		direction = "FORWARD",
		loop = false
	    }

	    function t.on_new_frame(t,msecs,p)
	        if msecs <= 100 then
		     right_sel.opacity = 255* msecs/100
		elseif msecs <= 200 then
		     right_sel.opacity = 255
		else 
		     right_sel.opacity = 255*(1- (msecs-200)/100)
		end

		items:find_child("item"..tostring(prev_i)).x = prev_old_x + p*(prev_new_x - prev_old_x)
		items:find_child("item"..tostring(prev_i)).y = prev_old_y + p*(prev_new_y - prev_old_y)
		items:find_child("item"..tostring(next_i)).x = next_old_x + p*(next_new_x - next_old_x)
		items:find_child("item"..tostring(next_i)).y = next_old_y + p*(next_new_y - next_old_y)
	    end
	    function t.on_completed()
	        items:find_child("item"..tostring(prev_i)).x = prev_new_x
		items:find_child("item"..tostring(prev_i)).y = prev_new_y
		items:find_child("item"..tostring(next_i)).x = next_new_x
		items:find_child("item"..tostring(next_i)).y = next_new_y
		p.selected_item = next_i
		if p.rotate_func then
	       	     p.rotate_func(next_i)
	    	end
		t = nil
	    end
	    t:start()
	end

 	function bp_group.extra.press_up()
	end
	function bp_group.extra.press_down()
	end
	function bp_group.extra.press_enter()
	end

	function bp_group.extra.insert_item(itm) 
		table.insert(p.items, itm) 
		create_buttonPicker()
        end 

	function bp_group.extra.remove_item() 
		table.remove(p.items)
		create_buttonPicker()
        end 
	--bp_group.out_focus()
        
        mt = {}
        mt.__newindex = function (t, k, v)

             if k == "bsize" then  
	    	p.wwidth = v[1] 	
		p.wheight = v[2]  
		w_scale = v[1]/180
		h_scale = v[2]/60
             elseif k == "wwidth" then 
		w_scale = v/180
                p[k] = v
	     elseif k == "wheight" then   
		h_scale = v/60
                p[k] = v
	     else 
                p[k] = v
             end
	     if k ~= "selected" and k ~= "org_x"  and k ~= "org_y" and 
		k ~= "is_in_group" and k ~= "group_position" then 
                 create_buttonPicker()
	     end 
        end 

        mt.__index = function (t,k)
             if k == "bsize" then 
	        return {p.wwidth, p.wheight}  
             else 
	        return p[k]
             end 
        end 

        setmetatable (bp_group.extra, mt) 

        return bp_group 
end


--[[
Function: radioButton

Creates a Radio button widget

Arguments:
	Table of Radio button properties

	skin - Modify the skin for the Radio button by changing this value  
    bwidth - Width of the Radio button 
    bheight - Height of the Radio button 
	items - Table of Radio button items
    font - Font of the Radio button items
    color - Color of the Radio button items
	button_color - Color of the Radio button
	select_color - Color of the selected Radio button
	button_radius - Radius of the Radio button
	select_radius - Radius of the selected Radio button
	ring_pos - The position of the group of Radio buttons 
	item_pos - The position of the group of text items 
	line_space - The space between the text items 
	selected_item - Selected item's number 
	rotate_func - function that is called by selceted item number

Return:
 	rb_group - Group containing the radio button 

Extra Function:
	insert_item(item) - Add an item to the items table
	remove_item(item) - Remove an item from the items table 
]]


function widget.radioButton(table) 

 --default parameters
    local p = {
	skin = "custom", 
	wwidth = 600,
	wheight = 200,
	items = {"item1", "item2", "item3"},
	font = "DejaVu Sans 30px", -- items 
	color = {255,255,255,255}, --"FFFFFF", -- items 
	button_color = {255,255,255,200}, -- items 
	select_color = {100, 100, 100, 255}, -- items 
	button_radius = 10, -- items 
	select_radius = 5,  -- items 
	b_pos = {0, 0},  -- items 
	item_pos = {50,-5},  -- items 
	line_space = 40,  -- items 
	button_image = Image{}, --assets("assets/radiobutton.png"),
	select_image = Image{}, --assets("assets/radiobutton_selected.png"),
	rotate_func = nil, 
	direction = 1, 
	selected_item = 1 
    }

 --overwrite defaults
    if table ~= nil then 
        for k, v in pairs (table) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local items = Group()
    local rings = Group() 
    local select_img

    local rb_group = Group {
          name = "radioButton",  
    	  position = {200, 200, 0}, 
          reactive = true, 
          extra = {type = "RadioButton"}
     }

    local create_radioButton = function() 

	if(p.skin ~= "custom") then 
	 p.button_image = assets(skin_list[p.skin]["radiobutton"])
	 p.select_image = assets(skin_list[p.skin]["radiobutton_sel"])
	end

         rb_group:clear()
         rings:clear()
         items:clear()
         --rb_group.size = { p.wwidth , p.wheight},
	
         if(p.skin == "custom") then 
	     select_img = create_select_circle(p.select_radius, p.select_color)
         else 
    	     select_img = p.select_image
         end 
    
         select_img:set{name = "select_img", position = {0,0}, opacity = 255} 

	 local pos = {0,0}
         for i, j in pairs(p.items) do 
	      if(p.direction == 1) then --vertical 
                  pos= {0, i * p.line_space - p.line_space}
	      end   	
              items:add(Text{name="item"..tostring(i), text = j, font=p.font, color =p.color, position = pos})     
	      if p.skin == "custom" then 
    	           rings:add(create_circle(p.button_radius, p.button_color):set{name="ring"..tostring(i), position = {pos[1], pos[2] - 8}} ) 
	      else
	           rings:add(Clone{name = "item"..tostring(i),  source=p.button_image, position = {pos[1], pos[2] - 8}}) 
	      end 

	      if(p.direction == 2) then --horizontal
		  pos= {pos[1] + items:find_child("item"..tostring(i)).w + 2*p.line_space, 0}
	      end 

         end 
	 rings:set{name = "rings", position = p.b_pos} 
	 items:set{name = "items", position = p.item_pos} 
     	 select_img.x  = items:find_child("item"..tostring(p.selected_item)).x + 10
     	 select_img.y  = items:find_child("item"..tostring(p.selected_item)).y + 2 

	 rb_group:add(rings, items, select_img)

     end

     create_radioButton()

     function rb_group.extra.select_button(item_n) 
	    p.selected_item = item_n
            if p.rotate_func then
	       p.rotate_func(p.selected_item)
	    end
     end 

     function rb_group.extra.insert_item(itm) 
	table.insert(p.items, itm) 
	create_radioButton()
     end 

     function rb_group.extra.remove_item() 
	table.remove(p.items)
	create_radioButton()
     end 


     mt = {}
     mt.__newindex = function (t, k, v)
	if k == "bsize" then  
	    p.wwidth = v[1] p.wheight = v[2]  
        else 
           p[k] = v
        end
        create_radioButton()
     end 

     mt.__index = function (t,k)
	if k == "bsize" then 
	    return {p.wwidth, p.wheight}  
        else 
	    return p[k]
        end 
     end 
  
     setmetatable (rb_group.extra, mt)

     return rb_group
end 




--[[
Function: checkBox

Creates a Check box widget

Arguments:
	Table of Check box properties
		skin - Modify the skin for the button by changing this value   
    	bwidth - Width of the Check box 
    	bheight - Height of the Check box
		items - Table of Check box items
    	font - Font of the Check box items
    	color - Color of the Check box items
		box_color - Color of the Check box border 
		f_color - the color of the Check box 
		box_width - Width of Check box border
		box_size - The size of Check box 
        check_size - The size of Check image 
		box_pos - Postion of the group of check boxes
		item_pos - Position of the group of text items 
		line_space - Space between the text items 
		selected_item - Selected item's number 
		rotate_func - function that is called by selected item number   
		direction - Option of list direction (1=Vertical, 2=Horizontal)


Return:
		rb_group - Group containing the check box  

Extra Function:
		insert_item(item) - Add an item to the items table 
		remove_item(item) - Remove an item from the items table 
]]


function widget.checkBox(table) 

 --default parameters
    local p = {
	skin = "custom", 
	wwidth = 600,
	wheight = 200,
	items = {"item1", "item2", "item3"},
	font = "DejaVu Sans 30px", -- items 
	color = {255,255,255,255}, -- "FFFFFF", -- items 
	box_color = {255,255,255,255},
	f_color = {255,255,255,50},
	box_width = 2,
	box_size = {25,25},
	check_size = {25,25},
	line_space = 40,   
	b_pos = {0, 0},  -- items 
	item_pos = {50,-5},  -- items 
	selected_item = {1, 3},  
	direction = 2, 
	rotate_func = {},  
    } 

 --overwrite defaults
    if table ~= nil then 
        for k, v in pairs (table) do
	    p[k] = v 
        end 
    end

 --the umbrella Group
    local check_image
    local checks = Group()
    local items = Group()
    local boxes = Group() 
    local cb_group = Group()

    local  cb_group = Group {
    	  name = "checkBox",  
    	  position = {200, 200, 0}, 
          reactive = true, 
          extra = {type = "CheckBox"}
     }


    local function create_checkBox()

	 items:clear() 
	 checks:clear() 
	 boxes:clear() 
	 cb_group:clear()

	 if(p.skin ~= "custom") then 
             p.box_image = assets(skin_list[p.skin]["checkbox"])
             p.check_image = skin_list[p.skin]["check"]
	 else 
	     p.box_image = Image{}
             p.check_image = "assets/checkmark.png"
	 end
	
	 boxes:set{name = "boxes", position = p.b_pos} 
	 checks:set{name = "checks", position = p.b_pos} 
	 items:set{name = "items", position = p.item_pos} 

         local pos = {0, 0}
         for i, j in pairs(p.items) do 
	       
	      if(p.direction == 1) then --vertical 
                  pos= {0, i * p.line_space - p.line_space}
	      end   			

	      items:add(Text{name="item"..tostring(i), text = j, font=p.font, color = p.color, position = pos})     
	      if p.skin == "custom" then 
    	           boxes:add(Rectangle{name="box"..tostring(i),  color= p.f_color, border_color= p.box_color, border_width= p.box_width, 
				       size = p.box_size, position = pos, opacity = 255}) 
	           checks:add(Image{name="check"..tostring(i), src=p.check_image, size = p.check_size, position = pos, opacity = 0}) 
	      else
	           boxes:add(Clone{name = "item"..tostring(i),  source=p.button_image, size = p.box_size, position = pos, opacity = 255}) 
	           checks:add(Image{name = "check"..tostring(i),  src=p.check_image, size = p.check_size, position = pos, opacity = 0}) 
	      end 

	      if(p.direction == 2) then --horizontal
		  pos= {pos[1] + items:find_child("item"..tostring(i)).w + 2*p.line_space, 0}
	      end 
         end 

	 for i,j in pairs(p.selected_item) do 
             checks:find_child("check"..tostring(j)).opacity = 255 
	 end 

	 cb_group:add(boxes, items, checks)
    end
    
    create_checkBox()


    function cb_group.extra.insert_item(itm) 
	table.insert(p.items, itm) 
	create_checkBox()
    end 

    function cb_group.extra.remove_item() 
	table.remove(p.items)
	create_checkBox()
    end 

    mt = {}
    mt.__newindex = function (t, k, v)
    	if k == "bsize" then  
	    p.wwidth = v[1] p.wheight = v[2]  
        else 
           p[k] = v
        end
        create_checkBox()
    end 

    mt.__index = function (t,k)
        if k == "bsize" then 
	    return {p.wwidth, p.wheight}  
        else 
	    return p[k]
        end 
    end 

    setmetatable (cb_group.extra, mt)
     
    return cb_group
end 


--[[
Function: Loading Dots

Creates a Loading dots widget

Arguments:
	Table of Loading dots box properties
		dot_radius - Radius of the individual dots
		dot_color - Color of the individual dots
		num_dots - Number of dots in the loading circle
		anim_radius - Radius of the circle of dots
		anim_duration - Millisecs spent on a dot, this number times the number of dots is the time for the animation to make a full circle

Return:

	loading_dots_group - Group containing the loading dots
    
Extra Function:
	speed_up() - spin faster
	speed_down() - spin slower
]]
 
---[[
function widget.loadingdots(t) 
    --default parameters
    local p = {
        skin          = "default",
        dot_radius    = 5,
        dot_color     = "#FFFFFF",
        num_dots      = 12,
        anim_radius   = 50,
        anim_duration = 150,
        clone_src     = nil
    }
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end

    local create_dots
    
    --the umbrella Group
    local l_dots = Group{ 
        name     = "loadingdots",
        position = {400,400},
        anchor_point = {p.radius,p.radius},
        reactive = true,
        extra = {
            type = "LoadingDots", 
            speed_up = function()
                p.anim_duration = p.anim_duration - 20
                create_dots()
            end,
            speed_down = function()
                p.anim_duration = p.anim_duration + 20
                create_dots()
            end,
        },
    }
    --table of the dots, used by the animation
    local dots   = {}
    local load_timeline = nil
    
    --the Canvas used to create the dots
    local make_dot = function(x,y)
          local dot  = Canvas{size={2*p.dot_radius, 2*p.dot_radius}}
          dot:begin_painting()
          dot:arc(p.dot_radius,p.dot_radius,p.dot_radius,0,360)
          dot:set_source_color(p.dot_color)
          dot:fill(true)
          dot:finish_painting()

          if dot.Image then
              dot = dot:Image()
          end
          dot.anchor_point ={p.dot_radius,p.dot_radius}
          dot.name         = "Loading Dot"
          dot.position     = {x,y}
	  

          return dot
    end
    local img
    --function used to remake the dots upon a parameter change
    create_dots = function()
        l_dots:clear()
        dots = {}
	
        local rad
        
        for i = 1, p.num_dots do
            --they're radial position
            rad = (2*math.pi)/(p.num_dots) * i
            print(p.clone_src)
            if p.clone_src == nil and skin_list[p.skin]["loadingdot"] == nil then
                print(1)
                dots[i] = make_dot(
                    math.floor( p.anim_radius * math.cos(rad) )+p.anim_radius+p.dot_radius,
                    math.floor( p.anim_radius * math.sin(rad) )+p.anim_radius+p.dot_radius
                )
	    elseif skin_list[p.skin]["loadingdot"] ~= nil then
		img = assets(skin_list[p.skin]["loadingdot"])
		img.anchor_point = {
                        img.w/2,
                        img.h/2
                    }
		img.position = {

                        math.floor( p.anim_radius * math.cos(rad) )+p.anim_radius+p.dot_radius,
                        math.floor( p.anim_radius * math.sin(rad) )+p.anim_radius+p.dot_radius
                    }
		dots[i] = img
            else
                print(2)
                dots[i] = Clone{
                    source = p.clone_src,
                    position = {

                        math.floor( p.anim_radius * math.cos(rad) )+p.anim_radius+p.dot_radius,
                        math.floor( p.anim_radius * math.sin(rad) )+p.anim_radius+p.dot_radius
                    },
                    anchor_point = {
                        p.clone_src.w/2,
                        p.clone_src.h/2
                    }
                }
            end
            l_dots:add(dots[i])
        end
        
        -- the animation timeline
        if load_timeline ~= nil and load_timeline.is_playing then
            load_timeline:stop()
            load_timeline = nil
        end
        local load_timeline = Timeline
        {
            name      = "Loading Animation",
            loop      =  true,
            duration  =  p.anim_duration * (p.num_dots),
            direction = "FORWARD", 
        }

	-- table.insert( fff , load_timeline )

        local increment = math.ceil(255/p.num_dots)
        
        function load_timeline.on_new_frame(t)
            local start_i   = math.ceil(t.elapsed/p.anim_duration)
            local curr_i    = nil
            
            for i = 1, p.num_dots do
                curr_i = (start_i + (i-1))%(p.num_dots) +1
                
                dots[curr_i].opacity = increment*i
            end
            
        end
        load_timeline:start()

	
    end
    create_dots()


    local mt = {}
    mt.__newindex = function(t,k,v)
       p[k] = v
       create_dots()
    end
    mt.__index = function(t,k)       
       return p[k]
    end
    setmetatable(l_dots.extra, mt)
    return l_dots
end

--]]



--[[
Function: Loading Bar

Creates a Loading bar widget

Arguments:
	Table of Loading bar properties
		bsize - Size of the loading bar
		shell_upper_color - The upper color for the inside of the loading bar
		shell_lower_color - The upper color for the inside of the loading bar
		stroke_color - Color for the border
		fill_upper_color - The upper color for the loading bar fill
		fill_lower_color - The lower color for the loading bar fill

Return:

		loading_bar_group - Group containing the loading bar
        
Extra Function:
	set_prog(prog) - set the progress of the loading bar (meant to be called in an on_new_frame())
]]

---[[
function widget.loadingbar(t)

    --default parameters
    local p={
        bsize     = {300, 50},
        shell_upper_color  = "000000",
        shell_lower_color  = "7F7F7F",
        stroke_color       = "A0A0A0",
        fill_upper_color  = "FF0000",
        fill_lower_color  = "603030",
    }
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end

	

	local c_shell = Canvas{
            size = {p.bsize[1],p.bsize[2]},
            x    = p.bsize[1],
            y    = p.bsize[2]
        }
	local c_fill  = Canvas{
            size = {1,p.bsize[2]},
            x    = p.bsize[1]+2,
            y    = p.bsize[2]
        }
	local l_bar_group = Group{
		name     = "loadingbar",
        	position = {400,400},
	        anchor_point = {p.radius,p.radius},
        	reactive = true,
	        extra = {
        	    type = "LoadingBar", 
        	    set_prog = function(prog)
	                c_fill.scale = {(p.bsize[1]-4)*(prog),1}
        	    end,
	        },
	}

	local function create_loading_bar()
		l_bar_group:clear()
		c_shell = Canvas{
				size = {p.bsize[1],p.bsize[2]},
		}
		c_fill  = Canvas{
				size = {1,p.bsize[2]},
		}  
        
		local stroke_width = 2
		local RAD = 6
        
		local top    = math.ceil(stroke_width/2)
		local bottom = c_shell.h - math.ceil(stroke_width/2)
		local left   = math.ceil(stroke_width/2)
		local right  = c_shell.w - math.ceil(stroke_width/2)
        
		c_shell:begin_painting()
        
		
		c_shell:move_to(        left,         top )
		c_shell:line_to(   right-RAD,         top )
		c_shell:curve_to( right, top,right,top,right,top+RAD)
		c_shell:line_to(       right,  bottom-RAD )
		c_shell:curve_to( right,bottom,right,bottom,right-RAD,bottom)
        
		c_shell:line_to(           left+RAD,          bottom )
		c_shell:curve_to(left,bottom,left,bottom,left,bottom-RAD)
		c_shell:line_to(           left,            top+RAD )
		c_shell:curve_to(left,top,left,top,left+RAD,top)
        
		c_shell:set_source_linear_pattern(
			c_shell.w/2,0,
			c_shell.w/2,c_shell.h
		)
		c_shell:add_source_pattern_color_stop( 0 , p.shell_upper_color )
		c_shell:add_source_pattern_color_stop( 1 , p.shell_lower_color )
        
		c_shell:fill(true)
		c_shell:set_line_width(   stroke_width )
		c_shell:set_source_color( p.stroke_color )
		c_shell:stroke( true )
		c_shell:finish_painting()
        
        
        
		c_fill:begin_painting()
        
		c_fill:move_to(-1,    top )
		c_fill:line_to( 2,    top )
		c_fill:line_to( 2, bottom )
		c_fill:line_to(-1, bottom )
		c_fill:line_to(-1,    top )
        
		c_fill:set_source_linear_pattern(
			c_shell.w/2,0,
			c_shell.w/2,c_shell.h
		)
		c_fill:add_source_pattern_color_stop( 0 , p.fill_upper_color )
		c_fill:add_source_pattern_color_stop( 1 , p.fill_lower_color )
		c_fill:fill(true)
		c_fill:finish_painting()
		if c_shell.Image then
			c_shell = c_shell:Image()
		end
		if c_fill.Image then
			c_fill = c_fill:Image()
		end
		l_bar_group:add(c_shell,c_fill)
	end
    
	create_loading_bar()
    
    
    
    
	local mt = {}
    
    mt.__newindex = function(t,k,v)
        p[k] = v
        create_loading_bar()
    end
    
    mt.__index = function(t,k)       
        return p[k]
    end
    
    setmetatable(l_bar_group.extra, mt)
    
	return l_bar_group
end
--[[
Function: 3D List

Creates a 2D grid of items, that animate in with a flipping animation

Arguments:
    num_rows    - number of rows
    num_cols    - number of columns
    item_w      - width of an item
    item_h      - height of an item
    grid_gap    - the number of pixels in between the grid items
	duration_per_tile - how long a particular tile flips for
	cascade_delay     - how long a tile waits to start flipping after its neighbor began flipping

Return:

		Group - Group containing the grid
        
Extra Function:
	get_tile_group(r,c) - returns group for the tile at row 'r' and column 'c'
    animate_in() - performs the animate-in sequence
]]
function widget.threeDlist(t)
    --default parameters
    local p = {
        num_rows    = 4,
        num_cols    = 3,
        item_w      = 300,
        item_h      = 200,
        grid_gap    = 40,
		duration_per_tile = 300,
		cascade_delay     = 200, 
    }
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
	
	local tiles = {}

    --the umbrella Group, containing the full slate of tiles
    local slate = Group{ 
        name     = "3D List",
        position = {200,100},
	reactive = true,
        extra    = {
			type = "3D_List",
            reactive = true,
			get_tile_group = function(r,c)
				return tiles[r][c]
			end,
            insert = function(r,c,obj)
                if tiles[r][c] == nil then
                    return false
                else
                    tiles[r][c]:add(obj)
                    return true
                end
			end,
            clear_group = function(r,c)
                if tiles[r][c] == nil then
                    return false
                else
                    tiles[r][c]:clear()
                    return true
                end
            end,
            animate_in = function()
				local tl = Timeline{
					duration =p.cascade_delay*(p.num_rows+p.num_cols-2)+ p.duration_per_tile
				}
				function tl:on_started()
					for r = 1, p.num_rows  do
						for c = 1, p.num_cols do
							tiles[r][c].y_rotation={90,0,0}
							tiles[r][c].opacity = 0
						end
					end
				end
				function tl:on_new_frame(msecs,prog)
					msecs = tl.elapsed
					local item
					for r = 1, p.num_rows  do
						for c = 1, p.num_cols do
							item = tiles[r][c] 
							if msecs > item.delay and msecs < (item.delay+p.duration_per_tile) then
								prog = (msecs-item.delay) / p.duration_per_tile
								item.y_rotation = {90*(1-prog),0,0}
								item.opacity = 255*prog
							elseif msecs > (item.delay+p.duration_per_tile) then
								item.y_rotation = {0,0,0}
								item.opacity = 255
							end
							
						end
					end
				end
				function tl:on_completed()
					for r = 1, p.num_rows  do
						for c = 1, p.num_cols do
							tiles[r][c].y_rotation={0,0,0}
							tiles[r][c].opacity = 255
						end
					end
				end
				tl:start()
            end
        }
    }


	local make_tile = function()
		local group = Group{anchor_point = {p.item_w/2,p.item_h/2}}
		local rect  = Rectangle{name="Base_Rect",w=p.item_w,h=p.item_h,color="303030"}
		group:add(rect)
		return group
	end
	local x_y_from_index = function(r,c)
		return (p.item_w+p.grid_gap)*(c-1)+p.item_w/2,
		       (p.item_h+p.grid_gap)*(r-1)+p.item_h/2
	end
	local make_grid = function()
        
		local g
		for r = 1, p.num_rows  do
            if tiles[r] == nil then tiles[r] = {} end
			for c = 1, p.num_cols do
                if tiles[r][c] == nil then
                    g = make_tile()
                    slate:add(g)
                    tiles[r][c] = g
                else
                    g = tiles[r][c]
                    if g:find_child("Base_Rect") ~= nil then
                        g:find_child("Base_Rect").size = {p.item_w,p.item_h}
                    end
                end
                g.x, g.y = x_y_from_index(r,c)
                g.delay = p.cascade_delay*(r+c-1)
			end
		end
        
        if p.num_rows < #tiles then
            for r = p.num_rows + 1, #tiles do
                for c = 1, #tiles[r] do
                    tiles[r][c]:unparent()
                    tiles[r][c] = nil
                end
                tiles[r] = nil
            end
        end
        if p.num_cols < #tiles[1] then
            for c = p.num_cols + 1, #tiles[r] do
                for r = 1, #tiles do
                    tiles[r][c]:unparent()
                    tiles[r][c] = nil
                end
            end
        end
	end
	make_grid()

    


    mt = {}
    mt.__newindex = function(t,k,v)
		
       p[k] = v
       make_grid()
		
    end
    mt.__index = function(t,k)       
       return p[k]
    end
    setmetatable(slate.extra, mt)
    return slate
end
--[[
Function: Scroll Window

Creates a clipped window that can be scrolled

Arguments:
    clip_w    - width of the clip
    clip_h    - height of the clip
	color     - color of the frame and scrolling items
	border_w  - width of the border
    content_h - height of the group that holds the content being scrolled
	content_w - width of the group that holds the content being scrolled
	arrow_clone_source - a Trickplay object that is to be cloned to replace the scroll arrows
	arrow_sz  - size of the scroll arrows
    arrows_in_box - a flag, setting to true positions the arrows inside the border
    arrows_centered - a flag, setting to true positions the arrows along the center axises
    grip_is_visible - a flag that either makes the grips of the scroll bars visible or invisible
    border_is_visible - a flag that either makes the border visible or invisible
Return:

		Group - Group containing the grid
        
Extra Function:
	on_key_down(key) - contains the scrolling functions for pressing left, right, up, down
    get_content_group() - returns the content group, so that things can be added
]]
function widget.scrollWindow(t)

	-- reference: http://www.csdgn.org/db/179

    --default parameters
    local p = {
        clip_w    =  600,
		color     = "FFFFFF",
        clip_h    =  600,
		border_w  =    2,
        content   = Group{},
        content_h =  1000,
		content_w =  1000,
		arrow_clone_source = nil,
		arrow_sz  = 10,
		arrows_in_box = false,
		arrows_centered = false,
		grip_is_visible = true,
        border_is_visible = true
    }
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
	
	--Group that Clips the content
	local window  = Group{}
	--Group that contains all of the content
	--local content = Group{}
	--declarations for dependencies from scroll_group
	local scroll
	--flag to hold back key presses while animating content group
	local animating = false

	
	

    --the umbrella Group, containing the full slate of tiles
    local scroll_group = Group{ 
        name     = "Scroll clip",
        position = {200,100},
        reactive = true,
        extra    = {
			type = "ScrollImage",
            --[[
			get_content_group = function()
				return content
			end
            --]]
        }
    }
	
	--Key Handler
	local keys={
		[keys.Left] = function()
			if p.content_w > p.clip_w then
				scroll_x(1)
			end
		end,
		[keys.Right] = function()
			if p.content_w > p.clip_w then
				scroll_x(-1)
			end
		end,
		[keys.Up] = function()
			if p.content_h > p.clip_h then
				scroll_y(1)
			end
		end,
		[keys.Down] = function()
			if p.content_h > p.clip_h then
				scroll_y(-1)
			end
		end,
	}
	scroll_group.on_key_down = function(self,key)
		if animating then return end
		if keys[key] then
			keys[key]()
		else
			print("Scroll Window does not support that key")
		end
	end
	local border = Rectangle{ color = "00000000" }
	
	local arrow_up, arrow_dn, arrow_l, arrow_r
	
	local track_h, track_w
	local grip_h, grip_w
	
	
	local grip_vert_base_y, grip_hor_base_x
	local grip_vert = Rectangle{name="scroll_window",reactive=true}
	local grip_hor  = Rectangle{name="scroll_window",reactive=true}
	
	scroll_y = function(dir)
		local new_y = p.content.y+ dir*10
		animating = true
		p.content:animate{
			duration = 200,
			y = new_y,
			on_completed = function()
				if p.content.y < -(p.content_h - p.clip_h) then
					p.content:animate{
						duration = 200,
						y = -(p.content_h - p.clip_h),
						on_completed = function()
							animating = false
						end
					}
				elseif p.content.y > 0 then
					p.content:animate{
						duration = 200,
						y = 0,
						on_completed = function()
							animating = false
						end
					}
				else
					animating = false
				end
			end
		}
		
		if new_y < -(p.content_h - p.clip_h) then
			grip_vert.y = grip_vert_base_y+(track_h-grip_h)
		elseif new_y > 0 then
			grip_vert.y = grip_vert_base_y
		else
			grip_vert:complete_animation()
			grip_vert:animate{
				duration= 200,
				y = grip_vert_base_y-(track_h-grip_h)*new_y/(p.content_h - p.clip_h)
			}
		end
	end
	
	
	scroll_x = function(dir)
		local new_x = p.content.x+ dir*10
		animating = true
		p.content:animate{
			duration = 200,
			x = new_x,
			on_completed = function()
				if p.content.x < -(p.content_w - p.clip_w) then
					p.content:animate{
						duration = 200,
						y = -(p.content_w - p.clip_w),
						on_completed = function()
							animating = false
						end
					}
				elseif p.content.x > 0 then
					p.content:animate{
						duration = 200,
						x = 0,
						on_completed = function()
							animating = false
						end
					}
				else
					animating = false
				end
			end
		}
		
		if new_x < -(p.content_w - p.clip_w) then
			grip_hor.x = grip_hor_base_x+(track_w-grip_h)
		elseif new_x > 0 then
			grip_hor.x = grip_hor_base_x
		else
			grip_hor:complete_animation()
			grip_hor:animate{
				duration= 200,
				x = grip_hor_base_x-(track_w-grip_h)*new_x/(p.content_w - p.clip_w)
			}
		end
	end
	
	
	--this function creates the whole scroll bar box
	local function create()
        window.position={ p.border_w, p.border_w }
		window.clip = { 0,0, p.clip_w, p.clip_h }
		border.w = p.clip_w+2*p.border_w
		border.h = p.clip_h+2*p.border_w
		border.border_width = p.border_w
		border.border_color = p.color
		if p.border_is_visible then border.opacity=255
        else border.opacity=0 end
        
		if p.arrow_clone_source == nil then
			
			if arrow_up ~= nil then arrow_up:unparent() end
			
			arrow_up = Canvas{size={p.arrow_sz,p.arrow_sz}}
			arrow_up:begin_painting()
			arrow_up:move_to( arrow_up.w/2,          0 )
			arrow_up:line_to(   arrow_up.w, arrow_up.h )
			arrow_up:line_to(            0, arrow_up.h )
			arrow_up:line_to( arrow_up.w/2,          0 )
			arrow_up:set_source_color(p.color)

			arrow_up:fill(true)
			arrow_up:finish_painting()
			if arrow_up.Image then
				arrow_up = arrow_up:Image()
			end
			
			
			if arrow_dn ~= nil then arrow_dn:unparent() end
			
			arrow_dn = Canvas{size={p.arrow_sz,p.arrow_sz}}
			arrow_dn:begin_painting()
			arrow_dn:move_to(            0,          0 )
			arrow_dn:line_to(   arrow_dn.w,          0 )
			arrow_dn:line_to( arrow_dn.w/2, arrow_dn.h )
			arrow_dn:line_to(            0,          0 )
			arrow_dn:set_source_color(p.color)
			arrow_dn:fill(true)
			arrow_dn:finish_painting()
			if arrow_dn.Image then
				arrow_dn = arrow_dn:Image()
			end
			
			
			if arrow_l ~= nil then arrow_l:unparent() end
			
			arrow_l = Canvas{size={p.arrow_sz,p.arrow_sz}}
			arrow_l:begin_painting()
			arrow_l:move_to(   arrow_l.w,           0 )
			arrow_l:line_to(   arrow_l.w,   arrow_l.h )
			arrow_l:line_to(           0, arrow_l.h/2 )
			arrow_l:line_to(   arrow_l.w,           0 )
			arrow_l:set_source_color(p.color)
			arrow_l:fill(true)
			arrow_l:finish_painting()
			if arrow_l.Image then
				arrow_l = arrow_l:Image()
			end
			
			
			if arrow_r ~= nil then arrow_r:unparent() end
			
			arrow_r = Canvas{size={p.arrow_sz,p.arrow_sz}}
			arrow_r:begin_painting()
			arrow_r:move_to(         0,           0 )
			arrow_r:line_to( arrow_r.w, arrow_l.h/2 )
			arrow_r:line_to(         0,   arrow_l.h )
			arrow_r:line_to(         0,           0 )
			arrow_r:set_source_color(p.color)
			arrow_r:fill(true)
			arrow_r:finish_painting()
			if arrow_r.Image then
				arrow_r = arrow_r:Image()
			end
		else
			arrow_up = Clone{source=p.arrow_clone_source}
			arrow_dn = Clone{source=p.arrow_clone_source, z_rotation={180,0,0}}
			arrow_l  = Clone{source=p.arrow_clone_source, z_rotation={-90,0,0}}
			arrow_r  = Clone{source=p.arrow_clone_source, z_rotation={ 90,0,0}}
		end
		
		arrow_up.anchor_point = {arrow_up.w/2,arrow_up.h/2}
		arrow_dn.anchor_point = {arrow_dn.w/2,arrow_dn.h/2}
		arrow_l.anchor_point  = { arrow_l.w/2, arrow_l.h/2}
		arrow_r.anchor_point  = { arrow_r.w/2, arrow_r.h/2}
		
		arrow_up.reactive = true
        arrow_dn.reactive = true
        arrow_l.reactive=true
        arrow_r.reactive=true

		function arrow_up:on_button_down(x,y,button,num_clicks)
            scroll_y(1)
        end
        function arrow_dn:on_button_down(x,y,button,num_clicks)
            scroll_y(-1)
        end
		function arrow_l:on_button_down(x,y,button,num_clicks)
            scroll_x(1)
        end
        function arrow_r:on_button_down(x,y,button,num_clicks)
            scroll_x(-1)
        end
		
		scroll_group:add(arrow_up,arrow_dn,arrow_l,arrow_r)
		
		-- re-used values
		grip_vert_base_y =  arrow_up.h+5
		track_h     = (p.clip_h-2*arrow_up.h-10+2*p.border_w)
		grip_h      =  p.clip_h/p.content_h*track_h
		if grip_h < p.arrow_sz then
			grip_h = p.arrow_sz
		elseif grip_h > track_h then
			grip_h = track_h
		end
		
		grip_hor_base_x = arrow_l.w+5
		track_w     = (p.clip_w-2*arrow_l.w-10+2*p.border_w)
		grip_w      =  p.clip_w/p.content_w*track_w
		if grip_w < p.arrow_sz then
			grip_w = p.arrow_sz
		elseif grip_w > track_h then
			grip_w = track_h
		end
		
		
		grip_vert.w        = p.arrow_sz
		grip_vert.h        = grip_h
		grip_vert.color    = p.color
		grip_vert.position = {border.w+5,grip_vert_base_y}
		
		grip_hor.h        = p.arrow_sz
		grip_hor.w        = grip_h
		grip_hor.color    = p.color
		grip_hor.position = {grip_hor_base_x,border.h+5}
		
		if p.grip_is_visible and not p.arrows_centered then
			grip_hor.opacity  = 255
			grip_vert.opacity = 255
		else
			grip_hor.opacity  = 0
			grip_vert.opacity = 0
		end
		
		if p.arrows_centered then
			if p.arrows_in_box then
				arrow_up.position = {border.w/2+arrow_up.w/2+5,arrow_up.h/2+5 }
				arrow_dn.position = {border.w/2+arrow_dn.w/2+5,border.h-arrow_dn.h/2-5}
				arrow_l.position  = {arrow_l.w/2+5,border.h/2 + 5 + arrow_up.h/2}
				arrow_r.position  = {border.w-arrow_r.w/2-5,border.h/2 + 5 + arrow_up.h/2}
			else
				arrow_up.position = {border.w/2+arrow_up.w/2+5,-arrow_up.h/2-5}
				arrow_dn.position = {border.w/2+arrow_dn.w/2+5,border.h+arrow_dn.h/2+5}
				arrow_l.position  = {-arrow_l.w/2-5,border.h/2 + 5 + arrow_up.h/2}
				arrow_r.position  = {border.w+arrow_r.w/2+5,border.h/2 + 5 + arrow_up.h/2}
			end
		else
			if p.arrows_in_box then
				arrow_up.position = {border.w-arrow_up.w/2-5,arrow_up.h/2+5}
				arrow_dn.position = {border.w-arrow_dn.w/2-5,border.h-arrow_dn.h*3/2}
				arrow_l.position  = {         arrow_l.w/2+5,   border.h - 5 - arrow_up.h/2}
				arrow_r.position  = {border.w-arrow_r.w/2*3/2-5,   border.h - 5 - arrow_up.h/2}
				grip_hor_base_x = arrow_l.x + arrow_l.w+5
				grip_vert_base_y =  arrow_up.y+arrow_up.h+5
				grip_vert.position = {border.w-arrow_up.w-5,grip_vert_base_y}
				grip_hor.position = {grip_hor_base_x,border.h-5- arrow_up.h}
			else
				arrow_up.position = {border.w+arrow_up.w/2+5,arrow_up.h/2}
				arrow_dn.position = {border.w+arrow_dn.w/2+5,border.h-arrow_dn.h/2}
				arrow_l.position  = {         arrow_l.w/2,   border.h + 5 + arrow_up.h/2}
				arrow_r.position  = {border.w-arrow_r.w/2,   border.h + 5 + arrow_up.h/2}
				grip_vert.position = {border.w+5,grip_vert_base_y}
				grip_hor.position = {grip_hor_base_x,border.h+5}
			end
		end
		
		if p.content_w <= p.clip_w then
			arrow_r.opacity=0
			arrow_l.opacity=0
			grip_hor.opacity=0
		end
		
		if p.content_h <= p.clip_h then
			arrow_up.opacity=0
			arrow_dn.opacity=0
			grip_vert.opacity=0
		end
	end
	
    create()
	scroll_group:add(border,grip_hor,grip_vert,window)
	window:add(p.content)
	
	
	
	--The mouse events for the grips
	function grip_hor:on_button_down(x,y,button,num_clicks)
		
		local dx = x - grip_hor.x
		
        dragging = {grip_hor,
			function(x,y)
				
				grip_hor.x = x - dx
				
				if  grip_hor.x < grip_hor_base_x then
					grip_hor.x = grip_hor_base_x
				elseif grip_hor.x > grip_hor_base_x+(track_w-grip_w) then
					   grip_hor.x = grip_hor_base_x+(track_w-grip_w)
				end
				
				p.content.x = -(grip_hor.x - grip_hor_base_x) * p.content_w/track_w
				
			end 
		}
		
        return true
    end
	function grip_vert:on_button_down(x,y,button,num_clicks)
		
		local dy = y - grip_vert.y
		
        dragging = {grip_vert, function(x,y)
				
				grip_vert.y = y - dy
				
				if  grip_vert.y < grip_vert_base_y then
					grip_vert.y = grip_vert_base_y
				elseif grip_vert.y > grip_vert_base_y+(track_h-grip_h) then
					   grip_vert.y = grip_vert_base_y+(track_h-grip_h)
				end
				
				p.content.y = -(grip_vert.y - grip_vert_base_y) * p.content_h/track_h
				
			end
		}
		
        return true

    end 

	--set the meta table to overwrite the parameters
    mt = {}
    mt.__newindex = function(t,k,v)
		
        if k == "content" then
            p.content:unparent()
            if v.parent ~= nil then
                v:unparent()
            end
            v.position={0,0}
            v.reactive = false
            window:add(v)
        end
        p[k] = v
        create()
		
    end
    mt.__index = function(t,k)       
       return p[k]
    end
    setmetatable(scroll_group.extra, mt)

    return scroll_group
end
--]]



return widget
