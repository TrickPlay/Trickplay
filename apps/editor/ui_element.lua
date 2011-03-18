     local ui_element = {}
     skin_list = { ["default"] = {
				   ["button"] = "assets/smallbutton.png", 
				   ["button_focus"] = "assets/smallbuttonfocus.png", 
			           ["buttonpicker"] = "assets/smallbutton.png",
     				   ["buttonpicker_focus"] = "assets/smallbuttonfocus.png",
				   ["buttonpicker_left_un"] = "assets/left.png",
				   ["buttonpciker_left_sel"] = "assets/leftfocus.png",
				   ["buttonpicker_right_un"] = "assets/right.png",
        			   ["buttonpicker_right_sel"] = "assets/rightfocus.png",
				   ["checkbox_sel"] = "assets/checkmark.png", 
				   ["loading_dot"]  = nil,
                   ["scroll_arrow"] = nil,
                   ["drop_down_color"]={0,0,0},
                   ["menu_bar"] = "assets/menu-background.png",
				  },

	            ["custom"] = {},
		    ["skin_type1"] = { 
				   ["button"] = "assets/button-red.png", 
				   ["button_focus"] = "assets/button-focus.png", 
				   ["toast"] = "assets/background-blue-6.jpg", 
				   ["textinput"] = "", 
				   ["textinput_focus"] = "", 
				   ["dialogbox"] = "", 
			           ["dialogbox_x"] ="", 
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
                   ["drop_down_color"]={255,0,0},
                   ["scroll_arrow"] = nil,
                   ["menu_bar"] = "assets/menu-background.png",
				  },
 
		    ["skin_type2"] = { 
				   ["button"] = "assets/button-blue.png", 
				   ["button_focus"] = "assets/button-focus.png", 
				   ["textinput"] = "", 
				   ["textinput_focus"] = "", 
				   ["dialogbox"] = "", 
			           ["dialogbox_x"] ="", 
				   ["toast"] = "assets/background-red-6.jpg", 
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
                   ["drop_down_color"]={0,0,255},
                   ["scroll_arrow"] = nil,
                   ["menu_bar"] = "assets/menu-background.png",
				  },
		    ["skin_type3"] = { 
				   ["button"] = "assets/button-blue.png", 
				   ["button_focus"] = "assets/smallbuttonfocus.png",
                   ["drop_down_color"]={0,0,255},
                   ["scroll_arrow"] = nil,
				  },
		    ["skin_type4"] = { 
				   ["button"] = "assets/button-blue.png", 
				   ["button_focus"] = "assets/smallbuttonfocus.png",
                   ["drop_down_color"]={0,0,255},
                   ["scroll_arrow"] = nil,
				  },
		    ["skin_type5"] = { 
				   ["button"] = "assets/button-blue.png", 
				   ["button_focus"] = "assets/smallbuttonfocus.png",
                   ["drop_down_color"]={0,0,255},
                   ["scroll_arrow"] = nil,
				  },
		    ["skin_type6"] = { 
				   ["button"] = "assets/button-blue.png", 
				   ["button_focus"] = "assets/smallbuttonfocus.png",
                   ["drop_down_color"]={0,0,255},
                   ["scroll_arrow"] = nil,
				  },

		  }


	
	-- used for timeline 
        attr_map = {
          	["Rectangle"] = function() return {"x", "y", "z", "w","h","opacity","color","border_color", "border_width", "x_rotation", "y_rotation", "z_rotation", "anchor_point"} end,
        	["Image"] = function() return {"x", "y", "z", "w","h","opacity","x_rotation", "y_rotation", "z_rotation", "anchor_point"} end,
        	["Text"] = function() return {"x", "y", "z", "w","h","opacity","color","x_rotation", "y_rotation", "z_rotation", "anchor_point"} end,
        	["Group"] = function() return {"x", "y", "z", "w","h","opacity","x_rotation", "y_rotation", "z_rotation", "anchor_point", "scale"} end,
        	["Clone"] = function() return {"x", "y", "z", "w","h","opacity","x_rotation", "y_rotation", "z_rotation", "anchor_point", "scale"} end,
        }

 -- for mouse control 

if controllers.start_pointer then 
  controllers:start_pointer()
end


--[[
Function: change_all_skin

Changes all ui elements' skins to 'skin_name' item:find_child("textInput").text

Arguments:
	skin_name - name of skin  
]]

function ui_element.change_all_skin(skin_name)
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


function ui_element.change_button_skin(skin_name)
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

-- make_titile_seperator() : make a title seperator line

local function make_title_seperator(thickness, color, length)

    local c = Canvas{ size = {length, thickness} }

    c:begin_painting()
    c:new_path()

  -- Draw x button
    local x=0 
    local y=0

    c:move_to ( x, y)
    c:line_to ( x + length, y)
    c:set_line_width (thickness)
    c:set_source_color(color)
    c:stroke (true)
    c:fill (true)

    c:finish_painting()

    if c.Image then
         c = c:Image()
    end
    
    return c
end 


-- make_dialogBox_bg() : make message window background 

--make_dialogBox_bg(p.wwidth, p.wheight, p.border_width, p.border_color, p.f_color, p.padding_x, p.padding_y, p.border_corner_radius) 
local function make_dialogBox_bg(w,h,bw,bc,fc,px,py,br,tst,tsc)

    local size = {w, h} 
    local color = fc 
    local BORDER_WIDTH= bw
    local POINT_HEIGHT=34
    local POINT_WIDTH=60
    local BORDER_COLOR=bc
    local CORNER_RADIUS=br 
    local POINT_CORNER_RADIUS=2
    local H_BORDER_WIDTH = BORDER_WIDTH / 2

    local XBOX_SIZE = 25
    local PADDING = px 

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
    -- test c:set_dash(0,{10,10})
    c:stroke( true )

  -- Draw title line
    if tst > 0 then 
    c:new_path()
    c:move_to (0, 74)
    c:line_to (c.w, 74)
    c:set_line_width (tst)
    c:set_source_color(tsc)
    c:stroke (true)
    c:fill (true)
    end 
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

local function name2num(name)
	if name then 
	    return tonumber(name:sub(8, -1))	
	end 
end 

local function draw_timeline(timeline, p, duration, num_pointer)

	bg = Rectangle {
		color = {25,25,25,50},
		border_color = {25,25,25,255},
		border_width = 2,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "bg",
		position = {0,0,0},
		size = {screen.w,76},
		opacity = 255,
	}

	line = Rectangle {
		color = {25,25,25,255},
		border_color = {255,255,255,255},
		border_width = 0,
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "line",
		position = {60,36,0},
		size = {screen.w - 120,6},
		opacity = 255,
	}

	timeline:add(bg,line)

	timeline:add(Text{
		color = {255,255,255,255},
		font = "DejaVu Sans 22px",
		text = "Beginnig", 
		editable = true,
		wants_enter = true,
		cursor_visible = false,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text0",
		position = {60,6,0},
		size = {200,30},
		opacity = 255,
	})

	timeline:add(Image{
		src = "assets/left.png",
		clip = {0,0,16,33},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {90,0,0},
		anchor_point = {0,0},
		reactive = true,
		name = "pointer0",
		position = {90,42,0},
		size = {16,33},
		opacity = 255,
		extra = {set = true},
	})


	local function make_pointer_focus(pointerName)
	    local pointer = timeline:find_child(pointerName)
	    if pointer then 
	       function pointer.extra.on_focus_in()
		    timeline:find_child(pointer.name).src = "assets/leftfocus.png"
	       end
      
	       function pointer.extra.on_focus_out()
		 pointer.src = "assets/left.png"
		 for n,m in pairs (g.children) do 
		     if m.extra.timeline[name2num(pointerName)] then
			for l,k in pairs (attr_map[m.type]()) do 
	     			m.extra.timeline[name2num(pointerName)][k] = m[k]
			end
                     end 
	         end 
		 pointer.extra.set = true
	       end 
	    end
	end 

	make_pointer_focus("pointer0")

	local prev_text_x = -60 
	local prev_img_x = 60

	for i, j in orderedPairs(p) do 
	    timeline:add(Text{
		color = {255,255,255,255},
		font = "DejaVu Sans 22px",
		text = p[i][1],
		editable = true,
		wants_enter = true,
		cursor_visible = false,
		wrap = true,
		wrap_mode = "CHAR",
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {0,0,0},
		anchor_point = {0,0},
		name = "text"..tostring(i),
  		position = {math.floor(p[i][2] * line.w / duration) + prev_text_x,6,0},
		size = {200,30},
		opacity = 255,
	    })
	    prev_text_x = math.floor(p[i][2] * line.w / duration) + prev_text_x

	    timeline:add(Image{
		src = "assets/left.png",
		clip = {0,0,16,33},
		scale = {1,1,0,0},
		x_rotation = {0,0,0},
		y_rotation = {0,0,0},
		z_rotation = {90,0,0},
		anchor_point = {0,0},
		reactive = true,
		name = "pointer"..tostring(i),
  		position = {math.floor(p[i][2] * line.w / duration) + prev_img_x,42,0},
		size = {16,33},
		opacity = 255,
		extra = {set = false},
	   })
	   prev_img_x = math.floor(p[i][2] * line.w / duration) + prev_img_x 
	   make_pointer_focus("pointer"..tostring(i))
        end 

        return timeline
end 


--[[
Function: timeline

Creates a timeline ui element

Arguments:
	Table of timeline properties
	
	duration 
	num_point  
	points - time point information - {name of point, duration, chainging time}

Return:
 	timeline - The timeline tool 

Extra Function:
	hide()
	show()
	
]]

function ui_element.timeline(t)

 --default parameters
    local p = {
	duration = 6000,
    	num_point = 3,  	--[read only] 
	points = {},
    }

 --overwrite defaults
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end 

 --set default points table

    local function set_default_point(i, j)
	if not j then
	    p.points[i] = {}
	    p.points[i][1] = ""--timepoint"..tostring(i) -- name of time point
	    p.points[i][2] = p.duration / p.num_point -- duration
	    p.points[i][3] = p.duration / p.num_point -- changing time 
	elseif j == 1 then   
       	     p.points[i][j] = "timepoint"..tostring(i) -- name of time point
	else 
   	     p.points[i][j] = p.duration / p.num_point -- duration, changing time 
	end 
    end

   
 --the umbrella Group
    local timeline_timers, timeline_timelines 
    local timeline = Group {
		name = "timeline",
		reactive = true,
		position = {0,screen.h - 76,0},
		size = {1700,76},
		opacity = 255,
		extra = {type = "TimeLine"}
    }


    local function find_prev_i(name)
	local prev_i = 0 
        local num_name = name2num(name)
	local rr 

        for j,k in orderedPairs (p.points) do 
	     if j == num_name then 
		rr = prev_i 
	     end 
	     prev_i = j 
	end 
	return rr 
    end 

