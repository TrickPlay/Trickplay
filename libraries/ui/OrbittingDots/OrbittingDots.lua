ORBITTINGDOTS = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV


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

OrbittingDots = setmetatable(
    {},
    {
        __index = function(self,k)
            
            return getmetatable(self)[k]
            
        end,
        __call = function(self,p)
            
            return self:declare():set(p or {})
            
        end,
        subscriptions = {
        },
        public = {
            properties = {
                image = function(instance,env)
                    return function(oldf) return env.image     end,
                    function(oldf,self,v) 
                        if type(v) == "string" then
                            
                            if env.image == nil or env.image == false or env.image.src ~= v then
                                
                                env.setup_image(Image{ src = v })
                                
                            end
                            
                        elseif type(v) == "userdata" and v.__types__.actor then
                            
                            if v ~= env.image then
                                
                                env.setup_image(v)
                                
                            end
                            
                        elseif v == nil then
                            
                            if not env.canvas then
                                
                                env.flag_for_redraw = true
                                
                                return
                                
                            end
                            
                        else
                            
                            error("OrbittingDots.image expected type 'table'. Received "..type(v),2)
                            
                        end
                        
                    end
                end,
                animating = function(instance,env)
                    return function(oldf) return env.animating     end,
                    function(oldf,self,v) 
                        
                        if type(v) ~= "boolean" then
                            
                            error("OrbittingDots.animating expects type boolean. Received "..type(v),2)
                            
                        elseif env.animating == v then
                            
                            return
                            
                        end
                        
                        env.animating = v
                        
                        if env.animating then
                            env.start_animation = true
                        else
                            env.stop_animation = true
                        end
                    end
                end,
                w = function(instance,env)
                    return function(oldf) return env.w     end,
                    function(oldf,self,v) env.reposition = true env.w = v end
                end,
                width = function(instance,env)
                    return function(oldf) return env.w     end,
                    function(oldf,self,v) env.reposition = true env.w = v end
                end,
                h = function(instance,env)
                    return function(oldf) return env.h     end,
                    function(oldf,self,v) env.reposition = true env.h = v end
                end,
                height = function(instance,env)
                    return function(oldf) return env.h     end,
                    function(oldf,self,v) env.reposition = true env.h = v end
                end,
                size = function(instance,env)
                    return function(oldf) return {env.w,env.h}     end,
                    function(oldf,self,v) 
                        env.reposition = true 
                        env.w = v[1]
                        env.h = v[2]
                    end
                end,
                widget_type = function(instance,env)
                    return function() return "OrbittingDots" end
                end,
                dot_size = function(instance,env)
                    return function(oldf) return env.dot_size     end,
                    function(oldf,self,v) 
                        
                        size_is_set = true
                        
                        env.dot_size = v
                        
                        env.reanchor_clones()
                    end
                end,
                num_dots = function(instance,env)
                    return function(oldf) return env.num     end,
                    function(oldf,self,v) 
                        if v == env.num then return end
                        
                        --if new number is smaller than the previous number
                        if env.num > v then
                            
                            --toss the excess
                            for i = env.num,v+1,-1 do
                                env.clones[i]:unparent()
                                env.clones[i] = nil
                            end
                            
                        --if new number is larger than the previous number
                        else
                            
                            --add more
                            for i = env.num+1,v do
                                env.clones[i] = Clone{
                                    source       = env.image,
                                    anchor_point = {env.dot_size/2,env.dot_size/2},
                                    w            = env.dot_size,
                                    h            = env.dot_size,
                                }
                                env.add( instance, env.clones[i])
                            end
                            
                        end
                        
                        env.num = v
                        
                        env.reposition_clones()
                        
                    end
                end,
                duration = function(instance,env)
                    return function(oldf) return env.load_timeline.duration     end,
                    function(oldf,self,v) 
                        load_timeline.duration = v
                    end
                end,
                duration = function(instance,env)
                    return function(oldf) return env.load_timeline.duration     end,
                    function(oldf,self,v) 
                        load_timeline.duration = v
                    end
                end,
                attributes = function(instance,env)
                    return function(oldf,self) 
                        local t = oldf(self)
                        
                        t.animating = self.animating
                        t.duration = self.duration
                        t.num_dots = instance.num_dots
                        t.dot_size = instance.dot_size
                        
                        if (not env.canvas) and env.image.src and env.image.src ~= "[canvas]" then 
                            
                            t.image = env.image.src
                            
                        end
                        t.type = "OrbittingDots"
                        
                        return t
                    end
                end,
    
            },
            functions = {
            },
        },
        private = {
            reanchor_clones = function(instance,env)
                local rad
                return function() 
                    for i,d in ipairs(env.clones) do
                        d:set{
                            anchor_point = {env.dot_size/2,env.dot_size/2},
                            w            =  env.dot_size,
                            h            =  env.dot_size,
                        }
                    end
                    
                end
            end,
            reposition_clones = function(instance,env)
                local rad
                return function() 
                    for i,d in ipairs(env.clones) do
                        --they're radial position
                        rad = (2*math.pi)/(env.num) * i
                        
                        env.clones[i].position = {
                            math.floor( instance.w/2 * math.cos(rad) )+instance.w/2+env.dot_size/2,
                            math.floor( instance.h/2 * math.sin(rad) )+instance.h/2+env.dot_size/2
                        }
                        
                    end
                end
            end,
            make_canvas = function(instance,env)
                return function() 
		
                    env.canvas = true
                    
                    if env.image then env.image:unparent() end
                    
                    env.image = canvas_dot(instance)
                    
                    env.add( instance, env.image )
                    
                    env.image:hide()
                    
                    for i,d in ipairs(env.clones) do d.source = env.image end
                    
                    return true
                end
            end,
            resize_images = function(instance,env)
                return function() 
                    if not size_is_set then return end
                    
                    env.image.w = instance.w
                    env.image.h = instance.h
                end
            end,
            setup_image = function(instance,env)
                return function(v) 
		
                    env.canvas = false
                    
                    if env.image then env.image:unparent() end
                    
                    env.image = v
                    
                    env.add( instance, v )
                    
                    v:hide()
                    
                    for i,d in ipairs(env.clones) do d.source = env.image end
                    
                    if not instance.is_size_set() then
                        
                        instance.dot_size = env.image.w
                        
                        instance:reset_size_flag()
                        
                    end
                    
                    return true
                end
            end,
            update = function(instance,env)
                return function()
                    if env.flag_for_redraw then
                        env.flag_for_redraw = false
                        if env.canvas then
                            env.make_canvas()
                        else
                            env.resize_images()
                        end
                    end
                    if env.reposition then
                        env.reposition = false
                        env.reposition_clones()
                    end
                    if env.reanimate then
                        env.reanimate = false
                        
                        env.stop_animation = true
                        env.start_animation = true
                        
                    end
                    if  env.stop_animation then
                        env.stop_animation = false
                        env.load_timeline:stop()
                    end
                    if env.start_animation then
                        env.start_animation = false
                        env.load_timeline:start()
                        
                    end
                end
            end,
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local instance, env = Widget()
            
            env.duration  = 1000
            env.image     = false
            env.animating = false
            
            env.dot_size = 20
            env.num = 0
            env.clones = {}
            env.canvas = true
            env.flag_for_redraw = true
            env.load_timeline = Timeline{
                loop =  true,
                on_new_frame = function(tl,ms,p)
                    
                    for i,d in ipairs(env.clones) do
                        d.opacity = 255*((1-p)-i/env.num)
                    end
                end
            }
            env.reposition = true
            env.w = 1
            env.h = 1
            env.style_flags = {
                border      = "flag_for_redraw",
                fill_colors = "flag_for_redraw",
            }
            
            for name,f in pairs(self.private) do
                env[name] = f(instance,env)
            end
            
            for name,f in pairs(self.public.properties) do
                getter, setter = f(instance,env)
                override_property( instance, name,
                    getter, setter
                )
                
            end
            
            for name,f in pairs(self.public.functions) do
                
                override_function( instance, name, f(instance,env) )
                
            end
            
            for t,f in pairs(self.subscriptions) do
                instance:subscribe_to(t,f(instance,env))
            end
            --[[
            for _,f in pairs(self.subscriptions_all) do
                instance:subscribe_to(nil,f(instance,env))
            end
            --]]
            
            --env.subscribe_to_sub_styles()
            
            --instance.images = nil
            env.updating = true
            instance:set(parameters)
            env.updating = false
            
            return instance, env
            
        end
    }
)

ggOrbittingDots = function(parameters)
	
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
	
	local instance, env = Widget( parameters )
	
	
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
		
		env.add( instance, image )
		
		image:hide()
		
		for i,d in ipairs(clones) do d.source = image end
		
	end
	
	local setup_image = function(v)
		
		canvas = false
		
		if image then image:unparent() end
		
		image = v
		
		env.add( instance, image )
		
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
					env.add( instance, clones[i])
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
external.OrbittingDots = OrbittingDots