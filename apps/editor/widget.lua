
local widget = {}

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

    return c
end 


-- make_dialogBox_bg() : make message window background 

--make_dialogBox_bg(p.width, p.height, p.border_width, p.border_color, p.fill_color, p.padding_x, p.padding_y, p.border_radius) 
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
  --if(o_type ~= "dBox" and o_type ~= "Code") then 
    c:new_path()
    c:move_to (0, 74)
    c:line_to (c.w, 74)
    c:set_line_width (3)
    c:set_source_color( BORDER_COLOR )
    c:stroke (true)
    c:fill (true)
  --  end

    c:finish_painting()
    c.position = {0,0}

    return c
end 




-- make_toastBox_bg() : make toast box background  

local function make_toastBox_bg(w,h,bw,bc,fc,px,py,br)

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
print("circle drawn")

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
print("circle drawn")

return c
end

--------------
--  Button  
--------------

function widget.button(t) 

    local p = {}
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end 

    if not p.button_type then p.button_type = "ring_image" end -- "ring", "image"  
    if not p.width then p.width = 180 end
    if not p.height then p.height = 60 end 
    if not p.size then p.size = {p.width, p.height} end   
    if not p.border_color then p.border_color = "FFFFFF" end 
    if not p.focus_color then p.focus_color = "1b911b" end 
    if not p.border_width then p.border_width = 1 end
    if not p.text then p.text = "Button" end 
    if not p.font then p.font = "DejaVu Sans 30px" end
    if not p.color then p.color = "FFFFFF" end
    if not p.padding_x then p.padding_x = 7 end
    if not p.padding_y then p.padding_y = 7 end
    if not p.border_radius then p.border_radius = 12 end
    if not p.button_image then p.button_image = assets("assets/smallbutton.png") end
    if not p.focus_image then p.focus_image = assets("assets/smallbuttonfocus.png") end

    local ring = make_ring(p.width, p.height, p.border_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
    local focus_ring = make_ring(p.width, p.height, p.focus_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
    local text = Text{name = "text", text = p.text, font = p.font, color = p.color, reactive = true} 

    local button = p.button_image
    local focus = p.focus_image

    group = Group
    {
        size = { p.width , p.height},
        children =
        {
            ring:set{name="ring", position = { 0 , 0 }, opacity = 255 },
            focus_ring:set{name="focus_ring", position = { 0 , 0 }, opacity = 0},
            button:set{name="button", position = { 0 , 0 } , size = { p.width , p.height } , opacity = 255 },
            focus:set{name="focus", position = { 0 , 0 } , size = { p.width , p.height } , opacity = 0 },
            text:set{name = "text", position = { (p.width  -text.w)/2, (p.height - text.h)/2} }
        }, 
       position = {100, 100, 0},  
       name = "button", 
       reactive = true,
       extra = {type = "Button"} 
    }
    
    if (p.button_type == "ring") then 
	button.opacity = 0
    elseif (p.button_type == "image") then 
	ring.opacity = 0
    end 

    function group.extra.on_focus_in()
        if (p.button_type == "ring") then 
	     ring.opacity = 0
	     focus_ring.opacity = 255
        elseif (p.button_type == "image") then 
	     button.opacity = 0
             focus.opacity = 255
	else 
	     ring.opacity = 0
	     focus_ring.opacity = 255
	     button.opacity = 0
             focus.opacity = 255
        end 
	group:grab_key_focus(group)
    end
    
    function group.extra.on_focus_out()
        if (p.button_type == "ring") then 
	     ring.opacity = 255
	     focus_ring.opacity = 0
             focus.opacity = 0
        elseif (p.button_type == "image") then 
	     button.opacity = 255
             focus.opacity = 0
	     focus_ring.opacity = 0
	else 
	     ring.opacity = 255
	     focus_ring.opacity = 0
	     button.opacity = 255
             focus.opacity = 0
        end 
    end
	
    mt = {}
    mt.__newindex = function (t, k, v)

    local function redraw_ring()
       ring = make_ring(p.width, p.height, p.border_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
       focus_ring = make_ring(p.width, p.height, p.focus_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
       if p.button_type == "image" then 
            ring:set{name="ring", opacity = 0}
       else 
            ring:set{name="ring", opacity = 255}
       end 
       group:remove(group:find_child("ring"))  
       group:add(ring)

       focus_ring:set{name="focus_ring", opacity = 0}
       group:remove(group:find_child("focus_ring"))  
       group:add(focus_ring)

       button:set{size={p.width , p.height }}
       focus:set{size={p.width , p.height }, opacity = 0}
       text:set{position={(p.width  -text.w)/2, (p.height - text.h)/2} }  
    end  

    if k == "text" then
       text.text = v
       text.position = { (p.width  -text.w)/2, (p.height - text.h)/2} 
       p.text = v
    elseif k == "bsize" then 
       p.width = v[1]
       p.height = v[2]
       p.size = {v[1], v[2]}
       redraw_ring()
    elseif (k == "bwidth" or k == "bw" )then 
       p.width = v
       p.size = {p.width, p.height}
       redraw_ring()
    elseif (k == "bheight" or k == "bh") then 
       p.height = v
       p.size = {p.width, p.height}
       redraw_ring()
    elseif (k == "border_width") then 
       p.border_width= v
       redraw_ring()
     elseif (k == "border_color" or k == "bc") then 
       p.border_color= v
       redraw_ring()
     elseif (k == "focus_color" or k == "fc") then 
       p.focus_color= v
       redraw_ring()
     elseif (k == "padding_x")then 
       p.padding_x = v
       redraw_ring()
     elseif (k == "padding_y")then 
       p.padding_y = v
       redraw_ring()
     elseif (k == "border_radius")then 
       p.border_radius = v
       redraw_ring()
     elseif (k == "font") then 
       p.font = v
       text:set{font = v}
     elseif (k == "color") then 
       p.color = v
       text:set{color = v}
     elseif (k == "button_image") then 
       p.button_image = assets(v)
       group:remove(group:find_child("button"))  
       button = p.button_image
       button:set{name="button", position = {0,0} , size = { p.width , p.height }}
       if p.button_type == "ring_image" or p.button_type == "image" then
	    button.opacity = 255
       else 
	    button.opacity = 0
       end 
       group:add(button)
       group:find_child("text"):raise_to_top()
     elseif (k == "focus_image") then 
       p.focus_image = assets(v)
       group:remove(group:find_child("focus"))  
       focus = p.focus_image
       focus:set{name="focus", position = {0,0} , size = { p.width , p.height }, opacity = 0}
       group:add(focus)
       group:find_child("text"):raise_to_top()
     elseif (k == "button_type" or k == "btype") then 
       p.button_type = v
       if (p.button_type == "ring") then 
	     ring.opacity = 255
	     button.opacity = 0
       elseif (p.button_type == "image") then 
	     button.opacity = 255
	     ring.opacity = 0
       else 
	     ring.opacity = 255
	     button.opacity = 255
       end 

     end 
     end 

    mt.__index = function (t,k)
    if k == "text" then return text.text
    elseif k == "bsize" then return p 
    elseif (k == "bwidth" or k == "bw") then return p.width
    elseif (k == "bheight" or k == "bh") then return p.height 
    elseif (k == "border_color") then return p.border_color 
    elseif (k == "forcus_color") then return p.forcus_color 
    elseif (k == "border_width") then return p.border_width 
    elseif (k == "font") then return p.font 
    elseif (k == "color") then return p.color 
    elseif (k == "padding_x") then return p.padding_x 
    elseif (k == "padding_y") then return p.padding_y 
    elseif (k == "border_radius") then return p.border_radius 
    elseif (k == "btype" or k =="button_type") then return p.button_type 
    end 
    end 
  
  setmetatable (group.extra, mt) 
  return group 

end

-----------------------
-- Text Input Field
-----------------------

function widget.textField(t)

    local p = {}
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end 

    if not p.box_type then p.box_type = "ring" end -- "ring_image" or "image"
    if not p.width then p.width = 200 end
    if not p.height then p.height = 80 end
    if not p.size then p.size = {p.width, p.height} end   
    if not p.text then p.text = "" end
    if not p.text_indent then p.text_indent = 20 end
    if not p.border_width then p.border_width  = 3 end
    if not p.border_color then p.border_color  = "FFFFFFC0" end 
    if not p.focus_color then p.focus_color  = "1b911b" end 
    if not p.font then p.font = "DejaVu Sans 30px"  end 
    if not p.color then p.color = "FFFFFF" end 
    if not p.padding_x then p.padding_x = 7 end
    if not p.padding_y then p.padding_y = 7 end
    if not p.border_radius then p.border_radius = 12 end
    if not p.box_img then p.box_img = assets("assets/smallbutton.png") end 
    if not p.focus_img then p.focus_img = assets("assets/smallbuttonfocus.png") end 

    local box = make_ring(p.width, p.height, p.border_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
    local focus_box = make_ring(p.width, p.height, p.focus_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
    local box_img = p.box_img
    local focus_img = p.focus_img
    local text = Text{text = p.text, editable = true, cursor_visible = true, reactive = true, font = p.font, color = p.color}

    textField = Group
     {
        size = { p.width , p.height},
        children =
        {
            box:set{name="box", position = { 0 , 0 } },
	    focus_box:set{name="focus_box", position = { 0 , 0 }, opacity = 0},
            box_img:set{name="box_img", position = { 0 , 0 } , size = { p.width , p.height } , opacity = 0 },
            focus_img:set{name="focus_img", position = { 0 , 0 } , size = { p.width , p.height } , opacity = 0 },
            text:set{name = "text", position = {p.text_indent, (p.height - text.h)/2} }
        }, 
       position = {200, 200, 0},  
       name = "textField", 
       reactive = true, 
       extra = {type = "TextInputField"} 
     }

     if (p.button_type == "ring_image") then 
	box_img.opacity = 255
     elseif (p.button_type == "image") then 
	box.opacity = 0
	box_img.opacity = 255
     end 

     function textField.extra.on_focus_in()
          if (p.box_type == "ring") then 
	     box.opacity = 0
	     focus_box.opacity = 255
          elseif (p.box_type== "image") then 
	     box_img.opacity = 0
             focus_img.opacity = 255
 	  else 
	     box.opacity = 0
	     focus_box.opacity = 255
	     box_img.opacity = 0
             focus_img.opacity = 255
          end 
          text:grab_key_focus()
	  text.cursor_visible = true
     end

     function textField.extra.on_focus_out()
          if (p.box_type == "ring") then 
	     box.opacity = 255
	     focus_box.opacity = 0
             focus_img.opacity = 0
          elseif (p.box_type == "image") then 
	     box_img.opacity = 255
	     focus_box.opacity = 0
             focus_img.opacity = 0
 	  else 
	     box.opacity = 255
	     focus_box.opacity = 0
	     box_img.opacity = 255
             focus_img.opacity = 0
          end 
	  text.cursor_visible = false
     end

     mt = {}
     mt.__newindex = function (t, k, v)

     local function redraw_ring()
       box = make_ring(p.width, p.height, p.border_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
       box:set{name="box"}
       focus_box = make_ring(p.width, p.height, p.focus_color, p.border_width, p.padding_x, p.padding_y, p.border_radius)
       focus_box:set{name="focus_box", opacity = 0}
       text:set{position={p.padding_x, (p.height - text.h)/2} }  
       textField:remove(textField:find_child("box"))  
       textField:add(box)
       textField:remove(textField:find_child("focus_box"))  
       textField:add(focus_box)
     end  

     if k == "text" then 
        p.text = v
	text.text = v
     elseif k == "bsize" then 
        p.width = v[1]
        p.height = v[2]
        p.size = {v[1], v[2]}
        redraw_ring()
     elseif (k == "bwidth" or k == "bw" )then 
        p.width = v
        p.size = {p.width, p.height}
        redraw_ring()
     elseif (k == "bheight" or k == "bh") then 
        p.height = v
        p.size = {p.width, p.height}
        redraw_ring()
     elseif (k == "border_width") then 
        p.border_width= v
        redraw_ring()
     elseif (k == "border_color" or k == "bc") then 
        p.border_color= v
        redraw_ring()
     elseif (k == "focus_color" or k == "fc") then 
        p.focus_color= v
        redraw_ring()
     elseif (k == "font") then 
        text:set{font = v}
        p.font = v
     elseif (k == "color") then 
        text:set{color = v}
	p.color = v
     elseif (k == "padding_x" or k== "px")then 
       p.padding_x = v
       redraw_ring()
     elseif (k == "padding_y" or k== "py")then 
       p.padding_y = v
       redraw_ring()
     elseif (k == "border_radius")then 
       p.border_radius = v
       redraw_ring()
     elseif (k == "box_image" or k == "b_img" or k == "box_img") then  
       p.box_img = assets(v)
       group:remove(group:find_child("box_img"))  
       box_img = p.box_img
       box_img:set{name="box_img", position = {0,0} , size = { p.width , p.height }}
       if p.box_type == "ring_image" or p.box_type == "image" then
	    box_img.opacity = 255
       else 
	    box_img.opacity = 0
       end 
       group:add(box_img)
       group:find_child("text"):raise_to_top()
     elseif (k == "focus_image" or k == "f_img" or k == "focus_img") then 
       p.focus_img = assets(v)
       group:remove(group:find_child("focus_img"))  
       focus_img = p.focus_img
       focus_img:set{name="focus_img", position = {0,0} , size = { p.width , p.height }, opacity = 0}
       group:add(focus_img)
       group:find_child("text"):raise_to_top()
    elseif (k == "box_type" or k == "btype" or k =="b_type") then 
       p.box_type = v
       if (p.box_type == "ring") then 
	     box.opacity = 255
	     box_img.opacity = 0
       elseif (p.button_type == "image") then 
	     box_img.opacity = 255
	     box.opacity = 0
       else 
	     box.opacity = 255
	     box_img.opacity = 255
       end 
     end
     end 

     mt.__index = function (t,k)
     if k == "text" then return text.text
     elseif k == "bsize" then return p.size 
     elseif (k == "bwidth" or k == "bw") then return p.width
     elseif (k == "bheight" or k == "bh") then return p.height 
     elseif (k == "border_width") then return border_width
     elseif (k == "border_color") then return border_color
     elseif (k == "focus_color") then return focus_color
     elseif (k == "font") then return font
     elseif (k == "color") then return color
     elseif (k == "padding_x") then return p.padding_x 
     elseif (k == "padding_y") then return p.padding_y 
     elseif (k == "border_radius") then return p.border_radius 
     elseif (k == "btype" or k =="box_type" or "b_type") then return p.box_type 
     end 
     end 
  
     setmetatable (textField.extra, mt) 
     return textField
end 

-------------------
--  Dialog Box  
-------------------

function widget.dialogBox(t)
    local p = {}
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end 


    if not p.box_type then p.box_type = "ring" end -- "image"
    if not p.title then p.title = "Dialog Box Title" end
    if not p.font then p.font = "DejaVu Sans 30px" end 
    if not p.color then p.color = "FFFFFF" end 

    if not p.width then p.width = 900 end
    if not p.height then p.height = 500 end
    if not p.size then p.size = {p.width, p.height} end   
    if not p.border_width then p.border_width  = 3 end
    if not p.border_color then p.border_color  = "FFFFFFC0" end 
    if not p.fill_color then p.fill_color  = {25,25,25,100} end
    if not p.padding_x then p.padding_x = 10 end
    if not p.padding_y then p.padding_y = 10 end
    if not p.border_radius then p.border_radius = 22 end

    if not p.box_image then p.box_image = assets("assets/smallbutton.png") end
    local d_box_img = p.box_image

    --if not p.x_image then p.x_image = assets("assets/xbox.png") end
    -- local x_box_img= p.x_image

    local dBox_cur_y = 40

    local d_box = make_dialogBox_bg(p.width, p.height, p.border_width, p.border_color, p.fill_color, p.padding_x, p.padding_y, p.border_radius) 
    local title= Text{text = p.title, font= "DejaVu Sans 32px", color = "FFFFFF"}     
    local x_box = make_xbox()

    local  dBox = Group {
    	  name = "dialogBox",  
    	  position = {200, 200, 0}, 
          children =
          {
	    d_box:set{name="d_box"}, 
            x_box:set{name = "x_box", position  = {p.width - 50, dBox_cur_y}},
            title:set{name = "title", position = {(p.width - title.w - 50)/2 , dBox_cur_y - 5}},
            d_box_img:set{name="d_box_img", size = { p.width , p.height } , opacity = 0}
            --x_box_img:set{name="x_box_img", size = { p.width , p.height } , opacity = 255 }, -- d_box_img have x box ? 
          }, 
          reactive = true, 
          extra = {type = "DialogBox"} 
     }

     function dBox.extra.clean()
          dBox.children = {}
          dBox_cur_y = 40
          screen:remove(dBox)
     end 

     mt = {}
     mt.__newindex = function (t, k, v)

     local function redraw_dialogBox()
          dBox:remove(dBox:find_child("x_box"))  
          dBox:remove(dBox:find_child("title"))  

          dBox:remove(dBox:find_child("d_box"))  
          d_box = make_dialogBox_bg(p.width, p.height, p.border_width, p.border_color, p.fill_color, p.padding_x, p.padding_y, p.border_radius) 
          d_box:set{name="d_box"}
          dBox:add(d_box)

          x_box:set{position  = {p.width - 50, dBox_cur_y}}
          title:set{position= {(p.width - title.w - 50)/2 , dBox_cur_y - 5}}
          dBox:add(x_box)
          dBox:add(title)
     end  

     if k == "title" then 
	title.text = v
	p.title = v
     elseif k == "bsize" then 
        p.size = {v[1], v[2]} 
        p.width = v[1]
        p.height = v[2]
        redraw_dialogBox()
     elseif (k == "bwidth" or k == "bw" )then 
        p.width = v
        p.size = {p.width, p.height}
        redraw_dialogBox()
     elseif (k == "bheight" or k == "bh") then 
        p.height = v
        p.size = {p.width, p.height}
        redraw_dialogBox()
     elseif (k == "border_width") then 
        p.border_width= v
        redraw_ring()
     elseif (k == "border_color" or k == "bc") then 
        p.border_color= v
        redraw_dialogBox()
     elseif (k == "focus_color" or k == "fc") then 
        p.focus_color= v
        redraw_dialogBox()
     elseif (k == "padding_x")then 
        p.padding_x = v
        redraw_dialogBox()
     elseif (k == "padding_y")then 
        p.padding_y = v
        redraw_dialogBox()
     elseif (k == "border_radius")then 
        p.border_radius = v
        redraw_dialogBox()
     elseif (k == "font") then 
        p.font = v
        title:set{font = v}
     elseif (k == "color") then 
        p.color = v
        title:set{color = v}
     elseif (k == "box_image") then 
        p.box_image = assets(v)
        dBox:remove(dBox:find_child("d_box_img"))  
        d_box_img = p.box_image
        d_box_img:set{name="d_box_img", position = {0,0} , size = { p.width , p.height }}
        if p.box_type == "ring" then 
	    d_box_img.opacity = 0
        elseif p.box_type == "image" then
	    d_box_img.opacity = 255
        end 
        dBox:add(d_box_img)
        dBox:find_child("title"):raise_to_top()
     elseif (k == "box_type" or k == "btype") then 
       p.box_type = v
       if (p.box_type == "ring") then 
	     d_box.opacity = 255
	     x_box.opacity = 255
	     d_box_img.opacity = 0
       elseif (p.box_type == "image") then 
	     d_box_img.opacity = 255
	     d_box.opacity = 0
	     x_box.opacity = 0
       end 
     end 
     end 

     mt.__index = function (t,k)
     if k == "title" then return title.text
     elseif k == "bsize" then return p.size 
     elseif (k == "bwidth" or k == "bw") then return p.width
     elseif (k == "bheight" or k == "bh") then return p.height 
     elseif (k == "font") then return title.font
     elseif (k == "color") then return title.color
     elseif (k == "padding_x") then return p.padding_x 
     elseif (k == "padding_y") then return p.padding_y 
     elseif (k == "border_radius") then return p.border_radius 
     elseif (k == "btype" or k =="box_type" or k == "b_type") then return p.box_type 
     end 
     end 
  
     setmetatable (dBox.extra, mt) 
     return dBox
end 


-------------------
--  Toast  
-------------------

function widget.toastBox(t)
    local p = {}
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end 

    if not p.box_type then p.box_type = "ring" end -- "image"
    if not p.title then p.title = "Toast Box Title" end
    if not p.message then p.message = "Toast box message ... " end
    if not p.font then p.font = "DejaVu Sans 30px" end 
    if not p.color then p.color = "FFFFFF" end 

    if not p.width then p.width = 600 end
    if not p.height then p.height = 200 end
    if not p.size then p.size = {p.width, p.height} end   
    if not p.border_width then p.border_width  = 3 end
    if not p.border_color then p.border_color  = "FFFFFFC0" end 
    if not p.fill_color then p.fill_color  = {25,25,25,100} end
    if not p.padding_x then p.padding_x = 10 end
    if not p.padding_y then p.padding_y = 10 end
    if not p.border_radius then p.border_radius = 22 end

    if not p.fade_duration then p.fade_duration = 2000 end
    if not p.duration then p.duration = 5000 end
    if not p.box_image then p.box_image = assets("assets/smallbutton.png") end
    local t_box_img = p.box_image
    if not p.icon_image then p.icon_image = assets("assets/voice-1.png") end
    local icon = p.icon_image

    local t_box = make_toastBox_bg(p.width, p.height, p.border_width, p.border_color, p.fill_color, p.padding_x, p.padding_y, p.border_radius) 
    local title= Text{text = p.title, font= "DejaVu Sans 32px", color = "FFFFFF"}     
    local message= Text{text = p.message, font= "DejaVu Sans 32px", color = "FFFFFF"}     

    local tBox_cur_y = 30
    local tBox_cur_x = 30

    local tBox_timer = Timer()
    tBox_timer.interval = p.duration 

    local tBox_timeline = Timeline {
	       duration = p.fade_duration,
	       direction = "FORWARD",
	       loop = false
	  }


    local  tBox = Group {
    	  name = "toastBox",  
    	  position = {200, 200, 0}, 
          children =
          {
	    t_box:set{name="t_box"}, 
            icon:set{size = {100, 100}, name = "icon", position  = {tBox_cur_x, tBox_cur_y}}, --30,30
            title:set{name = "title", position = {(p.width - title.w - tBox_cur_x)/2 , tBox_cur_y+20 }},  --,50
            message:set{name = "message", position = {icon.w + tBox_cur_x, tBox_cur_y*2 + title.h }}, 
            t_box_img:set{name="t_box_img", size = { p.width , p.height } , opacity = 0}
          }, 
          reactive = true, 
          extra = {type = "ToastBox"} 
     }

     function tBox.extra.clean()
          tBox.children = {}
          g:remove(tBox)
     end 

     function tBox_timeline.on_new_frame(t, m, p)
	tBox.opacity = 255 * (1-p) 
     end  

     function tBox_timeline.on_completed()
	tBox.opacity = 0
	tBox.extra.clean()
     end 

     function tBox_timer.on_timer(tBox_timer)
	tBox_timeline:start()
        tBox_timer:stop()
     end 
  
     function tBox.extra.start_timer() 
	tBox_timer:start()
     end 
    
     mt = {}
     mt.__newindex = function (t, k, v)

     local function redraw_tBox()
          tBox:remove(tBox:find_child("icon"))  
          tBox:remove(tBox:find_child("title"))  
          tBox:remove(tBox:find_child("message"))  
          tBox:remove(tBox:find_child("t_box"))  

          t_box = make_tBox_bg(p.width, p.height, p.border_width, p.border_color, p.fill_color, p.padding_x, p.padding_y, p.border_radius) 
          t_box:set{name="t_box"}
          icon:set{position  = {tBox_cur_x, tBox_cur_y}}
          title:set{position= {(p.width - title.w - tBox_cur_x)/2 , tBox_cur_y+20 }}
          message:set{position= {icon.w + tBox_cur_x, tBox_cur_y*2 + title.hi}}

          tBox:add(t_box)
          tBox:add(icon)
          tBox:add(title)
          tBox:add(message)
     end  

     if k == "title" then 
	title.text = v
	p.title = v
     elseif k == "message" or k == "msg" then 
	message.text = v
	p.message = v
     elseif k == "bsize" then 
        p.size = {v[1], v[2]} 
        p.width = v[1]
        p.height = v[2]
        redraw_tBox()
     elseif (k == "bwidth" or k == "bw" )then 
        p.width = v
	p.size = {p.width, p.height}
        redraw_tBox()
     elseif (k == "bheight" or k == "bh") then 
        p.height = v
	p.size = {p.width, p.height}
        redraw_tBox()
     elseif (k == "border_width") then 
        p.border_width= v
        redraw_ring()
     elseif (k == "border_color" or k == "bc") then 
        p.border_color= v
        redraw_tBox()
     elseif (k == "focus_color" or k == "fc") then 
        p.focus_color= v
        redraw_tBox()
     elseif (k == "padding_x")then 
        p.padding_x = v
        redraw_tBox()
     elseif (k == "padding_y")then 
        p.padding_y = v
        redraw_tBox()
     elseif (k == "border_radius")then 
        p.border_radius = v
        redraw_tBox()
     elseif (k == "font") then 
        p.font = v
        title:set{font = v}
        message:set{font = v}
     elseif (k == "color") then 
        p.color = v
        title:set{color = v}
        message:set{color = v}
     elseif (k == "box_image") then 
        p.box_image = assets(v)
        tBox:remove(tBox:find_child("t_box_img"))  
        t_box_img = p.box_image
        t_box_img:set{name="t_box_img", position = {0,0} , size = { p.width , p.height }}
        if p.box_type == "ring" then 
	    t_box_img.opacity = 0
        elseif p.box_type == "image" then
	    t_box_img.opacity = 255
        end 
        tBox:add(t_box_img)
        tBox:find_child("title"):raise_to_top()
     elseif (k == "icon_image" or k == "icon") then 
        p.icon_image = assets(v)
        tBox:remove(tBox:find_child("icon"))  
        icon = p.icon_image
        icon:set{name="icon", position = {0,0} , size = {tBox_cur_x, tBox_cur_y}}
        tBox:add(icon)
     elseif (k == "box_type" or k == "btype") then 
       p.box_type = v
       if (p.box_type == "ring") then 
	     t_box.opacity = 255
	     t_box_img.opacity = 0
       elseif (p.box_type == "image") then 
	     t_box_img.opacity = 255
	     t_box.opacity = 0
       end 
     elseif k == "fade_duration" or k == "f_dur" or k == "f_duration" then 
	p.fade_duration = v
        tBox_timeline.duration = p.fade_duration
     elseif k == "duration" or k == "dur" then 
	p.duration = v
	tBox_timer.interval = p.duration 
     end 
     end 

     mt.__index = function (t,k)
     if k == "title" then return title.text
     elseif k == "message" or k == "msg" then return message.text
     elseif k == "duration" or k == "dur" then return tBox_timer.interval --p.duration
     elseif k == "fade_duration" or k == "f_dur" or k == "fade_dur" then return tBox_timeline.duration --p.fade_duration
     elseif k == "bsize" then return p.size 
     elseif (k == "bwidth" or k == "bw") then return p.width
     elseif (k == "bheight" or k == "bh") then return p.height 
     elseif (k == "font") then return title.font
     elseif (k == "color") then return title.color
     elseif (k == "padding_x") then return p.padding_x 
     elseif (k == "padding_y") then return p.padding_y 
     elseif (k == "border_radius") then return p.border_radius 
     elseif (k == "btype" or k =="box_type" or k == "b_type") then return p.box_type 
     end 
     end 
  
     setmetatable (tBox.extra, mt) 

     return tBox
end 


-----------------------
--  Button Picker 
-----------------------
 
--[[name = mode, korean-mode 
    options : {{"Home Mode","Casa el Modo de","Mode d'Accueil","가정용"}, 
              {"Store Demo","Demo Store","Demo Store","데모 모드"}}
 ]]

-- options={}
-- ex: options = { "item1", "item2", item3" }
-- option_events = {} 
-- ex: option_events = { [options[1]] = function item1_eve() end } 

--[[
bp.options = {"home","school","shop"}
bp.home = function (a,b,c) print (a,b,c) end 
bp.home (1,2,3) 


   function eve1 () 
   end 
  

   function eve2 ()
   end 

   < [ options ] > 

   bp =  buttonPicker(options = {"item1", "item2"}, events = {eve1, eve2})

   dumptable (bp.options)
   bp.options = {}
  
   ]]



function widget.buttonPicker(t)
     local p = {}
     if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
     end 

     if not p.name then p.name = "buttonCarousel" end   
     if not p.options then p.options = {} end   
     if not p.items then p.items = {"item1", "item2", "itme3"} end
     if not p.events then p.events = {} end   

     if not p.width then p.width =  300 end -- 180 end
     if not p.height then p.height = 100 end  -- 60 end
     if not p.size then p.size = {p.width, p.height} end   

     if not p.border_width then p.border_width  = 3 end
     if not p.border_color then p.border_color  = "FFFFFFC0" end 
     if not p.font then p.font = "DejaVu Sans 30px"  end 
     if not p.color then p.color = "FFFFFF" end 
     if not p.padding_x then p.padding_x = 10 end
     if not p.padding_y then p.padding_y = 10 end
     if not p.border_radius then p.border_radius = 22 end
     if not p.rotate_func then p.rotate_func = function(p,n) end end 

     local index = 1
     local padding = 10 

     local buttons = { unfocus, focus }
     local arrows    = { right_un, right_sel, left_un, left_sel }

     --local pos = {30, 30} -- button top position   
     local pos = {p.width/6, p.height/2}
     local index = 1

     local unfocus = assets("assets/smallbutton.png")
	   unfocus:set{ position = {pos[1], pos[2]}, size = p.size, opacity = 255}
--anchor_point = {unfocus.w/2,unfocus.h/2}, position = {pos[1], pos[2]}, opacity = 255}
     local focus = assets("assets/smallbuttonfocus.png")
	   focus:set{ position = {pos[1], pos[2]}, size = p.size, opacity = 0}
--anchor_point = {focus.w/2,focus.h/2}, position = {pos[1], pos[2]}, opacity = 0}
     local left_un   = assets("assets/left.png")
	   left_un:set{position = {pos[1] - left_un.w - padding, pos[2] + padding}, opacity = 255}
--anchor_point = {left_un.w/2,left_un.h/2}, position = {pos[1] - left_un.w - padding, pos[2]}, opacity = 255}
     local left_sel  = assets("assets/leftfocus.png")
	   left_sel:set{position = {pos[1] - left_un.w - padding, pos[2] + padding}, opacity = 0}
--anchor_point = {left_sel.w/2,left_sel.h/2}, position = {pos[1] - left_un.w - padding, pos[2]}, opacity = 0}
     local right_un  = assets("assets/right.png")
	   right_un:set{position = {pos[1] + focus.w + padding, pos[2] + padding}, opacity = 255}
--anchor_point = {right_un.w/2,right_un.h/2}, position = {pos[1] + focus.w + padding, pos[2]}, opacity = 255}
     local right_sel = assets("assets/rightfocus.png")
	   right_sel:set{position = {right_un.x, right_un.y},  opacity = 0}
--anchor_point = {right_sel.w/2,right_sel.h/2}, position = {right_un.x, right_un.y},  opacity = 0}

     local txt_group = Group ()
     for i, j in pairs(p.options) do 
	  local item = Text {name = "item"..tostring(i), text = p.options[i], font = p.font, color = p.color } 
          txt_group:add(item) 
     end 
---

     local items = Group()
     items:set{name = "items"}
     for i, j in pairs(p.items) do 
	  if i == 1 then 
               items:add(Text{name="item"..tostring(i), text = j, font=p.font, color =p.color, position = {pos[1] + unfocus.w/2 - string.len(j)*20/2, pos[2] + padding}, opacity = 255})     
	  else 
               items:add(Text{name="item"..tostring(i), text = j, font=p.font, color =p.color, position = {pos[1] + unfocus.w/2 - string.len(j)*20/2 + 200 , pos[2] + padding}, opacity = 255})     
	  end 
     end 
---

     bPicker = Group
     {
	name = "buttonPicker", 
	position = {300, 300, 0}, 
	children = {unfocus, focus, right_un, right_sel, left_un, left_sel, items},
        reactive = true, 
	extra = {type = "ButtonPicker"}
     }

     function bPicker.extra.on_focus()
        unfocus.opacity = 0
	focus.opacity   = 255
     end
     function bPicker.extra.out_focus()
        unfocus.opacity = 255
	focus.opacity   = 0
     end

     bPicker:find_child("items").clip = 
     {
        
	pos[1] + unfocus.w/2 - 50 , 
	pos[2] + padding, 
	pos[1] + unfocus.w/2, 
	pos[2] + padding + unfocus.h

     }

     local t = nil

     function bPicker.extra.press_left()
            local prev_i = index
            local next_i = (index-1-1)%(table.getn(p.items))+1

            print(prev_i,next_i, table.getn(p.items),"hi")

	    index = next_i

	    local prev_old_x = pos[1] + unfocus.w/2 - 50 
	    local prev_old_y = pos[2] + padding
	    local next_old_x = pos[1] + unfocus.w/2 - 50 +focus.w
	    local next_old_y = pos[2] + padding
	    local prev_new_x = pos[1] + unfocus.w/2 - 50 -focus.w
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
	    if p.rotate_func then
	       p.rotate_func(next_i,prev_i)
	    end

	    t:start()
	end

	function bPicker.extra.press_right()
		local prev_i = index
		local next_i = (index+1-1)%(table.getn(p.items)) + 1
                print(prev_i,next_i)
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

		t = Timeline
		{
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
		if p.rotate_func then
		     p.rotate_func(next_i,prev_i)
		end

		t:start()

	end
 	function bPicker.extra.press_up()
	end
	function bPicker.extra.press_down()
	end
	function bPicker.extra.press_enter()
	end

	bPicker.out_focus()
        
        return bPicker 
end



------------------------------------
--  List Picker : Radio Button   
------------------------------------
function widget.radioButton(t)
    local p = {}
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end 

    if not p.b_type then p.b_type = "canvas" end -- "image"
    if not p.items then p.items = {"item1", "item2", "itme3"} end
    if not p.font then p.font = "DejaVu Sans 30px" end -- items 
    if not p.color then p.color = "FFFFFF" end -- items 


    if not p.width then p.width = 600 end
    if not p.height then p.height = 200 end
    if not p.size then p.size = {p.width, p.height} end   

    if not p.button_color then p.button_color = {255,255,255,200} end -- items 
    if not p.select_color then p.select_color = {100, 100, 100, 255} end -- items 
    if not p.button_radius then p.button_radius = 10 end -- items 
    if not p.select_radius then p.select_radius = 5 end  -- items 

    if not p.ring_pos then p.ring_pos = {0, 0} end  -- items 
    if not p.item_pos then p.item_pos = {50,3} end  -- items 
    if not p.line_pad then p.line_pad = 40 end  -- items 

    
    if not p.button_image then p.button_image = Image{} end --assets("assets/radiobutton.png") end
    if not p.select_image then p.select_image = Image{} end --assets("assets/radiobutton_selected.png") end

    if not p.selected_item then p.selected_item = 1 end 

    local items = Group()
    local rings = Group() 
    local select_img
    local rButton = Group()

    local function make_radioButton()
	 if items.children ~= nil then items.children = {} end 
	 if rings.children ~= nil then rings.children = {} end 
	 if select_img ~= nil then select_img = nil end 


         if(p.b_type == "canvas") then 
	     select_img = create_select_circle(p.select_radius, p.select_color)
         else 
    	     select_img = p.select_image
         end 
    
         select_img:set{name = "select_img", position = {0,0}, opacity = 255} 

         for i, j in pairs(p.items) do 
	      itm_h = p.line_pad
              items:add(Text{name="item"..tostring(i), text = j, font=p.font, color =p.color, position = {0, i * itm_h - itm_h}})     
	      if p.b_type == "canvas" then 
    	           rings:add(create_circle(p.button_radius, p.button_color):set{name="ring"..tostring(i), position = {0, i * itm_h - itm_h}} ) 
	      elseif p.b_type == "image" then 
	           rings:add(Clone{name = "item"..tostring(i),  source=p.button_image, position = {0, i * itm_h - itm_h}}) 
	      end 
         end 
     end

     make_radioButton()

     rButton = Group {
          name = "radioButton",  
    	  position = {200, 200, 0}, 
          children ={ 
	       rings:set{name = "rings", position = p.ring_pos}, 
	       items:set{name = "items", position = p.item_pos}, 
	       select_img
          }, 
          reactive = true, 
          extra = {type = "RadioButton", selected = p.selected_item}, -- selected items # 
     }

     rButton:find_child("select_img").x  = (rButton:find_child("items")):find_child("item"..tostring(rButton.extra.selected)).x + 10 
     rButton:find_child("select_img").y  = (rButton:find_child("items")):find_child("item"..tostring(rButton.extra.selected)).y + 10 

     function rButton.extra.clean() 
	  (rButton:find_child("items")).children = {}
	  (rButton:find_child("rings")).children = {}
          rButton:remove(rButton:find_child("items"))  
          rButton:remove(rButton:find_child("rings"))  
          rButton:remove(rButton:find_child("select_img"))  
          rButton.children = {}
          g:remove(rButton)
     end 

     mt = {}
     mt.__newindex = function (t, k, v)

     if k == "button_radius" or k == "br" or k == "b_radius" then 
        p.button_radius= v
        make_radioButton()
     elseif (k == "select_radius" or k == "sr" or k == "s_radius") then 
        p.select_radius= v
        make_radioButton()
     elseif k == "button_color" or k == "bc" or k == "b_color" then 
        p.button_color= v
        make_radioButton()
     elseif (k == "select_color" or k == "sc" or k == "s_color") then 
        p.select_color= v
        make_radioButton()
     elseif (k == "font") then 
        p.font = v
	for i, j in pairs(p.items) do 
              ((rButton:find_child("items")):find_child("item"..tostring(i))):set{font=p.font} 
	end
     elseif (k == "color") then 
        p.color = v
	for i, j in pairs(p.items) do 
              ((rButton:find_child("items")):find_child("item"..tostring(i))).color=p.color 
	end
     elseif (k == "button_image" or k == "b_img" or k == "b_image") then 
        p.button_image = assets(v)
	make_radioButton() 
     elseif (k == "select_image" or k == "s_img" or k == "s_image") then 
        p.select_image = assets(v)
	make_radioButton() 
     elseif (k == "button_type" or k == "btype" or k == "b_type") then 
        p.b_type = v
        make_radioButton() 
     elseif k == "items" then 
	p.items = v
        make_radioButton() 
     elseif k == "ring_pos" or k == "r_pos" or k == "rpos" then 
	p.ring_pos = v
	rButton:find_child("rings"):set{position = p.ring_pos} 
	rButton:find_child("select_img"):set{position = {p.ring_pos[1] + 10, p.ring_pos[2] + 10}} 
     elseif k == "item_pos" or k == "i_pos" or k == "ipos" then 
	p.item_pos = v
	rButton:find_child("items"):set{position = p.item_pos} 
     elseif k == "line_pad" or k == "l_pad" or k == "lpad" then 
	p.line_pad = v
	itm_h = p.line_pad
        for i, j in pairs(p.items) do 
	      ((rButton:find_child("rings")):find_child("ring"..tostring(i))).position = {0, i * itm_h - itm_h} 
	      ((rButton:find_child("items")):find_child("item"..tostring(i))).position = {0, i * p.line_pad - p.line_pad, 0}
        end 
     elseif k == "selected_item" or k == "s_item" then 
	if v <= table.getn(p.items) then 
	     print("item number :", table.getn(p.items))
	     p.selected_item = v
	else 
	     print("selected_item is bigger then the number of items")
	     p.selected_item = 1 
	end 
	rButton.extra.selected = p.selected_item
        rButton:find_child("select_img").opacity  = 255
        rButton:find_child("select_img").x  = (rButton:find_child("items")):find_child("item"..tostring(rButton.extra.selected)).x + 10 
        rButton:find_child("select_img").y  = (rButton:find_child("items")):find_child("item"..tostring(rButton.extra.selected)).y + 10 
     end 
     end 

     mt.__index = function (t,k)
     if k == "items" then return p.items
     elseif k == "selected_item" or k == "s_item" then return p.selected_item
     elseif k == "line_pad" or k == "lpad" then return p.line_pad
     elseif k == "button_radius" or k == "br" or k == "b_radius" then return p.button_radius
     elseif k == "select_radius" or k == "sr" or k == "s_radius" then return p.select_radius
     elseif k == "button_color" or k == "bc" or k == "b_color" then return p.button_color
     elseif k == "select_color" or k == "sc" or k == "s_color"then return p.select_color
     elseif (k == "font") then return p.font
     elseif (k == "color") then return p.color
     elseif k == "button_image" or k == "b_img" or k == "b_image" then return p.button_image.source
     elseif k == "select_image" or k == "s_img" or k == "s_image" then return p.select_image.source
     elseif k == "button_type" or k == "b_type" or k == "btype" then return p.b_type 
     elseif k == "bsize" then return p.size 
     elseif (k == "bwidth" or k == "bw") then return p.width
     elseif (k == "bheight" or k == "bh") then return p.height 
     elseif (k == "ring_pos") then return p.ring_pos
     elseif (k == "item_pos") then return p.item_pos
     end 
     end 
  
     setmetatable (rButton.extra, mt)

     return rButton
end 



------------------------------------
--  List Picker : Check Box   
------------------------------------
function widget.checkBox(t)
    local p = {}
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end 

    if not p.b_type then p.b_type = "canvas" end -- "image"
    if not p.items then p.items = {"item1", "item2", "itme3"} end
    if not p.font then p.font = "DejaVu Sans 30px" end -- items 
    if not p.color then p.color = "FFFFFF" end -- items 

    if not p.box_color then p.box_color = {255,255,255,255} end
    if not p.fill_color then p.fill_color = {255,255,255,50} end
    if not p.box_width then p.box_width = 2 end
    if not p.box_size then p.box_size = {25,25} end
    if not p.check_size then p.check_size = {25,25} end

    if not p.width then p.width = 600 end
    if not p.height then p.height = 200 end
    if not p.size then p.size = {p.width, p.height} end   

    if not p.line_pad then p.line_pad = 40 end   
    if not p.box_pos then p.box_pos = {0, 0} end  -- items 
    if not p.item_pos then p.item_pos = {50,-5} end  -- items 
    if not p.selected_item then p.selected_item = 1 end  

    if not p.box_image then p.box_image = Image{} end --assets("assets/radiobutton.png") end
    if not p.check_image then p.check_image = assets("assets/checkmark.png") end 

    local items = Group()
    local boxes = Group() 
    local check_img
    local cBox = Group()

    local function make_checkBox()

	 if items.children ~= nil then items.children = {} end 
	 if boxes.children ~= nil then boxes.children = {} end 
	 if check_img ~= nil then check_img = nil end 
	 
    	 check_img = p.check_image
	 check_img:set { name="check_img", position = {0,0,0}, size = p.check_size, opacity = 255 }

         for i, j in pairs(p.items) do 
	      itm_h = p.line_pad
              items:add(Text{name="item"..tostring(i), text = j, font=p.font, color = p.color, position = {0, i * itm_h - itm_h}})     
	      if p.b_type == "canvas" then 
    	           boxes:add(Rectangle{name="box"..tostring(i),  color= p.fill_color, border_color= p.box_color, border_width= p.box_width, 
				       size = p.box_size, position = {0, i * itm_h - itm_h,0}, opacity = 255}) 
	      elseif p.b_type == "image" then 
	           boxes:add(Clone{name = "item"..tostring(i),  source=p.button_image, size = p.box_size, position = {0, i * itm_h - itm_h,0}, opacity = 255}) 
	      end 
         end 
    end
    
    make_checkBox()

    local  cBox = Group {
    	  name = "checkBox",  
    	  position = {200, 200, 0}, 
          children ={ 
	      boxes:set{name = "boxes", position = p.box_pos}, 
	      items:set{name = "items", position = p.item_pos}, 
	      check_img
          }, 
          reactive = true, 
          extra = {type = "ToastBox", selected = 1}, -- selected items # 
     }

     cBox:find_child("check_img").x  = (cBox:find_child("items")):find_child("item"..tostring(cBox.extra.selected)).x 
     cBox:find_child("check_img").y  = (cBox:find_child("items")):find_child("item"..tostring(cBox.extra.selected)).y 

     function cBox.extra.clean()
 	  (cBox:find_child("items")).children = {}
	  (cBox:find_child("boxes")).children = {}
          cBox:remove(cBox:find_child("items"))  
          cBox:remove(cBox:find_child("boxes"))  
          cBox:remove(cBox:find_child("check_img"))  
          cBox.children = {}
          g:remove(cBox)
     end 

     mt = {}
     mt.__newindex = function (t, k, v)

     if (k == "button_type" or k == "btype" or k == "b_type") then 
        p.b_type = v
        make_checkBox() 
     elseif k == "items" then 
	p.items = v
        make_checkBox() 
     elseif (k == "font") then 
        p.font = v
	for i, j in pairs(p.items) do 
              ((cBox:find_child("items")):find_child("item"..tostring(i))):set{font=p.font} 
	end
     elseif (k == "color") then 
        p.color = v
	for i, j in pairs(p.items) do 
              ((cBox:find_child("items")):find_child("item"..tostring(i))).color=p.color 
	end
     elseif k == "box_color" or k == "bc" or k == "b_color" then 
        p.box_color= v
	for i, j in pairs(p.items) do 
	      if p.b_type == "canvas" then 
    	          ((cBox:find_child("boxes")):find_child("box"..tostring(i))):set{ border_color= p.box_color }
	      end
	end
     elseif k == "fill_color" or k == "fc" or k == "f_color" then 
        p.fill_color= v
	for i, j in pairs(p.items) do 
	      if p.b_type == "canvas" then 
    	          ((cBox:find_child("boxes")):find_child("box"..tostring(i))):set{ color= p.fill_color} 
	      end
	end
     elseif k == "box_width" or k == "bw" or k == "b_width" then 
        p.box_width= v
	for i, j in pairs(p.items) do 
	      if p.b_type == "canvas" then 
    	          ((cBox:find_child("boxes")):find_child("box"..tostring(i))):set{ border_width= p.box_width}
	      end
	end
     elseif k == "box_size" or k == "bs" or k == "b_size" then 
        p.box_size= v
	for i, j in pairs(p.items) do 
	      if p.b_type == "canvas" then 
    	          ((cBox:find_child("boxes")):find_child("box"..tostring(i))):set{ size = p.box_size}
	      end
	end
     elseif k == "check_size" or k == "cs" or k == "c_size" then 
        p.check_size= v
	check_img:set {size = p.check_size}
     elseif (k == "box_image" or k == "b_img" or k == "b_image") then 
        p.box_image = assets(v)
	for i, j in pairs(p.items) do 
	     if p.b_type == "image" then 
    	     ((cBox:find_child("boxes")):find_child("box"..tostring(i))):set{source = p.box_image}
	     end 
        end 

     elseif (k == "check_image" or k == "c_img" or k == "c_image") then 
        cBox:find_child("check_img").source = v
        cBox:find_child("check_img").x  = (cBox:find_child("items")):find_child("item"..tostring(cBox.extra.selected)).x 
        cBox:find_child("check_img").y  = (cBox:find_child("items")):find_child("item"..tostring(cBox.extra.selected)).y 
     elseif k == "box_pos" or k == "b_pos" or k == "bpos" then 
	p.box_pos = v
	cBox:find_child("boxes"):set{position = p.box_pos} 
	cBox:find_child("check_img"):set{position = p.box_pos} 
     elseif k == "item_pos" or k == "i_pos" or k == "ipos" then 
	p.item_pos = v
	cBox:find_child("items"):set{position = p.item_pos} 
     elseif k == "line_pad" or k == "l_pad" or k == "lpad" then 
	p.line_pad = v
	itm_h = p.line_pad
        for i, j in pairs(p.items) do 
	      ((cBox:find_child("boxes")):find_child("box"..tostring(i))).position = {0, i * itm_h - itm_h} 
	      ((cBox:find_child("items")):find_child("item"..tostring(i))).position = {0, i * p.line_pad - p.line_pad, 0}
        end 
     elseif k == "selected_item" or k == "s_item" then 
	if v <= table.getn(p.items) then 
	     p.selected_item = v
	else 
	     p.selected_item = 1 
	end 
	cBox.extra.selected = p.selected_item
        cBox:find_child("check_img").opacity  = 255
        cBox:find_child("check_img").x  = (cBox:find_child("items")):find_child("item"..tostring(cBox.extra.selected)).x 
        cBox:find_child("check_img").y  = (cBox:find_child("items")):find_child("item"..tostring(cBox.extra.selected)).y 
     end 
     end 

     mt.__index = function (t,k)
     if k == "items" then return p.items
     elseif k == "selected_item" or k == "s_item" then return p.selected_item
     elseif k == "line_pad" or k == "lpad" then return p.line_pad
     elseif k == "box_color" or k == "bc" or k == "b_color" then return p.box_color
     elseif k == "fill_color" or k == "fc" or k == "f_color" then return p.fill_color
     elseif k == "box_width" or k == "bw" or k == "b_width" then return p.box_width
     elseif k == "box_size" or k == "bs" or k == "b_size" then return p.box_size
     elseif k == "check_size" or k == "cs" or k == "c_size"then return p.check_size
     elseif (k == "font") then return p.font
     elseif (k == "color") then return p.color
     elseif k == "box_image" or k == "b_img" or k == "b_image" then return p.box_image.source
     elseif k == "check_image" or k == "c_img" or k == "c_image" then return p.check_image.source
     elseif k == "box_type" or k == "b_type" or k == "btype" then return p.b_type 
     elseif (k == "box_pos") then return p.box_pos
     elseif (k == "item_pos") then return p.item_pos
     end 
     end 
  
     setmetatable (cBox.extra, mt)
     
     return cBox
end 



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