-- make_on_button_down() function for time pointer image
    local function make_on_button_down(name) 
	 local pointer = timeline:find_child(name)

	 local function pointer_on_button_up(x,y,b,n)
	     if(dragging ~= nil) then 
	          local actor , dx , dy = unpack( dragging )
		  local timepoint, new_timepoint, prev_point, next_point, last_point, new_x
		  local timeline_length = 1800
		  local duration = screen:find_child("timeline").duration
		  for j,k in orderedPairs (screen:find_child("timeline").points) do
	     	       last_point = j
		  end 
		  timepoint = tonumber(actor.name:sub(8, -1))
		  new_x = x - dx 
		  if timepoint == last_point then 
		      if new_x > timeline_length + 60 then 
		          new_x = timeline_length + 60
	              end 
	          end
		  screen:find_child("text"..tostring(timepoint)).x = new_x - 120 
		  pointer.x = new_x
	          dragging = nil

		  new_timepoint = math.floor((new_x - 60)/timeline_length * duration)

		  if new_timepoint ~= timepoint then 
		      screen:find_child("timeline").points[new_timepoint] = {}
		      screen:find_child("timeline").points[new_timepoint][1] = 
		      screen:find_child("timeline").points[timepoint][1]	

		      table_removekey(screen:find_child("timeline").points, timepoint)

		      local prev_i = 0
		      for j,k in orderedPairs (screen:find_child("timeline").points) do
	    	          if j == new_timepoint then 
		 	       prev_point = prev_i 
	     	          end 
	     	          prev_i = j
		      end 
		      screen:find_child("timeline").points[new_timepoint][2] = new_timepoint - prev_point 
		      screen:find_child("timeline").points[new_timepoint][3] = new_timepoint - prev_point 
            	      
		      local temp_point = nil 
		      for j,k in orderedPairs (screen:find_child("timeline").points) do
			  if temp_point then 
				next_point = j
				temp_point = nil
			  end 
	    	          if j == new_timepoint then 
		 	       temp_point = j 
	     	          end 
		      end 
			
		      --print("new_point::",new_timepoint)
		      --print("next_point::",next_point)
                      if next_point then 
		          screen:find_child("timeline").points[next_point][2] = next_point - new_timepoint 
		          screen:find_child("timeline").points[next_point][3] = next_point - new_timepoint 
                      end
			
		      --dumptable(screen:find_child("timeline").points)
		      for n,m in pairs (g.children) do
			     if m.extra.timeline then
				  for i,j in pairs (m.extra.timeline) do 
					if i == timepoint then 
					    m.extra.timeline[new_timepoint] = {}
				            for l,k in pairs (j) do 
					         m.extra.timeline[new_timepoint][l] = k
					    end 
					    table_removekey(m.extra.timeline, timepoint) 
				        end 
				  end 
			     end
		      end 
			
		      pointer.name = "pointer"..tostring(new_timepoint) 
		      screen:find_child("text"..tostring(timepoint)).name = "text"..tostring(new_timepoint) 
		      screen:find_child("timeline").points = screen:find_child("timeline").points
		      for i,j in pairs (screen:find_child("timeline").children) do 
		           if j.name:find("pointer") then 
		                j.extra.set = true
			   end
		      end
			
		      if current_time_focus then 
			     current_time_focus.extra.on_focus_out()
		      end 
		      current_time_focus = timeline:find_child("pointer"..tostring(new_timepoint)) 
		      timeline:find_child("pointer"..tostring(new_timepoint)).on_focus_in()

        	      for n,m in pairs (g.children) do 
	                  if m.extra.timeline then 
	                       if m.extra.timeline[new_timepoint] then 
	         	            m:show()
	                            for l,k in pairs (m.extra.timeline[new_timepoint]) do 
		                        if l ~= "hide" then
		                          m[l] = k
		                        elseif k == true then 
		                          m:hide() 
		                        end 
	                            end
                               end 
	                  end
	              end 

		  end 
             end
         end


	 function pointer:on_button_down(x,y,b,n)
	    if current_time_focus then 
	         current_time_focus.on_focus_out()
	    end 
	    current_time_focus = pointer
	    pointer.on_focus_in()
	    
            for n,m in pairs (g.children) do 
		if pointer.extra.set == false then 
		   local prev_i = find_prev_i(pointer.name)
		   if m.extra.timeline[prev_i] then    
		     for l,k in pairs (m.extra.timeline[prev_i]) do 
			m[l] = k
		     end 
	           end 
		else 
		   if m.extra.timeline[name2num(pointer.name)] then 
		     m:show()
		     for l,k in pairs (m.extra.timeline[name2num(pointer.name)]) do 
			if l ~= "hide" then
			     m[l] = k
			elseif k == true then 
			     m:hide() 
			end 
		     end
                   end 
		end 
	   end 
           if name2num(pointer.name) ~= 0 then 
	   	if(b == 3) then-- imsi : num_clicks is not correct ! 
	 	--if(b == 3 or n >= 2) then
			-- point_inspector()
	   	else
                 	dragging = {pointer, x - pointer.x, y - pointer.y, pointer_on_button_up }
           	 	return true
	   	end 
	   end 
	end 
    end 

    local function points_getn(points)
	local num = 0
	for i, j in pairs (points) do
	     num = num+1
	end
	return num
    end

    local create_timeline = function ()

    	timeline:clear()

	if points_getn(p.points) > 0 then 
	     p.num_point = points_getn(p.points) 
	else 
 	     for i = p.duration/p.num_point , p.duration,  p.duration/p.num_point do 
	          set_default_point(i)
	     end 
   	end 
 
    	timeline = draw_timeline(timeline, p.points, p.duration, p.num_point)

        current_time_focus = timeline:find_child("pointer0") 
	timeline:find_child("pointer0").on_focus_in()

        for n,m in pairs (g.children) do 
	   if m.extra.timeline then 
	     if m.extra.timeline[0] then 
	         m:show()
	         for l,k in pairs (m.extra.timeline[0]) do 
		     if l ~= "hide" then
		         m[l] = k
		     elseif k == true then 
		         m:hide() 
		     end 
	         end
             end 
	   end
	end 
        	
    	timeline_timers = {}
    	timeline_timelines = {}

	local first_point = 0 
	for i, j in orderedPairs(p.points) do 
	  timeline_timers[i] = Timer()
	  timeline_timelines[i] = Timeline()
	  if first_point == 0 then 
	       timeline_timers[i].interval = 1
          else 
	       timeline_timers[i].interval = first_point
	  end 
    	  timeline_timelines[i].duration = p.points[i][2] 	 
    	  timeline_timelines[i].direction = "FORWARD"
    	  timeline_timelines[i].loop = false
    
	  local tl = timeline_timelines[i]
  	  local next_point, current_point 

	  current_point = first_point
          next_point = i 

          function tl.on_new_frame(t, m, p) 
		for n,m in pairs (g.children) do 
		     if m.extra.timeline[current_point] then  
			if m.extra.timeline[current_point]["hide"] then 
			   if  m.extra.timeline[current_point]["hide"] == true then 
				m:hide()
			   end 
			end 	
			for l,k in pairs (attr_map[m.type]()) do 
				 if type(m[k]) == "table" then 
					local temptable = {}
					for o = 1, table.getn(m[k]),1 do 
				      		local interval = Interval(m.extra.timeline[current_point][k][o], m.extra.timeline[next_point][k][o])
						temptable[o] = interval:get_value(p)
				        end 
					m[k] = temptable
				elseif k ~= "hide" then  
					local interval = Interval(m.extra.timeline[current_point][k], m.extra.timeline[next_point][k])
					m[k] = interval:get_value(p)
				end
			end 
		     end 
	         end
         end  

         function tl.on_completed()
		for n,m in pairs (g.children) do 
		     if m.extra.timeline[current_point] then 
			for l,k in pairs (attr_map[m.type]()) do 
				if type(m[k]) == "table" then 
				    local temptable = {}
				    for o = 1, table.getn(m[k]),1 do 
					temptable[o] = m.extra.timeline[next_point][k][o]
				    end
				    m[k] = temptable
				elseif k ~= "hide" then
				    m[k] = m.extra.timeline[next_point][k] 
				end 
			end 
		     end
		     if m.extra.timeline[next_point] then 
			if not m.extra.timeline[next_point]["hide"] then 
			     m:show()
			end 	
		     end 
		end
        end 


        local tl_timer = timeline_timers[i]
	
        function tl_timer:on_timer()
		timeline_timelines[i]:start()
        	timeline_timers[i]:stop()
        end 
     
	  first_point = next_point
     end 
    dumptable(timeline_timers)
    dumptable(timeline_timelines)

     -- start_timer() function 
     function g.extra.start_timer()
	if current_time_focus then 
		current_time_focus.on_focus_out()
		current_time_focus = nil
	end 
	for i, j in orderedPairs(p.points) do 
	     timeline_timers[i]:start()
	end 
     end 

    -- set object.extra.timeline table
      for n,m in pairs (g.children) do 
	 if m.name then 
	    local prev_point = 0	  
	    if not m.extra.timeline then 
                m.extra.timeline = {}
                m.extra.timeline[0] = {}
	        for l,k in pairs (attr_map[m.type]()) do 
	        	m.extra.timeline[0][k] = m[k]
	        end
	    end 
	    for i, j in orderedPairs(p.points) do 
	        if not m.extra.timeline[i] then 
		    m.extra.timeline[i] = {} 
	            for l,k in pairs (attr_map[m.type]()) do 
		         m.extra.timeline[i][k] = m.extra.timeline[prev_point][k] 
		    end 
		    prev_point = i 
		end 
	    end 
    	   end 
    	end 

	make_on_button_down("pointer0")
	for i, j in orderedPairs(p.points) do 
	     make_on_button_down("pointer"..tostring(i))
        end 
    end 

    create_timeline()

    mt = {}
    mt.__newindex = function (t, k, v)
	print("NEW NEW NEW")
	if k ~= "num_point" then
        	p[k] = v
        	create_timeline()
	else 
	     print(k,"is read only. \n")
	end 
	
    end 

    mt.__index = function (t,k)
	return p[k]
    end 

    setmetatable (timeline.extra, mt) 

    return timeline
	
end 




--[[
Function: button

Creates a button ui element

Arguments:
	Table of button properties
	
	skin - Modify the skin for the button by changing this value
    	bwidth  - Width of the button
    	bheight - Height of the button
    	button_color - Border color of the button
    	focus_color - Focus color of the button
    	border_width - Border width of the button
    	text - Caption of the button
    	text_font - Font of the button text
    	text_color - Color of the button text
    	padding_x - Padding of the button image on the X axis
    	padding_y - Padding of the button image on the Y axis
    	border_corner_radius - Radius of the border for the button
	pressed - Function that is called by on_focus_in() or on_key_down() event
	release - Function that is called by on_focus_out()


Return:
 	b_group - The group containing the button 

Extra Function:
	on_focus_out() - Releases the button focus
	on_focus_in() - Grabs the button focus
	
]]

