ORBITTINGDOTS = true


local canvas_dot = function(self)
	
	local c = Canvas(self.dot_size,self.dot_size)
	
	c.line_width = self.style.border.width
	
	local c1 = self.style.border.colors.default
	local c2 = self.style.fill_colors.default
	c:arc(c.w/2,c.h/2,c.w/2 - c.line_width/2,0,360)
	c:set_source_color(c2)
	c:fill(true)
	c:set_source_color(c1)
	c:stroke()
	
	
	return c:Image()
	
end

local default_parameters = {w = 100, h = 100, num_dots = 12}

OrbittingDots = function(parameters)
	
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("OrbittingDots",parameters)
	
	local canvas = parameters.image == nil
	local flag_for_redraw = false --ensure at most one canvas redraw from Button:set()
	local size_is_set = parameters.dot_size ~= nil
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
	----------------------------------------------------------------------------
	--The Button Object inherits from Widget
	
	local instance = Widget( parameters )
	
	
	local image
	local dot_size = 20
	local num = 0
	local clones = {}
	local load_timeline = Timeline{
		loop =  true,
		on_new_frame = function(tl,ms,p)
			
			for i,d in ipairs(clones) do
				d.opacity = 255*((1-p)-i/num)
			end
		end
	}
	
	----------------------------------------------------------------------------
	-- helper functions used for the clones
	local rad
	local reposition_clones = function()
		
		for i,d in ipairs(clones) do
			--they're radial position
        	rad = (2*math.pi)/(num) * i
			
			clones[i].position = {
				math.floor( instance.w/2 * math.cos(rad) )+instance.w/2+dot_size/2,
				math.floor( instance.h/2 * math.sin(rad) )+instance.h/2+dot_size/2
			}
        	
		end
		
	end
	instance:subscribe_to(
		{"h","w","width","height","size"},
		reposition_clones
	)
	
	local reanchor_clones = function()
		
		for i,d in ipairs(clones) do
			d:set{
				anchor_point = {dot_size/2,dot_size/2},
				w            = dot_size,
				h            = dot_size,
			}
		end
		
	end
	----------------------------------------------------------------------------
	-- helper functions used when Button.images is set
	
	local make_canvas = function()
		
		canvas = true
		
		if images then image:unparent() end
		
		image = canvas_dot(instance)
		
		instance:add( image )
		
		image:hide()
		
		for i,d in ipairs(clones) do d.source = image end
		
	end
	
	local setup_image = function(v)
		
		canvas = false
		
		if image then image:unparent() end
		
		image = v
		
		instance:add( image )
		
		image:hide()
		
		for i,d in ipairs(clones) do d.source = image end
		
		if not size_is_set then
			
			--so that the label centers properly
			instance.dot_size = image.w
			
			size_is_set = false
			
		end
	end
	
	override_property(instance,"image",
		
		function(oldf)    return image   end,
		
		function(oldf,self,v)
			
			if type(v) == "string" then
				
				if image == nil or image.src ~= v then
					
					setup_image(Image{ src = v })
					
				end
				
			elseif type(v) == "userdata" and v.__types__.actor then
				
				if v ~= image then
					
					setup_image(v)
					
				end
				
			elseif v == nil then
				
				if not canvas then
					
					flag_for_redraw = true
					
					return
					
				end
				
			else
				
				error("ProgressSpinner.image expected type 'table'. Received "..type(v),2)
				
			end
			
		end
	)
	--prevents multiple canvas redraws
	instance:subscribe_to(
		nil,
		function()
			
			if flag_for_redraw then
				
				flag_for_redraw = false
				
				make_canvas()
				
			end
			
		end
	)
	----------------------------------------------------------------------------
	--functions pertaining to getting and setting of attributes
	
	override_property(instance,"widget_type",
		function() return "OrbittingDots" end, nil
	)
    
	override_property(instance,"dot_size",
		
		function(oldf)    return dot_size   end,
		
		function(oldf,self,v)
			
			size_is_set = true
			
			dot_size = v
			
			reanchor_clones()
		end
	)
	
	override_property(instance,"num_dots",
		
		function(oldf)    return num   end,
		
		function(oldf,self,v)
			
			if v == num then return end
			
			--if new number is smaller than the previous number
			if num > v then
				
				--toss the excess
				for i = num,v+1,-1 do
					clones[i]:unparent()
					clones[i] = nil
				end
				
			--if new number is larger than the previous number
			else
				
				--add more
				for i = num+1,v do
					clones[i] = Clone{
						source       = image,
						anchor_point = {dot_size/2,dot_size/2},
						w            = dot_size,
						h            = dot_size,
					}
					instance:add(clones[i])
				end
				
			end
			
			num = v
			
			reposition_clones()
			
		end
	)
	
	----------------------------------------------------------------------------
	
	override_property(instance,"duration",
		function(oldf) return load_timeline.duration     end,
		function(oldf,self,v) load_timeline.duration = v end
	)
    local animating = false
	override_property(instance,"animating",
		function(oldf) return load_timeline.is_playing end,
		function(oldf,self,v)
			
			if type(v) ~= "boolean" then
				
				error("ProgressSpinner.animating expects type boolean. Received "..type(v),2)
				
			elseif animating == v then
				
				return
				
			end
			
			animating = v
			
			if animating then
				
				load_timeline:start()
				
			else
				
				load_timeline:stop()
				
			end
			
		end
	)
	
	----------------------------------------------------------------------------
    
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.animating = self.animating
            t.duration = self.duration
            t.num_dots = instance.num_dots
            t.dot_size = instance.dot_size
            
            if (not canvas) and image.src and image.src ~= "[canvas]" then 
                
                t.image = image.src
                
            end
            t.type = "OrbittingDots"
            
            return t
        end
    )
    
	----------------------------------------------------------------------------
    
	local style_callback = function() if canvas then flag_for_redraw = true end   end
	
	local instance_on_style_changed
    function instance_on_style_changed()
        
        instance.style.border:subscribe_to(      nil, style_callback )
        instance.style.fill_colors:subscribe_to( nil, style_callback )
        
		style_callback()
	end
	
	instance:subscribe_to( "style", instance_on_style_changed )
	
	instance_on_style_changed()
	
	----------------------------------------------------------------------------
	
	instance:set(parameters)
	
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