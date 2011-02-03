
local widget = {}
local skin_list = { ["default"] = {
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

		    ["skin_type1"] = { 
				   ["button"] = "assets/button-red.png", 
				   ["button_focus"] = "assets/button-focus.png", 
				   ["textinput"] = "", 
				   ["textinput_focus"] = "", 
				   ["dialogbox"] = "", 
			           ["dialogbox_x"] ="", 
				   ["toast"] = "", 
				   ["icon"] = "", 
				   ["toast_icon"] = "assets/voice-2.png", 
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
				   ["toast"] = "", 
				   ["icon"] = "", 
				   ["toast_icon"] = "assets/voice-2.png", 
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

		  }

--[[
Function: change_all_skin

Change all widgets' skin to skin_name 

Arguments:
	skin_name 	   - name of skin  
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

Change all buttons' skin to skin_name 

Arguments:
	skin_name 	   - name of skin  
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

-- Lang_Text() : to be deleted ! 

Lang_Text = function(txt_arr, params,align)
	assert(#txt_arr == 4)
	local langs = txt_arr
	print(langs[1],langs[2],langs[3],langs[4])

	l_t = Text{}
	for k,v in pairs(params) do
		print(k,v)
		l_t[k] = v
	end
 
	function l_t.extra.change_lang_to(this_l_t,num)
		if align == "left" then
		this_l_t.text = langs[num]
			
		elseif align == "right" then
		this_l_t.x = this_l_t.x + this_l_t.w/2 
		this_l_t.text = langs[num]
		this_l_t.x = this_l_t.x - this_l_t.w/2 
		this_l_t.anchor_point = {this_l_t.w/2,this_l_t.h/2}
		
		else
			this_l_t.text = langs[num]
			print(this_l_t.x,this_l_t.y)
			this_l_t.anchor_point = {this_l_t.w/2,this_l_t.h/2}
			print("me",this_l_t.w/2,this_l_t.h/2,"  ",this_l_t.x,this_l_t.y)
		end

	end
	l_t.extra.change_lang_to(l_t,1)

	table.insert(text_object_list,l_t)
	return l_t
end


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

--make_dialogBox_bg(p.wwidth, p.wheight, p.border_width, p.border_color, p.fill_color, p.padding_x, p.padding_y, p.border_radius) 
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
	Table of 

	skin 	- skin name of button 
    	wwidth  - button image width 
    	wheight - button image hight 
    	border_color - the border color of button image 
    	focus_color - the focus color of button image  
    	border_width - the focus color of button image  
    	text - the caption of button 
    	font - the font of button caption 
    	color - the color of button caption 
    	padding_x - the x padding of button image 
    	padding_y - the y padding of button image
    	border_radius - the border radius of button image 

Return:
 	b_group - group containing the button 

Extra Function:
	on_focus_out() - release button focus 
	on_focus_in() - grab button focus 
	
]]

function widget.button(table) 

 --default parameters
    local p = {
    	font = "DejaVu Sans 30px",
    	color = "FFFFFF",
    	skin = "default", 
    	wwidth = 180,
    	wheight = 60, 

    	text = "Button", 
    	focus_color = "1b911b", 

    	border_color = "FFFFFF", 
    	border_width = 1,
    	padding_x = 0,
    	padding_y = 0,
    	border_radius = 12,
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
    

	if(p.skin ~= "canvas") then 
		p.button_image = assets(skin_list[p.skin]["button"])
		p.focus_image  = assets(skin_list[p.skin]["button_focus"])
	end
        b_group:clear()
        b_group.size = { p.wwidth , p.wheight}
        ring = make_ring(p.wwidth, p.wheight, p.border_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
        ring:set{name="ring", position = { 0 , 0 }, opacity = 255 }

        focus_ring = make_ring(p.wwidth, p.wheight, p.focus_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
        focus_ring:set{name="focus_ring", position = { 0 , 0 }, opacity = 0}

	if(p.skin ~= "canvas") then 
            button = assets(skin_list[p.skin]["button"])
            button:set{name="button", position = { 0 , 0 } , size = { p.wwidth , p.wheight } , opacity = 255}
            focus = assets(skin_list[p.skin]["button_focus"])
            focus:set{name="focus", position = { 0 , 0 } , size = { p.wwidth , p.wheight } , opacity = 0}
	else 
	     button = Image{}
	     focus = Image{}
	end 
        text = Text{name = "text", text = p.text, font = p.font, color = p.color} --reactive = true 
        text:set{name = "text", position = { (p.wwidth  -text.w)/2, (p.wheight - text.h)/2}}

        b_group:add(ring, focus_ring, button, focus, text)

        if (p.skin == "canvas") then button.opacity = 0 print("heheheheh")
        else ring.opacity = 0 end 

    end 

    create_button()

    function b_group.extra.on_focus_in() 
        if (p.skin == "canvas") then 
	     ring.opacity = 0
	     focus_ring.opacity = 255
        else
	     button.opacity = 0
             focus.opacity = 255
        end 
	b_group:grab_key_focus(b_group)
    end
    
    function b_group.extra.on_focus_out() 
        if (p.skin == "canvas") then 
	     ring.opacity = 255
	     focus_ring.opacity = 0
             focus.opacity = 0
        else
	     button.opacity = 255
             focus.opacity = 0
	     focus_ring.opacity = 0
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

Creates a text input field widget

Arguments:
	Table of 

	skin 	- skin name of text input field 
    	wwidth  - button image width 
    	wheight - text input field image hight 
    	border_color - the border color of text input field image 
    	focus_color - the focus color of text input field image  
    	border_width - the focus color of text input field image  
    	text - the text  
    	text_indent - the size of text indentation  
    	font - the font of text input field caption 
    	color - the color of text input field caption 
    	padding_x - the x padding of text input field image 
    	padding_y - the y padding of text input field image
    	border_radius - the border radius of text input field image 

Return:
 	t_group - group containing the text input field 

Extra Function:
	on_focus_out() - release text input field focus 
	on_focus_in() - grab text input field focus 
	
]]



function widget.textField(table) 
 --default parameters
    local p = {
    	skin = "canvas", 
    	wwidth = 200 ,
    	wheight = 60 ,
    	text = "" ,
    	text_indent = 20 ,
    	border_width  = 3 ,
    	border_color  = "FFFFFFC0" , 
    	focus_color  = "1b911b" , 
    	font = "DejaVu Sans 30px"  , 
    	color = "FFFFFF" , 
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
 	

	if(p.skin ~= "canvas") then 
             p.box_image   = assets(skin_list[p.skin]["textinput"])
	     p.focus_image = assets(skin_list[p.skin]["textinput_focus"])
	end 

    	t_group:clear()
        t_group.size = { p.wwidth , p.wheight}

    	box = make_ring(p.wwidth, p.wheight, p.border_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
    	box:set{name="box", position = { 0 , 0 } }

    	focus_box = make_ring(p.wwidth, p.wheight, p.focus_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
    	focus_box:set{name="focus_box", position = { 0 , 0 }, opacity = 0}

	if(p.skin ~= "canvas") then 
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

    	if (p.skin == "canvas") then box_img.opacity = 0
    	else box.opacity = 0 box_img.opacity = 255 end 

     end 

     create_textInputField()

     function t_group.extra.on_focus_in()
          if (p.skin == "canvas") then 
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
          if (p.skin == "canvas") then 
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

Creates a dialog box widget

Arguments:
	Table of 

	skin 	- skin name of dialog box 
    	wwidth  - button image width 
    	wheight - dialog box image hight 
    	fill_color - the color of dialog box image  
    	border_color - the border color of dialog box image 
    	focus_color - the focus color of dialog box image  
    	border_width - the focus color of dialog box image  
    	title - the title of dialog box
    	font - the font of dialog box title 
    	color - the color of dialog box caption 
    	padding_x - the x padding of dialog box image 
    	padding_y - the y padding of dialog box image
    	border_radius - the border radius of dialog box image 

Return:
 	db_group - group containing the dialog box
]]

function widget.dialogBox(table) 
 
--default parameters
   local p = {
	skin = "canvas", 
	wwidth = 900 ,
	wheight = 500 ,
	title = "Dialog Box Title" ,
	font = "DejaVu Sans 30px" , 
	color = "FFFFFF" , 
	border_width  = 3 ,
	border_color  = "FFFFFFC0" , 
	fill_color  = {25,25,25,100},
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

        d_box = make_dialogBox_bg(p.wwidth, p.wheight, p.border_width, p.border_color, p.fill_color, p.padding_x, p.padding_y, p.border_radius) 
	d_box.y = d_box.y - 34
	d_box:set{name="d_box"} 

        x_box = make_xbox()
        x_box:set{name = "x_box", position  = {p.wwidth - 50, db_group_cur_y}}

        title= Text{text = p.title, font= p.font, color = p.color}     
        title:set{name = "title", position = {(p.wwidth - title.w - 50)/2 , db_group_cur_y - 5}}

	if(p.skin ~= "canvas") then 
        	d_box_img = assets(skin_list[p.skin]["dialogbox"])
        	d_box_img:set{name="d_box_img", size = { p.wwidth , p.wheight } , opacity = 0}
        	x_box_img = assets(skin_list[p.skin]["dialogbox_x"])
        	x_box_img:set{name="x_box_img", size = { p.wwidth , p.wheight } , opacity = 0}
	else 
		d_box_img = Image{} 
        	x_box_img = Image{} 
	end

	db_group:add(d_box, x_box, title, d_box_img, x_box_img)

	if (p.skin == "canvas") then d_box_img.opacity = 0
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

Creates a toast widget

Arguments:
	Table of 

	skin 	- skin name of toast 
	title - title of toast
	message - message of toast
    	font - the font of toast title and message 
    	color - the color of toast title and message 
    	wwidth  - toast image width 
    	wheight - toast image hight 
    	border_color - the border color of toast image 
    	fill_color - the color of toast image  
    	focus_color - the focus color of toast image  
    	border_width - the focus color of toast image  
    	padding_x - the x padding of toast image 
    	padding_y - the y padding of toast image
    	border_radius - the border radius of toast image 
	fade_duration - millisecs spent on fading away the toast 
	duration - millisecs spent on showing the toast 

Return:
 	tb_group - group containing the toast box

Extra Function:
	start_timer() - start the timer of toast box 	
]]



function widget.toastBox(table) 

 --default parameters
    local p = {
 	skin = "canvas",  
	wwidth = 600,
	wheight = 200,
	title = "Toast Box Title",
	message = "Toast box message ... ",
	font = "DejaVu Sans 30px", 
	color = "FFFFFF", 
	border_width  = 3,
	border_color  = "FFFFFFC0", 
	fill_color  = {25,25,25,100},
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

    local tb_group_cur_y = 30
    local tb_group_cur_x = 30
    local tb_group_timer = Timer()
    local tb_group_timeline = Timeline ()

    if(p.skin == "canvas") then 
	icon = assets("assets/voice-1.png")
    else 
	icon = assets(skin_list[p.skin]["icon"])
    end 
    

    local create_toastBox = function()

    	tb_group:clear()
        tb_group.size = { p.wwidth , p.wheight}

    	t_box = make_toastb_group_bg(p.wwidth, p.wheight, p.border_width, p.border_color, p.fill_color, p.padding_x, p.padding_y, p.border_radius) 
    	t_box:set{name="t_box"}
    
    	icon:set{size = {100, 100}, name = "icon", position  = {tb_group_cur_x, tb_group_cur_y}} --30,30

    	title= Text{text = p.title, font= "DejaVu Sans 32px", color = "FFFFFF"}     
    	title:set{name = "title", position = {(p.wwidth - title.w - tb_group_cur_x)/2 , tb_group_cur_y+20 }}  --,50

    	message= Text{text = p.message, font= "DejaVu Sans 32px", color = "FFFFFF"}     
    	message:set{name = "message", position = {icon.w + tb_group_cur_x, tb_group_cur_y*2 + title.h }} 

	if(p.skin ~= "canvas") then 
    	     t_box_img = assets(skin_list[p.skin]["toast"])
    	     t_box_img:set{name="t_box_img", size = { p.wwidth , p.wheight } , opacity = 0}
	else 
	     t_box_img = Image{}
	end 

	t_box.y = t_box.y -30
	tb_group.h = tb_group.h - 30

    	tb_group:add(t_box, icon, title, message, t_box_img)

    	if (p.skin == "canvas") then t_box_img.opacity = 0
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
	Table of 

	skin 	- skin name of button picker  
    	wwidth  - button picker image width 
    	wheight - button picker image hight 
	items   - a table of button picker items 
    	font - the font of button picker items
    	color - the color of button picker items
	selected_item - selected item's number 
	item_func - table of functions that is called by selected item numger   

Return:
 	bp_group - group containing the button picker 

Extra Function:
	on_focus() - grab focus of button picker 
	out_focus() - release focus of button picker
	press_left() - left key press event, apply the selection of button picker
	press_right() - right key press event, apply the selection of button picker
	press_up() - up key press event, apply the selection of button picker
	press_down() - down key press event, apply the selection of button picker
	press_enter() - enter key press event, apply the selection of button picker
	insert_item(item) - add an item to the items table 
	remove_item(item) - remove an item from the items table 
]]

 
function widget.buttonPicker(table) 
 --default parameters 
    local p = {
	skin = "default", 
	wwidth =  180,
	wheight = 60,
	items = {"item1", "item2", "item3"},
	font = "DejaVu Sans 30px" , 
	color = "FFFFFF", 
	item_func = {}, 
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

     local index = 1
     local padding = 10 
     --local pos = {26, 0}
     local pos = {0, 0}
     local t = nil

     local create_buttonPicker = function() 

	bp_group:clear()
        bp_group.size = { p.wwidth , p.wheight}

	if p.skin == "canvas" then 
            ring = make_ring(p.wwidth, p.wheight, "FFFFFF", 1, 7, 7, 12)
            ring:set{name="ring", position = {pos[1] , pos[2]}, opacity = 255 }

            focus_ring = make_ring(p.wwidth, p.wheight, {255, 0,0,255}, 1, 7, 7, 12)
            focus_ring:set{name="focus_ring", position = {pos[1], pos[2]}, opacity = 0}

	    left_un   = assets(skin_list["default"]["buttonpicker_left_un"])
	    left_un:set{position = {pos[1] - left_un.w - padding, pos[2] + padding}, opacity = 255}

	    left_sel  = assets(skin_list["default"]["buttonpciker_left_sel"])
	    left_sel:set{position = {pos[1] - left_un.w - padding, pos[2] + padding}, opacity = 0}

	    right_un  = assets(skin_list["default"]["buttonpicker_right_un"])
	    right_un:set{position = {pos[1] + focus.w + padding, pos[2] + padding}, opacity = 255}

            right_sel = assets(skin_list["default"]["buttonpicker_right_sel"])
	    right_sel:set{position = {right_un.x, right_un.y},  opacity = 0}
	else 
	    ring = Image{}
	    focus_ring = Image{}

     	    unfocus = assets(skin_list[p.skin]["buttonpicker"])
     	    unfocus:set{ position = {pos[1], pos[2]}, size = {p.wwidth, p.wheight}, opacity = 255}

     	    focus = assets(skin_list[p.skin]["buttonpicker_focus"])
	    focus:set{ position = {pos[1], pos[2]}, size = {p.wwidth, p.wheight}, opacity = 0}

	    left_un   = assets(skin_list[p.skin]["buttonpicker_left_un"])
	    left_un:set{position = {pos[1] - left_un.w - padding, pos[2] + padding}, opacity = 255}

	    left_sel  = assets(skin_list[p.skin]["buttonpciker_left_sel"])
	    left_sel:set{position = {pos[1] - left_un.w - padding, pos[2] + padding}, opacity = 0}

	    right_un  = assets(skin_list[p.skin]["buttonpicker_right_un"])
	    right_un:set{position = {pos[1] + focus.w + padding, pos[2] + padding}, opacity = 255}

            right_sel = assets(skin_list[p.skin]["buttonpicker_right_sel"])
	    right_sel:set{position = {right_un.x, right_un.y},  opacity = 0}
 	end 
   	
     	for i, j in pairs(p.items) do 
	  if i == 1 then 
               items:add(Text{name="item"..tostring(i), text = j, font=p.font, color =p.color, position = {pos[1] + unfocus.w/2 - string.len(j)*20/2, pos[2] + padding}, opacity = 255})     
	  else 
               items:add(Text{name="item"..tostring(i), text = j, font=p.font, color =p.color, position = {pos[1] + unfocus.w/2 - string.len(j)*20/2 + 200 , pos[2] + padding}, opacity = 255})     
	  end 
     	end 

	items.clip = {
		pos[1] + unfocus.w/2 - 50 , 
		pos[2] + padding, 
		pos[1] + unfocus.w/2, 
		pos[2] + padding + unfocus.h
     	}

   	bp_group:add(ring, focus_ring, unfocus, focus, right_un, right_sel, left_un, left_sel, items) 

	if(p.skin == "canvas") then unfocus.opacity = 0 
        else ring.opacity = 0 end 

        t = nil
     end 
 
     create_buttonPicker()

     function bp_group.extra.on_focus()
        unfocus.opacity = 0
	focus.opacity   = 255
     end
     function bp_group.extra.out_focus()
        unfocus.opacity = 255
	focus.opacity   = 0
     end

     function bp_group.extra.press_left()
            local prev_i = index
	    dumptable(p)

            local next_i = (index-2)%(#p.items)+1

	    index = next_i

	    local prev_old_x = pos[1] + unfocus.w/2 - 50 
	    local prev_old_y = pos[2] + padding
	    local next_old_x = pos[1] + unfocus.w/2 - 50 + focus.w
	    local next_old_y = pos[2] + padding
	    local prev_new_x = pos[1] + unfocus.w/2 - 50 - focus.w
	    local prev_new_y = pos[2] + padding
	    local next_new_x = pos[1] + unfocus.w/2 - 50
	    local next_new_y = pos[2] + padding

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

			t = nil
	    end
	    if p.item_func then
	      -- p.item_func(next_i,prev_i)
	    end

	    t:start()
	end

	function bp_group.extra.press_right()
	    local prev_i = index
	    --local next_i = (index+1-1)%(table.getn(p.items)) + 1
            local next_i = (index)%(#p.items)+1
	    index = next_i

	    local prev_old_x = pos[1] + unfocus.w/2 - 50 
	    local prev_old_y = pos[2] + padding
	    local next_old_x = pos[1] + unfocus.w/2 - 50 -focus.w
	    local next_old_y = pos[2] + padding
	    local prev_new_x = pos[1] + unfocus.w/2 - 50 +focus.w
	    local prev_new_y = pos[2] + padding
	    local next_new_x = pos[1] + unfocus.w/2 - 50
	    local next_new_y = pos[2] + padding

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
		t = nil
	    end
	    --if p.item_func then
	       -- p.item_func(next_i,prev_i)
	    --end
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
	    	p.wwidth = v[1] p.wheight = v[2]  
             else 
                p[k] = v
             end
	     if k ~= "selected" and k ~= "org_x"  and k ~= "org_y" and 
		k ~= "is_in_group" and k ~= "group_position" then 
		 print(k) 
		 print(k) 
		 print(k) 
		 print(k) 
		 print(k) 
		 print(k) 
		 print(k) 
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

Creates a radio button widget

Arguments:
	Table of 

	skin 	- skin name of radio button  
    	wwidth  - radio button image width 
    	wheight - radio button image hight 
	items   - a table of radio button items 
    	font - the font of radio button items
    	color - the color of radio button items
	button_color - the color of radio button
	select_color - the color of selected radio button 
	button_radius - the radius of radio button
	select_radius - the radius of selected radio button
	b_pos - the postion of the group of radio buttons 
	item_pos - the position of the group of text items 
	line_space - the space between the text itmes 
	selected_item - selected item's number 
	item_func - table of functions that is called by selected item numger   

Return:
 	rb_group - group containing the radio button 

Extra Function:
	insert_item(item) - add an item to the items table 
	remove_item(item) - remove an item from the items table 
]]


function widget.radioButton(table) 

 --default parameters
    local p = {
	skin = "canvas", 
	wwidth = 600,
	wheight = 200,
	items = {"item1", "item2", "item3"},
	font = "DejaVu Sans 30px", -- items 
	color = "FFFFFF", -- items 
	button_color = {255,255,255,200}, -- items 
	select_color = {100, 100, 100, 255}, -- items 
	button_radius = 10, -- items 
	select_radius = 5,  -- items 
	b_pos = {0, 0},  -- items 
	item_pos = {50,-5},  -- items 
	line_space = 40,  -- items 
	button_image = Image{}, --assets("assets/radiobutton.png"),
	select_image = Image{}, --assets("assets/radiobutton_selected.png"),
	item_func = {}, 
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

	if(p.skin ~= "canvas") then 
	 p.button_image = assets(skin_list[p.skin]["radiobutton"])
	 p.select_image = assets(skin_list[p.skin]["radiobutton_sel"])
	end

         rb_group:clear()
         rings:clear()
         items:clear()
         --rb_group.size = { p.wwidth , p.wheight},
	
         if(p.skin == "canvas") then 
	     select_img = create_select_circle(p.select_radius, p.select_color)
         else 
    	     select_img = p.select_image
         end 
    
         select_img:set{name = "select_img", position = {0,0}, opacity = 255} 

         for i, j in pairs(p.items) do 
	      itm_h = p.line_space
              items:add(Text{name="item"..tostring(i), text = j, font=p.font, color =p.color, position = {0, i * itm_h - itm_h}})     
	      if p.skin == "canvas" then 
    	           rings:add(create_circle(p.button_radius, p.button_color):set{name="ring"..tostring(i), position = {0, i * itm_h - itm_h - 8}} ) 
	      else
	           rings:add(Clone{name = "item"..tostring(i),  source=p.button_image, position = {0, i * itm_h - itm_h - 8}}) 
	      end 
         end 
	 rings:set{name = "rings", position = p.b_pos} 
	 items:set{name = "items", position = p.item_pos} 
     	 select_img.x  = items:find_child("item"..tostring(p.selected_item)).x + 10
     	 select_img.y  = items:find_child("item"..tostring(p.selected_item)).y + 2 

	 rb_group:add(rings, items, select_img)

     end

     create_radioButton()


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

Creates a check box widget

Arguments:
	skin 	- skin name of check box   
    	wwidth  - check box image width 
    	wheight - check box image hight 
	items   - a table of check box items 
    	font - the font of check box items
    	color - the color of check box items
	box_color - the color of check box border 
	fill_color - the color of check box 
	box_width - the line width of check box border
	box_size - the size of check box 
        check_size - the size of check image 
	b_pos - the postion of the group of check box  
	item_pos - the position of the group of text items 
	line_space - the space between the text itmes 
	selected_item - selected item's number 
	item_func - table of functions that is called by selected item numger   

Return:
 	rb_group - group containing the check box  

Extra Function:
	insert_item(item) - add an item to the items table 
	remove_item(item) - remove an item from the items table 
]]


function widget.checkBox(table) 

 --default parameters
    local p = {
	skin = "canvas", 
	wwidth = 600,
	wheight = 200,
	items = {"item1", "item2", "item3"},
	font = "DejaVu Sans 30px", -- items 
	color = "FFFFFF", -- items 
	box_color = {255,255,255,255},
	fill_color = {255,255,255,50},
	box_width = 2,
	box_size = {25,25},
	check_size = {25,25},
	line_space = 40,   
	b_pos = {0, 0},  -- items 
	item_pos = {50,-5},  -- items 
	selected_item = 1,  
	box_image = Image{},
	item_func = {}, 
	check_image = assets("assets/checkmark.png") 
    } 

 --overwrite defaults
    if table ~= nil then 
        for k, v in pairs (table) do
	    p[k] = v 
        end 
    end

 --the umbrella Group
    local check_img
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
	if(p.skin ~= "canvas") then 
         p.box_image = assets(skin_list[p.skin]["checkbox"])
	end
	
	 items:clear() 
	 boxes:clear() 
	 cb_group:clear()

    	 check_img = p.check_image
	 check_img:set { name="check_img", position = {0,0,0}, size = p.check_size, opacity = 255 }

	 boxes:set{name = "boxes", position = p.b_pos} 
	 items:set{name = "items", position = p.item_pos} 


         for i, j in pairs(p.items) do 
	      itm_h = p.line_space
              items:add(Text{name="item"..tostring(i), text = j, font=p.font, color = p.color, position = {0, i * itm_h - itm_h}})     
	      if p.skin == "canvas" then 
    	           boxes:add(Rectangle{name="box"..tostring(i),  color= p.fill_color, border_color= p.box_color, border_width= p.box_width, 
				       size = p.box_size, position = {0, i * itm_h - itm_h,0}, opacity = 255}) 
	      else
	           boxes:add(Clone{name = "item"..tostring(i),  source=p.button_image, size = p.box_size, position = {0, i * itm_h - itm_h,0}, opacity = 255}) 
	      end 
         end 
         check_img.x  = items:find_child("item"..tostring(p.selected_item)).x 
         check_img.y  = items:find_child("item"..tostring(p.selected_item)).y 

	 cb_group:add(boxes, items, check_img) 
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

Creates a loading bar widget

Arguments:
	dot_radius              - radius of the individual dots
	dot_color  - color of the individual dots
	num_dots  - number of dots in the loading circle
	anim_radius       - the radius of the circle of dots
	anim_duration   - millisecs spent on a dot, this number times the number of
                      dots is the time for the animation to make a full circle

Return:

	loading_dots_group - group containing the loading dots
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

Creates a loading bar widget

Arguments:
	bsize              - size of the loading bar
	shell_upper_color  - the upper color for the inside of the loading bar
	shell_lower_color  - the upper color for the inside of the loading bar
	stroke_color       - the color for the outline
	fill_upper_color   - the upper color for the loading bar fill
	fill_lower_color   - the lower color for the loading bar fill

Return:

	loading_bar_group - group containing the loading bar
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

--]]
-----------------------------------------
-- List Scroll Button (or Arrow Image)   
-----------------------------------------

--[[
function make_scroll (x_scroll_from, x_scroll_to, y_scroll_from, y_scroll_to)  
     
     local x_scroll_box, y_scroll_box 
     local x_scroll_bar, y_scroll_bar 

     if(x_scroll_to == 0)then 
	 x_scroll_to = screen.w
     end
     if(y_scroll_to == 0)then 
	 y_scroll_to = screen.h
     end

     g.extra.canvas_h = y_scroll_to - y_scroll_from -- y 전체 캔버스 사이즈가 되겠구 
     g.extra.canvas_w = x_scroll_to - x_scroll_from -- x 전체 캔버스 사이즈가 되겠구 
     g.extra.canvas_f = y_scroll_from
     g.extra.canvas_xf = x_scroll_from
     g.extra.canvas_t = y_scroll_to
     g.extra.canvas_xt = x_scroll_to

     screen_rect =  Rectangle{
                name="screen_rect",
                border_color= {2, 25, 25, 140},
                border_width=2,
                color= {255,255,255,0},
                size = {screen.w+1,screen.h+1},
                position = {0,0,0}, 
     }
     screen_rect.reactive = false
     g:add(screen_rect)


     
    if (g.extra.canvas_w > screen.w) then 
	local SCROLL_X_POS = 10
	local BOX_BAR_SPACE = 6
	
        x_scroll_box = factory.make_x_scroll_box()
        x_scroll_bar = factory.make_x_scroll_bar(g.extra.canvas_w)

	x_scroll_box.position = {SCROLL_X_POS, screen.h - 60}
	x_scroll_bar.position = {SCROLL_X_POS + BOX_BAR_SPACE, screen.h - 56}

	
        x_scroll_bar.extra.org_x = 16
	x_scroll_bar.extra.h_x = 16
	x_scroll_bar.extra.l_x = x_scroll_box.x + x_scroll_box.w - x_scroll_bar.w - BOX_BAR_SPACE -- 스크롤 되는 영역의 길이 

	screen:add(x_scroll_box) 
	screen:add(x_scroll_bar) 

        -- 요 값은 스크롤 바가 움직일때 오브젝의 와이 포지션이 밖뀌는 값을 나타내는건데 이름이 너무 헤깔리는군 
        g.extra.scroll_dx = ((g.extra.canvas_w - screen.w)/(x_scroll_bar.extra.l_x - x_scroll_bar.extra.h_x))

		
	local x0 = - g.extra.canvas_xf/g.extra.scroll_dx + 10 
	local x1920 = (-g.extra.canvas_xf+1080)/g.extra.scroll_dx + 10

	x_0_mark= Rectangle {
		name="x_0_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {2, 40},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {SCROLL_X_POS + x0, screen.h - 55, 0},
		opacity = 255
        }

	x_1920_mark= Rectangle {
		name="x_1920_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {2, 40},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {SCROLL_X_POS + x1920, screen.h - 55, 0},
		opacity = 255
        }
  
	screen:add(x_0_mark)
	screen:add(x_1920_mark) 

        -- 스크롤 바 넣고 원래 좌표를 기억해 두는기지요 
	for n,m in pairs (g.children) do 
		m.extra.org_x = m.x
	end 
         
        function x_scroll_bar:on_button_down(x,y,button,num_clicks)
		dragging = {x_scroll_bar, x-x_scroll_bar.x, y-x_scroll_bar.y }

		if table.getn(selected_objs) ~= 0 then
		     for q, w in pairs (selected_objs) do
			 local t_border = screen:find_child(w)
			 local i, j = string.find(t_border.name,"border")
		         local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		         if(t_obj ~= nil) then 
			      screen:remove(screen:find_child(t_obj.name.."a_m"))
			 end
		     end
		end

        	return true
    	end 

    	function x_scroll_bar:on_button_up(x,y,button,num_clicks)
	 	if(dragging ~= nil) then 
	      		local actor , dx , dy = unpack( dragging )
			local dif
	      		if (actor.extra.h_x <= x-dx and x-dx <= actor.extra.l_x) then -- 스크롤 되는 범위안에 있으면	
	           		dif = x - dx - x_scroll_bar.extra.org_x -- 스크롤이 이동한 거리 
	           		x_scroll_bar.x = x - dx 
	      		elseif (actor.extra.h_x > x-dx ) then
				dif = actor.extra.h_x - x_scroll_bar.extra.org_x 
	           		x_scroll_bar.x = actor.extra.h_x
	      		elseif (actor.extra.l_x < x-dx ) then
				dif = actor.extra.l_x- x_scroll_bar.extra.org_x 
	           		x_scroll_bar.x = actor.extra.l_x
			end 
			dif = dif * g.extra.scroll_dx -- 스클롤된 길이 * 그 길이가 나타내는 와이값 증감 
			for i,j in pairs (g.children) do 
	           	     j.position = {j.extra.org_x-dif-x_scroll_from, j.y, j.z}
			end 

			if table.getn(selected_objs) ~= 0 then
			     for q, w in pairs (selected_objs) do
				 local t_border = screen:find_child(w)
				 local i, j = string.find(t_border.name,"border")
		                 local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                 if(t_obj ~= nil) then 
			              t_border.x = t_obj.x 
				 end
			     end
			end

			g.extra.scroll_x = math.floor(dif) 
	      		dragging = nil
	 	end 
         	return true
    	end 
     end 


     if(g.extra.canvas_h > screen.h) then 


	local SCROLL_Y_POS = 90
	local BOX_BAR_SPACE = 6

	y_scroll_box = factory.make_y_scroll_box()
        y_scroll_bar = factory.make_y_scroll_bar(g.extra.canvas_h) 

	y_scroll_box.position = {screen.w - 60, SCROLL_Y_POS}
	y_scroll_bar.position = {screen.w - 56, SCROLL_Y_POS + BOX_BAR_SPACE}

        y_scroll_bar.extra.org_y = 96
	y_scroll_bar.extra.h_y = 96
	y_scroll_bar.extra.l_y = y_scroll_box.y + y_scroll_box.h - y_scroll_bar.h - BOX_BAR_SPACE -- 스크롤 되는 영역의 길이 

	screen:add(y_scroll_box) 
	screen:add(y_scroll_bar) 

        -- 요 값은 스크롤 바가 움직일때 오브젝의 와이 포지션이 밖뀌는 값을 나타내는건데 이름이 너무 헤깔리는군 
        g.extra.scroll_dy = ((g.extra.canvas_h - screen.h)/(y_scroll_bar.extra.l_y - y_scroll_bar.extra.h_y))
  
	
	local y0 = - g.extra.canvas_f/g.extra.scroll_dy + 10 
	local y1080 = (-g.extra.canvas_f+1080)/g.extra.scroll_dy + 10

	y_0_mark= Rectangle {
		name="y_0_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {40,2},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {screen.w - 55, SCROLL_Y_POS + y0, 0},
		opacity = 255
        }

	y_1080_mark= Rectangle {
		name="y_1080_mark",
		border_color={255,255,255,255},
		border_width=0,
		color={100,255,25,255},
		size = {40,2},
		anchor_point = {0,0},
		x_rotation={0,0,0},
		y_rotation={0,0,0},
		z_rotation={0,0,0},
		position = {screen.w - 55, SCROLL_Y_POS + y1080, 0},
		opacity = 255
       }
  
	screen:add (y_0_mark)
	screen:add (y_1080_mark)

        -- 스크롤 바 넣고 원래 좌표를 기억해 두는기지요 
	for n,m in pairs (g.children) do 
		m.extra.org_y = m.y
	end 
         
        function y_scroll_bar:on_button_down(x,y,button,num_clicks)
		dragging = {y_scroll_bar, x-y_scroll_bar.x, y-y_scroll_bar.y }
		if table.getn(selected_objs) ~= 0 then
			for q, w in pairs (selected_objs) do
				 local t_border = screen:find_child(w)
				 local i, j = string.find(t_border.name,"border")
		                 local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                 if(t_obj ~= nil) then 
				      screen:remove(screen:find_child(t_obj.name.."a_m"))
				 end
			end
		end

        	return true
    	end 

    	function y_scroll_bar:on_button_up(x,y,button,num_clicks)
	 	if(dragging ~= nil) then 
	      		local actor , dx , dy = unpack( dragging )
			local dif
	      		if (actor.extra.h_y <= y-dy and y-dy <= actor.extra.l_y) then -- 스크롤 되는 범위안에 있으면	
	           		dif = y - dy - y_scroll_bar.extra.org_y -- 스크롤이 이동한 거리 
	           		y_scroll_bar.y = y - dy 
	      		elseif (actor.extra.h_y > y-dy ) then
				dif = actor.extra.h_y - y_scroll_bar.extra.org_y 
	           		y_scroll_bar.y = actor.extra.h_y
	      		elseif (actor.extra.l_y < y-dy ) then
				dif = actor.extra.l_y- y_scroll_bar.extra.org_y 
	           		y_scroll_bar.y = actor.extra.l_y
			end 
			dif = dif * g.extra.scroll_dy -- 스클롤된 길이 * 그 길이가 나타내는 와이값 증감 
			for i,j in pairs (g.children) do 
	           	     j.position = {j.x, j.extra.org_y-dif-y_scroll_from, j.z}
			end 

			if table.getn(selected_objs) ~= 0 then
			     for q, w in pairs (selected_objs) do
				 local t_border = screen:find_child(w)
				 local i, j = string.find(t_border.name,"border")
		                 local t_obj = g:find_child(string.sub(t_border.name, 1, i-1))	
		                 if(t_obj ~= nil) then 
			              t_border.y = t_obj.y 
				 end
			     end
			end

			g.extra.scroll_y = math.floor(dif) 
	      		dragging = nil
	 	end 
         	return true
    	end 
     end 
end

]]

--[[

----------------
--  Menu Bar 
----------------

-- main.lua 60 lines 

     ui = {
        fs_focus            = nil,
        bar                 = Group {},
        bar_background      = assets( "assets/menu-background.png" ),
        button_focus        = assets( "assets/button-focus.png" ),
        logo                = assets( "assets/logo.png" ),

        sections =
        {
        }
     }

    ----------------------------------------------------------------------------
    -- The group that holds the bar background and the buttons
    ----------------------------------------------------------------------------
    
    ui.bar:set
    {
        size = ui.bar_background.size,
        
        position = { 0 , 0 },
        
        children =
        {
            ui.bar_background:set
            {
                position = { 0 , 0 },
		size = {ui.bar_background.w, ui.bar_background.h - 15}
            },
            
            ui.button_focus:set
            {
                position = { FIRST_BUTTON_X , FIRST_BUTTON_Y },        
		size  = {ui.button_focus.w, ui.button_focus.h - 15}
            }
        }
    }

    screen:add( ui.bar )    

       
    local i = 0
    local left = FIRST_BUTTON_X
    
    for _ , section in ipairs( ui.sections ) do
    
        section.ui = ui
        section.button.h = section.button.h - 15

        -- Create the dropdown background
        section.dropdown_bg = ui.factory.make_dropdown( { section.button.w + DROPDOWN_WIDTH_OFFSET , section.height } , section.color )
    
        -- Position the button and text for this section
        section.button.position =
        {
            left,
            FIRST_BUTTON_Y
        }
        
        left = left + BUTTON_X_OFFSET + section.button.w 
    
        section.text.position =
        {
            section.button.x + BUTTON_TEXT_X_OFFSET ,
            section.button.y + BUTTON_TEXT_Y_OFFSET - 5 
        }
        
        -- Create the dropdown group
        
        section.dropdown = Group
        {
            size = section.dropdown_bg.size,
            anchor_point = { section.dropdown_bg.w / 2 , 0 },
            position = 
            {
                section.button.x + section.button.w / 2,
                ui.bar.h + DROPDOWN_POINT_Y_OFFSET
            },
            children =
            {
                section.dropdown_bg
            }
        }
        
        -- Add the text and button
        
        ui.bar:add( section.button , section.text )
        
        -- Make sure its Z is correct with respect to the focus image
        
        section.button:lower( ui.button_focus )
        section.text:raise( ui.button_focus )
        
        -- Add the section dropdown to the screen
        
        screen:add( section.dropdown )
        i = i + 1

    end

]]
return widget