function ui_element.button(table) 

 --default parameters
    local p = {
    	text_font = "DejaVu Sans 30px",
    	text_color = {255,255,255,255}, --"FFFFFF",
    	skin = "default", 
    	wwidth = 180,
    	wheight = 60, 

    	label = "Button", 
    	focus_color = {27,145,27,255}, --"1b911b", 
    	button_color = {255,255,255,255}, --"FFFFFF"
    	border_width = 1,
    	border_corner_radius = 12,
	pressed = nil, 
	released = nil, 

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
    
    function b_group.extra.on_focus_in() 
	current_focus = b_group
        if (p.skin == "custom") then 
	     ring.opacity = 0
	     focus_ring.opacity = 255
        else
	     button.opacity = 0
             focus.opacity = 255
        end 
	if p.pressed then 
		p.pressed()
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
	if p.released then 
		p.released()
	end 
 
    end

    local create_button = function() 

	if(p.skin ~= "custom") then 
		p.button_image = assets(skin_list[p.skin]["button"])
		p.focus_image  = assets(skin_list[p.skin]["button_focus"])
	end
        b_group:clear()
        b_group.size = { p.wwidth , p.wheight}
        ring = make_ring(p.wwidth, p.wheight, p.button_color, p.border_width, 0, 0, p.border_corner_radius)
        ring:set{name="ring", position = { 0 , 0 }, opacity = 255 }

        focus_ring = make_ring(p.wwidth, p.wheight, p.focus_color, p.border_width, 0, 0, p.border_corner_radius)
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
        text = Text{name = "text", text = p.label, font = p.text_font, color = p.text_color} --reactive = true 
        text:set{name = "text", position = { (p.wwidth  -text.w)/2, (p.wheight - text.h)/2}}

        b_group:add(ring, focus_ring, button, focus, text)

        if (p.skin == "custom") then button.opacity = 0 
        else ring.opacity = 0 end 

	if editor_lb == nil then 
	     function b_group:on_button_down(x,y,b,n)
		if current_focus then 
		     current_focus.on_focus_out()
		end
		b_group.extra.on_focus_in()
		return true
	     end 
	end 
    end 

    create_button()
	
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
Function: textInput

Creates a text field ui element

Arguments:
	Table of text field properties

		skin - Modify the skin used for the text field by changing this value
    	bwidth  - Width of the text field
    	bheight - Height of the text field 
    	border_color - Border color of the text field
    	focus_color - Focus color of the text field
    	text_color - Color of the text in the text field
    	text_font - Font of the text in the text field
    	border_width - Border width of the text field 
    	padding - Size of the text indentiation 
    	border_corner_radius - Radius of the border for the button image 
    	text - Caption of the text field  

Return:
 	t_group - The group contaning the text field
 	
Extra Function:
	on_focus_out() - Releases the text field focus
	on_focus_in() - Grabs the text field focus
	
]]


function ui_element.textInput(table) 
 --default parameters
    local p = {
    	skin = "custom", 
    	wwidth = 200 ,
    	wheight = 60 ,
    	text = "" ,
    	padding = 20 ,
    	border_width  = 4 ,
    	border_color  = {255,255,255,255}, --"FFFFFFC0" , 
    	focus_color  = {0,255,0,255}, --"1b911b" , 
    	text_font = "DejaVu Sans 30px"  , 
    	text_color =  {255,255,255,255}, -- "FFFFFF" , 
    	border_corner_radius = 12 ,

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
       extra = {type = "TextInput"} 
    }
 

    local create_textInputField= function()
    	t_group:clear()
        t_group.size = { p.wwidth , p.wheight}

    	box = make_ring(p.wwidth, p.wheight, p.border_color, p.border_width, 0, 0, p.border_corner_radius)
    	box:set{name="box", position = {0 ,0}}

    	focus_box = make_ring(p.wwidth, p.wheight, p.focus_color, p.border_width, 0, 0, p.border_corner_radius)
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

    	text = Text{text = p.text, editable = false, cursor_visible = false, wants_enter = false, reactive = true, font = p.text_font, color = p.text_color}
    	text:set{name = "textInput", position = {p.padding, (p.wheight - text.h)/2} }
    	t_group:add(box, focus_box, box_img, focus_img, text)

    	if (p.skin == "custom") then box_img.opacity = 0
    	else box.opacity = 0 box_img.opacity = 255 end 

     end 

     create_textInputField()

     function t_group.extra.on_focus_in()
	  current_focus = t_group
          if (p.skin == "custom") then 
	     box.opacity = 0
	     focus_box.opacity = 255
          else
	     box_img.opacity = 0
             focus_img.opacity = 255
          end 
	  text.editable = true
	  text.cursor_visible = true
	  text.reactive = true 
          text:grab_key_focus(text)
     end

     function t_group.extra.on_focus_out()
          if (p.skin == "custom") then 
	     box.opacity = 255
	     focus_box.opacity = 0
          else
	     box_img.opacity = 255
             focus_img.opacity = 0
          end 
	  text.cursor_visible = false
	  text.reactive = false 
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

Creates a Dialog box ui element

Arguments:
	Table of Dialog box properties

	skin - Modify the skin used for the dialog box by changing this value
    	bwidth  - Width of the dialog box 
    	bheight - Height of the dialog box
    	label - Title in the dialog box
    	fill_color - Background color of the dialog box
    	border_color - Border color of the dialog box
    	title_color - Color of the dialog box text 
    	title_font - Font of the text in the dialog box
    	border_width - Border width of the dialog box  
    	border_corner_radius - The radius of the border of the dialog box
	title_seperator_thickness - Thickness of the title seperator 
	title_seperator_color - Color of the title seperator 
    	padding_x - Padding of the dialog box on the X axis
    	padding_y - Padding of the dialog box on the Y axis

Return:
 	db_group - group containing the dialog box
]]

function ui_element.dialogBox(table) 
 
--default parameters
   local p = {
	skin = "custom", 
	wwidth = 900 ,
	wheight = 500 ,
	label = "Dialog Box Title" ,
	border_color  = {255,255,255,255}, --"FFFFFFC0" , 
	fill_color  = {25,25,25,100},
	title_color = {255,255,255,255} , --"FFFFFF" , 
	title_font = "DejaVu Sans 30px" , 
	border_width  = 4 ,
	padding_x = 0 ,
	padding_y = 0 ,
	border_corner_radius = 22 ,
	title_seperator_thickness = 4, 
	title_seperator_color = {255,255,255,255},
    }

 --overwrite defaults
    if table ~= nil then 
        for k, v in pairs (table) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local db_group_cur_y = 6
    local d_box, title_seperator, title, d_box_img, title_seperator_img

    local  db_group = Group {
    	  name = "dialogBox",  
    	  position = {200, 200, 0}, 
          reactive = true, 
          extra = {type = "DialogBox"} 
    }


    local create_dialogBox  = function ()
   
        db_group:clear()
        db_group.size = { p.wwidth , p.wheight - 34}

        d_box = make_dialogBox_bg(p.wwidth, p.wheight, p.border_width, p.border_color, p.fill_color, p.padding_x, p.padding_y, p.border_corner_radius, p.title_seperator_thickness, p.title_seperator_color) 
	d_box.y = d_box.y - 34
	d_box:set{name="d_box"} 
	db_group:add(d_box)
--[[
	if p.title_seperator_thickness >  0 then 
             title_seperator = make_title_seperator(p.title_seperator_thickness, p.title_seperator_color, p.wwidth)
             title_seperator:set{name = "title_seperator", position  = {0, db_group_cur_y + 30}}
	     db_group:add(title_seperator)
	end
  ]]

        title= Text{text = p.label, font= p.title_font, color = p.title_color}     
        title:set{name = "title", position = {(p.wwidth - title.w - 50)/2 , db_group_cur_y - 5}}

	if(p.skin ~= "custom") then 
        	d_box_img = assets(skin_list[p.skin]["dialogbox"])
        	d_box_img:set{name="d_box_img", size = { p.wwidth , p.wheight } , opacity = 0}
	else 
		d_box_img = Image{} 
	end

	db_group:add(d_box_img, title)

	if (p.skin == "custom") then d_box_img.opacity = 0
        else d_box.opacity = 0 end 

     end 

     create_dialogBox ()

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
Function: toastAlert

Creates a Toast alert ui element

Arguments:
	Table of Toast alert properties
	
	skin - Modify the skin used for the toast ui element by changing this value
	title - Title of the Toast alert
	message - Message displayed in the Toast alert
    	title_font - Font used for text in the Toast alert
    	message_font - Font used for text in the Toast alert
    	title_color - Color of the text in the Toast alert
    	message_color - Color of the text in the Toast alert
    	bwidth  - Width of the Toast alert 
    	bheight - Height of the Toast alert 
    	border_color - Border color of the Toast alert
    	fill_color - Fill color of the Toast alert
    	border_width - Border width of the Toast alert 
    	padding_x - Padding of the toast alert on the X axis 
    	padding_y - Padding of the toast alert on the Y axis
    	border_corner_radius - Radius of the border for the Toast alert 
	fade_duration - Time in milleseconds that the Toast alert spends fading away
	on_screen_duration - Time in milleseconds that the Toast alert spends in view before fading out
	icon - The image file name for the icon 

Return:
 		tb_group - Group containing the Toast alert

Extra Function:
		start_timer() - Start the timer of the Toast alert
]]



function ui_element.toastAlert(table) 

 --default parameters
    local p = {
 	skin = "custom",  
	wwidth = 600,
	wheight = 200,
	label = "Toast Alert Title",
	message = "Toast alert message",
	title_font = "DejaVu Sans 32px", 
	message_font = "DejaVu Sans 28px", 
	title_color = {255,255,255,255},  
	message_color = {255,255,255,255}, 
	border_width  = 3,
	border_color  = {255,255,255,255}, --"FFFFFFC0", 
	fill_color  = {25,25,25,100},
	padding_x = 0,
	padding_y = 0,
	border_corner_radius = 22,
	fade_duration = 2000,
	on_screen_duration = 5000,
	icon = "assets/voice-1.png"
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
    	  position = {800, 600, 0}, 
          reactive = true, 
          extra = {type = "ToastAlert"} 
     }

    local tb_group_cur_y = 10
    local tb_group_cur_x = 20
    local tb_group_timer = Timer()
    local tb_group_timeline = Timeline ()
    

    local create_toastBox = function()

    	tb_group:clear()
        tb_group.size = { p.wwidth , p.wheight}

    	t_box = make_toastb_group_bg(p.wwidth, p.wheight, p.border_width, p.border_color, p.fill_color, p.padding_x, p.padding_y, p.border_corner_radius) 
    	t_box:set{name="t_box"}
	tb_group.anchor_point = {p.wwidth/2, p.wheight/2}

	icon = assets(p.icon)
    	icon:set{size = {100, 100}, name = "icon", position  = {tb_group_cur_x, tb_group_cur_y}} --30,30

    	title= Text{text = p.label, font= p.title_font, color = p.title_color}     
    	title:set{name = "title", position = {(p.wwidth - title.w - tb_group_cur_x)/2 , tb_group_cur_y+20 }}  --,50

    	message= Text{text = p.message, font= p.message_font, color = p.message_color}     
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

    	tb_group_timer.interval = p.on_screen_duration 
    	tb_group_timeline.duration = p.fade_duration
    	tb_group_timeline.direction = "FORWARD"
    	tb_group_timeline.loop = false

     	function tb_group_timeline.on_new_frame(t, m, p)
		tb_group.opacity = 255 * (1-p) 
		if(tb_group.scale[1] > 0.8) then 
		     tb_group.scale = {(1-p/10), (1-p/10)} 
	        end 
     	end  

     	function tb_group_timeline.on_completed()
		tb_group.opacity = 0
		tb_group.scale = {0.8, 0.8}
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

