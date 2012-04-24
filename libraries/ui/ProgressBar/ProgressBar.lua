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
	set_progress(prog) - set the progress of the loading bar (meant to be called in an on_new_frame())
]]


local function draw_c_shell(ui_width, ui_height, empty_top_color, empty_bottom_color, border_color)

	local c_shell = Canvas {
		size = {ui_width,ui_height},
	}
        
    local stroke_width = 2
	local RAD = 6
	local top    = math.ceil(stroke_width/2)
	local left   = math.ceil(stroke_width/2)
	local bottom = c_shell.h - math.ceil(stroke_width/2)
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
	c_shell:add_source_pattern_color_stop( 0 , empty_top_color )
	c_shell:add_source_pattern_color_stop( 1 , empty_bottom_color )
        
	c_shell:fill(true)
	c_shell:set_line_width(   stroke_width )
	c_shell:set_source_color( border_color )
	c_shell:stroke( true )
	c_shell:finish_painting()

    if c_shell.Image then
		c_shell = c_shell:Image()
	end
 
    return c_shell 
end 
        
local function my_draw_c_shell( _ , ... )
    return draw_c_shell( ... )
end


local function draw_c_fill(c_shell_w, c_shell_h, ui_width, ui_height, filled_top_color, filled_bottom_color, progress)

    local stroke_width = 2
	local RAD = 6
	local top    = math.ceil(stroke_width)
	local left   = math.ceil(stroke_width)

	local bottom = c_shell_h - math.ceil(stroke_width)
	local right  = c_shell_w - math.ceil(stroke_width)
        
	local c_fill  = Canvas{ size = {1,ui_height} }  
        
	c_fill:begin_painting()
        
	c_fill:move_to(-1,    top )
	c_fill:line_to( 2,    top )
	c_fill:line_to( 2, bottom )
	c_fill:line_to(-1, bottom )
	c_fill:line_to(-1,    top )
        
	c_fill:set_source_linear_pattern(
		c_shell_w/2,0,
		c_shell_w/2,c_shell_h
	)
	c_fill:add_source_pattern_color_stop( 0 , filled_top_color )
	c_fill:add_source_pattern_color_stop( 1 , filled_bottom_color )
	c_fill:fill(true)
	c_fill:finish_painting()

	if c_fill.Image then
		c_fill = c_fill:Image()
	end

	c_fill.x=stroke_width
    --c_fill.y=stroke_width/2
    c_fill.scale = {(ui_width-4)*(progress),1}
   
	return c_fill
end 

local function my_draw_c_fill( _ , ... )
   	return draw_c_fill( ... )
end


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
        skin                = "Custom", 
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
        	    set_progress = function(prog)
	                c_fill.scale = {(p.ui_width-4)*(prog),1}
					p.progress = prog
        	    end,
	        },
	}
	local function create_loading_bar()

		l_bar_group:clear()

		local key = string.format("cshell:%d:%d:%s:%s:%s", p.ui_width, p.ui_height, color_to_string(p.empty_top_color), 
								   color_to_string(p.empty_bottom_color), color_to_string(p.border_color))

--		c_shell =  assets(key, my_draw_c_shell, p.ui_width, p.ui_height, p.empty_top_color, p.empty_bottom_color, p.border_color)
		c_shell =  draw_c_shell( p.ui_width, p.ui_height, p.empty_top_color, p.empty_bottom_color, p.border_color)

		key = string.format("cshell:%d:%d:%d:%d:%s:%s:%f", c_shell.w, c_shell.h, p.ui_width, p.ui_height, 
							color_to_string(p.filled_top_color), color_to_string(p.filled_bottom_color), p.progress)

--		c_fill  = assets(key, my_draw_c_fill, c_shell.w, c_shell.h, p.ui_width, p.ui_height, p.filled_top_color, p.filled_bottom_color, p.progress)
		c_fill  = draw_c_fill( c_shell.w, c_shell.h, p.ui_width, p.ui_height, p.filled_top_color, p.filled_bottom_color, p.progress)

		l_bar_group:add(c_shell,c_fill) 

	end
    
	create_loading_bar()
    

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