local ui_element = {}

dofile("/lib/ui_element_header.lua")     
function ui_element.populate_to (grp, tbl)

	local uiContainers = {"DialogBox", "LayoutManager", "ScrollPane", "ArrowPane", "TabBar", "Group"} 
	 
	local function is_in_list(item, list)
    		if list == nil then 
        		return false
    		end 

    		for i, j in pairs (list) do
			if item == j then 
				return true
			end 
    		end 
    		return false
	end 

	local function is_this_container(v)
    		if v.extra then 
        		if is_in_list(v.extra.type, uiContainers) == true then 
	    			return true
        		else 
	    			return false
        		end 
    		else 
        		return false
    		end 
	end 	

	for i, j in pairs (grp.children) do 
		local function there()
			if j.extra then 
				if j.extra.type == "ScrollPane" or j.extra.type == "DialogBox" or j.extra.type == "ArrowPane" then 
					tbl[j.name] = grp:find_child(j.name) 
					for k,l in pairs (j.content.children) do 
						if is_this_container(l) == true then 
							j = l 
							there()
						else 
							tbl[l.name] = grp:find_child(l.name) 
						end 
					end 
				elseif j.extra.type == "LayoutManager" then
					tbl[j.name] = grp:find_child(j.name) 
					for k,l in pairs (j.tiles) do 
						for n,m in pairs (l) do 
							if m then 
								if is_this_container(m) == true then 
									j = m 
									there()
								else 
									tbl[m.name] = grp:find_child(m.name) 
								end 
							end 
						end 
					end 
				elseif j.type == "Group" and j.extra.type == nil then 
					tbl[j.name] = grp:find_child(j.name) 
					for k,l in pairs (j.children) do 
						if is_this_container(l) == true then 
							j = l 
							there()
						else 
							tbl[l.name] = grp:find_child(l.name) 
						end 
					end 
				else 
					if j.name then 
						tbl[j.name] = j
					end 
				end 
			else 
				if j.name then 
					tbl[j.name] = j
				end 
			end 
		end 
		there()
	end 
	if grp.extra then 	
		if grp.extra.video then 
			tbl[grp.extra.video.name] = grp.extra.video
		end
	end

return tbl

end 

function ui_element.set_cursor_pointer (src_file)
	--[[
	user_mouse_pointer.src = "/assets/images/"..src_file
	]]
end 

function ui_element.transit_to (prev_grp, next_grp, effect)
	for i, j in pairs (g.children) do
		if j.on_focus_out then 
				j.on_focus_out()
		end
	end 
	if effect == "fade" then 
		screen:add(next_grp)
    	local fade_timeline = Timeline ()

    	fade_timeline.duration = 1000 -- progress duration 
    	fade_timeline.direction = "FORWARD"
    	fade_timeline.loop = false

     	function fade_timeline.on_new_frame(t, m, p)
			next_grp.opacity = p * 255
			prev_grp.opacity = (1-p) * 255 
     	end  

     	function fade_timeline.on_completed()
			screen:remove(prev_grp)
			--g:clear()
			g = next_grp
			screen:add(g)
			screen:grab_key_focus()
			prev_grp.opacity = 255
     	end 
		fade_timeline:start()
	else 
		if prev_grp then 
			screen:remove(prev_grp)
		end 
		--g:clear()
		g = next_grp
		screen:add(g)
		screen:grab_key_focus()
	end 
end 

function ui_element.screen_add(grp)
	g = grp
	screen:add(g)
end 

function ui_element.start_animation()
	screen:find_child("timeline").start_timer()
end

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


local function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

local function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
        return key, t[key]
    end
    -- fetch the next value
    key = nil
    for i = 1,table.getn(t.__orderedIndex) do
        if t.__orderedIndex[i] == state then
            key = t.__orderedIndex[i+1]
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

local function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end


-- Localized string table

local strings = dofile( "localized:lib/strings.lua" ) or {}

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
	if k then 
        assert( asset , "Failed to create asset "..k )
        asset:set{ opacity = 0 }
        rawset( list , k , asset )
        screen:add( asset )
	end
    end
    return Clone{ source = asset , opacity = 255 }
end


function _mt.__newindex( t , k , v )
    assert( false , "You cannot add assets to the asset cache" )
end

local assets = setmetatable( {} , _mt )



local function table_remove_val(t, val)
	for i,j in pairs (t) do
		if j == val then 
		     table.remove(t, i)
		end 
	end 
	return t
end 

local function table_removekey(table, key)
	local idx = 1	
	local temp_t = {}
	table[key] = nil
	for i, j in pairs (table) do 
		temp_t[idx] = j 
		idx = idx + 1 
	end 
	return temp_t
end

-------------------
-- UI Factory
-------------------

-- make_titile_separator() : make a title separator line

local function make_title_separator(thickness, color, length)

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

--make_dialogBox_bg(p.ui_width, p.ui_height, p.border_width, p.border_color, p.f_color, p.padding_x, p.padding_y, p.border_corner_radius) 
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

local function make_ring(w,h,bc,fc,bw,px,py,br)
        local ring = Canvas{ size = {w, h} }
        ring:begin_painting()
        ring:set_source_color(bc)
        ring:round_rectangle(
            px + bw / 2,
            py + bw / 2,
            w - bw - px * 2 ,
            h - bw - py * 2 ,
            br )
	if fc then 
		ring:set_source_color( fc )
    		ring:fill(true)

		ring:set_line_width (bw)
    		ring:set_source_color(bc)
	end
    	ring:stroke(true)
	

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
c:set_line_width(3)
c:stroke(true)
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
		src = "lib/assets/left.png",
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
		    timeline:find_child(pointer.name).src = "lib/assets/leftfocus.png"
	       end
      
	       function pointer.extra.on_focus_out()
		 pointer.src = "lib/assets/left.png"
		 for n,m in pairs (g.children) do 
		     if m.extra.timeline then 
		     if m.extra.timeline[name2num(pointerName)] then
			for l,k in pairs (attr_map[m.type]()) do 
	     			m.extra.timeline[name2num(pointerName)][k] = m[k]
			end
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
		src = "lib/assets/left.png",
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
                 	--imsi : dragging = {pointer, x - pointer.x, y - pointer.y, pointer_on_button_up }
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
		     if m.extra.timeline then 
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
    --dumptable(timeline_timers)
    --dumptable(timeline_timelines)

     -- start_timer() function 
     
     --start_timer = function () 
     --function g.extra.start_timer()
     function timeline.extra.start_timer() 
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
    	ui_width = 180,
    	ui_height = 60, 

    	label = "Button", 
    	focus_color = {27,145,27,255}, 
    	focus_fill_color = {27,145,27,0}, 
    	focus_text_color = {255,255,255,255},
    	border_color = {255,255,255,255}, 
    	fill_color = {255,255,255,0},
    	border_width = 1,
    	border_corner_radius = 12,
		focused=nil, 
		pressed = nil, 
		released = nil, 
		button_image = nil,
		focus_image  = nil,
		text_has_shadow = true,
		single_button = false,
		label_align = nil,
		--------------------------------
		is_in_menu = false,
		ui_position = {100,100,0},
    }

 --overwrite defaults
    if table ~= nil then 
        for k, v in pairs (table) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local ring, focus_ring, text, button, focus, s_txt

    local b_group = Group
    {
        name = "button", 
        size = { p.ui_width , p.ui_height},
        position = p.ui_position, 
        reactive = true,
        extra = {type = "Button"}
    } 
    
    function b_group.extra.on_focus_in(key) 
		current_focus = b_group
        if (p.skin == "custom") then 
	     	ring.opacity = 0
	     	focus_ring.opacity = 255
        else
	     	button.opacity = 0
            focus.opacity = 255
        end 
        b_group:find_child("text").color = p.focus_text_color
	
	    if p.focused ~= nil then 
			p.focused()
		end 

		if key then 
	    	if p.pressed and key == keys.Return then
				p.pressed()
	    	end 
		end 
		
		if p.skin == "edit" then 
			input_mode = S_MENU_M
		end 

		b_group:grab_key_focus(b_group)
    end
    
    function b_group.extra.on_focus_out(key) 
		current_focus = nil 
        if (p.skin == "custom") then 
	     	ring.opacity = 255
	     	focus_ring.opacity = 0
            focus.opacity = 0
        else
	     	button.opacity = 255
            focus.opacity = 0
	     	focus_ring.opacity = 0
        end
        b_group:find_child("text").color = p.text_color
		if p.released then  
			if p.is_in_menu then 
				if key ~= keys.Return then
					p.released()
				end 
			else 
				p.released()
			end
		end 
    end

    local create_button = function() 
        b_group:clear()
        b_group.size = { p.ui_width , p.ui_height}
        ring = make_ring(p.ui_width, p.ui_height, p.border_color, p.fill_color, p.border_width, 0, 0, p.border_corner_radius)
        ring:set{name="ring", position = { 0 , 0 }, opacity = 255 }

        focus_ring = make_ring(p.ui_width, p.ui_height, p.focus_color, p.focus_fill_color, p.border_width, 0, 0, p.border_corner_radius)
        focus_ring:set{name="focus_ring", position = { 0 , 0 }, opacity = 0}
		
		if(p.skin == "editor") then 
	    	button= assets("assets/invisible_pixel.png")
            button:set{name="button", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 0}
	    	focus= assets("assets/menu-bar-focus.png")
            focus:set{name="focus", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 0}
		elseif(p.skin == "inspector") then 
	    	button= Group{}
			left_cap = Image{src="lib/assets/button-small-leftcap.png", position = {0,0}} 
			repeat_1px = Image{src="lib/assets/button-small-center1px.png", tile={true, false}, width = p.ui_width-left_cap.w*2, position = {left_cap.w, 0}} 
			right_cap = Image{src="lib/assets/button-small-rightcap.png", position = {p.ui_width-left_cap.w, 0 }} 
			button:add(left_cap, repeat_1px, right_cap)
			button:set{name="button", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 255}
			button.reactive = true 

			focus = Group{}
			left_cap_f = Image{src="lib/assets/button-small-leftcap-focus.png", position = {0,0}} 
			repeat_1px_f = Image{src="lib/assets/button-small-center1px-focus.png", tile={true, false}, 
						 width = p.ui_width - left_cap_f.w * 2, position = {left_cap_f.w, 0}} 
			right_cap_f = Image{src="lib/assets/button-small-rightcap-focus.png", position = {p.ui_width-left_cap_f.w, 0 }} 
			focus:add(left_cap_f, repeat_1px_f, right_cap_f)
            focus:set{name="focus", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 0}
			button.reactive = true 
		elseif(p.skin ~= "custom") then 
            button = assets(skin_list[p.skin]["button"])
            button:set{name="button", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 255}
            focus = assets(skin_list[p.skin]["button_focus"])
            focus:set{name="focus", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 0}
		else
			
	     	button = Image{}
	     	focus = Image{}
		end 
        text = Text{name = "text", text = p.label, font = p.text_font, color = p.text_color} --reactive = true 
		if p.label_align ~= nil then 
        	text:set{name = "text", position = { 10, p.ui_height/2 - text.h/2}}
		else 
        	text:set{name = "text", position = { (p.ui_width-text.w)/2, p.ui_height/2 - text.h/2}}
		end 
	
		b_group:add(ring, focus_ring, button, focus)
		if p.text_has_shadow then 
	       	s_txt = Text{
		    	name = "shadow",
            	text  = p.label, 
            	font  = p.text_font,
            	color = {0,0,0,255/2},
            	x     = p.ui_width/2-text.w/2 - 1,
            	y     = p.ui_height/2- text.h/2 - 1,
            }
			if p.label_align ~= nil then 
            	s_txt.x = 9
			end 
            s_txt.anchor_point={0,s_txt.h/2}
            s_txt.y = s_txt.y+s_txt.h/2
        	b_group:add(s_txt)
		end 

        b_group:add(text)

        if (p.skin == "custom") then 
			button.opacity = 0 
        else 
			ring.opacity = 0 
		end
		
		if editor_lb == nil or editor_use then 
	     	function b_group:on_button_down(x,y,b,n)
				if current_focus ~= b_group then 
					if current_focus then 
		     			current_focus.on_focus_out()
					end
					b_group.extra.on_focus_in(keys.Return)
				else 
		     		--current_focus.on_focus_in(keys.Return)
		     		current_focus.on_focus_out()
					screen:grab_key_focus()
				end 
				return true
	     	end 

			function b_group:on_button_up(x,y,b,n)
				if input_mode ~= S_MENU_M then 
				if b_group.single_button == true then 
	     			button.opacity = 255
            		focus.opacity = 0
	     			focus_ring.opacity = 0
				end 
				end
				return true
	     	end 

		--[[
			function b_group:on_enter()
				if input_mode ~= S_MENU_M then 
		    		if current_focus ~= b_group then 
						if current_focus then 
		     				current_focus.on_focus_out()
						end
						b_group.extra.on_focus_in(keys.Return)
		    		else 
		     			current_focus.on_focus_in(keys.Return)
		    		end 
				end
				return true
            end
			function b_group:on_leave()
				b_group.extra.on_focus_out()
			end
			---]]
		end

		--[[
		if p.skin == "editor"  then 
	     	function b_group:on_motion()
				if input_mode == S_MENU_M then 
		    		if current_focus ~= b_group then 
						if current_focus then 
		     				current_focus.on_focus_out()
						end
						b_group.extra.on_focus_in(keys.Return)
		    		else 
		     			current_focus.on_focus_in(keys.Return)
		    		end 
				end 
             end
		end 
		]]
    end 

    create_button()
	
    mt = {}
    mt.__newindex = function (t, k, v)
        if k == "bsize" then  
	    	p.ui_width = v[1] p.ui_height = v[2]  
        else 
           	p[k] = v
        end
		if k ~= "selected" then 
        	create_button()
		end
    end 

    mt.__index = function (t,k)
        if k == "bsize" then 
	    return {p.ui_width, p.ui_height}  
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
    	ui_width = 200 ,
    	ui_height = 60 ,
    	text = "",
    	padding = 20 ,
    	border_width  = 4 ,
    	border_color  = {255,255,255,255}, 
    	fill_color = {255,255,255,0},
    	focus_color  = {0,255,0,255},
    	focus_fill_color = {27,145,27,0}, 
    	cursor_color = {255,255,255,255},
    	text_font = "DejaVu Sans 30px"  , 
    	text_color =  {255,255,255,255},
    	border_corner_radius = 12 ,
		readonly = "",
		ui_position = {200,200,0},

    }
 --overwrite defaults
    if table ~= nil then 
        for k, v in pairs (table) do
	    p[k] = v 
        end 
    end

 --the umbrella Group
    local box, focus_box, box_img, focus_img, readonly, text
    local t_group = Group
    {
       name = "t_group", 
       size = { p.ui_width , p.ui_height},
       position = p.ui_position, 
       reactive = true, 
       extra = {type = "TextInput"} 
    }

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
		t_group.text = text.text
		--current_focus = nil
     end 

    local create_textInputField= function()
    	t_group:clear()
        t_group.size = { p.ui_width , p.ui_height}

    	box = make_ring(p.ui_width, p.ui_height, p.border_color, p.fill_color, p.border_width, 0, 0, p.border_corner_radius)
    	box:set{name="box", position = {0 ,0}}

    	focus_box = make_ring(p.ui_width, p.ui_height, p.focus_color, p.focus_fill_color, p.border_width, 0, 0, p.border_corner_radius)
    	focus_box:set{name="focus_box", position = { 0 , 0 }, opacity = 0}

		if(p.skin ~= "custom") then 
    		box_img = assets(skin_list[p.skin]["textinput"])
    		box_img:set{name="box_img", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 0 }
    		focus_img = assets(skin_list[p.skin]["textinput_focus"])
    		focus_img:set{name="focus_img", position = { 0 , 0 } , size = { p.ui_width , p.ui_height } , opacity = 0 }
		else 
	    	box_img = Image{}
	    	focus_img = Image{}
		end 

		if p.readonly ~= "" then 
			readonly = Text{text= p.readonly, editable=false, cursor_visible=false, font = p.text_font, color = p.text_color, }

    		text = Text{text= p.text, editable=true, cursor_visible=false, single_line = true, 
						cursor_color = p.cursor_color, wants_enter = true, 
						reactive = true, font = p.text_font, color = p.text_color, width = p.ui_width - 2 * p.padding - readonly.w}

    		readonly:set{name = "readonlyText", position = {p.padding, (p.ui_height - text.h)/2},}
    		text:set{name = "textInput", position = {readonly.x+readonly.w, (p.ui_height - text.h)/2},}

    		t_group:add(box, focus_box, box_img, focus_img, readonly, text)
		else 
    		text = Text{text= p.text, editable=true, cursor_visible=false, single_line = true, 
						cursor_color = p.cursor_color, wants_enter = true, 
						reactive = false, font = p.text_font, color = p.text_color, width = p.ui_width - 2 * p.padding}
    		text:set{name = "textInput", position = {p.padding, (p.ui_height - text.h)/2},}
    		t_group:add(box, focus_box, box_img, focus_img, text)
		end


		local t_pos_min = t_group.x + t_group:find_child("textInput").x 

		if editor_lb == nil or editor_use then 
	   		function t_group:on_button_down()
				t_group.extra.on_focus_in()
				return true
	   		end 
	    end 

		function text:on_key_down(key)
			if key == keys.Return then 
				t_group:grab_key_focus()
				t_group:on_key_down(key)
			elseif key == keys.Tab then 
				t_group:grab_key_focus()
				t_group:on_key_down(key)
			end 
			p.text = text.text 
		end 

    	if (p.skin == "custom") then 
			box_img.opacity = 0
    	else 
			box.opacity = 0 
			box_img.opacity = 255 
		end 
     end 

     create_textInputField()

     mt = {}
     mt.__newindex = function (t, k, v)
	 	if k == "bsize" then  
	     	p.ui_width = v[1] p.ui_height = v[2]  
        else 
           p[k] = v
        end
		if k ~= "selected" then 
        	create_textInputField()
		end
     end 

     mt.__index = function (t,k)
        if k == "bsize" then 
	     	return {p.ui_width, p.ui_height}  
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
	title_separator_thickness - Thickness of the title separator 
	title_separator_color - Color of the title separator 
    	padding_x - Padding of the dialog box on the X axis
    	padding_y - Padding of the dialog box on the Y axis