Creates a button picker ui element

Arguments:
	Table of Button picker properties

	skin - Modify the skin for the Button picker by changing this value
    	bwidth - Width of the Button picker 
    	bheight - Height of the Button picker 
        items - A table containing the items for the Button picker
    	text_font - Font of the Button picker items
    	text_color - Color of the Button picker items
    	border_color - Color of the Button 
    	focus_color - Focus color of the Button 
	selected_item - The number of the selected item 
	rotate_func - function that is called by selected item number   

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
function ui_element.buttonPicker(table) 
    local w_scale = 1
    local h_scale = 1

 --default parameters 
    local p = {
	skin = "default", 
	wwidth =  180,
	wheight = 60,
	items = {"item1", "item2", "item3"},
	text_font = "DejaVu Sans 30px" , 
	text_color = {255,255,255,255}, 
	border_color = {255,255,255,255},
	focus_color = {0,255,0,255},
	rotate_func = nil, 
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

     local bp_group = Group
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
	items:clear()
        bp_group.size = { p.wwidth , p.wheight}

	ring = make_ring(p.wwidth, p.wheight, p.border_color, 1, 7, 7, 12)
        ring:set{name="ring", position = {pos[1] , pos[2]}, opacity = 255 }

        focus_ring = make_ring(p.wwidth, p.wheight, p.focus_color, 1, 7, 7, 12)
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
               items:add(Text{name="item"..tostring(i), text = j, font=p.text_font, color =p.text_color, opacity = 255})     
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
	current_focus = bp_group
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

Creates a Radio button ui element

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


function ui_element.radioButton(table) 

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

Creates a Check box ui element

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


function ui_element.checkBox(table) 

 --default parameters
    local p = {
	skin = "custom", 
	wwidth = 600,
	wheight = 200,
	items = {"item1", "item2", "item3"},
	font = "DejaVu Sans 30px", 
	color = {255,255,255,255}, 
	box_color = {255,255,255,255},
	f_color = {255,255,255,0},
	box_width = 2,
	box_size = {25,25},
	check_size = {25,25},
	line_space = 40,   
	b_pos = {0, 0},  
	item_pos = {50,-5},  
	selected_items = {1},  
	direction = 1,  -- 1:vertical 2:horizontal
		rotate_func = nil,  
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
	      local box, check
	      if(p.direction == 1) then --vertical 
                  pos= {0, i * p.line_space - p.line_space}
	      end   			

	      items:add(Text{name="item"..tostring(i), text = j, font=p.font, color = p.color, position = pos})     
	      if p.skin == "custom" then 
		   box = Rectangle{name="box"..tostring(i),  color= p.f_color, border_color= p.box_color, border_width= p.box_width, 
				       size = p.box_size, position = pos, reactive = true, opacity = 255}
    	           boxes:add(box) 
	     else
	           box = Clone{name = "box"..tostring(i),  source=p.button_image, size = p.box_size, position = pos, reactive = true, opacity = 255}
		   boxes:add(box) 
	     end 

	     check = Image{name="check"..tostring(i), src=p.check_image, size = p.check_size, position = pos, reactive = false, opacity = 0}
	     checks:add(check) 

	     function box:on_button_down (x,y,b,n)
		local box_num = tonumber(box.name:sub(4,-1))
		p.selected_items = table_insert(p.selected_items, box_num)
		cb_group:find_child("check"..tostring(box_num)).opacity = 255
		cb_group:find_child("check"..tostring(box_num)).reactive = true
		return true
	     end 
	     function check:on_button_down(x,y,b,n)
		local check_num = tonumber(check.name:sub(6,-1))
		p.selected_items = table_removeval(p.selected_items, check_num)
		check.opacity = 0
		check.reactive = false
		return true
	     end 

	     if(p.direction == 2) then --horizontal
		  pos= {pos[1] + items:find_child("item"..tostring(i)).w + 2*p.line_space, 0}
	     end 
         end 

	 for i,j in pairs(p.selected_items) do 
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
Function: Progress Spinner

Creates a Loading dots ui element

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
function ui_element.progressSpinner(t) 
    --default parameters
    local p = {
        skin          = "default",
        dot_diameter    = 5,
        dot_color     = {255,255,255,255},
        number_of_dots      = 12,
        overall_diameter   = 50,
        cycle_time = 150*12,
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
        name     = "progressSpinner",
        position = {400,400},
        anchor_point = {p.overall_diameter/2,p.overall_diameter/2},
        reactive = true,
        extra = {
            type = "ProgressSpinner", 
            speed_up = function()
                p.cycle_time = p.cycle_time - 50
                create_dots()
            end,
            speed_down = function()
                p.cycle_time = p.cycle_time + 50
                create_dots()
            end,
        },
    }
    --table of the dots, used by the animation
    local dots   = {}
    local load_timeline = nil
    
    --the Canvas used to create the dots
    local make_dot = function(x,y)
          local dot  = Canvas{size={p.dot_diameter, p.dot_diameter}}
          dot:begin_painting()
          dot:arc(p.dot_diameter/2,p.dot_diameter/2,p.dot_diameter/2,0,360)
          dot:set_source_color(p.dot_color)
          dot:fill(true)
          dot:finish_painting()

          if dot.Image then
              dot = dot:Image()
          end
          dot.anchor_point ={p.dot_diameter/2,p.dot_diameter/2}
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
        
        for i = 1, p.number_of_dots do
            --they're radial position
            rad = (2*math.pi)/(p.number_of_dots) * i
            print(p.clone_src)
            if p.clone_src == nil and skin_list[p.skin]["loadingdot"] == nil then
                print(1)
                dots[i] = make_dot(
                    math.floor( p.overall_diameter/2 * math.cos(rad) )+p.overall_diameter/2+p.dot_diameter/2,
                    math.floor( p.overall_diameter/2 * math.sin(rad) )+p.overall_diameter/2+p.dot_diameter/2
                )
	    elseif skin_list[p.skin]["loadingdot"] ~= nil then
		img = assets(skin_list[p.skin]["loadingdot"])
		img.anchor_point = {
                        img.w/2,
                        img.h/2
                    }
		img.position = {

                        math.floor( p.overall_diameter/2 * math.cos(rad) )+p.overall_diameter/2+p.dot_diameter/2,
                        math.floor( p.overall_diameter/2 * math.sin(rad) )+p.overall_diameter/2+p.dot_diameter/2
                    }
		dots[i] = img
            else
                print(2)
                dots[i] = Clone{
                    source = p.clone_src,
                    position = {

                        math.floor( p.overall_diameter/2 * math.cos(rad) )+p.overall_diameter/2+p.dot_diameter/2,
                        math.floor( p.overall_diameter/2 * math.sin(rad) )+p.overall_diameter/2+p.dot_diameter/2
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
            duration  =  p.cycle_time,
            direction = "FORWARD", 
        }

	-- table.insert( fff , load_timeline )

        local increment = math.ceil(255/p.number_of_dots)
        
        function load_timeline.on_new_frame(t)
            local start_i   = math.ceil(t.elapsed/(p.cycle_time/p.number_of_dots))
            local curr_i    = nil
            
            for i = 1, p.number_of_dots do
                curr_i = (start_i + (i-1))%(p.number_of_dots) +1
                
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
Function: Progress Bar

Creates a Loading bar ui element

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
function ui_element.progressBar(t)

    --default parameters
    local p={
        wwidth             = 300,
        wheight            = 50,
        shell_upper_color  = {0,0,0,255},
        shell_lower_color  = {127,127,127,255},
        stroke_color       = {160,160,160,255},
        fill_upper_color  = {255,0,0,255},
        fill_lower_color  = {96,48,48,255},
        progress          = 0,
    }
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end

	

	local c_shell = Canvas{
            size = {p.wwidth,p.wheight},
            x    = p.wwidth,
            y    = p.wheight
        }
	local c_fill  = Canvas{
            size = {1,p.wheight},
            x    = p.wwidth+2,
            y    = p.wheight
        }
	local l_bar_group = Group{
		name     = "progressBar",
        	position = {400,400},
	        anchor_point = {p.radius,p.radius},
        	reactive = true,
	        extra = {
        	    type = "ProgressBar", 
        	    set_prog = function(prog)
	                c_fill.scale = {(p.wwidth-4)*(prog),1}
        	    end,
	        },
	}

	local function create_loading_bar()
		l_bar_group:clear()
        local stroke_width = 2
		c_shell = Canvas{
				size = {p.wwidth,p.wheight},
		}
		c_fill  = Canvas{
				size = {1,p.wheight-stroke_width},
		}  
        
		
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
        c_fill.x=stroke_width
        c_fill.y=stroke_width/2
        c_fill.scale = {(p.wwidth-4)*(p.progress),1}
		l_bar_group:add(c_shell,c_fill)
	end
    
	create_loading_bar()
    
    
    
    
	local mt = {}
    
    mt.__newindex = function(t,k,v)
        p[k] = v
        if k == "progress" then
            c_fill.scale = {(p.wwidth-4)*(v),1}
        else
            create_loading_bar()
        end
    end
    
    mt.__index = function(t,k)       
        return p[k]
    end
    
    setmetatable(l_bar_group.extra, mt)
    
	return l_bar_group
end
--[[
Function: Layout Manager

Creates a 2D grid of items, that animate in with a flipping animation

Arguments:
    num_rows    - number of rows
    num_cols    - number of columns
    item_w      - width of an item
    item_h      - height of an item
    grid_gap    - the number of pixels in between the grid items
	duration_per_tile - how long a particular tile flips for
	cascade_delay     - how long a tile waits to start flipping after its neighbor began flipping
    tiles       - the uielements that are the tiles, the elements are assumed to be of the size {item_w,item_h} and that there are 'num_rows' by 'num_cols' elements in a 2 dimensional table 
Return:

		Group - Group containing the grid
        
Extra Function:
	get_tile_group(r,c) - returns group for the tile at row 'r' and column 'c'
    animate_in() - performs the animate-in sequence
]]
function ui_element.layoutManager(t)
    --default parameters
    local p = {
        rows    = 4,
        columns    = 3,
        cell_w      = 300,
        cell_h      = 200,
        cell_spacing    = 40,
	cell_timing = 300,
	cell_timing_offset     = 200,
        tiles       = {},
        focus       = nil,
        cells_focusable = true,
        skin="default",
    }
    
    local functions={}
    local focus_i = {1,1}
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
	
    local x_y_from_index = function(r,c)
		return (p.cell_w+p.cell_spacing)*(c-1)+p.cell_w/2,
		       (p.cell_h+p.cell_spacing)*(r-1)+p.cell_h/2
	end
    

    --the umbrella Group, containing the full slate of tiles
    local slate = Group{ 
        name     = "layoutManager",
        position = {200,100},
        reactive = true,
        extra    = {
			type = "LayoutManager",
            reactive = true,
            replace = function(self,r,c,obj)
                if p.tiles[r][c] ~= nil then
                    p.tiles[r][c]:unparent()
                end
                p.tiles[r][c] = obj
                
                if obj.parent ~= nil then obj:unparent() end
                
                self:add(obj)
                obj.x, obj.y = x_y_from_index(r,c)
                obj.anchor_point = {obj.w/2,obj.h/2}
                obj.delay = p.cell_timing_offset*(r+c-1)
			end,
            add_next = function(self,obj)
                self:replace(focus_i[1],focus_i[2],obj)
                if focus_i[2]+1 > p.columns then
                    if focus_i[1] + 1 >p.rows then
                        self.focus_to(1,1)
                    else
                        self.focus_to(focus_i[1]+1,1)
                    end
                else
                    self.focus_to(focus_i[1],focus_i[2]+1)
                end
            end,
            set_function = function(r,c,f)
                if r > p.rows or r < 1 or c < 1 or c > p.columns then
                    print("invalid row/col")
                    return
                end
                if functions[r][c] == nil then
                    print("no function")
                    return
                else
                    functions[r][c]()
                end
            end,
            focus_to = function(r,c)
                if r > p.rows or r < 1 or c < 1 or c > p.columns then
                    print("invalid row/col")
                    return
                end
                focus_i = {r,c}
                local x,y = x_y_from_index(r,c)
                focus:complete_animation()
                focus:animate{
                    duration=300,
                    mode="EASE_OUT_CIRC",
                    x=x,
                    y=y
                }
            end,
            press_enter = function(p)
                functions[focus_i[1]][focus_i[2]](p)
            end,
            animate_in = function()
				local tl = Timeline{
					duration =p.cell_timing_offset*(p.rows+p.columns-2)+ p.cell_timing
				}
				function tl:on_started()
					for r = 1, p.num_rows  do
						for c = 1, p.num_cols do
							p.tiles[r][c].y_rotation={90,0,0}
							p.tiles[r][c].opacity = 0
						end
					end
				end
				function tl:on_new_frame(msecs,prog)
					msecs = tl.elapsed
					local item
					for r = 1, p.num_rows  do
						for c = 1, p.num_cols do
							item = p.tiles[r][c] 
							if msecs > item.delay and msecs < (item.delay+p.cell_timing) then
								prog = (msecs-item.delay) / p.cell_timing
								item.y_rotation = {90*(1-prog),0,0}
								item.opacity = 255*prog
							elseif msecs > (item.delay+p.cell_timing) then
								item.y_rotation = {0,0,0}
								item.opacity = 255
							end
						end
					end
				end
				function tl:on_completed()
					for r = 1, p.rows  do
						for c = 1, p.columns do
							p.tiles[r][c].y_rotation={0,0,0}
							p.tiles[r][c].opacity = 255
						end
					end
				end
				tl:start()
            end
        }
    }


	local make_tile = function()
        local c = Canvas{size={p.cell_w, p.cell_h}}
        c:begin_painting()
        c:move_to(            0,          0 )
        c:line_to(   c.w,          0 )
        c:line_to( c.w, c.h )
        c:line_to( 0, c.h )
        c:line_to(            0,          0 )
        c:set_source_color("ffffff")
        c:set_line_width( 4 )
        c:set_dash(0,{10,10})
        c:stroke(true)
        c:finish_painting()
        if c.Image then
            c = c:Image()
        end
        c.name="nil"
		return c
	end
    local make_focus = function()
        return Rectangle{
            name="Focus",
            size={ p.cell_w+5, p.cell_h+5},
            color="00000000",
            anchor_point = { (p.cell_w+5)/2, (p.cell_h+5)/2},
            border_width=5,
            border_color="FFFFFFFF",
        }
    end
	
	local make_grid = function()
        
		local g
        slate:clear()
        
        if p.focus == nil then
            focus = make_focus()
        else
            focus = p.focus
            focus.anchor_point={focus.w/2,focus.h/2}
        end
        focus.x, focus.y = x_y_from_index(focus_i[1],focus_i[2])
        slate:add(focus)
        
        if p.cells_focusable then
            focus.opacity=255
        else
            focus.opacity=0
        end
        
		for r = 1, p.rows  do
            if p.tiles[r] == nil then
                p.tiles[r]   = {}
                functions[r] = {}
            end
			for c = 1, p.columns do
                if p.tiles[r][c] == nil then
                    g = make_tile()
                    slate:add(g)
                    p.tiles[r][c] = g
                    g.x, g.y = x_y_from_index(r,c)
                    g.delay = p.cell_timing_offset*(r+c-1)
                else
                    g = p.tiles[r][c]
                    if g.parent ~= nil then
                        g:unparent()
                    end
                    slate:add(g)
                    g.x, g.y = x_y_from_index(r,c)
                    g.anchor_point = {g.w/2,g.h/2}
                    g.delay = p.cell_timing_offset*(r+c-1)
                end
			end
		end
        
        if p.rows < #p.tiles then
            for r = p.rows + 1, #tiles do
                for c = 1, #p.tiles[r] do
                    p.tiles[r][c]:unparent()
                    p.tiles[r][c] = nil
                end
                tiles[r]     = nil
                functions[r] = nil
            end
        end
        if p.columns < #p.tiles[1] then
            for c = p.columns + 1, #tiles[r] do
                for r = 1, #p.tiles do
                    p.tiles[r][c]:unparent()
                    p.tiles[r][c]   = nil
                    functions[r][c] = nil
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
Function: Scroll Pane

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
function ui_element.scrollPane(t)

	-- reference: http://www.csdgn.org/db/179

    --default parameters
    local p = {
        visible_w    =  600,
	--color     =  {255,255,255,255},
        visible_h    =  600,
	    border_w  =    2,
        content   = Group{},
        virtual_h = 1000,
	    virtual_w = 1000,
	--arrow_clone_source = nil,
	
	--arrows_in_box = false,
	--arrows_centered = false,
        --hor_arrow_y     = nil,
        --vert_arrow_x    = nil,
	    scroll_bars_visible = true,
        bar_color_inner     = {180,180,180},
        bar_color_outer     = {30,30,30},
        empty_color_inner   = {120,120,120},
        empty_color_outer   = {255,255,255},
        frame_thickness     =    2,
        border_color        = {60, 60,60},
        bar_thickness       =   15,
        bar_offset          =    5,
        vert_bar_visible    = true,
        hor_bar_visbile     = true,
        
        box_visible = true,
        box_color = {160,160,160},
        box_width = 2,
        skin="default",
    }
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
	
	--Group that Clips the content
	local window  = Group{name="scroll_window"}
	--Group that contains all of the content
	--local content = Group{}
	--declarations for dependencies from scroll_group
	local scroll, scroll_x, scroll_y
	--flag to hold back key presses while animating content group
	local animating = false

	local border = Rectangle{ color = "00000000" }
	
	
	local track_h, track_w, grip_hor, grip_vert
	

    --the umbrella Group, containing the full slate of tiles
    local scroll_group = Group{ 
        name     = "scrollPane",
        position = {200,100},
        reactive = true,
        extra    = {
			type = "ScrollPane",
            seek_to = function(x,y)
                local new_x, new_y
                if p.virtual_w > p.visible_w then
                    if x > p.virtual_w - p.visible_w/2 then
                        new_x = -p.virtual_w + p.visible_w
                    elseif x < p.visible_w/2 then
                        new_x = 0
                    else
                        new_x = -x + p.visible_w/2
                    end
                else
                    new_x =0
                end
                if p.virtual_h > p.visible_h then
                    if y > p.virtual_h - p.visible_h/2 then
                        new_y = -p.virtual_h + p.visible_h
                        print(1)
                    elseif y < p.visible_h/2 then
                        new_y = 0
                        print(2)
                    else
                        new_y = -y + p.visible_h/2
                        print(3)
                    end
                else
                    new_y =0
                end
                
                if new_x ~= p.content.x or new_y ~= p.content.y then
                    p.content:animate{
                        duration = 200,
                        x = new_x,
                        y = new_y,
                        on_completed = function()
                            animating = false
                        end
                    }
                
                    if new_y < -(p.virtual_h - p.visible_h) then
                        grip_vert.y = track_h-grip_vert.h
                    elseif new_y > 0 then
                        grip_vert.y = 0
                    elseif new_y ~= p.content.y then
                        grip_vert:complete_animation()
                        grip_vert:animate{
                            duration= 200,
                            y = 0-(track_h-grip_vert.h)*new_y/(p.virtual_h - p.visible_h)
                        }
                    end
                    if new_x < -(p.virtual_w - p.visible_w) then
                        grip_hor.x = track_w-grip_hor.w
                    elseif new_x > 0 then
                        grip_hor.x = 0
                    elseif new_x ~= p.content.x then
                        grip_hor:complete_animation()
                        grip_hor:animate{
                            duration= 200,
                            x = 0-(track_w-grip_hor.w)*new_x/(p.virtual_w - p.visible_w)
                        }
                    end
                end
            end
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
			if p.visible_w < p.virtual_w then
				scroll_x(1)
			end
		end,
		[keys.Right] = function()
			if p.visible_w < p.virtual_w then
				scroll_x(-1)
			end
		end,
		[keys.Up] = function()
			if p.visible_h < p.virtual_h then
				scroll_y(1)
			end
		end,
		[keys.Down] = function()
			if p.visible_h < p.virtual_h then
				scroll_y(-1)
			end
		end,
	}
	scroll_group.on_key_down = function(self,key)
		if animating then return end
		if keys[key] then
			keys[key]()
		end
	end
	
	scroll_y = function(dir)
		local new_y = p.content.y+ dir*10
		animating = true
		p.content:animate{
			duration = 200,
			y = new_y,
			on_completed = function()
				if p.content.y < -(p.virtual_h - p.visible_h) then
					p.content:animate{
						duration = 200,
						y = -(p.virtual_h - p.visible_h),
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
		
		if new_y < -(p.virtual_h - p.visible_h) then
			grip_vert.y = track_h-grip_vert.h
		elseif new_y > 0 then
			grip_vert.y = 0
		else
			grip_vert:complete_animation()
			grip_vert:animate{
				duration= 200,
				y = 0-(track_h-grip_vert.h)*new_y/(p.virtual_h - p.visible_h)
			}
		end
	end
	
	
	scroll_x = function(dir)
              print("gaaaaa")
		local new_x = p.content.x+ dir*10
		animating = true
		p.content:animate{
			duration = 200,
			x = new_x,
			on_completed = function()
				if p.content.x < -(p.virtual_w - p.visible_w) then
					p.content:animate{
						duration = 200,
						y = -(p.virtual_w - p.visible_w),
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
		
		if new_x < -(p.virtual_w - p.visible_h) then
			grip_hor.x = track_w-grip_hor.w
		elseif new_x > 0 then
			grip_hor.x = 0
		else
			grip_hor:complete_animation()
			grip_hor:animate{
				duration= 200,
				x = 0-(track_w-grip_hor.w)*new_x/(p.virtual_w - p.visible_w)
			}
		end
	end
    local function make_hor_bar(w,h,ratio)
        local bar = Group{}
        
		local shell = Canvas{
				size = {w,h},
		}
		local fill  = Canvas{
				size = {w*ratio,h-p.frame_thickness},
		}  
        
		
		local RAD = 6
        
		local top    =           math.ceil(p.frame_thickness/2)
		local bottom = shell.h - math.ceil(p.frame_thickness/2)
		local left   =           math.ceil(p.frame_thickness/2)
		local right  = shell.w - math.ceil(p.frame_thickness/2)
        
		shell:begin_painting()
        
		
		shell:move_to(        left,         top )
		shell:line_to(   right-RAD,         top )
		shell:curve_to( right, top,right,top,right,top+RAD)
		shell:line_to(       right,  bottom-RAD )
		shell:curve_to( right,bottom,right,bottom,right-RAD,bottom)
        
		shell:line_to(           left+RAD,          bottom )
		shell:curve_to(left,bottom,left,bottom,left,bottom-RAD)
		shell:line_to(           left,            top+RAD )
		shell:curve_to(left,top,left,top,left+RAD,top)
        
		shell:set_source_linear_pattern(
            
            shell.w/2,0,
			shell.w/2,shell.h
		)
		shell:add_source_pattern_color_stop( 0 , p.empty_color_inner )
		shell:add_source_pattern_color_stop( 1 , p.empty_color_outer )
        
		shell:fill(true)
		shell:set_line_width(   p.frame_thickness )
		shell:set_source_color( p.border_color )
		shell:stroke( true )
		shell:finish_painting()
        
        -----------------------------------------------------
        
		top    =          math.ceil(p.frame_thickness/2)
		bottom = fill.h - math.ceil(p.frame_thickness/2)
		left   =          math.ceil(p.frame_thickness/2)
		right  = fill.w - math.ceil(p.frame_thickness/2)
        
		shell:begin_painting()
        
		
		fill:move_to(        left,         top )
		fill:line_to(   right-RAD,         top )
		fill:curve_to( right, top,right,top,right,top+RAD)
		fill:line_to(       right,  bottom-RAD )
		fill:curve_to( right,bottom,right,bottom,right-RAD,bottom)
        
		fill:line_to(           left+RAD,          bottom )
		fill:curve_to(left,bottom,left,bottom,left,bottom-RAD)
		fill:line_to(           left,            top+RAD )
		fill:curve_to(left,top,left,top,left+RAD,top)
        
		fill:set_source_linear_pattern(
			fill.w/2,0,
			fill.w/2,fill.h
		)
		fill:add_source_pattern_color_stop( 0 , p.bar_color_inner )
		fill:add_source_pattern_color_stop( 1 , p.bar_color_outer )
		fill:fill(true)
        fill:set_line_width(   p.frame_thickness )
		fill:set_source_color( p.border_color )
		fill:stroke( true )
		fill:finish_painting()
        
        -----------------------------------------------------
        
		if shell.Image then
			shell = shell:Image()
		end
		if fill.Image then
			fill = fill:Image()
		end
        
		bar:add(shell,fill)
        
        shell.name="track"
        fill.name="grip"
        fill.reactive=true
        fill.y=p.frame_thickness/2 
        return bar
    end
    local function make_vert_bar(w,h,ratio)
        local bar = Group{}
        
		local shell = Canvas{
				size = {w,h},
		}
		local fill  = Canvas{
				size = {w-p.frame_thickness,h*ratio},
		}  
        
		
		local RAD = 6
        
		local top    =           math.ceil(p.frame_thickness/2)
		local bottom = shell.h - math.ceil(p.frame_thickness/2)
		local left   =           math.ceil(p.frame_thickness/2)
		local right  = shell.w - math.ceil(p.frame_thickness/2)
        
		shell:begin_painting()
        
		
		shell:move_to(        left,         top )
		shell:line_to(   right-RAD,         top )
		shell:curve_to( right, top,right,top,right,top+RAD)
		shell:line_to(       right,  bottom-RAD )
		shell:curve_to( right,bottom,right,bottom,right-RAD,bottom)
        
		shell:line_to(           left+RAD,          bottom )
		shell:curve_to(left,bottom,left,bottom,left,bottom-RAD)
		shell:line_to(           left,            top+RAD )
		shell:curve_to(left,top,left,top,left+RAD,top)
        
		shell:set_source_linear_pattern(
			0,shell.h/2,
            shell.w,shell.h/2
		)
		shell:add_source_pattern_color_stop( 0 , p.empty_color_inner )
		shell:add_source_pattern_color_stop( 1 , p.empty_color_outer )
        
		shell:fill(true)
		shell:set_line_width(   p.frame_thickness )
		shell:set_source_color( p.border_color )
		shell:stroke( true )
		shell:finish_painting()
        
        -----------------------------------------------------
        
		top    =          math.ceil(p.frame_thickness/2)
		bottom = fill.h - math.ceil(p.frame_thickness/2)
		left   =          math.ceil(p.frame_thickness/2)
		right  = fill.w - math.ceil(p.frame_thickness/2)
        
		shell:begin_painting()
        
		
		fill:move_to(        left,         top )
		fill:line_to(   right-RAD,         top )
		fill:curve_to( right, top,right,top,right,top+RAD)
		fill:line_to(       right,  bottom-RAD )
		fill:curve_to( right,bottom,right,bottom,right-RAD,bottom)
        
		fill:line_to(           left+RAD,          bottom )
		fill:curve_to(left,bottom,left,bottom,left,bottom-RAD)
		fill:line_to(           left,            top+RAD )
		fill:curve_to(left,top,left,top,left+RAD,top)
        
		fill:set_source_linear_pattern(
			0,fill.h/2,
            fill.w,fill.h/2
		)
		fill:add_source_pattern_color_stop( 0 , p.bar_color_inner )
		fill:add_source_pattern_color_stop( 1 , p.bar_color_outer )
		fill:fill(true)
        fill:set_line_width(   p.frame_thickness )
		fill:set_source_color( p.border_color )
		fill:stroke( true )
		fill:finish_painting()
        
        -----------------------------------------------------
        
		if shell.Image then
			shell = shell:Image()
		end
		if fill.Image then
			fill = fill:Image()
		end
        
		bar:add(shell,fill)
        
        shell.name="track"
        fill.name="grip"
        fill.reactive=true
        fill.x=p.frame_thickness/2 
        return bar
    end
	
	
	--this function creates the whole scroll bar box
	local function create()
        window.position={ p.box_width, p.box_width }
		window.clip = { 0,0, p.visible_w, p.visible_h }
        border:set{
            w = p.visible_w+2*p.box_width,
            h = p.visible_h+2*p.box_width,
            border_width =    p.box_width,
            border_color =    p.box_color,
        }
		
        if  scroll_group:find_child("Horizontal Scroll Bar") then
            scroll_group:find_child("Horizontal Scroll Bar"):unparent()
        end
        
        if  scroll_group:find_child("Vertical Scroll Bar") then
            scroll_group:find_child("Vertical Scroll Bar"):unparent()
        end
        
        if p.box_visible then border.opacity=255
        else border.opacity=0 end 
        
        if p.bar_offset < 0 then
            track_w = p.visible_w+p.bar_offset
            track_h = p.visible_h+p.bar_offset
        else
            track_w = p.visible_w
            track_h = p.visible_h
        end
        if p.hor_bar_visible and p.visible_w/p.virtual_w < 1 then
            hor_s_bar = make_hor_bar(
                track_w,
                p.bar_thickness,
                track_w/p.virtual_w
            )
            hor_s_bar.name = "Horizontal Scroll Bar"
            hor_s_bar.position={
                p.box_width,
                p.box_width*2+p.visible_h+p.bar_offset
            }
            scroll_group:add(hor_s_bar)
            
            grip_hor = hor_s_bar:find_child("grip")
            
            function grip_hor:on_button_down(x,y,button,num_clicks)
                
                local dx = x - grip_hor.x
	   	        
                dragging = {grip_hor,
	   		        function(x,y)
	   			
	   			        grip_hor.x = x - dx
	   			
	   			        if  grip_hor.x < 0 then
	   				        grip_hor.x = 0
	   			        elseif grip_hor.x > track_w-grip_hor.w then
	   				           grip_hor.x = track_w-grip_hor.w
	   			        end
	   			
	   			        p.content.x = -(grip_hor.x ) * p.virtual_w/track_w
	   			
	   		        end 
	   	        }
	   	
                return true
            end
        else
            grip_hor=nil
        end
        if p.vert_bar_visible and p.visible_h/p.virtual_h < 1 then
            vert_s_bar = make_vert_bar(
                
                p.bar_thickness,
                track_h,
                track_h/p.virtual_h
            )
            vert_s_bar.name = "Vertical Scroll Bar"
            vert_s_bar.position={
                p.box_width*2+p.visible_w+p.bar_offset,
                p.box_width
            }
            --vert_s_bar.z_rotation={90,0,0}
            scroll_group:add(vert_s_bar)
            
            grip_vert = vert_s_bar:find_child("grip")
            
            function grip_vert:on_button_down(x,y,button,num_clicks)
                
                local dy = y - grip_vert.y
	   	        
                dragging = {grip_vert,
	   		        function(x,y)
	   			
	   			        grip_vert.y = y - dy
	   			
	   			        if  grip_vert.y < 0 then
	   				        grip_vert.y = 0
	   			        elseif grip_vert.y > track_h-grip_vert.h then
	   				           grip_vert.y = track_h-grip_vert.h
	   			        end
	   			
	   			        p.content.y = -(grip_vert.y) * p.virtual_h/track_h
	   			
	   		        end 
	   	        }
	   	
                return true
            end
        else
            grip_vert=nil
        end
        
		

  --[[
          scroll_group.size = {p.visible_w, p.visible_h}
 ]]
	end
	
    
	scroll_group:add(border,window)
    create()
	window:add(p.content)
	
	
	


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


--[[
Function: Menu Button
]]

function ui_element.menuButton(t)
    --default parameters
    local p = {

--[[


button 
--]]
        label_font = "DejaVu Sans 30px",
    	label_color = {255,255,255,255}, --"FFFFFF",
    	skin = "default", 
    	button_width = 180,
    	button_height = 60, 

    	label = "Button", 
    	focus_color = {27,145,27,255}, --"1b911b", 
    	button_color = {255,255,255,255}, --"FFFFFF"
    	border_width = 1,
    	border_corner_radius = 12,


--]]



        name  = "dropdownbar",
        menu_font  = "DejaVu Sans 26px",
        items = {
        --[[
            {
                name="Subgroup A:",
                items={
                    {txt="Item A1",f=nil},
                    {txt="Item A2",f=nil}
                }
            },
            {
                name="Subgroup B:",
                items={
                    {txt="Item B1",f=nil},
                    {txt="Item B2",f=nil}
                }
            },
            {
                items={
                    {txt="Item 1",f=nil},
                    {txt="Item 2",f=nil}
                }
            },--]]
            {type="label", string="Subgroup A:"},
            {type="item",  string="Item A1", f=nil},
            {type="item",  string="Item A2", f=nil},
            --{type="seperator"},
            {type="label", string="Subgroup B:"},
            {type="item",  string="Item B1", f=nil},
            {type="item",  string="Item B2", f=nil},
            {type="seperator"},
            {type="item",  string="Item 1", f=nil},
            {type="item",  string="Item 2", f=nil},
            {type="seperator"},
            {type="label", string="Subgroup B:"},
            {type="item",  string="Item B1", f=nil},
            {type="item",  string="Item B2", f=nil},
        },
        vert_spacing = 5,
        hor_spacing  = 10,
        vert_offset  = 40,
        
        menu_text_color    = {255,255,255,255},
        bg_color     = {255,0,0,255},
        menu_width   = 220,
        hor_padding  = 10,
        seperator_thickness    = 2,
        expansion_location   = false,
        
        
        skin          = "default",
    }
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
    
    local create
    local curr_cat = 1
    local curr_index = 0
    local selectable_items  = {}
    
    local dropDownMenu = Group{}
    local button       = ui_element.button{
        text_font=p.label_font,
    	text_color=p.label_color,
    	skin=p.skin,
    	wwidth=p.wwidth,
    	wheight=p.wheight, 
        
    	label=p.label, 
    	focus_color=p.focus_color,
    	button_color=p.button_color, 
    	border_width=p.border_width,
    	border_corner_radius=p.border_corner_radius,
    }
    local umbrella
    umbrella     = Group{
        name="menuButton",
        reactive = true,
        children={button,dropDownMenu},
        extra={
            type="MenuButton",
            focus_index = function(i)
                if curr_cat == cat and curr_index == i then
                    print("Item on Drop Down Bar is already focused")
                    return
                end
                if selectable_items[curr_index] ~= nil then
                    
                    selectable_items[curr_index]:complete_animation()
                    selectable_items[curr_index].opacity=255
                    selectable_items[curr_index]:animate{
                        duration=300,
                        opacity=0
                    }
                end
                if selectable_items[i] ~= nil then
                   
                    selectable_items[i]:complete_animation()
                    selectable_items[i].opacity=0
                    selectable_items[i]:animate{
                        duration=300,
                        opacity=255
                    }
                    curr_cat = cat
                    curr_index=i
                end
            end,
            press_up = function()
                if curr_index == 1 then
                    return
                else
                    umbrella.focus_index(curr_index-1)
                end
            end,
            press_down = function()
                if curr_index == #selectable_items then
                    return
                else
                    umbrella.focus_index(curr_index+1)
                end
            end,
            insert_item = function (index,item)
                assert(type(item)=="table","invalid item")
                assert(index > 0 and index <= #p.items, "invalid index")
                
                table.insert(p.items,index,item)
                create()
            end,
            remove_item = function (index)
                assert(index > 0 and index <= #p.items, "invalid index")
                
                table.remove(p.items,index)
                
                create()
            end,
            move_item_up = function (index)
                assert(index > 1 and index <= #p.items, "invalid index")
                
                local swp = p.items[index]
                p.items[index] = p.items[index-1]
                p.items[index-1] = swp
                
                create()
            end,
            move_item_down = function (index)
                assert(index > 0 and index < #p.items, "invalid index")
                
                local swp = p.items[index]
                p.items[index] = p.items[index+1]
                p.items[index+1] = swp
                
                create()
            end,
            spin_in = function()
                dropDownMenu:complete_animation()
                dropDownMenu.y_rotation={90,0,0}
                dropDownMenu.opacity=0
                dropDownMenu:animate{
                    duration=300,
                    opacity=255,
                    y_rotation=0
                }
                button:on_focus_in()
                if selectable_items[curr_index] then
                    selectable_items[curr_index].opacity=0
                end
                curr_index = 0
            end,
            spin_out = function()
                dropDownMenu:complete_animation()
                dropDownMenu.y_rotation={0,0,0}
                dropDownMenu.opacity=255
                dropDownMenu:animate{
                    duration=300,
                    opacity=0,
                    y_rotation=-90
                }
                button:on_focus_out()
            end,
            fade_in = function()
                dropDownMenu:complete_animation()
                dropDownMenu.y_rotation={0,0,0}
                dropDownMenu.opacity=0
                dropDownMenu:animate{
                    duration=300,
                    opacity=255,
                }
                if selectable_items[curr_index] then
                    selectable_items[curr_index].opacity=0
                end
                button:on_focus_in()
                curr_index = 0
            end,
            fade_out = function()
                dropDownMenu:complete_animation()
                dropDownMenu.y_rotation={0,0,0}
                dropDownMenu.opacity=255
                dropDownMenu:animate{
                    duration=300,
                    opacity=0,
                }
                button:on_focus_out()
            end,
            set_item_function = function(index,f)
                assert(index > 0 and index <= #p.selectable_items, "invalid index")
                
                p.selectable_items[index].f=f
                
            end,
            press_enter = function(p)
                if p.selectable_items[curr_index] ~= nil and
                   p.selectable_items[curr_index].f ~= nil then
                   
                    p.selectable_items[curr_index].f(p)
                else
                    print("no function")
                end
            end
        }

  --[[
    umbrella.size = {p.wwidth, p.wheight}
 ]]
    }
    local function make_item_ring(w,h,padding)
        local ring = Canvas{ size = { w , h } }
        ring:begin_painting()
        ring:set_source_color( p.menu_text_color )
        ring:round_rectangle(
            padding + 2 / 2,
            padding + 2 / 2,
            w - 2 - padding * 2 ,
            h - 2 - padding * 2 ,
            12 )
        ring:stroke()
        ring:finish_painting()
    	if ring.Image then
       		ring= ring:Image()
    	end
        return ring
    end
    
    function create()
        
        --local vars used to create the menu
        local ui_ele = nil
        local curr_y = 0
        
        local max_item_w = 0
        local max_item_h = 0
        
        local txt_spacing = 10
        local txt_h       = Text{font=p.font}.h
        local inset       = 20
        
        --reset globals
        curr_cat   = 1
        curr_index = 0
        selectable_items  = {}
        dropDownMenu:clear()
        dropDownMenu.opacity=0
        
        
        
        button.text_font=p.label_font
    	button.text_color=p.label_color
    	button.skin=p.skin
    	button.wwidth=p.button_width
    	button.wheight=p.button_height
        
    	button.label=p.label
    	button.focus_color=p.focus_color
    	button.button_color=p.button_color
    	button.border_width=p.border_width
    	button.border_corner_radius=p.border_corner_radius
        
        
        curr_y = p.vert_offset
        
        --For each category
        for i = 1, #p.items do
            local item=p.items[i]
            --focus_sel_items[cat] = {}
            
            if item.type == "seperator" then
                dropDownMenu:add(
                    Rectangle{
                        x     = p.hor_padding,
                        y     = curr_y,
                        name  = "divider "..i,
                        w     = p.menu_width-2*p.hor_padding,
                        h     = p.seperator_thickness,
                        color = txt_color
                    }
                )
                curr_y = curr_y + p.seperator_thickness + p.vert_spacing
            elseif item.type == "item" then
                
                
                
                --Make the text label for each item
                local txt = Text{
                        text  = item.string,
                        font  = p.menu_font,
                        color = p.menu_text_color,
                        x     = p.hor_padding+p.hor_spacing,
                        y     = curr_y,
                    }
                    txt.anchor_point={0,txt.h/2}
                    txt.y = txt.y+txt.h/2
                dropDownMenu:add(
                    txt
                )
                ui_ele = make_item_ring(p.menu_width-2*p.hor_spacing,txt.h+10,7)
                
                ui_ele.anchor_point = { 0,     ui_ele.h/2 }
                ui_ele.position     = {  p.hor_spacing, txt.y }
                dropDownMenu:add(ui_ele)
                
                
                
                ui_ele = assets(skin_list[p.skin]["button_focus"])
                ui_ele.size = {p.bg_w,txt_h+15}
                
                
                ui_ele.anchor_point = { ui_ele.w/2,     ui_ele.h/2 }
                ui_ele.position     = {   p.menu_width/2, curr_y+txt_h/2 }
                ui_ele.opacity      = 0
                dropDownMenu:add(ui_ele)
                table.insert(selectable_items,ui_ele)
                
                curr_y = curr_y + txt.h + p.vert_spacing
            elseif item.type == "label" then
                txt = Text{
                        text  = item.string,
                        font  = p.menu_font,
                        color = p.menu_text_color,
                        x     = p.hor_spacing,
                        y     = curr_y,
                    }
                dropDownMenu:add(
                    txt
                )
                curr_y = curr_y + txt.h + p.vert_spacing
            else
                print("Invalid type in the item list. Type: ",item.type)
            end
        end
        
        
        if skin_list[p.skin]["drop_down_bg"] then
            ui_ele = assets(skin_list[p.skin]["drop_down_bg"])
            ui_ele.size = { p.bg_w , curr_y }
        else
            ui_ele = ui.factory.make_dropdown(
                { p.menu_width , curr_y } ,
                p.bg_color
            )
        end
        dropDownMenu:add(ui_ele)
        ui_ele:lower_to_bottom()
        
        dropDownMenu.anchor_point = {ui_ele.w/2,ui_ele.h/2}
        if p.bg_goes_up then
            ui_ele.x_rotation={180,0,0}
            ui_ele.y = ui_ele.h+p.item_start_y
            dropDownMenu.position     = {ui_ele.w/2,-ui_ele.h/2-p.vert_offset}
        else
            dropDownMenu.position     = {ui_ele.w/2,ui_ele.h/2}
        end
        
        button.reactive=true
        
        function button:on_button_down(x,y,b,n)
            if dropDownMenu.opacity == 0 then
                umbrella.spin_in()
            else
                umbrella.spin_out()
            end
        end
        
        
        
        button.position = {button.w/2,button.h/2}
        button.anchor_point = {button.w/2,button.h/2}
        dropDownMenu.x = button.w/2
        if p.expansion_location then
            dropDownMenu.y = dropDownMenu.y -10
        else
            dropDownMenu.y = dropDownMenu.y + button.h+10
        end
    end
    
    
    create()
    --set the meta table to overwrite the parameters
    mt = {}
    mt.__newindex = function(t,k,v)
		
        p[k] = v
        create()
		
    end
    mt.__index = function(t,k)       
       return p[k]
    end
    setmetatable(umbrella.extra, mt)

    return umbrella
end



function ui_element.menuBar(t)
    local p = {
        bar_widgets = {
            ui_element.dropDownBar(),
            ui_element.dropDownBar(),
            ui_element.dropDownBar(),
            ui_element.dropDownBar(),
            ui_element.dropDownBar(),
            ui_element.button(),
            ui_element.button(),
            ui_element.button(),
            ui_element.button(),
            ui_element.button(),
        },
        y_offset  = 20,
        clip_w      = 2/3*screen.w,
        bg_pic      = nil,
        arrow_img   = nil,
        arrow_y     = 60,
        skin        = "default"
    }
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
    local create
    local index = 0
    
    local si = ui_element.scrollPane{
        clip_h    = screen.h,
        content_h = screen.h,
        arrow_sz  = 30,
        arrows_centered   = true,
        border_is_visible = false,
    }
    si.position={40,0}
    local func = {
        ["Button"] = {
            fade_in = "on_focus_in",
            fade_out = "on_focus_out"
        },
        ["DropDown"] ={
            fade_in = "spin_in",
            fade_out = "spin_out"
        }
    }
    local width = {
        ["Button"]   = 200,
        ["DropDown"] = 300
    }
    local umbrella = Group{
        name     = "menubar",
        reactive = true,
        position = {0,200},
        extra    = {
            type = "MenuBar",
            press_left = function()
                if index > 1 then
                    if p.bar_widgets[index] ~= nil then
                        p.bar_widgets[index].extra[func[p.bar_widgets[index].extra.type].fade_out]()
                        si.seek_to(p.bar_widgets[index].x,0)
                    end
                    index = index - 1
                    p.bar_widgets[index].extra[func[p.bar_widgets[index].extra.type].fade_in]()
                end
            end,
            press_right = function()
                if index < #p.bar_widgets then
                    if p.bar_widgets[index] ~= nil then
                        p.bar_widgets[index].extra[func[p.bar_widgets[index].extra.type].fade_out]()
                    end
                    index = index + 1
                    p.bar_widgets[index].extra[func[p.bar_widgets[index].extra.type].fade_in]()
                    
                    si.seek_to(p.bar_widgets[index].x,0)
                end
            end,
            press_up = function()
                if p.bar_widgets[index].press_up then
                    p.bar_widgets[index].press_up()
                end
            end,
            press_down = function()
                if p.bar_widgets[index].press_down then
                    p.bar_widgets[index].press_down()
                end
            end,
            press_enter= function()
                if p.bar_widgets[index].press_enter then
                    p.bar_widgets[index].press_enter()
                elseif p.bar_widgets[index].pressed then
                    p.bar_widgets[index].pressed()
                end
            end,
            insert_widget = function(i,w)
                table.insert(p.bar_widgets,i,w)
                create()
            end,
            replace_widget = function(i,w)
                p.bar_widgets[i] = w
                create()
            end,
            remove_widget = function(i)
                table.remove(p.bar_widgets,i)
                create()
            end,
        }
    }
    
    create = function()
        
        --clear the groups
        umbrella:clear()
        si.content:clear()
        
        --load the background
        if p.bg_pic == nil then
            umbrella:add(assets(skin_list[p.skin]["menu_bar"]))
        else
            umbrella:add(p.bg_pic)
        end
        
        umbrella:add(si)
        si.seek_to(0,0)
        si.clip_w       = p.clip_w
        si.skin         = p.skin
        si.hor_arrows_y = p.arrow_y
        index = 0
        
        local curr_w = 0
        for i = 1, #p.bar_widgets do
            
            assert(
                p.bar_widgets[i].extra.type == "Button" or
                p.bar_widgets[i].extra.type == "DropDown",
                "invalid widget added to the dropdown bar"
            )
            si.content:add(p.bar_widgets[i])
            p.bar_widgets[i].position = {curr_w,p.y_offset}
            p.bar_widgets[i].skin     = p.skin
            
            curr_w = curr_w + width[p.bar_widgets[i].extra.type] + 15
            
        end
        si.content_w = curr_w
    end
    
    create()
    --set the meta table to overwrite the parameters
    mt = {}
    mt.__newindex = function(t,k,v)
		
        p[k] = v
        create()
		
    end
    mt.__index = function(t,k)       
       return p[k]
    end
    setmetatable(umbrella.extra, mt)

    return umbrella
end
function ui_element.tabBar(t)
    
    --default parameters
    local p = {
        name  = "Drop Down Bar",
        font  = "DejaVu Sans 26px",
        tabs = {
        --  item text, selectable, icon source
            {"Item 1",      true,  nil },
            {"Item 2",      true,  nil },
            {"Item 3",      true,  nil },
        },
        tab_w_equal = false,
        tab_w_padding = 30,
        min_w = 500,
        border_width=2,
        border_color={255,255,255},
        
        bg_color = {0,0,0},
        border_rad=12,
        
    }
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
    
    local curr_index = 0
    local selectable_items = {}
    local focus_sel_items  = {}
    
    local dropDownMenu = Group{}
    local button       = Group{}
    local button_focus = nil
    local umbrella     = Group{
        name="Drop down bar",
        reactive = true,
        children={button,dropDownMenu},
        extra={
            type="MenuBar",
            focus_index = function(i)
                if curr_index == i then
                    print("Item on Drop Down Bar is already focused")
                    return
                end
                if focus_sel_items[curr_index] ~= nil then
                    focus_sel_items[curr_index]:complete_animation()
                    focus_sel_items[curr_index].opacity=255
                    focus_sel_items[curr_index]:animate{
                        duration=300,
                        opacity=0
                    }
                end
                if focus_sel_items[i] ~= nil then
                    focus_sel_items[i]:complete_animation()
                    focus_sel_items[i].opacity=0
                    focus_sel_items[i]:animate{
                        duration=300,
                        opacity=255
                    }
                    curr_index=i
                end
            end,
            spin_in = function()
                dropDownMenu:complete_animation()
                button_focus:complete_animation()
                button_focus.opacity=0
                dropDownMenu.y_rotation={90,0,0}
                dropDownMenu.opacity=0
                dropDownMenu:animate{
                    duration=300,
                    opacity=255,
                    y_rotation=0
                }
                button_focus:animate{
                    duration=300,
                    opacity=255,
                }
                curr_index = 0
            end,
            spin_out = function()
                dropDownMenu:complete_animation()
                button_focus:complete_animation()
                button_focus.opacity=255
                dropDownMenu.y_rotation={0,0,0}
                dropDownMenu.opacity=255
                dropDownMenu:animate{
                    duration=300,
                    opacity=0,
                    y_rotation=-90
                }
                button_focus:animate{
                    duration=300,
                    opacity=0,
                }
            end,
            fade_in = function()
                dropDownMenu:complete_animation()
                button_focus:complete_animation()
                button_focus.opacity=0
                dropDownMenu.y_rotation={0,0,0}
                dropDownMenu.opacity=0
                dropDownMenu:animate{
                    duration=300,
                    opacity=255,
                }
                button_focus:animate{
                    duration=300,
                    opacity=255,
                }
                curr_index = 0
            end,
            fade_out = function()
                dropDownMenu:complete_animation()
                button_focus:complete_animation()
                button_focus.opacity=255
                dropDownMenu.y_rotation={0,0,0}
                dropDownMenu.opacity=255
                dropDownMenu:animate{
                    duration=300,
                    opacity=0,
                }
                button_focus:animate{
                    duration=300,
                    opacity=0,
                }
            end,
        }
    }
    local function make_ring(w,h,padding)
        local ring = Canvas{ size = { w , h } }
        ring:begin_painting()
        ring:set_source_color( p.txt_color )
        ring:round_rectangle(
            padding + 2 / 2,
            padding + 2 / 2,
            w - 2 - padding * 2 ,
            h - 2 - padding * 2 ,
            12 )
        ring:stroke()
        ring:finish_painting()
    	if ring.Image then
       		ring= ring:Image()
    	end
        return ring
    end
    
    local function create()
        
        local ui_ele = nil
        local curr_y = 0
        
        local max_item_w = 0
        local max_item_h = 0
        
        curr_index   = 0
        selectable_items = {}
        focus_sel_items  = {}
        dropDownMenu:clear()
        dropDownMenu.opacity=0
        
        if p.bg_clone_src == nil then
            curr_y = 45
        else
            curr_y = p.item_start_y
        end
        
        for i = 1, #p.items do
            
            ui_ele = Text{
                text  = p.items[i][1],
                font  = p.font,
                color = p.txt_color,
                x     = p.padding,
                y     = curr_y,
            }
            
            curr_y = ui_ele.h+curr_y+p.item_spacing
            
            if p.items[i][2] then
                table.insert(selectable_items,ui_ele)
                ui_ele.x = ui_ele.x + 20
            end
            
            if  max_item_w < ui_ele.w + ui_ele.x then
                max_item_w = ui_ele.w + ui_ele.x
            end
            if  max_item_h < ui_ele.h then
                max_item_h = ui_ele.h
            end
            
            dropDownMenu:add(ui_ele)
        end
        max_item_w = max_item_w+p.right_margin+p.padding
        
        for i = 1, #selectable_items do
            if p.item_focus_clone_src ~= nil then
                ui_ele = Clone{source=p.item_focus_clone_src}
            else
                ui_ele = assets(skin_list[p.skin]["button_focus"])
                ui_ele.size = {max_item_w,max_item_h+15}
            end
            
            ui_ele.anchor_point = {ui_ele.w/2,ui_ele.h/2}
            ui_ele.position     = {max_item_w/2,selectable_items[i].y+selectable_items[i].h/2}
            ui_ele.opacity = 0
            dropDownMenu:add(ui_ele)
            ui_ele:lower_to_bottom()
            table.insert(focus_sel_items,ui_ele)
            if p.item_bg_clone_src ~= nil then
                ui_ele = Clone{source=p.item_bg_clone_src}
                
            else
                ui_ele = make_ring(max_item_w,max_item_h+15,7)
            end
            
            ui_ele.anchor_point = {ui_ele.w/2,ui_ele.h/2}
            ui_ele.position     = {max_item_w/2,selectable_items[i].y+selectable_items[i].h/2}
            dropDownMenu:add(ui_ele)
            ui_ele:lower_to_bottom()
        end
        
        if p.bg_clone_src == nil then
            local color = p.bg_color or skin_list[p.skin]["drop_down_color"]
            ui_ele = ui.factory.make_dropdown(
                { max_item_w , curr_y } ,
                color
            )
        else
            ui_ele = Clone{source=p.bg_clone_src}
            print("this")
        end
        dropDownMenu:add(ui_ele)
        ui_ele:lower_to_bottom()
        
        dropDownMenu.anchor_point = {ui_ele.w/2,ui_ele.h/2}
        dropDownMenu.position     = {ui_ele.w/2,ui_ele.h/2}
        
        button:clear()
        if p.top_img ~= nil then
            if p.top_img.parent ~= nil then
                p.top_img.unparent()
            end
            p.top_img.anchor_point = {p.top_img.w/2,p.top_img.h/2}
            button:add(p.top_img)
        else
            ui_ele = assets(skin_list[p.skin]["button"])
            ui_ele.anchor_point = {ui_ele.w/2,ui_ele.h/2}
            button:add(ui_ele)
        end
        
        if p.top_focus_img ~= nil then
            if p.top_focus_img.parent ~= nil then
                p.top_focus_img.unparent()
            end
            p.top_focus_img.anchor_point = {p.top_focus_img.w/2,p.top_focus_img.h/2}
            button:add(p.top_focus_img)
            button_focus = p.top_focus_img
        else
            button_focus = assets(skin_list[p.skin]["button_focus"])
            button_focus.anchor_point = {button_focus.w/2,button_focus.h/2}
            button:add(button_focus)
        end
        
        button_focus.opacity = 0
        ui_ele = Text{text=p.name,font=p.font,color = p.txt_color}
        ui_ele.anchor_point = {ui_ele.w/2,ui_ele.h/2}
        button:add(ui_ele)
        
        button.position = {button.w/2,button.h/2}
        dropDownMenu.x = button.w/2
        dropDownMenu.y = dropDownMenu.y + button.h+10
    end
    
    
    
    --set the meta table to overwrite the parameters
    mt = {}
    mt.__newindex = function(t,k,v)
		
        p[k] = v
        create()
		
    end
    mt.__index = function(t,k)       
       return p[k]
    end
    setmetatable(umbrella.extra, mt)

    return umbrella
end

--]]

return ui_element
