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
            widget_type = function(instance,_ENV)
                return function() return "Button" end
            end,
            label = function(instance,_ENV)
                return function(oldf) return label.text     end,
                function(oldf,self,v) 
                    label.text = v 
                    flag_for_resize = true 
                    if v ~= "" and label.parent == nil then
                        add(instance,label)
                    elseif v == "" and label.parent ~= nil then
                        v:unparent()
                    end
                end
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
                    
                    t.type = "Button"
                    
                    return t
                end
            end,
            create_canvas = function(instance,_ENV)
                return function(oldf) return create_canvas     end,
                function(oldf,self,v) 
                    
                    create_canvas = v 
                    flag_for_redraw = true
                end
            end,
            w = function(instance,_ENV)
                return function(oldf,self) return w_set_to or oldf(self)    end,
                function(oldf,self,v) flag_for_resize = true w_set_to = v oldf(self,v) end
            end,
            width = function(instance,_ENV)
                return function(oldf,self) return w_set_to or oldf(self)    end,
                function(oldf,self,v) flag_for_resize = true w_set_to = v oldf(self,v) end
            end,
            h = function(instance,_ENV)
                return function(oldf,self) return h_set_to or oldf(self)    end,
                function(oldf,self,v) flag_for_resize = true h_set_to = v oldf(self,v) end
            end,
            height = function(instance,_ENV)
                return function(oldf,self) return h_set_to or oldf(self)    end,
                function(oldf,self,v) flag_for_resize = true h_set_to = v oldf(self,v) end
            end,
            size = function(instance,_ENV)
                return function(oldf,self) return {self.w,self.h}     end,
                function(oldf,self,v) 
                    flag_for_resize = true 
                    w_set_to = v[1]
                    h_set_to = v[2]
                    oldf(self,v)
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
                        
                        
                        images = {}
                        clear(instance)
                        for _,state in pairs(states) do
                            images[state] = create_canvas(instance,state)
                            add(instance,images[state])
                            if state ~= "default" then
                                image_states[state] = define_image_animation(images[state],state)
                            end
                        end
                        if label.text ~= "" then
                            add(instance, label )
                        end
                        
                        flag_for_resize = true
                    end
                    if text_style_changed then
                        text_style_changed = false
                        label:set(   instance.style.text:get_table()   )
                        center_label()
                    end
                    if text_color_changed then
                        text_color_changed = false
                        define_label_animation()
                    end
                    if flag_for_resize then
                        flag_for_resize = false
                        if w_set_to then
                            label.w = w_set_to
                            for state,image in pairs(images) do
                                image.w = w_set_to
                            end
                        elseif label.text ~= "" then
                            for state,image in pairs(images) do
                                image.w = label.w + (image.borders and image.borders[1]+image.borders[2] or 0)
                            end
                        end
                        if h_set_to then
                            label.h = h_set_to
                            for state,image in pairs(images) do
                                image.h = h_set_to
                            end
                        elseif label.text ~= "" then
                            for state,image in pairs(images) do
                                image.h = label.h + (image.borders and image.borders[3]+image.borders[4] or 0)
                            end
                        end
                        center_label()
                    end
                    print("set to",w_set_to,h_set_to)
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
                    
                    label.anchor_point = {0,0}
                    if w_set_to then 
                        label.w = w_set_to 
                    end
                    
                    print("center label",label.text,w_set_to,h_set_to)
                    label.x = instance.style.text.x_offset + (w_set_to and (w_set_to/2) or 
                        (label.w/2 + (images.default.borders and images.default.borders[1] or 0)))
                    
                    label.y = instance.style.text.y_offset + (h_set_to and (h_set_to/2) or 
                        (label.h/2 + (images.default.borders and images.default.borders[3] or 0)))
                    
                    label.anchor_point = {label.w/2,label.h/2}
                end
            end,
    },
    
    
    declare = function(self,parameters)
        
        parameters = parameters or {}
        
        local instance, _ENV = Widget()
        
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
        
        pressed = false
        flag_for_resize = true
        flag_for_redraw = true
        text_color_changed = true
        text_style_changed = true
        --public attributes, set to false if there is no default
        w_set_to = false
        h_set_to = false
        on_focus_in   = false
        on_focus_out  = false
        on_pressed    = false
        on_released   = false
        --images        = false
        label         = Text{text = "Button"}
        label_state   = {state = "DEFAULT"}
        --create_canvas = create_canvas
        states = {"default","focus","activation"}
        --default create_canvas function
        create_canvas = function(self,state)
            --print(state)
            --if type(self.style.fill_colors[state]) == "table" then dumptable(self.style.fill_colors[state]) end
            --[[
            print( state,"\n",
                    self.style[self.widget_type.."/"..state.."/nw.png"],
                    self.style[self.widget_type.."/"..state.."/n.png"],
                    self.style[self.widget_type.."/"..state.."/ne.png"],
                    self.style[self.widget_type.."/"..state.."/w.png"],
                    self.style[self.widget_type.."/"..state.."/c.png"],
                    self.style[self.widget_type.."/"..state.."/e.png"],
                    self.style[self.widget_type.."/"..state.."/sw.png"],
                    self.style[self.widget_type.."/"..state.."/s.png"],
                    self.style[self.widget_type.."/"..state.."/se.png"]
            )
            --]]
            return NineSlice{
                name   = state,
                w      = self.w,
                h      = self.h,
                sheet  = self.style.spritesheet,
                ids    = {
                    nw = self.style[self.widget_type.."/"..state.."/nw.png"],
                    n  = self.style[self.widget_type.."/"..state.."/n.png"],
                    ne = self.style[self.widget_type.."/"..state.."/ne.png"],
                    w  = self.style[self.widget_type.."/"..state.."/w.png"],
                    c  = self.style[self.widget_type.."/"..state.."/c.png"],
                    e  = self.style[self.widget_type.."/"..state.."/e.png"],
                    sw = self.style[self.widget_type.."/"..state.."/sw.png"],
                    s  = self.style[self.widget_type.."/"..state.."/s.png"],
                    se = self.style[self.widget_type.."/"..state.."/se.png"],
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
