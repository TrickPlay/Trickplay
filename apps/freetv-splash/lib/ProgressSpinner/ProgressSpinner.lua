PROGRESSSPINNER = true


local canvas_dot = function(self)
	
	local c = Canvas(self.w,self.h)
	
	c.line_width = self.style.border.width
	
	local c1 = self.style.border.colors.default
	local c2 = self.style.fill_colors.default
	c:arc(c.w/2,c.h/2,c.w/2 - c.line_width/2,0,360)
	c:set_source_color(c2)
	c:fill(true)
	c:set_source_color(c1)
	c:stroke()
	
	c:move_to(c.w/2,c.line_width/2)
	c:arc(c.w/2,c.h/2,c.w/2 - c.line_width/2,270,360)
	c:line_to(c.w/2,c.h/2)
	c:line_to(c.w/2,c.line_width/2)
	c:set_source_color(c1)
	c:fill()
	
	c:move_to(c.w/2,c.h - c.line_width/2)
	c:arc(c.w/2,c.h/2,c.w/2 - c.line_width/2,90,180)
	c:line_to(c.w/2,c.h/2)
	c:line_to(c.w/2,c.h - c.line_width/2)
	c:fill()
	
	return c:Image()
	
end

local default_parameters = {w = 100, h = 100, duration = 2000}

ProgressSpinner = function(parameters)
	
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("ProgressSpinner",parameters)
	
	local canvas = type(parameters.image) == "nil"
	local flag_for_redraw = false --ensure at most one canvas redraw from Button:set()
	local size_is_set = -- an ugly flag that is used to determine if the user set the Button size themselves yet
		parameters.h or
		parameters.w or
		parameters.height or
		parameters.width or
		parameters.size
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
	----------------------------------------------------------------------------
	--The Button Object inherits from Widget
	
	local instance = Widget( parameters )
	
	--the default w and h does not count as setting the size
	if not size_is_set then instance:reset_size_flag() end
	
	
	local duration, image, animating
	
	----------------------------------------------------------------------------
	-- helper functions used when Button.images is set
	
	local make_canvas = function()
		
		canvas = true
		
		if image then image:unparent() end
		
		image = canvas_dot(instance)
		
		instance:add( image )
		
		image:move_anchor_point(image.w/2,image.h/2)
		image:move_by(image.w/2,image.h/2)
		
		return true
		
	end
	
	local function resize_images()
		
		if not size_is_set then return end
		
		image.w = instance.w
		image.h = instance.h
		
	end
	
	local setup_image = function(v)
		
		canvas = false
		
		if image then image:unparent() end
		
		image = v
		
		instance:add( image )
		
		image:move_anchor_point(image.w/2,image.h/2)
		image:move_by(image.w/2,image.h/2)
		
		if instance.is_size_set() then
			
			resize_images()
			
		else
			
			--so that the label centers properly
			instance.size = image.size
			
			instance:reset_size_flag()
			
		end
		
		return true
		
	end
	
	----------------------------------------------------------------------------
	--functions pertaining to getting and setting of attributes
	
	override_property(instance,"image",
		
		function(oldf)    return image   end,
		
		function(oldf,self,v)
			
			return v == nil and make_canvas() or
				
				type(v) == "string" and setup_image( Image{ src = v } ) or
				
				type(v) == "userdata" and v.__types__.actor and setup_image(v) or
				
				error("ProgressSpinner.image expected type 'table'. Received "..type(v),2)
			
		end
	)
	
	----------------------------------------------------------------------------
	
	override_property(instance,"widget_type",
		function() return "ProgressSpinner" end, nil
	)
    
	override_property(instance,"duration",
		function(oldf) return duration     end,
		function(oldf,self,v) duration = v end
	)
	
	override_property(instance,"animating",
		function(oldf) return animating     end,
		function(oldf,self,v)
			
			if type(v) ~= "boolean" then
			elseif animating == v then
				
				return
				
			end
			
			animating = v
			
			if animating then
				
				image:animate{
					duration   = duration,
					z_rotation = 360,
					loop       = true,
				}
				
			else
				image:stop_animation()
				image.z_rotation = {0,0,0}
			end
		end
	)
	
	----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.animating = self.animating
            t.duration = self.duration
            
            if (not canvas) and image.src and image.src ~= "[canvas]" then 
                
                t.image = image.src
                
            end
            t.type = "ProgressSpinner"
            
            return t
        end
    )
    
	----------------------------------------------------------------------------
    
	instance:subscribe_to(
		{"h","w","width","height","size"},
		function()   flag_for_redraw = true   end
	)
	instance:subscribe_to(
		{"duration","image"},
		function()
			if animating then
				
				instance.animating = false
				
				instance.animating = true
				
			end
		end
	)
	
	local canvas_callback = function() return canvas and make_canvas()   end
	
	instance:subscribe_to(
		nil,
		function()
			
			if flag_for_redraw then
				flag_for_redraw = false
				if canvas then
					canvas_callback()
				else
					resize_images()
				end
			end
			
		end
	)
	
	local instance_on_style_changed
    function instance_on_style_changed()
        
        instance.style.border:subscribe_to(      nil, canvas_callback )
        instance.style.fill_colors:subscribe_to( nil, canvas_callback )
        
		canvas_callback()
	end
	
	instance:subscribe_to( "style", instance_on_style_changed )
	
	instance_on_style_changed()
	
	----------------------------------------------------------------------------
	
	instance.duration  = parameters.duration
	instance.image     = parameters.image
	instance.animating = parameters.animating
	
	return instance
	
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
 
 --[[
function ui_element.progressSpinner(t) 
    --default parameters
    local p = {
        skin          = "Custom",
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
    local load_timeline

    --function used to remake the dots upon a parameter change
    create_dots = function()

        l_dots:clear()
        dots = {}
        
        if p.style == "orbitting" then
        
        	local rad, key
        
        	for i = 1, p.number_of_dots do
            	--they're radial position
            	rad = (2*math.pi)/(p.number_of_dots) * i
            	if p.skin == "Custom" then -- skin_list[p.skin]["loadingdot"] == nil then
					key = string.format("dot:%d:%s", p.dot_diameter, color_to_string(p.dot_color))
					dots[i] = assets(key, my_make_dot, p.dot_diameter, p.dot_color)
	        	else		        
		        	dots[i] = assets(skin_list[p.skin]["loadingdot"])
                	dots[i].size={p.dot_diameter, p.dot_diameter}
					dots[i].anchor_point = {
                		dots[i].w/2,
                    	dots[i].h/2
                	}
            	end

				dots[i].position = {
                	math.floor( p.overall_diameter/2 * math.cos(rad) )+p.overall_diameter/2+p.dot_diameter/2,
                	math.floor( p.overall_diameter/2 * math.sin(rad) )+p.overall_diameter/2+p.dot_diameter/2
            	}

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

        else -- spinning 

			local img, key

			if p.skin == "Custom" then 
				key = string.format("big_dot:%d:%s", p.overall_diameter, color_to_string(p.dot_color))
            	img = assets(key, my_make_big_dot, p.overall_diameter, p.dot_color)
            	img.anchor_point={img.w/2,img.h/2}
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