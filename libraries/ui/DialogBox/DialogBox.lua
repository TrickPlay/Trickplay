DIALOGBOX = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV

local function default_bg(self,w,h)
	
	
	local c = Canvas(w,h)
	
	c.line_width = self.style.border.width
	
	round_rectangle(c,self.style.border.corner_radius)
	
	c:set_source_color( self.style.fill_colors.default )     c:fill(true)
	
	c:move_to(       c.line_width/2, self.separator_y or 0 )
	c:line_to( c.w - c.line_width/2, self.separator_y or 0 )
	
	c:set_source_color( self.style.border.colors.default )   c:stroke(true)
	
	return c:Image()
	
end

local default_parameters = {
	w = 400, h = 300, title = "DialogBox", separator_y = 50, reactive = true
}



DialogBox = setmetatable(
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
            
                widget_type = function(instance,env)
                    return function() return "DialogBox" end, nil
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
                image = function(instance,env)
                    return function(oldf,self) return env.image     end,
                    function(oldf,self,v) 
                        
                        if type(v) == "string" then
                            
                            if env.image == nil or env.image.src ~= v then
                                
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
                            
                            error("DialogBox.image expected type 'table'. Received "..type(v),2)
                            
                        end
                        
                    end
                end,
                title = function(instance,env)
                    return function(oldf,self) return env.title.text     end,
                    function(oldf,self,v)             env.title.text = v end
                end,
                separator_y = function(instance,env)
                    return function(oldf,self) return env.separator_y     end,
                    function(oldf,self,v) 
                        env.separator_y = v
                        env.content_group.y = v
                        env.flag_for_redraw = true
                    end
                end,
                children = function(instance,env)
                    return function(oldf) return env.content_group.children     end,
                    function(oldf,self,v) 
                        if type(v) ~= "table" then error("Expected table. Received "..type(v), 2) end
                        env.content_group:clear()
                        
                        if type(v) == "table" then
                            
                            for i,obj in ipairs(v) do
                                
                                if type(obj) == "table" and obj.type then 
                                    
                                    v[i] = _G[obj.type](obj)
                                    
                                elseif type(obj) ~= "userdata" and obj.__types__.actor then 
                                
                                    error("Must be a UIElement or nil. Received "..obj,2) 
                                    
                                end
                                
                            end
                            env.content_group:add(unpack(v))
                            
                        elseif type(v) == "userdata" then
                            
                            env.content_group:add(v)
                            
                        end
                    end
                end,
                attributes = function(instance,env)
                    return function(oldf,self) 
                        local t = oldf(self)
                            
                        t.separator_y = instance.separator_y
                        t.title       = instance.title
                        
                        if (not env.canvas) and env.bg.src and env.bg.src ~= "[canvas]" then 
                            
                            t.image = env.bg.src
                            
                        end
                        
                        t.children = {}
                        
                        for i, child in ipairs(env.content_group.children) do
                            t.children[i] = child.attributes
                        end
                        --[[
                        if content and content.to_json then
                            
                            t.children = 
                            
                        end
                        --]]
                        
                        t.type = "DialogBox"
                        
                        return t
                    end
                end,
                
    
            },
            functions = {
                add    = function(instance,env) return function(oldf,self,...) env.content_group:add(   ...) end end,
                remove = function(instance,env) return function(oldf,self,...) env.content_group:remove(...) end end,
                
                
            },
        },
        
        
        private = {
        
            update_title = function(instance,env)
                return function()
                    
                    local text_style = instance.style.text
                    
                    env.title:set(   text_style:get_table()   )
                    
                    env.title.anchor_point = {0,env.title.h/2}
                    env.title.x            = text_style.x_offset
                    env.title.color        = text_style.colors.default
                    
                    env.center_title()
                end
            end,
            center_title = function(instance,env)
                return function()
                    
                    env.title.w = instance.w
                    env.title.y = instance.style.text.y_offset + env.separator_y/2
                    
                end
            end,
            resize_images = function(instance,env)
                return function()
                    
                    if not env.size_is_set then return end
                    
                    env.bg.w = instance.w
                    env.bg.h = instance.h
                    
                end
            end,
            make_canvas = function(instance,env)
                return function()
                    
                    --env.flag_for_redraw = false
                    
                    env.canvas = true
                    
                    if env.bg then env.bg:unparent() end
                    
                    env.bg = default_bg(instance,env.w,env.h)
                    
                    env.add(instance, env.bg )
                    
                    env.bg:lower_to_bottom()
                    
                    return true
                    
                end
            end,
            setup_image = function(instance,env)
                return function(v)
                    
                    env.canvas = false
                    
                    env.bg = v
                    
                    if env.bg then env.bg:unparent() end
                    
                    env.add(instance, env.bg )
                    
                    env.bg:lower_to_bottom()
                    
                    if instance.is_size_set() then
                        
                        env.resize_images()
                        
                    else
                        --so that the label centers properly
                        instance.size = env.bg.size
                        
                        --instance:reset_size_flag()
                        
                        env.center_title()
                        
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
                    if env.redraw_title then
                        env.redraw_title = false
                        env.update_title()
                    end
                    if env.resize then
                        env.resize = false
                        env.center_title()
                    end
                end
            end,
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            local instance, env = Widget()
            local getter, setter
            
          
            env.style_flags = {
                border = "flag_for_redraw",
                text = {
                    "redraw_title",
                },
                fill_colors = "flag_for_redraw"
            }
            env.title = Text{text="DialogBox"}
            env.content_group = Widget_Group()
            env.bg = nil
            env.separator_y = parameters.separator_y or 100
            env.content_group.y = env.separator_y
            
            env.w = 400
            env.h = 300
            env.canvas = true
            env.redraw_title = true
            env.flag_for_redraw = true
            env.resize = true
            
            env.add( instance, env.content_group, env.border, env.title )
            
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
            dumptable(env.get_children(instance))
            return instance, env
            
        end
    }
)
external.DialogBox = DialogBox