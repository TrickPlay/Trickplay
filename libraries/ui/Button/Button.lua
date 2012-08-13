BUTTON = true


local states = {"default","focus","activation"}

--default create_canvas function
local create_canvas = function(self,state)
	print("cc",self.w,self.h)
	local c = Canvas(self.w,self.h)
	
	c.line_width = self.style.border.width
	
	round_rectangle(c,self.style.border.corner_radius)
	
	c:set_source_color( self.style.fill_colors[state] or self.style.fill_colors.default )     c:fill(true)
	
	c:set_source_color( self.style.border.colors[state] or self.style.border.colors.default )   c:stroke(true)
	
	return c:Image()
	
end

Button = setmetatable(
    {},
    {
    __index = function(self,k)
        
        return getmetatable(self)[k]
        
    end,
    __call = function(self,p)
        
        return self:declare():set(p or {})
        
    end,
    subscriptions = {
        ["style"] = function(instance,env)
            return function()
                
                instance.style.border:subscribe_to( nil, function()
                    if env.canvas then 
                        env.flag_for_redraw = true 
                        env.update(instance)
                    end
                end )
                instance.style.fill_colors:subscribe_to( nil, function()
                    if env.canvas then 
                        env.flag_for_redraw = true 
                        env.update(instance)
                    end
                end )
                instance.style.text.colors:subscribe_to( nil, function()
                    env.text_color_changed = true 
                        env.update(instance)
                end )
                instance.style.text:subscribe_to( nil, function()
                    env.text_style_changed = true 
                        env.update(instance)
                end )
                if env.canvas then 
                    env.flag_for_redraw = true 
                end
                env.text_style_changed = true
                env.text_color_changed = true 
                instance:notify()
            end
        end,
    },
    public = {
        properties = {
            enabled = function(instance,env)
                return function(oldf,...) return oldf(...) end,
                function(oldf,self,v)
                    oldf(self,v)
                    if not v then
                        --image
                        dumptable(env.image_states)
                        if env.image_states.focus then   env.image_states.focus.state = "OFF"   end
                        --text
                        env.label_state.state = "DEFAULT"
                    elseif instance.focused then
                        --image
                        if env.image_states.focus then   env.image_states.focus.state = "ON"   end
                        --text
                        env.label_state.state = "FOCUS"
                        --event callback
                        if env.on_focus_in then env.on_focus_in() end
                    end
                end
            end,
            focused = function(instance,env)
                return function(oldf,...) return oldf(...) end,
                function(oldf,self,v)
                    oldf(self,v)
                    if not instance.enabled then return end
                    if v then
                        --image
                        if env.image_states.focus then   env.image_states.focus.state = "ON"   end
                        --text
                        if env.label and env.label_state then   env.label_state.state = "FOCUS" end
                        --event callback
                        if env.on_focus_in then env.on_focus_in() end
                    else
                        --image
                        if env.image_states.focus then   env.image_states.focus.state = "OFF"   end
                        --text
                        if env.label and env.label_state then   env.label_state.state = "DEFAULT" end
                        --event callback
                        if env.on_focus_out then env.on_focus_out() end
                    end
                end
            end,
            images = function(instance,env)
                return function(oldf)
                    
                    return env.images
                    
                end,
                function(oldf,self,v)
                    
                    return v == nil and env.make_canvases() or
                        
                        type(v) == "table" and env.setup_images(v) or
                        
                        error("Button.images expected type 'table'. Received "..type(v),2)
                    
                end
            end,
            widget_type = function(instance,env)
                return function() return "Button" end
            end,
            label = function(instance,env)
                return function(oldf) return env.label.text     end,
                function(oldf,self,v) env.label.text = v end
            end,
            on_pressed =  function(instance,env)
                return function(oldf) return env.on_pressed     end,
                function(oldf,self,v) env.on_pressed = v end
            end,
            on_released = function(instance,env)
                return function(oldf) return env.on_released     end,
                function(oldf,self,v) env.on_released = v end
            end,
            attributes = function(instance,env)
                return function(oldf,self)
                    local t = oldf(self)
                        
                    t.label = self.label
                    
                    if not env.canvas then
                        
                        t.images = {}
                        
                        for state, img in pairs(self.images) do
                            
                            while img.source do img = img.source end
                            
                            if img.src and img.src ~= "[canvas]" then t.images[state] = img.src end
                        end
                        
                    end
                    
                    t.type = "Button"
                    
                    return t
                end
            end,
            create_canvas = function(instance,env)
                return function(oldf) return env.create_canvas     end,
                function(oldf,self,v) env.flag_for_redraw = true env.create_canvas = v end
            end,
            w = function(instance,env)
                return function(oldf) return env.w     end,
                function(oldf,self,v) env.flag_for_redraw = true env.size_is_set = true env.w = v end
            end,
            width = function(instance,env)
                return function(oldf) return env.w     end,
                function(oldf,self,v) env.flag_for_redraw = true env.size_is_set = true env.w = v end
            end,
            h = function(instance,env)
                return function(oldf) return env.h     end,
                function(oldf,self,v) env.flag_for_redraw = true env.size_is_set = true env.h = v end
            end,
            height = function(instance,env)
                return function(oldf) return env.h     end,
                function(oldf,self,v) env.flag_for_redraw = true env.size_is_set = true env.h = v end
            end,
            size = function(instance,env)
                return function(oldf) return {env.w,env.h}     end,
                function(oldf,self,v) 
                    env.flag_for_redraw = true 
                    env.size_is_set = true 
                    env.w = v[1]
                    env.h = v[2]
                end
            end,
        },
        functions = {
            click = function(instance,env)
                return function(old_function,self)
                    
                    instance:press()
                    
                    dolater( 150, function()   instance:release()   end)
                end
            end,
            press = function(instance,env)
                return function(old_function,self)
                    
                    if env.pressed then return end
                    
                    env.pressed = true
                    
                    --image
                    if env.image_states.activation then  
                        env.image_states.activation.state = "ON"  
                    end
                    --text
                    env.label_state.state = "ACTIVATION"
                    --event callback
                    if env.on_pressed then env.on_pressed() end
                    
                end
            end,
            release = function(instance,env)
                return function(old_function,self)
                    
                    if not env.pressed then return end
                    
                    env.pressed = false
                    
                    --image
                    if env.image_states.activation then  
                        env.image_states.activation.state = "OFF"  
                    end
                    --text
                    env.label_state.state = env.focused and "FOCUS" or "DEFAULT"
                    --event callback
                    if env.on_released then env.on_released() end
                    
                end
            end,
        },
    },
    private = {
            update = function(instance,env)
                return function()
                    
                    if env.flag_for_redraw then
                        
                        env.flag_for_redraw = false
                        if env.canvas then
                            env.make_canvases()
                        else
                            env.resize_images()
                        end
                        
                        if not env.text_style_changed then
                            env.center_label()
                        end
                    end
                    
                    if env.text_style_changed then
                        env.text_style_changed = false
                        env.update_label()
                        env.center_label()
                    end
                    if env.text_color_changed then
                        env.text_color_changed = false
                        env.define_label_animation()
                    end
                end
            end,
            define_image_animation = function(instance,env)
                return function(image,state)
                    
                    local prev_state = env.image_states[state].state
                    local a = AnimationState{
                        duration    = 100,
                        transitions = {
                            {
                                source = "*", target = "OFF",
                                keys   = {  {image, "opacity",  0},  },
                            },
                            {
                                source = "*", target = "ON",
                                keys   = {  {image, "opacity",255},  },
                            },
                        }
                    }
                    
                    a:warp(prev_state or "OFF")
                    
                    return a
                end
            end,
            define_label_animation = function(instance,env)
                return function()
                    
                    local label_colors = instance.style.text.colors
                    local prev_state
                    local label = env.label
                    if env.label_state then
                        
                        prev_state = env.label_state.state
                        if  env.label_state.timeline then
                            env.label_state.timeline:stop()
                        end
                    end
                    
                    env.label_state = AnimationState{
                        duration    = 100,
                        transitions = {
                            {
                                source = "*",  target = "DEFAULT",
                                keys   = {  {label, "color",label_colors.default},  },
                            },
                            {
                                source = "*",  target = "FOCUS",
                                keys   = {  {label, "color",label_colors.focus},  },
                            },
                            {
                                source = "*",  target = "ACTIVATION",
                                keys   = {  {label, "color",label_colors.activation},  },
                            },
                        }
                    }
                    
                    env.label_state:warp(prev_state or "DEFAULT")
                    
                end
            end,
            center_label = function(instance,env)
                return function()
                    
                    env.label.w = env.w
                    env.label.y = instance.style.text.y_offset + env.h/2
                end
            end,
            resize_images = function(instance,env)
                return function()
                    
                    if not env.size_is_set then return end
                    
                    for k,img in pairs(env.images) do img.w = env.w end
                    for k,img in pairs(env.images) do img.h = env.h end
                    
                    env.center_label()
                end
            end,
            
            make_canvases = function(instance,env)
                return function()
                    
                    env.flag_for_redraw = false
                    
                    env.canvas = true
                    
                    env.images = {}
                    
                    env.clear(instance)
                    
                    for _,state in pairs(env.states) do
                        
                        env.images[state] = env.create_canvas(instance,state)
                        env.add(instance,env.images[state])
                        if state ~= "default" then
                            env.image_states[state] = env.define_image_animation(env.images[state],state)
                        end
                    end
                    
                    
                    env.add(instance, env.label )
                    
                    return true
                end
            end,
            
            setup_images = function(instance,env)
                return function(new_images)
                    print("setup_images")
                    env.canvas = false
                    
                    env.clear(instance)
                    
                    for _,state in pairs(env.states) do
                        
                        if new_images[state] then
                            new_images[state] = type(new_images[state] ) == "string" and
                                Image{src=new_images[state]} or new_images[state]
                            
                            env.add(instance,new_images[state])
                            
                            if state ~= "default" then
                                env.image_states[state] = env.define_image_animation(new_images[state],state)
                            end
                            
                        else
                            env.image_states[state] = {state = "OFF"}
                        end
                        
                    end
                    
                    env.images = new_images
                    
                    env.add(instance,env.label )
                    
                    if env.size_is_set then
                        
                        env.resize_images()
                        
                    else
                        --so that the label centers properly
                        instance.size = new_images.default.size
                        
                        instance:reset_size_flag()
                        
                        env.center_label()
                        
                    end
                    
                    return true
                end
            end,
            
            canvas_callback  = function(instance,env)
                return function()
                    if env.canvas then
                        env.make_canvases()
                    end
                end
            end,
            
            update_label  = function(instance,env)
                return function()
                    
                    text_style = instance.style.text
                    
                    local label = env.label
                    
                    label:set(   text_style:get_table()   )
                    
                    label.anchor_point = {0,label.h/2}
                    label.x            = text_style.x_offset
                    label.y            = text_style.y_offset + instance.h/2
                    label.w            = instance.w
                end
            end,
    },
    
    
    declare = function(self,parameters)
        local instance, env = Widget()
        ----------------------------------------------------------------------------
        --Key events
        function instance:on_key_focus_in()    instance.focused = true  end 
        function instance:on_key_focus_out()   instance.focused = false end 
        
        instance:add_key_handler(   keys.OK, function() instance:click()   end)
        
        ----------------------------------------------------------------------------
        --Mouse events
        
        function instance:on_enter()        instance.focused = true   end
        function instance:on_leave()        instance.focused = false  instance:release() end 
        function instance:on_button_down()  instance:press()          end
        function instance:on_button_up()    instance:release()        end
        
        
        local getter, setter
        
        env.canvas = true
        env.states = states
        env.pressed = false
        env.size_is_set = false
        env.flag_for_redraw = true
        env.text_color_changed = true
        env.text_style_changed = true
        --public attributes, set to false if there is no default
        env.w = 200
        env.h = 50
        env.on_focus_in   = false
        env.on_focus_out  = false
        env.on_pressed    = false
        env.on_released   = false
        env.images        = false
        env.label         = Text{text = "Button"}
        env.label_state   = {state = "DEFAULT"}
        env.create_canvas = create_canvas
        
        env.image_states = {}
        for _,state in pairs(env.states) do
            if state ~= "default" then env.image_states[state] = {state = "OFF"} end
        end
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
        
        --instance.images = nil
        return instance, env
        
    end
})