Return:
 	db_group - group containing the dialog box
]]

function ui_element.dialogBox(table) 
 
--default parameters
   local p = {
	skin = "custom", 
	ui_width = 900 ,
	ui_height = 500 ,
	label = "Dialog Box Title" ,
	border_color  = {255,255,255,255}, --"FFFFFFC0" , 
	fill_color  = {25,25,25,100},
	title_color = {255,255,255,255} , --"FFFFFF" , 
	title_font = "DejaVu Sans 30px" , 
	border_width  = 4 ,
	padding_x = 0 ,
	padding_y = 0 ,
	border_corner_radius = 22 ,
	title_separator_thickness = 4, 
	title_separator_color = {255,255,255,255},
	content = Group{}--children = {Rectangle{size={20,20},position= {100,100,0}, color = {255,255,255,255}}}},
    }

 --overwrite defaults
    if table ~= nil then 
        for k, v in pairs (table) do
	    p[k] = v 
        end 
    end 

 --the umbrella Group
    local db_group_cur_y = 6
    local d_box, title_separator, title, d_box_img, title_separator_img

    local  db_group = Group {
    	  name = "dialogBox",  
    	  position = {200, 200, 0}, 
          reactive = true, 
          extra = {type = "DialogBox"} 
    }


    local create_dialogBox  = function ()
   
        db_group:clear()
        db_group.size = { p.ui_width , p.ui_height - 34}

        d_box = make_dialogBox_bg(p.ui_width, p.ui_height, p.border_width, p.border_color, p.fill_color, p.padding_x, p.padding_y, p.border_corner_radius, p.title_separator_thickness, p.title_separator_color) 
	d_box.y = d_box.y - 34
	d_box:set{name="d_box"} 
	db_group:add(d_box)
