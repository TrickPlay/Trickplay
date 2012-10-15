BUTTON = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV




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
    },
    public = {
        properties = {
            enabled = function(instance,_ENV)
                return function(oldf,...) return oldf(...) end, --TODO, nil getter
                function(oldf,self,v)
                    oldf(self,v)
                    if not v then
                        --image
                        dumptable(image_states)
                        if image_states.focus then   image_states.focus.state = "OFF"   end
                        --text
                        label_state.state = "DEFAULT"
                    elseif instance.focused then
                        --image
                        if image_states.focus then   image_states.focus.state = "ON"   end
                        --text
                        label_state.state = "FOCUS"
                    end
                end
            end,
            focused = function(instance,_ENV)
                return nil,
                function(oldf,self,v)
                    oldf(self,v)
                    if not instance.enabled then return end
                    if v then
                        --image
                        if image_states.focus then   image_states.focus.state = "ON"   end
                        --text
                        if label and label_state then   label_state.state = "FOCUS" end
                    else
                        --image
                        if image_states.focus then   image_states.focus.state = "OFF"   end
                        --text
                        if label and label_state then   label_state.state = "DEFAULT" end
                    end
                end
            end,
            images = function(instance,_ENV)
                return function(oldf)
                    
                    return images
                    
                end,
                function(oldf,self,v)
                    
                    return v == nil and make_canvases() or
                        
                        type(v) == "table" and setup_images(v) or
                        
                        error("Button.images expected type 'table'. Received "..type(v),2)
                    
                end
            end,
            widget_type = function(instance,_ENV)
                return function() return "Button" end
            end,
            label = function(instance,_ENV)
                return function(oldf) return label.text     end,
                function(oldf,self,v) label.text = v end
            end,
            on_pressed =  function(instance,_ENV)
                return function(oldf) return on_pressed     end,
                function(oldf,self,v) on_pressed = v end
            end,
            on_released = function(instance,_ENV)
                return function(oldf) return on_released     end,
                function(oldf,self,v) on_released = v end
            end,
            attributes = function(instance,_ENV)
                return function(oldf,self)
                    local t = oldf(self)
                        
                    t.label = self.label
                    
                    if not canvas then
                        
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
            create_canvas = function(instance,_ENV)
                return function(oldf) return create_canvas     end,
                function(oldf,self,v) 
                    
                    create_canvas = v 
                    if canvas then
                        flag_for_redraw = true 
                    end
                end
            end,
            w = function(instance,_ENV)
                return function(oldf) return w     end,
                function(oldf,self,v) flag_for_redraw = true size_is_set = true w = v end
            end,
            width = function(instance,_ENV)
                return function(oldf) return w     end,
                function(oldf,self,v) flag_for_redraw = true size_is_set = true w = v end
            end,
            h = function(instance,_ENV)
                return function(oldf) return h     end,
                function(oldf,self,v) flag_for_redraw = true size_is_set = true h = v end
            end,
            height = function(instance,_ENV)
                return function(oldf) return h     end,
                function(oldf,self,v) flag_for_redraw = true size_is_set = true h = v end
            end,
            size = function(instance,_ENV)
                return function(oldf) return {w,h}     end,
                function(oldf,self,v) 
                    flag_for_redraw = true 
                    size_is_set = true 
                    w = v[1]
                    h = v[2]
                end
            end,
        },
        functions = {
            click = function(instance,_ENV)
                return function(old_function,self)
                    
                    instance:press()
                    
                    dolater( 150, function()   instance:release()   end)
                end
            end,
            press = function(instance,_ENV)
                return function(old_function,self)
                    
                    if pressed then return end
                    
                    pressed = true
                    
                    --image
                    if image_states.activation then  
                        image_states.activation.state = "ON"  
                    end
                    --text
                    label_state.state = "ACTIVATION"
                    --event callback
                    if on_pressed then on_pressed(instance) end
                    
                end
            end,
            release = function(instance,_ENV)
                return function(old_function,self)
                    
                    if not pressed then return end
                    
                    pressed = false
                    
                    --image
                    if image_states.activation then  
                        image_states.activation.state = "OFF"  
                    end
                    --text
                    label_state.state = instance.focused and "FOCUS" or "DEFAULT"
                    --event callback
                    if on_released then on_released(instance) end
                    
                end
            end,
        },
    },
    private = {
            update = function(instance,_ENV)
                return function()
                    
                    if flag_for_redraw then
                        
                        flag_for_redraw = false
                        if canvas then
                            make_canvases()
                        else
                            resize_images()
                        end
                        
                        if not text_style_changed then
                            center_label()
                        end
                    end
                    
                    if text_style_changed then
                        text_style_changed = false
                        update_label()
                        center_label()
                    end
                    if text_color_changed then
                        text_color_changed = false
                        define_label_animation()
                    end
                end
            end,
            define_image_animation = function(instance,_ENV)
                return function(image,state)
                    
                    local prev_state = image_states[state].state
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
            define_label_animation = function(instance,_ENV)
                return function()
                    
                    local label_colors = instance.style.text.colors
                    local prev_state
                    local label = label
                    if label_state then
                        
                        prev_state = label_state.state
                        if  label_state.timeline then
                            label_state.timeline:stop()
                        end
                    end
                    
                    label_state = AnimationState{
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
                    
                    label_state:warp(prev_state or "DEFAULT")
                    
                end
            end,
            center_label = function(instance,_ENV)
                return function()
                    
                    label.w = w
                    label.y = instance.style.text.y_offset + h/2
                end
            end,
            resize_images = function(instance,_ENV)
                return function()
                    
                    if not size_is_set then return end
                    
                    for k,img in pairs(images) do img.w = w end
                    for k,img in pairs(images) do img.h = h end
                    
                    center_label()
                end
            end,
            
            make_canvases = function(instance,_ENV)
                return function()
                    images = {}
                    clear(instance)
                    for _,state in pairs(states) do
                        images[state] = create_canvas(instance,state)
                        add(instance,images[state])
                        if state ~= "default" then
                            image_states[state] = define_image_animation(images[state],state)
                        end
                    end
                    add(instance, label )
                    return true
                    --[[
                    flag_for_redraw = false
                    
                    canvas = true
                    
                    images = {}
                    
                    clear(instance)
                    
                    for _,state in pairs(states) do
                        
                        images[state] = create_canvas(instance,state)
                        add(instance,images[state])
                        if state ~= "default" then
                            image_states[state] = define_image_animation(images[state],state)
                        end
                    end
                    
                    add(instance, label )
                    
                    return true
                    --]]
                end
            end,
            
            setup_images = function(instance,_ENV)
                return function(new_images)
                    
                    canvas = false
                    
                    clear(instance)
                    
                    for _,state in pairs(states) do
                        
                        if new_images[state] then
                            new_images[state] = type(new_images[state] ) == "string" and
                                Image{src=new_images[state]} or new_images[state]
                            
                            add(instance,new_images[state])
                            
                            if state ~= "default" then
                                image_states[state] = define_image_animation(new_images[state],state)
                            end
                            
                        else
                            image_states[state] = {state = "OFF"}
                        end
                        
                    end
                    
                    images = new_images
                    
                    add(instance,label )
                    
                    if size_is_set then
                        
                        resize_images()
                        
                    else
                        --so that the label centers properly
                        instance.size = new_images.default.size
                        
                        instance:reset_size_flag()
                        
                        center_label()
                        
                    end
                    
                    return true
                end
            end,
            
            canvas_callback  = function(instance,_ENV)
                return function()
                    if canvas then
                        make_canvases()
                    end
                end
            end,
            
            update_label  = function(instance,_ENV)
                return function()
                    
                    text_style = instance.style.text
                    
                    label:set(   text_style:get_table()   )
                    
                    label.anchor_point = {0,label.h/2}
                    label.x            = text_style.x_offset
                    label.y            = text_style.y_offset + instance.h/2
                    label.w            = instance.w
                end
            end,
    },
    
    
    declare = function(self,parameters)
        
        parameters = parameters or {}
        
        local instance, _ENV = Widget()
        print("button",_ENV)
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
        
        style_flags = {
            border = "flag_for_redraw",
            text = {
                "text_style_changed",
                colors = "text_color_changed",
            },
            fill_colors = "flag_for_redraw"
        }
        
        
        canvas = true
        --states = states
        pressed = false
        size_is_set = false
        flag_for_redraw = true
        text_color_changed = true
        text_style_changed = true
        --public attributes, set to false if there is no default
        w = 200
        h = 50
        on_focus_in   = false
        on_focus_out  = false
        on_pressed    = false
        on_released   = false
        images        = false
        label         = Text{text = "Button"}
        label_state   = {state = "DEFAULT"}
        --create_canvas = create_canvas
        states = {"default","focus","activation"}

        --default create_canvas function
        create_canvas = function(self,state)
            
            return NineSlice{
                w = self.w,
                h = self.h,
                cells={
                    {
                        Widget_Clone{source = self.style.rounded_corner[state]},
                        Widget_Clone{source = self.style.top_edge[state]},
                        Widget_Clone{source = self.style.rounded_corner[state],z_rotation = {90,0,0}},
                    },
                    {
                        Widget_Clone{source =   self.style.side_edge[state]},
                        Widget_Rectangle{color = self.style.fill_colors[state] },
                        Widget_Clone{source = self.style.side_edge[state],z_rotation = {180,0,0}},
                    },
                    {
                        Widget_Clone{source = self.style.rounded_corner[state],z_rotation = {270,0,0}},
                        Widget_Clone{source = self.style.top_edge[state], z_rotation = {180,0,0}},
                        Widget_Clone{source = self.style.rounded_corner[state],z_rotation = {180,0,0}},
                    },
                }
            }
            
        end
        
        image_states = {}
        for _,state in pairs(states) do
            if state ~= "default" then image_states[state] = {state = "OFF"} end
        end
        
        setup_object(self,instance,_ENV)
        
        updating = true
        instance:set(parameters)
        updating = false
        
        return instance, _ENV
        
    end
})

external.Button = Button
