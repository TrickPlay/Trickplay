SLIDER = true

local external = ({...})[1] or _G
local _ENV     = ({...})[2] or _ENV


local default_parameters = {
    direction = "horizontal",
    --grip  = {w =  80, h = 40,color="666666",border_width=2, border_color="ffffff"},
    --track = {w = 500, h = 40,color="000000",border_width=2, border_color="ffffff"},
    track_w = 400,
    track_h = 30,
    grip_w = 60,
    grip_h = 30,
}



Slider = setmetatable(
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
                end
            end,
        },
        public = {
            properties = {
                enabled = function(instance,env)
                    return function(oldf,...) return oldf(...) end,
                    function(oldf,self,v)
                        oldf(self,v)
                        env.grip.enabled  = v
                        env.track.enabled = v
                    end
                end,
                grip_w = function(instance,env)
                    return function(oldf) return env.grip.w     end,
                    function(oldf,self,v)        env.grip.w = v 
                        env.resized = true
                    end
                end,
                grip_h = function(instance,env)
                    return function(oldf) return env.grip.h     end,
                    function(oldf,self,v)        env.grip.h = v 
                        env.resized = true
                    end
                end,
                track_w = function(instance,env)
                    return function(oldf) return env.track.w     end,
                    function(oldf,self,v)        env.track.w = v 
                        env.resized = true
                    end
                end,
                track_h = function(instance,env)
                    return function(oldf) return env.track.h     end,
                    function(oldf,self,v)        env.track.h = v 
                        env.resized = true
                    end
                end,
                direction = function(instance,env)
                    return function(oldf) return env.direction     end,
                    function(oldf,self,v) 
                        
                        if v == "horizontal" then
                            env.direction_pos = "x"
                            env.direction_num =  1 
                            env.direction_dim = "w"
                        elseif v == "vertical" then
                            env.direction_pos = "y"
                            env.direction_num =  2 
                            env.direction_dim = "h"
                        else
                            error("Expected 'horizontal' or 'vertical'. Received "..v,2)
                        end
                        env.direction = v 
                        env.resized = true
                    end
                end,
                progress = function(instance,env)
                    return function(oldf) return env.progress     end,
                    function(oldf,self,v) 
                        print(v)
                        if type(v) ~= "number" then
                            error("Expected number. Received ".. type(v),2)
                        elseif v > 1 or v < 0 then 
                            error("Must be between [0,1]. Received ".. v,2)
                        end
                        env.grip[env.direction_pos] = 
                            v*(env.track[env.direction_dim]-env.grip[env.direction_dim]) + 
                            env.grip[env.direction_dim]/2
                        
                        print(env.direction_pos,env.grip.gid,env.grip[env.direction_pos])
                        
                        env.progress = v 
                    end
                end,
                widget_type = function(instance,env)
                    return function(oldf) return "Slider" end
                end,
                attributes = function(instance,env)
                    return function(oldf,self) 
                        local t = oldf(self)
                        t.direction = instance.direction
                        t.progress  = instance.progress
                        t.grip_w    = instance.grip_w
                        t.grip_h    = instance.grip_h
                        t.track_w   = instance.track_w
                        t.track_h   = instance.track_h
                        
                        t.type = "Slider"
                        
                        return t  
                    end
                end,
            },
            functions = {
            },
        },
        private = {
            drag_horizontal= function(instance,env)
                return function(x,_)
                    env.p = env.p + ( x - env.prev_pos )*env.pixels_to_progress_ratio
                    
                    env.prev_pos = x
                    
                    instance.progress = env.p > 1 and 1 or env.p > 0 and env.p or 0
                end
            end,
            drag_vertical =  function(instance,env)
                return function(_,y)
                    env.p = env.p + ( y - env.prev_pos )*env.pixels_to_progress_ratio
                    
                    env.prev_pos = y
                    
                    instance.progress = env.p > 1 and 1 or env.p > 0 and env.p or 0
                end
            end,
            update = function(instance,env)
                return function()
                    print("\n\nupdate\n\n")
                    if env.resized then
                        env.resized = false
                        print("grip sz1",env.grip.w,env.grip.h)
                        env.grip.x = env.grip.x
                        print("grip sz1.5",env.grip.w,env.grip.h)
                        env.grip.anchor_point = {
                            env.grip.w/2,
                            env.grip.h/2
                        }
                        print("grip ap",env.grip.w,env.grip.h)
                        if env.direction == "horizontal" then
                            local w = env.grip.w/2
                            print("settin x",w*2,env.grip.h)
                            env.grip.x = w
                            print("set x",env.grip.w,env.grip.h)
                            env.grip.y = env.track.h/2
                        elseif env.direction == "vertical" then
                            env.grip.x = env.track.w/2
                            env.grip.y = env.grip.h/2
                        else
                            error("invalid direction",2)
                        end
                    end
                end
            end,
        },
        
        
        declare = function(self,parameters)
            local instance, env = Widget(parameters)
            
            env.grip  = NineSlice{
                name = "grip",
                reactive = true,
                on_button_down = function(self,...)
                    print("here",env.direction_dim)
                    env.pixels_to_progress_ratio = 1/(env.track[env.direction_dim]-env.grip[env.direction_dim])
                    
                    --position_grabbed_from = ({...})[direction_num]
                    env.prev_pos = ({...})[env.direction_num]
                    
                    --this function is called by screen_on_motion
                    env.g_dragging = env["drag_"..env.direction]
                    env.grip:grab_pointer()
                    
                    return true
                end,
                on_motion = function(self,...)
                    return env.g_dragging and env.g_dragging(...)
                end,
                on_button_up = function(self,...)
                    env.grip:ungrab_pointer()
                    env.g_dragging = nil
                    env.p = instance.progress
                end,
            }
            env.track = NineSlice{
                name =  "track", 
                reactive = true,
                on_button_down = function(self,...)
                    
                    env.pixels_to_progress_ratio = 1/(env.track[env.direction_dim]-env.grip[env.direction_dim])
                    
                    env.prev_pos =
                        --the transformed position of the grip
                        env.grip.transformed_position[env.direction_num]*
                        --transformed position value has to be converted to the 1920x1080 scale
                        screen[env.direction_dim]/screen.transformed_size[env.direction_num]+
                        -- transformed position doesn't take anchor point into account
                        env.grip[env.direction_dim]/2 
                    
                    env["drag_"..env.direction](...)
                end,
            }
            
            env.p = 0
            env.progress = 0
            
            env.direction = "horizontal"
            env.direction_pos = "x"
            env.direction_num =  1
            env.direction_dim = "w"
            env.pixels_to_progress_ratio = 1
            env.prev_pos = 0
            
            env.add( instance, env.track, env.grip )
            
            
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
            
            return instance, env
            
            
        end,
    }
)
external.Slider = Slider