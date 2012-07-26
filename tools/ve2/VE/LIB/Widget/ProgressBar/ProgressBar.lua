PROGRESSBAR = true

local create_fill = function(self)
    
    if self.style.fill_colors.focus_upper and self.style.fill_colors.focus_lower then
        
        local c = Canvas(1,self.h-2*self.style.border.width)
        
        c:rectangle(-1,0,3,c.h )
        c:set_source_linear_pattern(
            0,0,
            0,c.h
        )
        c:add_source_pattern_color_stop( 0 , self.style.fill_colors.focus_upper )
        c:add_source_pattern_color_stop( 1 , self.style.fill_colors.focus_lower )
        c:fill()
        
        return c:Image{name = "fill"} 
        
    else
        
        return Rectangle{name = "fill", size={1,self.h},color=self.style.fill_colors.focus or "ff0000"}
        
    end
    
end

local create_shell = function(self)
    
	local c = Canvas(self.w,self.h)
	
	c.line_width = self.style.border.width
	
	round_rectangle(c,self.style.border.corner_radius)
    
    if self.style.fill_colors.default_upper and self.style.border.colors.default_lower then
        
        c:set_source_linear_pattern(
            0,0,
            0,c.h
        )
        c:add_source_pattern_color_stop( 0 , self.style.fill_colors.default_upper )
        c:add_source_pattern_color_stop( 1 , self.style.fill_colors.default_lower )
        
        c:fill(true)
        
    else
        
        c:set_source_color( self.style.fill_colors.default or "000000" )
        
        c:fill(true)
        
    end
    
    if self.style.border.colors.default_upper and self.style.border.colors.default_lower then
        
        c:set_source_linear_pattern(
            0,0,
            0,c.h
        )
        c:add_source_pattern_color_stop( 0 , self.style.border.colors.default_upper )
        c:add_source_pattern_color_stop( 1 , self.style.border.colors.default_lower )
        
        c:stroke()
        
    else
        
        c:set_source_color( self.style.border.colors.default or "ffffff" )
        
        c:stroke()
        
    end
    
    return c:Image{name = "shell"} 
    
end

local default_parameters = {
    w = 200, 
    h = 50,
    style = {
        fill_colors = {
            default_upper = {  0,  0,  0,255},
            default_lower = {127,127,127,255},
            focus_upper   = {255,  0,  0,255},
            focus_lower   = { 96, 48, 48,255},
        },
        border = { 
            corner_radius = 10,
            colors = { default_upper = "ffffff",default_lower = "444444"}
        }
    }
}

ProgressBar = function(parameters)
    
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("ProgressBar",parameters)
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
    
    local redraw_shell = false
    local redraw_fill  = false
    
	local instance = Widget( parameters )
    local fill, shell
    local progress = 0
    
	----------------------------------------------------------------------------
    
	override_property(instance,"widget_type",
		function() return "ProgressBar" end, nil
	)
    
    local expand_fill = function() 
        fill.w = (shell.w-2*instance.style.border.width)*progress
    end
	override_property(instance,"progress",
		function(oldf) return progress end,
		function(oldf,self,v)  
            
            progress = v
            
            if fill then expand_fill() end
            
        end 
	)
    
	----------------------------------------------------------------------------
	
	instance:subscribe_to(
		{"h","w","width","height","size"},
		function()
			redraw_shell = true 
            redraw_fill  = true 
		end
	)
	instance:subscribe_to(
		nil,
		function()
			if redraw_shell then 
                if shell then shell:unparent() end
                redraw_shell = false
                shell = create_shell(instance)
                instance:add(shell)
                shell:lower_to_bottom()
            end
            if redraw_fill then
                if fill then fill:unparent() end
                redraw_fill = false
                fill = create_fill(instance)
                instance:add(fill)
                
                fill.x = instance.style.border.width
                fill.y = instance.style.border.width
                
                expand_fill()
            end
		end
	)
    
	----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.progress = self.progress
            
            t.type = "ProgressBar"
            
            return t
        end
    )
    
	----------------------------------------------------------------------------
    
    local set_redraw_shell = function() redraw_shell = true end
    local set_redraw_both  = function() redraw_shell = true redraw_fill  = true end
    
    
	local instance_on_style_changed
    function instance_on_style_changed()
        
        instance.style.border:subscribe_to(      nil, set_redraw_shell )
        instance.style.fill_colors:subscribe_to( nil, set_redraw_both )
        
		set_redraw_both()
	end
	
	instance:subscribe_to( "style", instance_on_style_changed )
	
	instance_on_style_changed()
	
	----------------------------------------------------------------------------
	
	redraw_shell = true 
    redraw_fill  = true 
	instance:set(parameters)
	
	return instance
    
end


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

--[[
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
--]]