--[[
	if p.title_separator_thickness >  0 then 
             title_separator = make_title_separator(p.title_separator_thickness, p.title_separator_color, p.ui_width)
             title_separator:set{name = "title_separator", position  = {0, db_group_cur_y + 30}}
	     db_group:add(title_separator)
	end
  ]]

        title= Text{text = p.label, font= p.title_font, color = p.title_color}     
        title:set{name = "title", position = {(p.ui_width - title.w - 50)/2 , db_group_cur_y - 5}}

	if(p.skin ~= "custom") then 
        	d_box_img = assets(skin_list[p.skin]["dialogbox"])
        	d_box_img:set{name="d_box_img", size = { p.ui_width , p.ui_height } , opacity = 0}
	else 
		d_box_img = Image{} 
	end

	db_group:add(d_box_img, title)
	if p.content then 
	     db_group:add(p.content)
	end 
	if (p.skin == "custom") then d_box_img.opacity = 0
        else d_box.opacity = 0 end 

     end 

     create_dialogBox ()

     mt = {}
     mt.__newindex = function (t, k, v)
	 	if k == "bsize" then  
	    	p.ui_width = v[1] 
	    	p.ui_height = v[2]  
        else 
           p[k] = v
        end
		if k ~= "selected" then 
        	create_dialogBox()
		end
     end 

     mt.__index = function (t,k)
	if k == "bsize" then 
	    return {p.ui_width, p.ui_height}  
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
	ui_width = 770,
	ui_height = 113,
	label = "Toast Alert Title",
	message = "Toast alert message",
	title_font = "DejaVu Sans 22px", 
	message_font = "DejaVu Sans 20px", 
	title_color = {255,255,255,255},  
	message_color = {255,255,255,255}, 
	border_width  = 4,
	border_color  = {255,255,255,80}, --"FFFFFFC0", 
	fill_color  = {25,25,25,80},
	padding_x = 0,
	padding_y = 0,
	border_corner_radius = 22,
	fade_duration = 2000,
	on_screen_duration = 5000,
	icon = "lib/assets/toast-icon.jpg", 
	ui_position = {800,600,0},
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
    	  position = p.ui_position, 
          reactive = true, 
          extra = {type = "ToastAlert"} 
     }

    local tb_group_cur_y = 10
    local tb_group_cur_x = 20
    local tb_group_timer = Timer()
    local tb_group_timeline = Timeline ()
    

    local create_toastBox = function()

    	tb_group:clear()
        tb_group.size = { p.ui_width , p.ui_height}

    	t_box = make_toastb_group_bg(p.ui_width, p.ui_height, p.border_width, p.border_color, p.fill_color, p.padding_x, p.padding_y, p.border_corner_radius) 
    	t_box:set{name="t_box"}
	tb_group.anchor_point = {p.ui_width/2, p.ui_height/2}

		icon = Image {src = p.icon}
    	icon:set{size = {150, 150}, name = "icon", position  = {tb_group_cur_x/2, -80}} --30,30

    	title= Text{text = p.label, font= p.title_font, color = p.title_color}     
    	title:set{name = "title", position = { icon.w + icon.x + 20 , tb_group_cur_y }}  --,50

    	message= Text{text = p.message, font= p.message_font, color = p.message_color, wrap = true, wrap_mode = "CHAR"}     
    	message:set{name = "message", position = {icon.w  + icon.x + 20 , title.h + tb_group_cur_y }, size = {p.ui_width - 150 , p.ui_height - 150 }  } 

	if(p.skin ~= "custom") then 
    	     t_box_img = assets(skin_list[p.skin]["toast"])
    	     t_box_img:set{name="t_box_img", size = { p.ui_width , p.ui_height } , opacity = 255}
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


	local my_alpha = Alpha{timeline=tb_group_timeline,mode="EASE_OUT_SINE"}

	local opacity_interval = Interval(255, 0)
	local scale_interval = Interval(1,0.8)

     	function tb_group_timeline.on_new_frame(t, m)
		tb_group.opacity = opacity_interval:get_value(my_alpha.alpha)
		tb_group.scale = {scale_interval:get_value(my_alpha.alpha),scale_interval:get_value(my_alpha.alpha)}
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
	    p.ui_width = v[1] p.ui_height = v[2]  
        else 
           p[k] = v
        end
		if k ~= "selected" then 
        	create_toastBox()
		end
     end 

     mt.__index = function (t,k)
        if k == "bsize" then 
	    return {p.ui_width, p.ui_height}  
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
	ui_width =  180,
	ui_height = 60,
	items = {"item1", "item2", "item3"},
	text_font = "DejaVu Sans 30px" , 
	focus_text_font = "DejaVu Sans 30px" , 
	text_color = {255,255,255,255}, 
	focus_text_color = {255,255,255,255}, 
	border_color = {255,255,255,255},
	fill_color = {255,255,255,0},
	focus_color = {0,255,0,255},
	focus_fill_color = {0,255,0,0},
	rotate_func = nil, 
    selected_item = 1, 
	direction = "horizontal", 
	inspector = 0, 
	ui_position = {300, 300, 0},  
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
		position = p.ui_position, 
        reactive = true, 
		extra = {type = "ButtonPicker"}
     }

     local index 

     local padding = 5
     --local pos = {26, 0} -- left arrow 
     local pos = {0, 0}    -- focus, unfocus 
     local t = nil

     local create_buttonPicker = function() 

		index = p.selected_item 
		bp_group:clear()
		items:clear()
    	bp_group.size = { p.ui_width , p.ui_height}

		ring = make_ring(p.ui_width, p.ui_height, p.border_color, p.fill_color, 1, 7, 7, 12)
    	ring:set{name="ring", position = {pos[1] , pos[2]}, opacity = 255 }

    	focus_ring = make_ring(p.ui_width, p.ui_height, p.focus_color, p.focus_fill_color, 1, 7, 7, 12)
    	focus_ring:set{name="focus_ring", position = {pos[1], pos[2]}, opacity = 0}


		if p.skin == "custom" then 
    		unfocus = assets(skin_list["default"]["buttonpicker"])
     		focus =   assets(skin_list["default"]["buttonpicker_focus"])
        	left_un   = assets(skin_list["default"]["buttonpicker_left_un"])
	    	left_sel  = assets(skin_list["default"]["buttonpciker_left_sel"])
	    	right_un  = assets(skin_list["default"]["buttonpicker_right_un"])
        	right_sel = assets(skin_list["default"]["buttonpicker_right_sel"])
		elseif p.skin == "inspector" then  
     		unfocus = Group{} --name = "unfocus-button", reactive = true, position = {pos[1], pos[2]}}
			local left, right, u1px 
			
			left = Image{src="lib/assets/picker-left-cap.png"} 
			right = Image{src="lib/assets/picker-right-cap.png", position = {p.ui_width - left.w, 0}} 
			u1px = Image{src="lib/assets/picker-repeat1px.png", position = {left.w, 0}, tile = {true, false}, width = p.ui_width - left.w - right.w}

			unfocus:add(left)
			unfocus:add(u1px)
			unfocus:add(right)

     		focus = Group{} --name = "focus-button", reactive = true, position = {pos[1], pos[2]}}

			local fleft, fright, f1px
			fleft = Image{src="lib/assets/picker-left-cap-focus.png"}
			fright = Image{src="lib/assets/picker-right-cap-focus.png", position = {p.ui_width - fleft.w, 0}}
			f1px = Image{src="lib/assets/picker-repeat1px-focus.png", position = {fleft.w, 0}, tile = {true, false}, width = p.ui_width - left.w - right.w}

			focus:add(fleft)
			focus:add(f1px)
			focus:add(fright)

	    	left_un   = assets("lib/assets/picker-left-arrow.png")
	    	left_sel  = assets("lib/assets/picker-left-arrow-focus.png")
	    	right_un  = assets("lib/assets/picker-right-arrow.png")
        	right_sel = assets("lib/assets/picker-right-arrow-focus.png")
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

     	unfocus:set{name = "unfocus",  position = {pos[1], pos[2]+padding}, size = {p.ui_width, p.ui_height}, opacity = 255, reactive = true}
		focus:set{name = "focus",  position = {pos[1], pos[2]+padding}, size = {p.ui_width, p.ui_height}, opacity = 0}

		if p.direction == "horizontal" then 
			left_un:set{name = "left_un", position = {pos[1] - left_un.w*w_scale - padding, pos[2] + p.ui_height/5}, opacity = 255, reactive = true}
			left_sel:set{position = {pos[1] - left_un.w*w_scale - padding, pos[2] + p.ui_height/5}, opacity = 0}
			right_un:set{name = "right_un", position = {pos[1] + focus_ring.w + padding, pos[2] + p.ui_height/5}, opacity = 255, reactive = true}
			right_sel:set{position = {right_un.x, right_un.y},  opacity = 0}
		elseif p.direction == "vertical" then 
            left_un.anchor_point={left_un.w/2,left_un.h/2}
            left_un.z_rotation={90,0,0}
			left_un:set{name = "left_un", position = {pos[1] + p.ui_width/2 - left_un.w/2 + padding, pos[2] - left_un.h/2 }, opacity = 255, reactive = true} -- top
			left_sel:set{position = {pos[1] + p.ui_width/2 - left_un.w/2 + padding, pos[2] - left_un.h/2 }, opacity = 0}

            right_un.anchor_point={right_un.w/2,right_un.h/2}
            right_un.z_rotation={90,0,0}
			right_un:set{name = "right_un", position = {pos[1] + p.ui_width/2 - left_un.w/2 + padding, pos[2] + p.ui_height + padding * 2 }, opacity = 255, reactive = true} -- bottom
			right_sel:set{position = {pos[1] + p.ui_width/2 - left_un.w/2 + padding, pos[2] + p.ui_height + padding * 2  },  opacity = 0}
		end

     	for i, j in pairs(p.items) do 
               items:add(Text{name="item"..tostring(i), text = j, font=p.text_font, color =p.text_color, opacity = 255})     
     	end 

		local j_padding = 0

		for i, j in pairs(items.children) do 
	  		if i == p.selected_item then  
               j.position = {p.ui_width/2 - j.width/2, p.ui_height/2 - j.height/2 - p.inspector }
	       	   j_padding = 5 * j.x -- 5 는 진정한 해답이 아니고.. 이걸 바꿔 줘야함.. 그리고 박스 크기가 문자열과 비례해서 적당히 커줘야하고.. ^^;;;
			   break
			end 
		end 

		for i, j in pairs(items.children) do 
	  		if i > p.selected_item then  -- i == 1
               j.position = {p.ui_width/2 - j.width/2 + j_padding, p.ui_height/2 - j.height/2}
	  		elseif i < p.selected_item then  -- i == 1
               j.position = {p.ui_width/2 - j.width/2 + j_padding, p.ui_height/2 - j.height/2}
	  		end 
     	end 

		items.clip = { 0, 0, p.ui_width, p.ui_height }

   		bp_group:add(ring, focus_ring, unfocus, focus, right_un, right_sel, left_un, left_sel, items) 

		if(p.skin == "custom") then 
			unfocus.opacity = 0 
       	else 
			ring.opacity = 0 
		end 

        t = nil

		if editor_lb == nil or editor_use then 
			local unfocus, left_arrow, right_arrow 
			unfocus = bp_group:find_child("unfocus")
			unfocus.reactive = true
			function unfocus:on_button_down (x,y,b,n)
				if current_focus then
   			         current_focus.extra.on_focus_out()
	        		 current_focus = group
				end 
				bp_group.on_focus_in()
	            bp_group:grab_key_focus()
		        return true
			end 

        	left_arrow = bp_group:find_child("left_un")
			left_arrow.reactive = true 
			function left_arrow:on_button_down(x, y, b, n)
				if current_focus then
					current_focus.extra.on_focus_out()
	        		current_focus = group
				end
				bp_group.on_focus_in()
	        	bp_group:grab_key_focus()
				bp_group.press_left()
				return true 
			end 

			right_arrow = bp_group:find_child("right_un")
			right_arrow.reactive = true 
			function right_arrow:on_button_down(x, y, b, n)
				if current_focus then
					current_focus.extra.on_focus_out()
	        		current_focus = group
				end
				bp_group.on_focus_in()
	        	bp_group:grab_key_focus()
				bp_group.press_right()
				return true 
			end 
		end 
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
     	for i, j in pairs(p.items) do 
             bp_group:find_child("item"..tostring(i)).color = p.focus_text_color
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
     	for i, j in pairs(p.items) do 
             bp_group:find_child("item"..tostring(i)).color = p.text_color
		end
     end

     function bp_group.extra.press_left()
     	local prev_i = index
        local next_i = (index-2)%(#p.items)+1

	    index = next_i

	    local j = (bp_group:find_child("items")):find_child("item"..tostring(index))
	    local prev_old_x = p.ui_width/2 - j.width/2
	    local prev_old_y = p.ui_height/2 - j.height/2 - p.inspector
	    local next_old_x = p.ui_width/2 - j.width/2 + focus.w
	    local next_old_y = p.ui_height/2 - j.height/2 - p.inspector 
	    local prev_new_x = p.ui_width/2 - j.width/2 - focus.w
	    local prev_new_y = p.ui_height/2 - j.height/2 - p.inspector 
	    local next_new_x = p.ui_width/2 - j.width/2
	    local next_new_y = p.ui_height/2 - j.height/2 - p.inspector 

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
	    local prev_old_x = p.ui_width/2 - j.width/2
	    local prev_old_y = p.ui_height/2 - j.height/2 - p.inspector 
	    local next_old_x = p.ui_width/2 - j.width/2 - focus.w
	    local next_old_y = p.ui_height/2 - j.height/2 - p.inspector 
	    local prev_new_x = p.ui_width/2 - j.width/2 + focus.w
	    local prev_new_y = p.ui_height/2 - j.height/2 - p.inspector 
	    local next_new_x = p.ui_width/2 - j.width/2
	    local next_new_y = p.ui_height/2 - j.height/2 - p.inspector 

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
	          local prev_i = index

            local next_i = (index-2)%(#p.items)+1

	    index = next_i

	    local j = (bp_group:find_child("items")):find_child("item"..tostring(index))
	    local prev_old_x = p.ui_width/2 - j.width/2
	    local prev_old_y = p.ui_height/2 - j.height/2
	    local next_old_x = p.ui_width/2 - j.width/2 + focus.w
	    local next_old_y = p.ui_height/2 - j.height/2
	    local prev_new_x = p.ui_width/2 - j.width/2 - focus.w
	    local prev_new_y = p.ui_height/2 - j.height/2
	    local next_new_x = p.ui_width/2 - j.width/2
	    local next_new_y = p.ui_height/2 - j.height/2

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

	function bp_group.extra.press_down()
	    local prev_i = index
            local next_i = (index)%(#p.items)+1
	    index = next_i

	    local j = (bp_group:find_child("items")):find_child("item"..tostring(index))
	    local prev_old_x = p.ui_width/2 - j.width/2
	    local prev_old_y = p.ui_height/2 - j.height/2
	    local next_old_x = p.ui_width/2 - j.width/2 - focus.w
	    local next_old_y = p.ui_height/2 - j.height/2
	    local prev_new_x = p.ui_width/2 - j.width/2 + focus.w
	    local prev_new_y = p.ui_height/2 - j.height/2
	    local next_new_x = p.ui_width/2 - j.width/2
	    local next_new_y = p.ui_height/2 - j.height/2

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
	    	p.ui_width = v[1] 	
		p.ui_height = v[2]  
		w_scale = v[1]/180
		h_scale = v[2]/60
             elseif k == "ui_width" then 
		w_scale = v/180
                p[k] = v
	     elseif k == "ui_height" then   
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
	        return {p.ui_width, p.ui_height}  
             else 
	        return p[k]
             end 
        end 

        setmetatable (bp_group.extra, mt) 

        return bp_group 
end


--[[
Function: radioButtonGroup

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


function ui_element.radioButtonGroup(table) 

 --default parameters
    local p = {
	skin = "custom", 
	ui_width = 600,
	ui_height = 200,
	items = {"item1", "item2", "item3"},
	text_font = "DejaVu Sans 30px", -- items 
	text_color = {255,255,255,255}, --"FFFFFF", -- items 
	button_color = {255,255,255,200}, -- items 
	select_color = {255, 255, 255, 255}, -- items 
	focus_color = {0,255,0,255},
	focus_fill_color = {0,50,0,100},
	button_radius = 10, -- items 
	select_radius = 4,  -- items 
	b_pos = {0, 0},  -- items 
	item_pos = {50,-5},  -- items 
	line_space = 40,  -- items 
	button_image = Image{}, --assets("assets/radiobutton.png"),
	select_image = Image{}, --assets("assets/radiobutton_selected.png"),
	rotate_func = nil, 
	direction = "vertical", 
	selected_item = 1,  
	ui_position = {200, 200, 0}, 
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
          name = "radioButtonGroup",  
    	  position = p.ui_position, 
          reactive = true, 
          extra = {type = "RadioButtonGroup"}
     }


	function rb_group.extra.on_focus_in()
	  	current_focus = cb_group
        if (p.skin == "CarbonCandy") or p.skin == "custom" then 
	    	rings:find_child("ring"..1).opacity = 0 
	    	rings:find_child("focus"..1).opacity = 255 
        end 
		rings:find_child("ring"..1):grab_key_focus() 
    end

    function rb_group.extra.on_focus_out()
        if (p.skin == "CarbonCandy") or p.skin == "custom" then 
			--for i=1, table.getn(rings.children)/2 do 
			for i=1,  #rings.children/2 do 
	    		rings:find_child("ring"..i).opacity = 255 
	    		rings:find_child("focus"..i).opacity = 0 
			end 
        end 
    end 

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

    local create_radioButton = function() 

	if(p.skin ~= "custom") then 
	     p.button_image = skin_list[p.skin]["radi(dobutton"]
	     p.button_focus_image = skin_list[p.skin]["radiobutton_focus"]
	     p.select_image = skin_list[p.skin]["radiobutton_sel"]
	end

         rb_group:clear()
         rings:clear()
         items:clear()
         --rb_group.size = { p.ui_width , p.ui_height},
	
         if(p.skin == "custom") then 
	     	select_img = create_select_circle(p.select_radius, p.select_color)
         	select_img:set{name = "select_img", position = {0,0}, opacity = 255} 
         else 
    	    select_img = Image{src = p.select_image}
         	select_img:set{name = "select_img", position = {0,0}, opacity = 255} 
         end 
    

	 	local pos = {0,0}
        for i, j in pairs(p.items) do 
	      	local donut, focus 
	      	if(p.direction == "vertical") then --vertical 
          	   	pos= {0, i * p.line_space - p.line_space}
	      	end   	
            items:add(Text{name="item"..tostring(i), text = j, font=p.text_font, color =p.text_color, position = pos})     
	      	if p.skin == "custom" then 
		   		donut =  create_circle(p.button_radius, p.button_color):set{name="ring"..tostring(i), position = {pos[1], pos[2] - 8}}  
		   	   	focus =  create_circle(p.button_radius, p.focus_color):set{name="focus"..tostring(i), position = {pos[1], pos[2] - 8}, opacity = 0}  
    	       	rings:add(donut, focus) 
	      	else
	           	donut = Image{name = "ring"..tostring(i),  src=p.button_image, position = {pos[1], pos[2] - 8}}
	           	focus = Image{name = "focus"..tostring(i),  src=p.button_focus_image, position = {pos[1], pos[2] - 8}, opacity = 0}
    	       	rings:add(donut, focus) 
	      	end 

	      	if(p.direction == "horizontal") then --horizontal
		  	   	pos= {pos[1] + items:find_child("item"..tostring(i)).w + 2*p.line_space, 0}
	      	end 
	      	donut.reactive = true
          	if editor_lb == nil or editor_use then  

				function donut:on_key_down(key)
					local ring_num = tonumber(donut.name:sub(5,-1))
					local next_num
					if key == keys.Up then 
						if ring_num > 1 then 
							next_num = ring_num - 1
				 			if (p.skin == "CarbonCandy") or (p.skin == "custom") then 
	    						rings:find_child("ring"..ring_num).opacity = 255 
	    						rings:find_child("focus"..ring_num).opacity = 0 
	    						rings:find_child("ring"..next_num).opacity = 0 
	    						rings:find_child("focus"..next_num).opacity = 255 
        					end 
	    					rings:find_child("ring"..next_num):grab_key_focus()
							return true 
						end
					elseif key == keys.Down then 
						
						--if ring_num < table.getn(rings.children)/2 then 
						if ring_num < #rings.children/2 then 
							next_num = ring_num + 1
				 			if (p.skin == "CarbonCandy") or (p.skin == "custom") then 
	    						rings:find_child("ring"..ring_num).opacity = 255 
	    						rings:find_child("focus"..ring_num).opacity = 0 
	    						rings:find_child("ring"..next_num).opacity = 0 
	    						rings:find_child("focus"..next_num).opacity = 255 
        					end 
							rings:find_child("ring"..next_num):grab_key_focus() 
							return true 
						end
					elseif key == keys.Return then 
						rb_group.extra.select_button(ring_num)
						select_img.x  = items:find_child("item"..tostring(p.selected_item)).x + 12
	    				select_img.y  = items:find_child("item"..tostring(p.selected_item)).y + 4
					--[[
						if rb_group:find_child("select"..tostring(ring_num)).opacity == 255 then 
							p.selected_items = table_remove_val(p.selected_items, ring_num)
							rb_group:find_child("check"..tostring(ring_num)).opacity = 0 
							rb_group:find_child("check"..tostring(ring_num)).reactive = true 
    						rb_group.extra.select_button(p.selected_items) 
						else 
							table.insert(p.selected_items, ring_num)
							rb_group:find_child("check"..tostring(ring_num)).opacity = 255 
    						rb_group.extra.select_button(p.selected_items) 
						end 
					]]
						return true 
					end 
				end 
	
	           	function donut:on_button_down (x,y,b,n)
				    local ring_num = tonumber(donut.name:sub(5,-1))
					rb_group.extra.select_button(ring_num)
					select_img.x  = items:find_child("item"..tostring(p.selected_item)).x + 12
	    			select_img.y  = items:find_child("item"..tostring(p.selected_item)).y + 4
					return true
	     		end 
	      	end
         end 
	 	 rings:set{name = "rings", position = p.b_pos} 
	 	 items:set{name = "items", position = p.item_pos} 

     	 select_img.x  = items:find_child("item"..tostring(p.selected_item)).x + 12
     	 select_img.y  = items:find_child("item"..tostring(p.selected_item)).y + 4 

	 	 rb_group:add(rings, items, select_img)

     end
     create_radioButton()

     mt = {}
     mt.__newindex = function (t, k, v)
		if k == "bsize" then  
	    p.ui_width = v[1] p.ui_height = v[2]  
        else 
           p[k] = v
        end
		if k ~= "selected" then 
        	create_radioButton()
		end
     end 

     mt.__index = function (t,k)
	if k == "bsize" then 
	    return {p.ui_width, p.ui_height}  
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
		cb_group - Group containing the check box  

Extra Function:
		insert_item(item) - Add an item to the items table 
		remove_item(item) - Remove an item from the items table 
]]


function ui_element.checkBoxGroup(t) 

 --default parameters
    local p = {
	skin = "custom", 
	ui_width = 600,
	ui_height = 200,
	items = {"item1", "item2", "item3"},
	text_font = "DejaVu Sans 30px", 
	text_color = {255,255,255,255}, 
	box_color = {255,255,255,255},
	fill_color = {255,255,255,0},
	focus_color = {0,255,0,255},
	focus_fill_color = {0,50,0,0},
	box_width = 2,
	box_size = {25,25},
	check_size = {25,25},
	line_space = 40,   
	b_pos = {0, 0},  
	item_pos = {50,-5},  
	selected_items = {1},  
	direction = "vertical",  -- 1:vertical 2:horizontal
	rotate_func = nil,  
	ui_position = {200, 200, 0}, 
    } 

 --overwrite defaults
    if t ~= nil then 
        for k, v in pairs (t) do
	    p[k] = v 
        end 
    end

 --the umbrella Group
    local check_image
    local checks = Group()
    local items = Group{name = "items"}
    local boxes = Group() 
    local cb_group = Group()

    local  cb_group = Group {
    	  name = "checkBoxGroup",  
    	  position = p.ui_position, 
          reactive = true, 
          extra = {type = "CheckBoxGroup"}
    }

	function cb_group.extra.on_focus_in()
	  	current_focus = cb_group
        if (p.skin == "CarbonCandy") or p.skin == "custom" then 
	    	boxes:find_child("box"..1).opacity = 0 
	    	boxes:find_child("focus"..1).opacity = 255 
        end 
		boxes:find_child("box"..1):grab_key_focus() 
    end

    function cb_group.extra.on_focus_out()
        if (p.skin == "CarbonCandy") or p.skin == "custom" then 
			for i=1, table.getn(boxes.children)/2 do 
	    		boxes:find_child("box"..i).opacity = 255 
	    		boxes:find_child("focus"..i).opacity = 0 
			end 
        end 
    end 

    function cb_group.extra.select_button(items) 
	    p.selected_items = items
        if p.rotate_func then
	       p.rotate_func(p.selected_items)
	    end
    end 

    function cb_group.extra.insert_item(itm) 
		table.insert(p.items, itm) 
		create_checkBox()
    end 

    function cb_group.extra.remove_item() 
		table.remove(p.items)
		create_checkBox()
    end 

    local function create_checkBox()
	 	items:clear() 
	 	checks:clear() 
	 	boxes:clear() 
	 	cb_group:clear()

	 	if(p.skin ~= "custom") then 
             p.box_image = skin_list[p.skin]["checkbox"]
             p.box_focus_image = skin_list[p.skin]["checkbox_focus"]
             p.check_image = skin_list[p.skin]["checkbox_sel"]
	 	else 
	     	 p.box_image = Image{}
			 p.box_focus_image = Image{}
             p.check_image = "lib/assets/checkmark.png"
	 	end
	
	 	boxes:set{name = "boxes", position = p.b_pos} 
	 	checks:set{name = "checks", position = p.b_pos} 
	 	items:set{name = "items", position = p.item_pos} 

        local pos = {0, 0}
        for i, j in pairs(p.items) do 
	      	local box, check, focus
	      	if(p.direction == "vertical") then --vertical 
                  pos= {0, i * p.line_space - p.line_space}
	      	end   			

	      	items:add(Text{name="item"..tostring(i), text = j, font=p.text_font, color = p.text_color, position = pos})     
	      	if p.skin == "custom" then 
		   		focus = Rectangle{name="focus"..tostring(i),  color= p.focus_fill_color, border_color= p.focus_color, border_width= p.box_width, 
				size = p.box_size, position = pos, reactive = true, opacity = 0}
		   		box = Rectangle{name="box"..tostring(i),  color= p.fill_color, border_color= p.box_color, border_width= p.box_width, 
				size = p.box_size, position = pos, reactive = true, opacity = 255}
    	        boxes:add(box, focus) 
	     	else
	           	focus = Image{name = "focus"..tostring(i),  src=p.box_focus_image, position = pos, reactive = true, opacity = 0}
	           	box = Image{name = "box"..tostring(i),  src=p.box_image, position = pos, reactive = true, opacity = 255}
		   		boxes:add(box, focus) 
	     	end 

	      	if p.skin == "custom" then 
	     		check = Image{name="check"..tostring(i), src=p.check_image, size = p.check_size, position = pos, reactive = false, opacity = 0}
			else 
	     		check = Image{name="check"..tostring(i), src=p.check_image, position = pos, reactive = false, opacity = 0}
			end
	     	checks:add(check) 

            if editor_lb == nil or editor_use then  

				function box:on_key_down(key)
					local box_num = tonumber(box.name:sub(4,-1))
					local next_num
					if key == keys.Up then 
						if box_num > 1 then 
							next_num = box_num - 1
				 			if (p.skin == "CarbonCandy") or (p.skin == "custom") then 
	    						boxes:find_child("box"..box_num).opacity = 255 
	    						boxes:find_child("focus"..box_num).opacity = 0 
	    						boxes:find_child("box"..next_num).opacity = 0 
	    						boxes:find_child("focus"..next_num).opacity = 255 
        					end 
	    					boxes:find_child("box"..next_num):grab_key_focus()
							return true 
						end
					elseif key == keys.Down then 
						if box_num < table.getn(boxes.children)/2 then 
							next_num = box_num + 1
				 			if (p.skin == "CarbonCandy") or (p.skin == "custom") then 
	    						boxes:find_child("box"..box_num).opacity = 255 
	    						boxes:find_child("focus"..box_num).opacity = 0 
	    						boxes:find_child("box"..next_num).opacity = 0 
	    						boxes:find_child("focus"..next_num).opacity = 255 
        					end 
							boxes:find_child("box"..next_num):grab_key_focus() 
							return true 
						end
					elseif key == keys.Return then 
						if cb_group:find_child("check"..tostring(box_num)).opacity == 255 then 
							p.selected_items = table_remove_val(p.selected_items, box_num)
							cb_group:find_child("check"..tostring(box_num)).opacity = 0 
							cb_group:find_child("check"..tostring(box_num)).reactive = true 
    						cb_group.extra.select_button(p.selected_items) 
						else 
							table.insert(p.selected_items, box_num)
							cb_group:find_child("check"..tostring(box_num)).opacity = 255 
    						cb_group.extra.select_button(p.selected_items) 
						end 
						return true 
					end 
				end 

	     		function box:on_button_down (x,y,b,n)
					local box_num = tonumber(box.name:sub(4,-1))
					--dumptable(p.selected_items)
					table.insert(p.selected_items, box_num)
					cb_group:find_child("check"..tostring(box_num)).opacity = 255
					cb_group:find_child("check"..tostring(box_num)).reactive = true
    				cb_group.extra.select_button(p.selected_items) 
					return true
	     		end 

	     		function check:on_button_down(x,y,b,n)
					local check_num = tonumber(check.name:sub(6,-1))
					p.selected_items = table_remove_val(p.selected_items, check_num)
					check.opacity = 0
					check.reactive = false
    				cb_group.extra.select_button(p.selected_items) 
					return true
	     		end 
	     	end

	     	if(p.direction == "horizontal") then 
		  		pos= {pos[1] + items:find_child("item"..tostring(i)).w + 2*p.line_space, 0}
	     	end 
         end 

	 	for i,j in pairs(p.selected_items) do 
             checks:find_child("check"..tostring(j)).opacity = 255 
             checks:find_child("check"..tostring(j)).reactive = true 
	 	end 

	 	cb_group:add(boxes, items, checks)
    end
    
    create_checkBox()


    mt = {}
    mt.__newindex = function (t, k, v)
    	if k == "bsize" then  
	    p.ui_width = v[1] p.ui_height = v[2]  
        else 
           p[k] = v
        end
		if k ~= "selected" then 
        	create_checkBox()
		end
    end 

    mt.__index = function (t,k)
        if k == "bsize" then 
	    return {p.ui_width, p.ui_height}  
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
		dot_diameter - Radius of the individual dots
		dot_color - Color of the individual dots
		number_of_dots - Number of dots in the loading circle
		overall_diameter - Radius of the circle of dots
		cycle_time - Millisecs spent on a dot, this number times the number of dots is the time for the animation to make a full circle

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
        dot_diameter    = 10,
        dot_color     = {255,255,255,255},
        number_of_dots      = 12,
        overall_diameter   = 100,
        cycle_time = 150*12,
        style = "orbitting", 
		ui_position = {400,400, 0},
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
        position = p.ui_position,  
        --anchor_point = {p.overall_diameter/2,p.overall_diameter/2},
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
    local make_big_dot = function()

          return Rectangle{
              w=p.overall_diameter,
              h=p.overall_diameter,
              color = p.dot_color,
              anchor_point={p.overall_diameter/2,p.overall_diameter/2}
          }
          
    end
    local img, load_timeline
    --function used to remake the dots upon a parameter change
    create_dots = function()
        l_dots:clear()
        dots = {}
        
        if p.style == "orbitting" then
        
        local rad
        
        for i = 1, p.number_of_dots do
            --they're radial position
            rad = (2*math.pi)/(p.number_of_dots) * i
            if skin_list[p.skin]["loadingdot"] == nil then
                dots[i] = make_dot(
                    math.floor( p.overall_diameter/2 * math.cos(rad) )+p.overall_diameter/2+p.dot_diameter/2,
                    math.floor( p.overall_diameter/2 * math.sin(rad) )+p.overall_diameter/2+p.dot_diameter/2
                )
	        else
		        img = assets(skin_list[p.skin]["loadingdot"])
		        img.anchor_point = {
                        img.w/2,
                        img.h/2
                    }
		        img.position = {
                        math.floor( p.overall_diameter/2 * math.cos(rad) )+p.overall_diameter/2+p.dot_diameter/2,
                        math.floor( p.overall_diameter/2 * math.sin(rad) )+p.overall_diameter/2+p.dot_diameter/2
                    }
                    img.size={p.dot_diameter, p.dot_diameter}
		        dots[i] = img
            end
            l_dots:add(dots[i])
        end
        
        -- the animation timeline
        if load_timeline ~= nil and load_timeline.is_playing then
            load_timeline:stop()
            load_timeline = nil
        end
        load_timeline = Timeline
        {
            name      = "Loading Animation",
            loop      =  true,
            duration  =  p.cycle_time,
            direction = "FORWARD", 
        }


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
        
        else
        if skin_list[p.skin]["loadingdot"] == nil then
            img = make_big_dot()
            l_dots:add(img)
        else
            img = assets(skin_list[p.skin]["loadingdot"])
            img.anchor_point={img.w/2,img.h/2}
            
            l_dots:add(img)
        end
        img.position={img.w/2,img.h/2}
        if load_timeline ~= nil and load_timeline.is_playing then
            load_timeline:stop()
            load_timeline = nil
        end
        load_timeline = Timeline
        {
            name      = "Loading Animation",
            loop      =  true,
            duration  =  p.cycle_time,
            direction = "FORWARD", 
        }
        function load_timeline.on_new_frame(t,msces,p)
            img.z_rotation={360*p,0,0}
        end
        load_timeline:start()
        
        end
        
	
    end
    create_dots()


    local mt = {}
    mt.__newindex = function(t,k,v)
       p[k] = v
	   if k ~= "selected" then 
       		create_dots()
	   end
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
		border_color - Color for the border
		fill_upper_color - The upper color for the loading bar fill
		fill_lower_color - The lower color for the loading bar fill

Return:

		loading_bar_group - Group containing the loading bar
        
Extra Function:
	set_prog(prog) - set the progress of the loading bar (meant to be called in an on_new_frame())
	start_prog() 
]]

---[[
function ui_element.progressBar(t)

    --default parameters
    local p={
        ui_width              =  300,
        ui_height             =   50,
        empty_top_color     = {  0,  0,  0,255},
        empty_bottom_color  = {127,127,127,255},
        border_color        = {160,160,160,255},
        filled_top_color    = {255,  0,  0,255},
        filled_bottom_color = { 96, 48, 48,255},
        progress            = 0,
        skin                = "default", 
		ui_position 		= {400,400},
    }
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end

	

	local c_shell = Canvas{
            size = {p.ui_width,p.ui_height},
            x    = p.ui_width,
            y    = p.ui_height
        }
	local c_fill  = Canvas{
            size = {1,p.ui_height},
            x    = p.ui_width+2,
            y    = p.ui_height
        }
	local l_bar_group = Group{
		name     = "progressBar",
        	position = p.ui_position, 
	        anchor_point = {p.radius,p.radius},
        	reactive = true,
	        extra = {
        	    type = "ProgressBar", 
        	    set_prog = function(prog)
	                c_fill.scale = {(p.ui_width-4)*(prog),1}
        	    end,
	        },
	}

	local l_bar_timer = Timer()
    	local l_bar_timeline = Timeline ()

	local function create_loading_bar()
		l_bar_group:clear()
        local stroke_width = 2
		c_shell = Canvas{
				size = {p.ui_width,p.ui_height},
		}
		c_fill  = Canvas{
				size = {1,p.ui_height-stroke_width},
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
		c_shell:add_source_pattern_color_stop( 0 , p.empty_top_color )
		c_shell:add_source_pattern_color_stop( 1 , p.empty_bottom_color )
        
		c_shell:fill(true)
		c_shell:set_line_width(   stroke_width )
		c_shell:set_source_color( p.border_color )
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
		c_fill:add_source_pattern_color_stop( 0 , p.filled_top_color )
		c_fill:add_source_pattern_color_stop( 1 , p.filled_bottom_color )
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
        	c_fill.scale = {(p.ui_width-4)*(p.progress),1}
		l_bar_group:add(c_shell,c_fill)

		l_bar_timer.interval = 1 -- immediately 
    		l_bar_timeline.duration = 3000 -- progress duration 
    		l_bar_timeline.direction = "FORWARD"
    		l_bar_timeline.loop = false

     		function l_bar_timeline.on_new_frame(t, m, p)
			l_bar_group.set_prog(p)
     		end  

     		function l_bar_timeline.on_completed()
			l_bar_group.set_prog(1)
     		end 

     		function l_bar_timer.on_timer(l_bar_timer)
			l_bar_timeline:start()
        		l_bar_timer:stop()
     		end 

	end
    
	create_loading_bar()
    
    	function l_bar_group.extra.start_timer() 
		l_bar_timer:start()
     	end 
 
    
	local mt = {}
    
    mt.__newindex = function(t,k,v)
        p[k] = v
        if k == "progress" then
            c_fill.scale = {(p.ui_width-4)*(v),1}
        else
	   		if k ~= "selected" then 
            	create_loading_bar()
	   		end
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
    rows    - number of rows
    columns    - number of columns
    item_w      - width of an item
    item_h      - height of an item
    grid_gap    - the number of pixels in between the grid items
    duration_per_tile - how long a particular tile flips for
    cascade_delay     - how long a tile waits to start flipping after its neighbor began flipping
    tiles       - the uielements that are the tiles, the elements are assumed to be of the size {item_w,item_h} and that there are 'num_rows' by 'columns' elements in a 2 dimensional table 

Return:
    Group - Group containing the grid
        
Extra Function:
    get_tile_group(r,c) - returns group for the tile at row 'r' and column 'c'
    animate_in() - performs the animate-in sequence
]]
function ui_element.layoutManager(t)
    --default parameters
    local p = {
        rows    = 1,
        columns    = 5,
        cell_w      = 300,
        cell_h      = 200,
        cell_spacing    = 40, --grid_gap
		cell_timing = 300, -- duration_per_time
		cell_timing_offset     = 200,
        tiles       = {},
        focus       = nil,
        cells_focusable = true, --focus_visible
        skin="default",
        cell_size="fixed",
 		ui_position = {200,100},
    }
    
    local functions={}
    local focus_i = {1,1}
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
    
    local make_grid
    
    local row_hs = {}
    local col_ws = {}
	
    local x_y_from_index = function(r,c)
        if p.cell_size == "fixed" then
		    return (p.cell_w+p.cell_spacing)*(c-1)+p.cell_w/2,
		           (p.cell_h+p.cell_spacing)*(r-1)+p.cell_h/2
        end
        
        local x = (col_ws[1] or p.cell_w)/2
        local y = (row_hs[1] or p.cell_h)/2
        for i = 1, c-1 do x = x + (col_ws[i] or p.cell_w)/2 + (col_ws[i+1] or p.cell_w)/2 + p.cell_spacing end
        for i = 1, r-1 do y = y + (row_hs[i] or p.cell_h)/2 + (row_hs[i+1] or p.cell_h)/2 + p.cell_spacing end
        return x,y
	end

    --the umbrella Group, containing the full slate of tiles
    local slate = Group{ 
        name     = "layoutManager",
        position = p.ui_position, 
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
                
                make_grid()
			end,
            remove_row = function(self,r)
                if r > 0 and r <= #p.tiles then
                    table.remove(p.tiles,r)
                    p.rows = p.rows - 1
                    make_grid()
                end
            end,
            remove_col = function(self,c)
                if c > 0 and c <= #p.tiles[1] then
                    for r = 1,#p.tiles do
                        table.remove(p.tiles[r],c)
                    end
                    p.columns = p.columns - 1
                    make_grid()
                end
            end,
            add_row = function(self,r)
                if r > 0 and r <= #p.tiles then
                    table.insert(p.tiles,r,{})
                    p.rows = p.rows + 1
                    make_grid()
                end
            end,
            add_col = function(self,c)
                if c > 0 and c <= #p.tiles[1] then
                    for r = 1,#p.tiles do
                        table.insert(p.tiles[r],c,c)
                        p.tiles[r][c] = nil
                    end
                    p.columns = p.columns + 1
                    make_grid()
                end
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
                if p.cell_size == "variable" then
                    local w,h 
                    if p.tiles[r][c] == nil then
                        w = col_ws[r] or p.cell_w
                        h = row_hs[c] or p.cell_h
                    else
                        w=p.tiles[r][c].w
                        h=p.tiles[r][c].h
                    end
                    focus:animate{
                        duration=300,
                        mode="EASE_OUT_CIRC",
                        x=x,
                        y=y,
                        w=w,
                        h=h,
                        anchor_point={(col_ws[r] or p.cell_w)/2,(row_hs[c] or p.cell_h)/2}
                    }
                else
                    focus:animate{
                        duration=300,
                        mode="EASE_OUT_CIRC",
                        x=x,
                        y=y
                    }
                end
            end,
            press_enter = function(p)
                functions[focus_i[1]][focus_i[2]](p)
            end,
            animate_in = function()
				local tl = Timeline{
					duration =p.cell_timing_offset*(p.rows+p.columns-2)+ p.cell_timing
				}
				function tl:on_started()
					for r = 1, p.rows  do
						for c = 1, p.columns do
							p.tiles[r][c].y_rotation={90,0,0}
							p.tiles[r][c].opacity = 0
						end
					end
				end
				function tl:on_new_frame(msecs,prog)
					msecs = tl.elapsed
					local item
					for r = 1, p.rows  do
						for c = 1, p.columns do
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
            end,
            r_c_from_abs_position = function(self,x,y)
                x = x - self.transformed_position[1]/screen.scale[1]
                y = y - self.transformed_position[2]/screen.scale[2]
                if p.cell_size == "fixed" then
	        	    return math.floor(x/(p.cell_w+p.cell_spacing))+1,
                           math.floor(y/(p.cell_h+p.cell_spacing))+1
                end
                
                local r = 1
                local c = 1
                for i = 1, p.columns do
                    if x < (col_ws[i] or p.cell_w) then break end
                    x = x - (col_ws[i] or p.cell_w) - p.cell_spacing
                    r = r + 1
                end
                for i = 1, p.rows do
                    if y < (row_hs[i] or p.cell_h) then break end
                    y = y - (row_hs[i] or p.cell_h) - p.cell_spacing
                    c = c + 1
                end
                return  r,c
	        end,
            cell_x_y_w_h = function(self,r,c)
                if p.cell_size == "fixed" then
                    
                    return  (p.cell_w+p.cell_spacing)*(c-1),
                            (p.cell_h+p.cell_spacing)*(r-1),
                            p.cell_w,
                            p.cell_h
                    
                else
                    
                    local x, y = 0, 0
                    
                    for i = 1,c-1 do
                        
                        x = x + (col_ws[i] or p.cell_w) + p.cell_spacing
                        
                    end
                    
                    for i = 1,r-1 do
                        
                        y = y + (row_hs[i] or p.cell_h) + p.cell_spacing
                        
                    end
                    
                    return x, y, (col_ws[c] or p.cell_w), (row_hs[r] or p.cell_h)
                end
            end,
        }
    }


	local make_tile = function(w,h)
        local c = Canvas{size={w,h}}
        c:begin_painting()
        c:move_to(  0,   0 )
        c:line_to(c.w,   0 )
        c:line_to(c.w, c.h )
        c:line_to(  0, c.h )
        c:line_to(  0,   0 )
        c:set_source_color("ffffff")
        c:set_line_width( 4 )
        c:set_dash(0,{10,10})
        c:stroke(true)
        c:finish_painting()
        if c.Image then
            c = c:Image()
        end
        c.name="placeholder"
		return c
	end
    local make_focus = function()
        return Rectangle{
            name="Focus",
            size={ p.cell_w+10, p.cell_h+10},
            color="00000000",
            anchor_point = { (p.cell_w+10)/2, (p.cell_h+10)/2},
            border_width=5,
            border_color="FFFFFFFF",
        }
    end
	
	make_grid = function()
        
		local g
        slate:clear()
        
        if p.focus == nil then
            focus = make_focus()
        else
            focus = p.focus
            focus.anchor_point={focus.w/2,focus.h/2}
        end
        focus_i[1] = 1
        focus_i[2] = 1
        focus.x, focus.y = x_y_from_index(focus_i[1],focus_i[2])
        slate:add(focus)
        
        if p.cells_focusable then
            focus.opacity=255
        else
            focus.opacity=0
        end
        
        if p.cell_size == "variable" then
            
            for r = 1, p.rows  do
			    
                for c = 1, p.columns do
                    
                    if p.tiles[r]    == nil then break end
                    
                    if p.tiles[r][c] ~= nil and p.tiles[r][c].name ~= "placeholder" then 
                        
                        if row_hs[r] == nil or row_hs[r] < p.tiles[r][c].h then
                            
                            row_hs[r] = p.tiles[r][c].h
                            
                        end
                        
                        if col_ws[c] == nil or col_ws[c] < p.tiles[r][c].w then
                            
                            col_ws[c] = p.tiles[r][c].w
                            
                        end
                        
                    end
                    
                end
                
            end
            
        end
        
		for r = 1, p.rows  do
            if p.tiles[r] == nil then
                p.tiles[r]   = {}
                functions[r] = {}
            end
			for c = 1, p.columns do
                if p.tiles[r][c] == nil then
                    if p.cell_size == "variable" then
                        g = make_tile(col_ws[c] or p.cell_w, row_hs[r] or p.cell_h)
                    else
                        g = make_tile(p.cell_w,p.cell_h)
                    end
                else
                    g = p.tiles[r][c]
                    if g.parent ~= nil then
                        g:unparent()
                    end
                end
                slate:add(g)
                g.x, g.y = x_y_from_index(r,c)
                g.delay = p.cell_timing_offset*(r+c-1)
                g.anchor_point = {g.w/2,g.h/2}
			end
		end
        
        slate.w, slate.h = x_y_from_index(p.rows,p.columns)
        
        slate.w = slate.w + (col_ws[p.columns] or p.cell_w)/2
        
        slate.h = slate.h + (row_hs[p.rows]    or p.cell_h)/2
        
        if p.rows < #p.tiles then
            for r = p.rows + 1, #p.tiles do
                for c = 1, #p.tiles[r] do
                    p.tiles[r][c]:unparent()
                    p.tiles[r][c] = nil
                end
                p.tiles[r]     = nil
                functions[r] = nil
            end
        end
        
        if p.tiles[1] then 
            if p.columns < #p.tiles[1] then
                for c = p.columns + 1, #p.tiles[r] do
                    for r = 1, #p.tiles do
                        p.tiles[r][c]:unparent()
                        p.tiles[r][c]   = nil
                        functions[r][c] = nil
                    end
                end
            end
            if p.cell_size == "variable" then
                if p.tiles[focus_i[1]][focus_i[2]] == nil then
                    focus.w = col_ws[focus_i[2]] or p.cell_w
                    focus.h = row_hs[focus_i[1]] or p.cell_h
                else
                    focus.w = p.tiles[focus_i[1]][focus_i[2]].w
                    focus.h = p.tiles[focus_i[1]][focus_i[2]].h
                end
                focus.anchor_point = { (focus.w)/2, (focus.h)/2}
            end
        end
	end
	make_grid()

    


    mt = {}
    mt.__newindex = function(t,k,v)
		
       p[k] = v
	   if k ~= "selected" then 
       		make_grid()
	   end
		
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
        content   = Group{},
        virtual_h = 1000,
        virtual_w = 1000,
        --arrow_clone_source = nil,
        --arrow_sz = 15,
        arrow_color = {255,255,255,255},
        arrows_visible = false,
        --arrows_in_box = false,
        --arrows_centered = false,
        --hor_arrow_y     = nil,
        --vert_arrow_x    = nil,
        bar_color_inner     = {180,180,180,255},
        bar_color_outer     = {30,30,30,255},
        empty_color_inner   = {120,120,120,255},
        empty_color_outer   = {255,255,255,255},
        frame_thickness     =    2,
        frame_color        = {60, 60,60,255},
        bar_thickness       =   15,
        bar_offset          =    5,
        vert_bar_visible    = true,
        horz_bar_visible     = true,
        
        box_color = {160,160,160,255},
        box_width = 2,
        skin="default",
		ui_position = {200,100},
    }
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
	
	--Group that Clips the content
	local window  = Group{name="window"}
	--Group that contains all of the content
	--local content = Group{}
	--declarations for dependencies from scroll_group
	local scroll, scroll_x, scroll_y
	--flag to hold back key presses while animating content group
	local animating = false

	local border = Rectangle{ color = "00000000" }
	
	
	local track_h, track_w, grip_hor, grip_vert, track_hor, track_vert
	

    --the umbrella Group, containing the full slate of tiles
    local scroll_group = Group{ 
        name     = "scrollPane",
        position = p.ui_position, 
        reactive = true,
        extra    = {
			type = "ScrollPane",
            seek_to_middle = function(x,y)
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
                    elseif y < p.visible_h/2 then
                        new_y = 0
                    else
                        new_y = -y + p.visible_h/2
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
                
                    if grip_vert ~= nil then
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
                    end
                    if grip_hor ~= nil then
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
            end,
            --[[
			get_content_group = function()
				return content
			end
            --]]
            screen_pos_of_child = function(self,child)
                return  child.x + child.parent.x + self.x + p.box_width,
                        child.y + child.parent.y + self.y + p.box_width
            end,
        }
    }
    scroll_group.extra.seek_to = function(x,y)
        scroll_group.extra.seek_to_middle(x+p.visible_w/2,y+p.visible_h/2)
    end
	
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
    local make_arrow = function()
		
		local c = Canvas{size={p.bar_thickness,p.bar_thickness}}
		
		c:move_to(    0,c.h)
		c:line_to(c.w/2,  0)
		c:line_to(  c.w,c.h)
		c:line_to(    0,c.h)
		
		c:set_source_color( p.arrow_color )
		c:fill(true)
		
		if c.Image then
			c= c:Image()
		end
		
		c.anchor_point={c.w/2,c.h}
		
		return c
		
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
		shell:set_source_color( p.frame_color )
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
		fill:set_source_color( p.frame_color )
		fill:stroke( true )
		fill:finish_painting()
        
        -----------------------------------------------------
        
		if shell.Image then shell = shell:Image() end
		if  fill.Image then  fill =  fill:Image() end
        
		bar:add(shell,fill)
        
        shell.name="track"
        shell.reactive = true
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
		shell:set_source_color( p.frame_color )
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
		fill:set_source_color( p.frame_color )
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
        shell.reactive = true
        fill.name="grip"
        fill.reactive=true
        fill.x=p.frame_thickness/2 
        return bar
    end
	
	
	--this function creates the whole scroll bar box
        local hold = false
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
        
        if p.bar_offset < 0 then
            track_w = p.visible_w+p.bar_offset
            track_h = p.visible_h+p.bar_offset
        elseif p.arrows_visible then
            track_w = p.visible_w-p.bar_thickness*2-10
            track_h = p.visible_h-p.bar_thickness*2-10
        else
            track_w = p.visible_w
            track_h = p.visible_h
        end
        
