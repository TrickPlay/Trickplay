
MENUBUTTON = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV


local default_parameters = {
    direction = "down",
    vertical_alignment = "top",
    item_spacing = 0,
    popup_offset = 10,
}

local create_canvas = function(self,state)
	print("mb:cc",self.w,self.h)
	local c = Canvas(self.w,self.h)
	
	c.line_width = self.style.border.width
	
	round_rectangle(c,self.style.border.corner_radius)
	
	c:set_source_color( self.style.fill_colors[state] or "ffffff66" )     c:fill(true)
	
	c:set_source_color( self.style.border.colors[state] or self.style.border.colors.default )   c:stroke(true)
	
	return c:Image()
	
end

MenuButton = setmetatable(
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
                popup_offset = function(instance,env)
                    return function(oldf)  return   instance.vertical_spacing      end,
                    function(oldf,self,v)    instance.vertical_spacing = v end
                end,
                item_spacing = function(instance,env)
                    return function(oldf)  return   env.popup.spacing      end,
                    function(oldf,self,v)    env.popup.spacing = v end
                end,
                horizontal_alignment = function(instance,env)
                    return nil,
                    function(oldf,self,v)  oldf(self,v)  env.popup.horizontal_alignment = v end
                end,
                items = function(instance,env)
                    return function(oldf)  return   env.popup.cells      end,
                    function(oldf,self,v) 
                        
                        if type(v) ~= "table" then error("Expected table. Received: ",2) end
                        
                        local items = {}
                        
                        for i, item in ipairs(v) do
                            
                            if type(item) == "table" and item.type then 
                                
                                item = _G[item.type](item)
                                
                            elseif type(item) ~= "userdata" and item.__types__.actor then 
                            
                                error("Must be a UIElement or nil. Received "..obj,2) 
                                
                            end
                            
                            --items[i] = {item}
                        end
                        
                        env.popup.cells = v
                    end
                end,
                widget_type = function(instance,env)
                    return function(oldf)  return   "MenuButton"      end
                end,
                direction = function(instance,env)
                    return function(oldf)  return   env.direction      end,
                    function(oldf,self,v)
                        if direction == v then return end
                        env.new_direction = v
                    end
                end,
                focused = function(instance,env)
                    return nil,
                    function(oldf,self,v)
                        if not instance.enabled then return end
                        
                        env.button.focused = instance.focused
                        
                    end
                end,
                attributes = function(instance,env)
                    return function(oldf,self)
                        local t = oldf(self)
                        
                        t.number_of_cols       = nil
                        t.number_of_rows       = nil
                        t.vertical_alignment   = nil
                        t.horizontal_alignment = nil
                        t.vertical_spacing     = nil
                        t.horizontal_spacing   = nil
                        t.cell_h               = nil
                        t.cell_w               = nil
                        t.cells                = nil
                        
                        t.style = instance.style
                        
                        t.items = {}
                        
                        for i = 1,env.popup.length do
                            t.items[i] = env.popup.cells[i].attributes
                        end
                        
                        t.direction = instance.direction
                        t.item_spacing = instance.item_spacing
                        t.popup_offset = instance.popup_offset
                        t.horizontal_alignment = instance.horizontal_alignment
                        
                        t.type = "MenuButton"
                        
                        return t    
                    end
                end,
            },
            functions = {
            },
        },
        private = {
            update = function(instance,env)
                local possible_directions = {
                    up    = { {env.popup},{env.button}},
                    down  = {{env.button}, {env.popup}},
                    left  = {{ env.popup,  env.button}},
                    right = {{env.button,   env.popup}},
                }
                return function()
                    
                    if env.new_direction then
                        env.direction = env.new_direction
                        env.new_direction = false
                        
                        instance.number_of_rows = 
                                ((env.direction == "up"   or env.direction == "down")  and 2) or
                                ((env.direction == "left" or env.direction == "right") and 1)
                        instance.number_of_cols = 
                                ((env.direction == "up"   or env.direction == "down")  and 1) or
                                ((env.direction == "left" or env.direction == "right") and 2)
                        instance.cells = possible_directions[env.direction]
                        
                        instance.focus_to_index = {
                            env.direction == "up"   and 2 or 1,
                            env.direction == "left" and 2 or 1
                        }
                        
                        print("here")
                    end
                    if env.restyle_button then
                        env.restyle_button = false
                        local t = instance.style.attributes
                        t.name = nil
                        env.button.style:set(t)
                    end
                    env.old_update()
                end
            end
        },
        declare = function(self,parameters)
            
            parameters = parameters or {}
            
            
            local instance, env = LayoutManager:declare()
            env.button = ToggleButton{
                create_canvas=create_canvas,
                style = false,
                w=300,
                reactive=true, 
                selected = true
            }
            
            env.popup = ListManager{focus_to_index=1}
            env.style_flags = "restyle_button"
            env.old_update = env.update
            env.new_direction  = "down"
            env.button:add_key_handler(   keys.OK, function() env.button:click()   end)
            
            env.old_on_pressed = env.button.on_pressed
            ---[[
            function env.button:on_pressed()
                
                env.old_on_pressed(self)
                
                env.popup[ env.popup.is_visible and "hide" or "show" ](env.popup)
                
                env.popup.enabled = env.popup.is_visible
                
            end
            --]]
            
            for name,f in pairs(self.private) do
                env[name] = f(instance,env)
            end
            
            for name,f in pairs(self.public.properties) do
                
                getter, setter = f(instance,env)
                
                override_property( instance, name, getter, setter )
                
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
            
            env.updating = true
            instance:set(parameters)
            env.updating = false
            
            dumptable(env.get_children(instance))
            return instance, env
            
        end
    }
)
external.MenuButton = MenuButton