--[[
if editor_lb == nil  then
            function screen:on_motion(x,y) 
	  	if dragging then
	        local actor = unpack(dragging)
	    	  if (actor.name == "grip") then  
	             local actor,s_on_motion = unpack(dragging) 
	             s_on_motion(x, y)
	             return true
	    	  end 
		  return true 
		end
	    end 
	    function screen:on_button_up()
		if dragging then 
			dragging = nil 
		end 
	    end 
end
]]
        
        if p.horz_bar_visible and p.visible_w/p.virtual_w < 1 then
            hor_s_bar = make_hor_bar(
                track_w,
                p.bar_thickness,
                track_w/p.virtual_w
            )
            hor_s_bar.name = "Horizontal Scroll Bar"
            if p.arrows_visible then
                local l = make_arrow()
                l.name="L"
                l.x = p.box_width+p.bar_thickness
                l.y = p.box_width*2+p.visible_h+p.bar_offset+p.bar_thickness/2
                scroll_group:add(l)
                l.reactive=true
                function l:on_button_down()
                    scroll_x(1)
                end
                hor_s_bar.position={
                    p.box_width+p.bar_thickness+5,
                    p.box_width*2+p.visible_h+p.bar_offset
                }
                local r = make_arrow()
                r.name="R"
                r.x = p.box_width+p.bar_thickness+hor_s_bar.w+10
                r.y = p.box_width*2+p.visible_h+p.bar_offset+p.bar_thickness/2
                scroll_group:add(r)
                r.reactive=true
            else
                hor_s_bar.position={
                    p.box_width,
                    p.box_width*2+p.visible_h+p.bar_offset
                }
            end
            scroll_group:add(hor_s_bar)
            
            grip_hor = hor_s_bar:find_child("grip")
            track_hor = hor_s_bar:find_child("track")
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

--[[
            function grip_hor:on_button_up(x,y,button,num_clicks)
                hold = false
            end
--]] 



--[[
            function grip_hor:on_motion(dx,dy)
                if hold then
                    grip_hor.x =  grip_hor.x - dx
                   	print("on motion !!!!!!") 
                    if  grip_hor.x < 0 then
                    grip_hor.x = 0
                    elseif grip_hor.x > track_w-grip_hor.w then
                        grip_hor.x = track_w-grip_hor.w
                    end
                    
                    p.content.x = -(grip_hor.x ) * p.virtual_w/track_w
                end
            end
--]]
            function track_hor:on_button_down(x,y,button,num_clicks)
                
                local rel_x = x - track_hor.transformed_position[1]/screen.scale[1]
	   	        
                if rel_x < grip_hor.w/2 then
                    rel_x = grip_hor.w/2
                elseif rel_x > (track_hor.w-grip_hor.w/2) then
                    rel_x = (track_hor.w-grip_hor.w/2)
                end
                
                grip_hor.x = rel_x-grip_hor.w/2
                
                p.content.x = -(grip_hor.x) * p.virtual_w/track_w
                
                return true
            end
        else
            grip_hor=nil
            track_hor=nil
        end
        if p.vert_bar_visible and p.visible_h/p.virtual_h < 1 then
            vert_s_bar = make_vert_bar(
                
                p.bar_thickness,
                track_h,
                track_h/p.virtual_h
            )
            vert_s_bar.name = "Vertical Scroll Bar"
            if p.arrows_visible then
                local up = make_arrow()
                up.name="UP"
                up.x = p.box_width*2+p.visible_w+p.bar_offset+p.bar_thickness/2
                up.y = p.box_width+p.bar_thickness
                scroll_group:add(up)
                up.reactive=true
                function up:on_button_down()
                    scroll_y(1)
                end
                vert_s_bar.position={
                    p.box_width*2+p.visible_w+p.bar_offset,
                    p.box_width+p.bar_thickness+5
                }
                local dn = make_arrow()
                dn.name="DN"
                dn.x = p.box_width*2+p.visible_w+p.bar_offset+p.bar_thickness/2
                dn.y = p.box_width+p.bar_thickness+vert_s_bar.h+10
                dn.z_rotation = {180,0,0}
                scroll_group:add(dn)
                dn.reactive=true
                function dn:on_button_down()
                    scroll_y(-1)
                end
            else
                vert_s_bar.position={
                    p.box_width*2+p.visible_w+p.bar_offset,
                    p.box_width
                }
            end
            --vert_s_bar.z_rotation={90,0,0}
            scroll_group:add(vert_s_bar)
            
            grip_vert = vert_s_bar:find_child("grip")
            track_vert = vert_s_bar:find_child("track")
            ---[[
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

	    --]]


	    
            function track_vert:on_button_down(x,y,button,num_clicks)
                
                local rel_y = y - track_vert.transformed_position[2]/screen.scale[2]
	   	        
                if rel_y < grip_vert.h/2 then
                    rel_y = grip_vert.h/2
                elseif rel_y > (track_vert.h-grip_vert.h/2) then
                    rel_y = (track_vert.h-grip_vert.h/2)
                end
                
                grip_vert.y = rel_y-grip_vert.h/2
                
                p.content.y = -(grip_vert.y) * p.virtual_h/track_h
                
                return true
            end
        else
            grip_vert=nil
            track_vert=nil
        end
        
        scroll_group.size = {p.visible_w, p.visible_h}
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
        	p[k] = v
        elseif k =="selected" then 
        	p[k] = v
		else
        	p[k] = v
        	create()
		end
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

local function make_dropdown( size , color )

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

function ui_element.menuButton(t)
    --default parameters
    local p = {
--[[
button 
--]]
        text_font = nil,
    	text_color = nil,
    	text_focus_color = nil,
        label_text_font = nil,
    	label_text_color = nil,
    	label_text_focus_color = nil,
        item_text_font = nil,
    	item_text_color = nil,
    	item_text_focus_color = nil,

		text_font = "DejaVu Sans 30px",
    	text_color = {255,255,255,255}, --"FFFFFF",
    	skin = "default", 
    	ui_width = 250,
    	ui_height = 60, 

    	label = "Menu Button", 
    	focus_color = {27,145,27,255}, 	  --"1b911b", 
    	focus_fill_color = {27,145,27,0}, --"1b911b", 
		focus_text_color =  {255,255,255,255},   
    	border_color = {255,255,255,255}, --"FFFFFF"
    	fill_color = {255,255,255,0},     --"FFFFFF"
    	border_width = 1,
    	border_corner_radius = 12,
--]]

        name  = "dropdownbar",
        items = {
            {type="label", string="Label ..."},
            {type="separator"},
            {type="item",  string="Item ...", f=nil},
        },
        vert_spacing = 5, --item_spacing
        horz_spacing = 10, -- new 
        vert_offset  = 40, --item_start_y
        horz_offset  = 0,
        text_has_shadow = true,
        
        background_color     = {255,0,0,255},
        
        menu_width = 250,   -- bg_w 
        horz_padding  = 10, -- padding 
        separator_thickness    = 2, --divider_h
        expansion_location   = "below", --bg_goes_up -> true => "above" / false == below
        align = "left",
        show_ring     = true,
        skin = "default",
		status = nil,
		ui_position = {300,300},
    }
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
    
    local create
    local curr_index = 0
    local selectable_items  = {}

    local t_f = {"text_font", "label_text_font", "item_text_font"}
    local t_c = {"text_color", "label_text_color", "item_text_color",}
    local f_c = {"text_focus_color", "label_text_focus_color", "item_text_focus_color"}
    
    for k, v in pairs (t_f) do
	if p[v] == nil then 
		p[v] = p.text_font
	end 
    end 
    for k, v in pairs (t_c) do
	if p[v] == nil then 
		p[v] = p.text_color
	end 
    end 
    for k, v in pairs (f_c) do
	if p[v] == nil then 
		p[v] = p.focus_text_color
	end 
    end 

    local shadow 
    if p.skin == "editor" then
		p.horz_offset = -4
		shadow = true 
    else 
		shadow = false 
    end 

    local dropDownMenu = Group{}
    local button       = ui_element.button{
		name = "button",
        text_font=p.text_font,
    	text_color=p.text_color,
    	focus_text_color=p.text_focus_color,
    	skin=p.skin,
    	ui_width=p.ui_width,
    	ui_height=p.ui_height, 
    	label=p.label, 
    	focus_color=p.focus_color,
    	focus_fill_color=p.focus_fill_color,
    	border_color=p.border_color, 
    	fill_color=p.fill_color, 
    	border_width=p.border_width,
    	border_corner_radius=p.border_corner_radius,
		text_has_shadow = shadow,
		is_in_menu = true, 
		ui_position = p.ui_position,
    }
    local umbrella
    umbrella     = Group{
        name="menuButton",
        reactive = true,
        position = p.ui_position, 
        children = {button,dropDownMenu},
        extra={
            type="MenuButton",
            focus_index = function(i)
            if curr_index == i then
            	print("Item on Drop Down Bar is already focused")
                return
            end
            if selectable_items[curr_index] ~= nil then
            	selectable_items[curr_index].focus:complete_animation()
                selectable_items[curr_index].focus.opacity=255
                selectable_items[curr_index].focus:animate{
                	duration=300,
                	opacity=0
                }
            elseif curr_index==0 then
                    --button:on_focus_out()
            end
            if selectable_items[i] ~= nil then
               selectable_items[i].focus:complete_animation()
               selectable_items[i].focus.opacity=0
               selectable_items[i].focus:animate{

               		duration=300,
                    opacity=255,
               }
               curr_index=i
           elseif i==0 then
           	   button:on_focus_in()
               curr_index=i
           end
           end,
	    get_index = function ()
		return curr_index
	    end,
            press_up = function()
                if curr_index <= 0 then
                    return
                else
                    umbrella.focus_index(curr_index-1)
                end
            end,
            press_down = function()
                if curr_index >= #selectable_items then
                    return
                else
                    umbrella.focus_index(curr_index+1)
                end
            end,
            insert_item = function (index,item)
                assert(type(item)=="table","invalid item")
                assert(index > 0 and index <= #p.items + 1, "invalid index")
                
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
            replace_item = function(index,item)
                assert(type(item)=="table","invalid item")
                assert(index > 0 and index <= #p.items, "invalid index")
                
                p.items[index] = item
                create()
            end,
            index_from_y = function(y)
                y = y - umbrella.transformed_position[2]-p.vert_offset
                
                
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
                if selectable_items[curr_index] then
                    selectable_items[curr_index].focus.opacity=0
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
            end,
            fade_in = function()
                dropDownMenu:show()
                dropDownMenu:complete_animation()
                dropDownMenu.y_rotation={0,0,0}
                dropDownMenu.opacity=0
                dropDownMenu:animate{
                    duration=100,
                    opacity=255,
                }
                for _,s_i in ipairs(selectable_items) do
                    s_i.focus.opacity=0
                end
                curr_index = 0
				umbrella:raise_to_top()
				--[[
				if screen:find_child("mouse_pointer") then 
		 			screen:find_child("mouse_pointer"):raise_to_top()
				end
				]]
				input_mode = S_MENU_M
				p.status = "fade_in"
            end,
            fade_out = function()
                dropDownMenu:complete_animation()
                dropDownMenu.y_rotation={0,0,0}
                dropDownMenu.opacity=255
                dropDownMenu:animate{
                    duration=100,
                    opacity=0,
		    		on_completed = function()  dropDownMenu:hide()  end,
                }
				input_mode = S_SELECT
				p.status = "fade_out"
            end,
            set_item_function = function(index,f)
                assert(index > 0 and index <= #selectable_items, "invalid index")
                
                selectable_items[index].f=f
                
            end,
            press_enter = function(...)
                if selectable_items[curr_index] ~= nil and
                   selectable_items[curr_index].f ~= nil then
                   selectable_items[curr_index].f(...)
                else
                end
            end
        }

  	--[[ umbrella.size = {p.ui_width, p.ui_height} ]]
    }

	--yugi
	if editor_lb == nil or editor_use then  
		function button:on_key_down(key) 
			if input_mode == S_SELECT or p.status ==  "fade_out" then 
				if key == keys.Down then 
					umbrella.press_down()
					return true
				elseif key == keys.Up then 
					umbrella.press_up()
					return true
				elseif key == keys.Return then 
					if curr_index > 0 then 
						umbrella.press_enter()
					end 
                    umbrella.fade_out()
					umbrella:grab_key_focus()
					return true
				end 
			end 
		end 
	end

    local function make_item_ring(w,h,padding)
        local ring = Canvas{ size = { w , h } }
        ring:begin_painting()
        ring:set_source_color( p.text_color )
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
    
    function umbrella.extra.on_focus_in(key) 
		if key then 
			if key == keys.Return then 
				button.on_focus_in(keys.Return)
			else 
				button.on_focus_in()
				umbrella:grab_key_focus()
			end 
		end 
    end
    
    function umbrella.extra.on_focus_out(key) 
		if key then 
			button.on_focus_out(key)
		end
    end
   
    function create()
        --local vars used to create the menu
        local ui_ele = nil
        local txt, s_txt
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
        dropDownMenu:hide()
        
        button.text_font=p.text_font
    	button.text_color=p.text_color
    	button.skin=p.skin
    	button.ui_width=p.ui_width
    	button.ui_height=p.ui_height
        
    	button.label=p.label
    	button.focus_color=p.focus_color
    	button.fill_color=p.button_color
    	button.border_width=p.border_width
    	button.border_corner_radius=p.border_corner_radius
        
        umbrella.size = {button.ui_width,button.ui_height}
        curr_y = p.vert_offset
        
        --For each category
        local prev_item 
        for i = 1, #p.items do
            local item=p.items[i]
            --focus_sel_items[cat] = {}
             
            if item.type == "separator" then
                dropDownMenu:add(
                    Rectangle{
                        x     = p.horz_padding,
                        y     = curr_y,
                        name  = "divider "..i,
                        w     = p.menu_width-2*p.horz_padding,
                        h     = p.separator_thickness,
                        color = txt_color
                    }
                )
                curr_y = curr_y + p.separator_thickness + p.vert_spacing
            elseif item.type == "item" then
                
                --Make the text label for each item
                if p.text_has_shadow then
                s_txt = Text{
                        text  = item.string,
                        font  = p.item_text_font,
                        color = "000000",
                        opacity=255*.5,
                        x     = p.horz_padding+p.horz_spacing - 1,
                        y     = curr_y - 1,
                    }
                    s_txt.anchor_point={0,s_txt.h/2}
                    s_txt.y = s_txt.y+s_txt.h/2
                    dropDownMenu:add(s_txt)
                end
                txt = Text{
                        text  = item.string,
                        font  = p.item_text_font,
                        color = p.item_text_color,
                        x     = p.horz_padding+p.horz_spacing,
                        y     = curr_y,
                    }
                    txt.anchor_point={0,txt.h/2}
                    txt.y = txt.y+txt.h/2
                if item.mstring then 
                    txt.use_markup =true
                    txt.markup = item.mstring
                end 
                dropDownMenu:add(txt)
                
                
                if item.bg then
                    
                    ui_ele = item.bg
                    if i == #p.items and prev_item ~= nil then 
                    	ui_ele.anchor_point = { 0, prev_item.bg.h/2 }
                    	ui_ele.position     = {  0, txt.y }
                    else 
                    	ui_ele.anchor_point = { 0, ui_ele.h/2 }
                    	ui_ele.position     = {  0, txt.y }
                    end 
                    dropDownMenu:add(ui_ele)
                    if editor_lb == nil or editor_use then  
                        function ui_ele:on_button_down()
                            if dropDownMenu.opacity == 0 then return end
                            if item.f then item.f(item.parameter) end
                            button.on_focus_out() 
                        end
                        function ui_ele:on_motion()
                            for _,s_i in ipairs(selectable_items) do
                                s_i.focus.opacity=0
                            end
                            item.focus.opacity=255
                        end
                        ui_ele.reactive=true
                    end
                elseif p.show_ring then
                    ui_ele = make_item_ring(p.menu_width-2*p.horz_spacing,txt.h+10,7)
                    ui_ele.anchor_point = { 0,     ui_ele.h/2 }
                    ui_ele.position     = { 0, 	   txt.y }
                    dropDownMenu:add(ui_ele)
                    if editor_lb == nil or editor_use then  
                        function ui_ele:on_button_down()
                            if dropDownMenu.opacity == 0 then return end
                            if item.f then item.f(item.parameter) end
                            umbrella.fade_out()
                        end
                        function ui_ele:on_motion()
                            for _,s_i in ipairs(selectable_items) do
                                s_i.focus.opacity=0
                            end
                            item.focus.opacity=255
                        end
                        ui_ele.reactive=true
                    end
                else
                    if editor_lb == nil or editor_use then  
                        function txt:on_button_down()
                            if dropDownMenu.opacity == 0 then return end
                            if item.f then item.f(item.parameter) end
                            umbrella.fade_out()
                        end
                        function ui_ele:on_motion()
                            for _,s_i in ipairs(selectable_items) do
                                s_i.focus.opacity=0
                            end
                            item.focus.opacity=255
                        end
                        txt.reactive=true
                    end
                end
                
                if item.focus then
                    ui_ele = item.focus
                else
                    ui_ele = assets(skin_list[p.skin]["button_focus"])
                    ui_ele.size = {p.menu_width-2*p.horz_spacing,txt_h+15}
                    item.focus  = ui_ele
                end
                
                ui_ele.name="focus"
                if i == #p.items and prev_item ~= nil and
                    prev_item.focus ~= nil then
                     
                    ui_ele.anchor_point = {  0, prev_item.focus.h/2 }
                    ui_ele.position     = {  0, txt.y }
                else 
                    ui_ele.anchor_point = {  0, ui_ele.h/2 }
                    ui_ele.position     = {  0, txt.y }
                end 
                --ui_ele.anchor_point = { 0, ui_ele.h/2 }
                --ui_ele.position     = { 0, txt.y }
                ui_ele.opacity      = 0
                if ui_ele.parent then ui_ele:unparent() end
                dropDownMenu:add(ui_ele)
                table.insert(selectable_items,item)
                
                if item.icon then
                    ui_ele = item.icon
                    if ui_ele.parent then ui_ele:unparent() end
                    ui_ele.anchor_point = {ui_ele.w,ui_ele.h/2}
                    ui_ele.position={
                            p.menu_width + 10 , txt.y
                    }
                    dropDownMenu:add(ui_ele)
                end
                
                if p.text_has_shadow then
                    s_txt:raise_to_top()
                end
                txt:raise_to_top()
                if item.bg then
                    curr_y = curr_y + item.bg.h + p.vert_spacing
                else
                    curr_y = curr_y + txt.h
                end
            elseif item.type == "label" then
                if p.text_has_shadow then
                s_txt = Text{
                        text  = item.string,
                        font  = p.label_text_font,
                        color = "000000",
                        opacity=255*.5,
                        x     = p.horz_spacing-1,
                        y     = curr_y-1,
                    }
                s_txt.anchor_point={0,s_txt.h/2}
                s_txt.y = s_txt.y+s_txt.h/2
                dropDownMenu:add(
                    s_txt
                )
                end
                txt = Text{
                        text  = item.string,
                        font  = p.label_text_font,
                        color = p.label_text_color,
                        x     = p.horz_spacing,
                        y     = curr_y,
                    }
              txt.anchor_point={0,txt.h/2}
                    txt.y = txt.y+txt.h/2
                dropDownMenu:add(
                    txt
                )
                if item.bg then
                    ui_ele = item.bg
                    
                    ui_ele.anchor_point = { 0,     ui_ele.h/2 }
                    ui_ele.position     = {  0, txt.y }
                    dropDownMenu:add(ui_ele)
                    if p.text_has_shadow then
                        s_txt:raise_to_top()
                    end
                    txt:raise_to_top()
                    curr_y = curr_y + ui_ele.h + p.vert_spacing
                else
                    curr_y = curr_y + txt.h + p.vert_spacing
                end
                
                
            else
                print("Invalid type in the item list. Type: ",item.type)
            end
	    prev_item = item
        end
        
        if p.background_color[4] ~= 0 then
            ui_ele = make_dropdown(
                { p.menu_width , curr_y } ,
                p.background_color
            )
            
            dropDownMenu:add(ui_ele)
            ui_ele:lower_to_bottom()
            
            dropDownMenu.anchor_point = {ui_ele.w/2,ui_ele.h/2}
            if p.expansion_location == "above" then
                ui_ele.x_rotation={180,0,0}
                ui_ele.y = ui_ele.h+p.vert_offset
                dropDownMenu.position     = {ui_ele.w/2,-ui_ele.h/2-p.vert_offset}
            else
                dropDownMenu.position     = {ui_ele.w/2,ui_ele.h/2}
            end
        else
            dropDownMenu.anchor_point = {p.menu_width/2,0}
            if p.expansion_location == "above" then
                dropDownMenu.position     = {p.menu_width/2,-curr_y/2-p.vert_offset}
            else
                dropDownMenu.position     = {0,p.vert_offset}
            end
        end
        button.reactive=true
       
	if editor_lb == nil or editor_use then  
		button.pressed = function() umbrella.fade_in() end 
		button.released = function() umbrella.fade_out() end 
 	end 
        
        button.position = {button.w/2,button.h/2}
        button.anchor_point = {button.w/2,button.h/2}
        if p.align=="left" then
              dropDownMenu.x = p.menu_width/2
        elseif p.aligh == "middle" then
              dropDownMenu.x = button.w/2
        elseif p.align == "right" then
              dropDownMenu.x = button.w
        else
              error("drop down alignment received an invalid argument: "..p.align)
        end
        
        if p.expansion_location == "above"  then
            dropDownMenu.y = dropDownMenu.y -10
        else
            dropDownMenu.y = dropDownMenu.y + button.h
        end
        
        --dropDownMenu.x = dropDownMenu.x + p.horz_offset
    end
    
    
    create()
    --set the meta table to overwrite the parameters
    mt = {}
    mt.__newindex = function(t,k,v)
		
        p[k] = v
	    if k ~= "selected" then 
        	create()
	    end
		
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
        font  = "DejaVu Sans 26px",
        
        text_font = "DejaVu Sans 26px",
    	text_color = {255,255,255,255}, 
    	text_focus_color = {27,145,27,255}, 	  --"1b911b",
        
    	skin = "default", 
    	ui_width = 150,
    	ui_height = 60, 
        
    	focus_color      = { 27,145, 27,255}, --"1b911b", 
    	focus_fill_color = { 27,145, 27,255}, --"1b911b", 
    	focus_text_color = {255,255,255,255}, --"1b911b", 
    	border_color     = {255,255,255,255}, --"FFFFFF"
    	border_width = 1,
    	border_corner_radius = 12,
        
        tab_labels = {
            "Item 1",
            "Item 2",
            "Item 3",
        },
        tabs = {},
        --tab_align          = "CENTER",
        --label_align        = "CENTER",
        label_padding = 10,
        tab_position = "top",
        
        display_width  = 600,
        display_height = 500,
        tab_spacing = 10,
        --slant_width  = 20,
        border_width =  2,
        --border_color = {255,255,255,255},
        fill_color   = {  0,  0,  0,255},
        label_color  = {255,255,255,255},
        unsel_color  = { 60, 60, 60,255},
		
		arrow_sz     = 15,
		arrow_dist_to_frame = 5,
		arrow_image = nil,

		ui_position = {200,200},
    }
    
	local offset = {}
    local buttons = {}
    
    --overwrite defaults
    if t ~= nil then
		for k, v in pairs (t) do p[k] = v end
    end
    
	local ap = nil
	
    local create
    local current_index = 1
    --local tabs = {}
    local tab_bg = {}
    local tab_focus = {}
	
    local umbrella     = Group{
		
        name="tabBar",
		reactive = true,
		position = p.ui_position, 
        extra={
            
			type="TabBar",
			
            insert_tab = function(self,index)
                
                if index == nil then index = #p.tab_labels + 1 end
                
                table.insert(p.tab_labels,index,"TAB")
                
                table.insert(p.tabs,index,Group{})
                
                create()
                
            end,
			
            remove_tab = function(self,index)
                
				if index == nil then index = #p.tab_labels + 1 end
                
                table.remove(p.tab_labels,index,"TAB")
                
                table.remove(p.tabs,index,Group{})
                
                create()
				
            end,
			
            rename_tab = function(self,index,name)
                assert(index)
                p.tab_labels[index] = name
                
                create()
            end,
            
            move_tab_up = function(self,index)
                if index == 1 then return end
                local temp  = p.tab_labels[i-1]
                p.tab_labels[i-1] = p.tab_labels[i]
                p.tab_labels[i]   = temp
                
                temp      = p.tabs[i-1]
                p.tabs[i-1] = p.tabs[i]
                p.tabs[i]   = temp
                
                create()
            end,
            move_tab_down = function(self,index)
                if index == #p.tab_labels then return end
                local temp  = p.tab_labels[i+1]
                p.tab_labels[i+1] = p.tab_labels[i]
                p.tab_labels[i]   = temp
                
                temp      = p.tabs[i+1]
                p.tabs[i+1] = p.tabs[i]
                p.tabs[i]   = temp
                
                create()
            end,
            
            --switching 'visible tab' functions
            display_tab = function(self,index)
                
				if index < 1 or index > #p.tab_labels then return end
                
				p.tabs[current_index]:hide()
                buttons[current_index].on_focus_out()
				
                current_index = index
				
                p.tabs[current_index]:show()
                buttons[current_index].on_focus_in()
				
				if ap then
					
					ap:pan_to(
						
						buttons[current_index].x+buttons[current_index].w/2,
						buttons[current_index].y+buttons[current_index].h/2
						
					)
					
				end
            end,
			
            previous_tab = function(self)
                if current_index == 1 then return end
                
                self:display_tab(current_index-1)
            end,
			
            next_tab = function(self)
                if current_index == #p.tab_labels then return end
                
                self:display_tab(current_index+1)
            end,
			
			get_tab_group = function(self,index) return p.tabs[index] end,
			
			get_index = function(self) return current_index end,
			
			get_offset = function(self) return self.x+offset.x, self.y+offset.y end
			
        }
		
    }
    
    create = function()
        
        local labels, txt_h, txt_w 
        
		current_index = 1
		
        umbrella:clear()
        tab_bg = {}
        tab_focus = {}
        
        local bg = Rectangle{
            color        = p.fill_color,
            border_color = p.border_color,
            border_width = p.border_width,
            w = p.display_width,
            h = p.display_height,
        }
        
        umbrella:add(bg)
        for i = 1, #p.tab_labels do
            
			editor_use = true
            if p.tabs[i] == nil then
                p.tabs[i] = Group{}
            end

			
			buttons[i] = ui_element.button{
				
				ui_position             = { 0, 0 },
				skin                 = p.skin,
				ui_width             = p.ui_width,
				ui_height            = p.ui_height,
				focus_color          = p.focus_color,
				border_width         = p.border_width,
				border_corner_radius = p.border_corner_radius,
				label                = p.tab_labels[i],
				text_font            = p.font,
				fill_color           = p.unsel_color,
				focus_fill_color     = p.fill_color,
				focus_text_color     = p.focus_text_color,
				pressed              = function () umbrella:display_tab(i) end,
				
			}
			
			--buttons[i].position         = {0,0}
			
            if p.tab_position == "top" then
                buttons[i].x = (p.tab_spacing+buttons[i].w)*(i-1)
                p.tabs[i].y  = buttons[i].h
            else
                p.tabs[i].x  = buttons[i].w
                buttons[i].y = (p.tab_spacing+buttons[i].h)*(i-1)
            end
            umbrella:add(p.tabs[i],buttons[i])
			offset.x = p.tabs[i].x
			offset.y = p.tabs[i].y
			editor_use = false
        end
		
		ap = nil
		
		if p.arrow_image then p.arrow_sz = p.arrow_image.w end
		
		if p.tab_position == "top" and
			(buttons[# buttons].w + buttons[# buttons].x) > p.ui_width then
			
			ap = ui_element.arrowPane{
				visible_w=p.display_width - 2*(p.arrow_sz+p.arrow_dist_to_frame),
				visible_h=buttons[# buttons].h,
				virtual_w=buttons[# buttons].w + buttons[# buttons].x,
				virtual_h=buttons[# buttons].h,
				arrow_color=p.label_color,
				box_width=0,
				dist_per_press=buttons[# buttons].w,
				arrow_sz = p.arrow_sz,
				arrow_dist_to_frame = p.arrow_dist_to_frame,
				arrow_src = p.arrow_image,
			}
			
			ap.x = p.arrow_sz+p.arrow_dist_to_frame
			ap.y = 0
			
			for _,b in ipairs(buttons) do
				
				b:unparent()
				ap.content:add(b)
				
			end
			
			umbrella:add(ap)
			
		elseif (buttons[# buttons].h + buttons[# buttons].y) > p.ui_height then
			
			ap = ui_element.arrowPane{
				visible_w=buttons[# buttons].w,
				visible_h=p.display_height - 2*(p.arrow_sz+p.arrow_dist_to_frame),
				virtual_w=buttons[# buttons].w,
				virtual_h=buttons[# buttons].h + buttons[# buttons].y,
				arrow_color=p.label_color,
				box_width=0,
				dist_per_press=buttons[# buttons].h,
				arrow_sz = p.arrow_sz,
				arrow_dist_to_frame = p.arrow_dist_to_frame,
				arrow_src = p.arrow_image,
			}
			
			ap.x = 0
			ap.y = p.arrow_sz+p.arrow_dist_to_frame
			
			for _,b in ipairs(buttons) do
				
				b:unparent()
				ap.content:add(b)
				
			end
			
			umbrella:add(ap)
			
		end
		
		if ap then
			
		end
		
        if p.tab_position == "top" then
            bg.y = buttons[1].h-p.border_width
        else
            bg.x = buttons[1].w-p.border_width
        end
        
        for i = #p.tab_labels+1, #p.tabs do
            p.tabs[i]  = nil
            --tab_bg[i]  = nil
            buttons[i] = nil
        end
		
		umbrella:display_tab(current_index)
    end
    
    create()
    
    --set the meta table to overwrite the parameters
    setmetatable(umbrella.extra,{
		
		__newindex = function(t,k,v)
			
			p[k] = v
			
			if k ~= "selected" then
				
				create()
				
			end
			
		end,
		
		__index = function(t,k)       return p[k]       end,
		
    })

    return umbrella
end


--[[
old version 

function ui_element.tabBar(t)
    
    --default parameters
    local p = {
        font  = "DejaVu Sans 26px",
        
        
        text_font = "DejaVu Sans 26px",
    	text_color = {255,255,255,255}, 
    	text_focus_color = {27,145,27,255}, 	  --"1b911b",
        
    	skin = "default", 
    	ui_width = 150,
    	ui_height = 60, 
        
    	focus_color = {27,145,27,255}, 	  --"1b911b", 
    	focus_fill_color = {27,145,27,255}, --"1b911b", 
    	focus_text_color = {255,255,255,255}, --"1b911b", 
    	border_color = {255,255,255,255}, --"FFFFFF"
    	border_width = 1,
    	border_corner_radius = 12,
        
        tab_labels = {
            "Item 1",
            "Item 2",
            "Item 3",
        },
        tabs = {},
        --tab_align          = "CENTER",
        --label_align        = "CENTER",
        label_padding = 10,
        tab_position = "top",
        
        display_width  = 600,
        display_height = 500,
        tab_spacing = 10,
        --slant_width  = 20,
        border_width =  2,
        border_color = {255,255,255,255},
        fill_color   = {  0,  0,  0,255},
        label_color  = {255,255,255,255},
        unsel_color  = { 60, 60, 60,255},
    }
    
	local offset = {}
    local buttons = {}
    
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
    
    local create
    local current_index = 1
    --local tabs = {}
    local tab_bg = {}
    local tab_focus = {}
	
    local umbrella     = Group{
		position = {200,200},
        name="TabContainer",
		reactive = true,  
        extra={
            type="TabBar",
            insert_tab = function(self,index)
                
                if index == nil then index = #p.tab_labels + 1 end
                
                table.insert(p.tab_labels,index,"TAB")
                
                table.insert(p.tabs,index,Group{})
                
                create()
                
            end,
            remove_tab = function(self,index)
                if index == nil then index = #p.tab_labels + 1 end
                
                table.remove(p.tab_labels,index,"TAB")
                
                table.remove(p.tabs,index,Group{})
                
                create()
            end,
            rename_tab = function(self,index,name)
                assert(index)
                p.tab_labels[index] = name
                
                create()
            end,
            
            move_tab_up = function(self,index)
                if index == 1 then return end
                local temp  = p.tab_labels[i-1]
                p.tab_labels[i-1] = p.tab_labels[i]
                p.tab_labels[i]   = temp
                
                temp      = p.tabs[i-1]
                p.tabs[i-1] = p.tabs[i]
                p.tabs[i]   = temp
                
                create()
            end,
            move_tab_down = function(self,index)
                if index == #p.tab_labels then return end
                local temp  = p.tab_labels[i+1]
                p.tab_labels[i+1] = p.tab_labels[i]
                p.tab_labels[i]   = temp
                
                temp      = p.tabs[i+1]
                p.tabs[i+1] = p.tabs[i]
                p.tabs[i]   = temp
                
                create()
            end,
            
            --switching 'visible tab' functions
            display_tab = function(self,index)
                if index < 1 or index > #p.tab_labels then return end
                p.tabs[current_index]:hide()
				--tab_bg[current_index]:show()
				--tab_focus[current_index]:hide()
                buttons[current_index].on_focus_out()
                current_index = index
                p.tabs[current_index]:show()
                buttons[current_index].on_focus_in()
				--tab_bg[current_index]:hide()
				--tab_focus[current_index]:show()
            end,
            previous_tab = function(self)
                if current_index == 1 then return end
                
                self:display_tab(current_index-1)
            end,
            next_tab = function(self)
                if current_index == #p.tab_labels then return end
                
                self:display_tab(current_index+1)
            end,
			
			get_tab_group = function(self,index)
				return p.tabs[index]
			end,
			get_index = function(self)
				return current_index
			end,
			get_offset = function(self)
				return self.x+offset.x, self.y+offset.y
			end
        }

    }
    
    create = function()
        
        local labels, txt_h, txt_w 
        
		current_index = 1
		
        umbrella:clear()
        tab_bg = {}
        tab_focus = {}
        
        local bg = Rectangle{
            color        = p.fill_color,
            border_color = p.border_color,
            border_width = p.border_width,
            w = p.display_width,
            h = p.display_height,
        }
        
        umbrella:add(bg)
        for i = 1, #p.tab_labels do
            
			editor_use = true
            if p.tabs[i] == nil then
                p.tabs[i] = Group{}
            end
            buttons[i] = ui_element.button()
			p.tabs[i]:hide()
            
            buttons[i].position = {0,0}
            buttons[i].skin=p.skin
            buttons[i].ui_width=p.ui_width
            buttons[i].ui_height=p.ui_height
            
            buttons[i].focus_color=p.focus_color
            buttons[i].border_width=p.border_width
            buttons[i].border_corner_radius=p.border_corner_radius
            
            
            buttons[i].label      = p.tab_labels[i]
            buttons[i].text_font  = p.font
            buttons[i].text_color = p.label_color
            buttons[i].fill_color = p.unsel_color
            buttons[i].focus_fill_color = p.fill_color
            buttons[i].position = {0,0}
            buttons[i].focus_text_color = p.focus_text_color
           	buttons[i].pressed = function () umbrella:display_tab(i) end  
            buttons[i].on_focus_out()
            
            if p.tab_position == "top" then
                buttons[i].x = (p.tab_spacing+buttons[i].w)*(i-1)
                p.tabs[i].y  = buttons[i].h
            else
                p.tabs[i].x  = buttons[i].w
                buttons[i].y = (p.tab_spacing+buttons[i].h)*(i-1)
            end
            umbrella:add(p.tabs[i],buttons[i])
			offset.x = p.tabs[i].x
			offset.y = p.tabs[i].y
			editor_use = false
        end
        if p.tab_position == "top" then
            bg.y = buttons[1].h-p.border_width
        else
            bg.x = buttons[1].w-p.border_width
        end
        
        for i = #p.tab_labels+1, #p.tabs do
            p.tabs[i]  = nil
            --tab_bg[i]  = nil
            buttons[i] = nil
        end
		
		umbrella:display_tab(current_index)
    end
    
    create()
    
    --set the meta table to overwrite the parameters
    mt = {}
    mt.__newindex = function(t,k,v)
        p[k] = v
		if k ~= "selected" then 
        	create()
		end 
    end
    mt.__index = function(t,k)       
       return p[k]
    end
    setmetatable(umbrella.extra, mt)

    return umbrella
end

--]]

--[=[

function ui_element.arrowPane(t)

	-- reference: http://www.csdgn.org/db/179

    --default parameters
    local p = {
        
		visible_w =     600,
        visible_h =     600,
        content   = 	Group{},
        virtual_h =    1000,
		virtual_w =    1000,
        arrow_sz  =      15,
		
        arrow_dist_to_frame = 5,
        arrows_visible =   true,
        arrow_color = {160,160,160,255},
        box_color =   {160,160,160,255},
        box_width =    2,
        skin = "default",
    }
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
	
	--Group that Clips the content
	local window  = Group{name="window"}
	--Group that contains all of the content
	--local content = Group{}
	--declarations for dependencies from scroll_group
	local scroll, scroll_x, scroll_y
	--flag to hold back key presses while animating content group
	local animating = false

	local border = Rectangle{ color = "00000000" }
	
	
	local track_h, track_w, grip_hor, grip_vert, track_hor, track_vert
	
	
	local make_arrow = function()
		
		local c = Canvas{size={p.arrow_sz,p.arrow_sz}}
		
		c:move_to(    0,c.h)
		c:line_to(c.w/2,  0)
		c:line_to(  c.w,c.h)
		c:line_to(    0,c.h)
		
		c:set_source_color( p.arrow_color )
		c:fill(true)
		
		if c.Image then
			c= c:Image()
		end
		
		c.anchor_point={c.w/2,c.h}
		
		return c
		
	end
	
	
    --the umbrella Group, containing the full slate of tiles
    local umbrella = Group{ 
        name     = "arrowPane",
        position = {200,100},
        reactive = true,
        extra    = {
			type = "ArrowPane",
			--tries to place virtual coordinates 'x' and 'y' in the middle of the window
			pan_to = function(self,x,y,top_left)
				
				
				if top_left == true then
					x = x + p.visible_w/2
					y = y + p.visible_h/2
				end
				
				local new_x, new_y
                
				if x > p.virtual_w - p.visible_w/2 then
                    new_x = -p.virtual_w + p.visible_w
                elseif x < p.visible_w/2 then
                    new_x = 0
                else
                    new_x = -x + p.visible_w/2
                end
				
                
                if y > p.virtual_h - p.visible_h/2 then
                    new_y = -p.virtual_h + p.visible_h
                elseif y < p.visible_h/2 then
                    new_y = 0
                else
                    new_y = -y + p.visible_h/2
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
                    
                end
			end,
        }
    }
	umbrella.pan_by = function(self,dx,dy)
		
		self:pan_to(
			-p.content.x + dx,
			-p.content.y + dy,
			true
		)
		
	end
	
	--this function creates the whole scroll bar box
    local hold = false
	local function create()
		
		umbrella:clear()
		
        window.position={ p.box_width, p.box_width }
		window.clip = { 0,0, p.visible_w, p.visible_h }
        border:set{
            w = p.visible_w+2*p.box_width,
            h = p.visible_h+2*p.box_width,
            border_width =    p.box_width,
            border_color =    p.box_color,
        }
		
        
        if p.arrows_visible then
			
			local arrow = make_arrow()
			
			arrow.x = border.w/2
			arrow.y = -p.arrow_dist_to_frame
			
			umbrella:add(arrow)
			
			if editor_lb == nil or editor_use then  
                arrow.on_button_down = function()
                    umbrella:pan_by(0,-10)
                end
                
                arrow.reactive=true
            end
			
			arrow = Clone{source=arrow}
			arrow.anchor_point={arrow.w/2,arrow.h}
			
			arrow.x = border.w+p.arrow_dist_to_frame
			arrow.y = border.h/2
			arrow.z_rotation = {90,0,0}
			umbrella:add(arrow)
			
			if editor_lb == nil or editor_use then  
                arrow.on_button_down = function()
                    umbrella:pan_by(10,0)
                end
                
                arrow.reactive=true
            end
			
			arrow = Clone{source=arrow}
			arrow.anchor_point={arrow.w/2,arrow.h}
			arrow.x = border.w/2
			arrow.y = border.h+p.arrow_dist_to_frame
			arrow.z_rotation = {180,0,0}
			umbrella:add(arrow)
			
			if editor_lb == nil or editor_use then  
                arrow.on_button_down = function()
                    umbrella:pan_by(0,10)
                end
                
                arrow.reactive=true
            end
			
			arrow = Clone{source=arrow}
			arrow.anchor_point={arrow.w/2,arrow.h}
			arrow.x = -p.arrow_dist_to_frame
			arrow.y = border.h/2
			arrow.z_rotation = {270,0,0}
			umbrella:add(arrow)
			
			if editor_lb == nil or editor_use then  
                arrow.on_button_down = function()
                    umbrella:pan_by(-10,0)
                end
                
                arrow.reactive=true
            end
		end
		
        
		umbrella.size = {p.visible_w, p.visible_h}
		umbrella:add(border,window)
	end
	
    
	
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
        	p[k] = v
		elseif k == "selected" then 
        	p[k] = v
		else
        	p[k] = v
        	create()
        end
    end
    mt.__index = function(t,k)       
       return p[k]
    end
    setmetatable(umbrella.extra, mt)

    return umbrella
end
--]=]



function ui_element.arrowPane(t)

	

    --default parameters
    local p = {
        
		visible_w =     600,
        visible_h =     600,
        content   = 	Group{},
        virtual_h =    1000,
		virtual_w =    1000,
        arrow_sz  =      15,
		
		dist_per_press      = 10,
        arrow_dist_to_frame = 5,
        arrows_visible =   true,
        arrow_color = {160,160,160,255},
        box_color =   {160,160,160,255},
        box_width =    2,
        skin = "default",
		ui_position = {200,100},
    }
	
	local make_arrow = function()
		
		local c = Canvas{size={p.arrow_sz,p.arrow_sz}}
		
		c:move_to(    0,c.h)
		c:line_to(c.w/2,  0)
		c:line_to(  c.w,c.h)
		c:line_to(    0,c.h)
		
		c:set_source_color( p.arrow_color )
		c:fill(true)
		
		if c.Image then
			c= c:Image()
		end
		
		c.anchor_point={c.w/2,c.h}
		
		return c
		
	end
	
	p.arrow_src = make_arrow()
    --overwrite defaults
    if t ~= nil then
        for k, v in pairs (t) do
            p[k] = v
        end
    end
	
	--Group that Clips the content
	local window  = Group{name="window"}
	--Group that contains all of the content
	--local content = Group{}
	--declarations for dependencies from scroll_group
	local scroll, scroll_x, scroll_y
	--flag to hold back key presses while animating content group
	local animating = false

	local border = Rectangle{ color = "00000000" }
	
	
	local track_h, track_w, grip_hor, grip_vert, track_hor, track_vert
	
	
	
	
	
    --the umbrella Group, containing the full slate of tiles
    local umbrella = Group{ 
        name     = "arrowPane",
        position = p.ui_position, 
        reactive = true,
        extra    = {
			type = "ArrowPane",
			--tries to place virtual coordinates 'x' and 'y' in the middle of the window
			pan_to = function(self,x,y,top_left)
				
				if top_left == true then
					x = x + p.visible_w/2
					y = y + p.visible_h/2
				end
				
				local new_x, new_y
                
				if x > p.virtual_w - p.visible_w/2 then
                    new_x = -p.virtual_w + p.visible_w
                elseif x < p.visible_w/2 then
                    new_x = 0
                else
                    new_x = -x + p.visible_w/2
                end
				
                
                if y > p.virtual_h - p.visible_h/2 then
                    new_y = -p.virtual_h + p.visible_h
                elseif y < p.visible_h/2 then
                    new_y = 0
                else
                    new_y = -y + p.visible_h/2
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
                    
                end
			end,
        }
    }
	umbrella.pan_by = function(self,dx,dy)
		
		self:pan_to(
			-p.content.x + dx,
			-p.content.y + dy,
			true
		)
		
	end
	
	--this function creates the whole scroll bar box
    local hold = false
	
	
	
	local function create()
		
		umbrella:clear()
		if p.arrow_src.parent then p.arrow_src:unparent() end
		umbrella:add(p.arrow_src)
		p.arrow_src:hide()
		
        window.position={ p.box_width, p.box_width }
		window.clip = { 0,0, p.visible_w, p.visible_h }
        border:set{
            w = p.visible_w+2*p.box_width,
            h = p.visible_h+2*p.box_width,
            border_width =    p.box_width,
            border_color =    p.box_color,
        }
		
        
        if p.arrows_visible then
			
			
			
			if p.visible_h < p.virtual_h then
				arrow = Clone{source=p.arrow_src}
				arrow.x = border.w/2
				arrow.y = -p.arrow_dist_to_frame
				arrow.anchor_point={arrow.w/2,arrow.h}
				
				--arrow.h=p.arrow_sz
				
				arrow.on_button_down = function()
					umbrella:pan_by(0,-p.dist_per_press)
				end
				
				arrow.reactive=true
				umbrella:add(arrow)
				
				arrow = Clone{source=p.arrow_src}
				arrow.anchor_point={arrow.w/2,arrow.h}
				arrow.x = border.w/2
				arrow.y = border.h+p.arrow_dist_to_frame
				arrow.z_rotation = {180,0,0}
				
				
				arrow.on_button_down = function()
					umbrella:pan_by(0,p.dist_per_press)
				end
				
				arrow.reactive=true
				umbrella:add(arrow)
			end

			
			if p.visible_w < p.virtual_w then
				arrow = Clone{source=p.arrow_src}
				arrow.anchor_point={arrow.w/2,arrow.h}
				
				arrow.x = border.w+p.arrow_dist_to_frame
				arrow.y = border.h/2
				arrow.z_rotation = {90,0,0}
				
				
				
				arrow.on_button_down = function()
					umbrella:pan_by(p.dist_per_press,0)
				end
				
				arrow.reactive=true
				
				umbrella:add(arrow)

				arrow = Clone{source=p.arrow_src}
				arrow.anchor_point={arrow.w/2,arrow.h}
				arrow.x = -p.arrow_dist_to_frame
				arrow.y = border.h/2
				arrow.z_rotation = {270,0,0}
				
				
				
				arrow.on_button_down = function()
					umbrella:pan_by(-p.dist_per_press,0)
				end
				
				arrow.reactive=true
				
				umbrella:add(arrow)
			end
			
			
			
		end
		
        
		umbrella.size = {p.visible_w, p.visible_h}
		umbrella:add(border,window)
	end
	
    
	
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
        	p[k] = v
		elseif k == "selected" then 
        	p[k] = v
		else
        	p[k] = v
        	create()
        end
    end
    mt.__index = function(t,k)       
       return p[k]
    end
    setmetatable(umbrella.extra, mt)

    return umbrella
end
--]]


return ui_element
