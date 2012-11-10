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
            ["style"] = function(instance,_ENV)
                return function()
                end
            end,
        },
        public = {
            properties = {
                enabled = function(instance,_ENV)
                    return function(oldf,...) return oldf(...) end,
                    function(oldf,self,v)
                        oldf(self,v)
                        grip.enabled  = v
                        track.enabled = v
                    end
                end,
                grip_w = function(instance,_ENV)
                    return function(oldf) return grip.w     end,
                    function(oldf,self,v)        grip.w = v 
                        resized = true
                    end
                end,
                grip_h = function(instance,_ENV)
                    return function(oldf) return grip.h     end,
                    function(oldf,self,v)        grip.h = v 
                        resized = true
                    end
                end,
                track_w = function(instance,_ENV)
                    return function(oldf) return track.w     end,
                    function(oldf,self,v)        track.w = v 
                        resized = true
                    end
                end,
                track_h = function(instance,_ENV)
                    return function(oldf) return track.h     end,
                    function(oldf,self,v)        track.h = v 
                        resized = true
                    end
                end,
                direction = function(instance,_ENV)
                    return function(oldf) return direction     end,
                    function(oldf,self,v) 
                        
                        if v == "horizontal" then
                            direction_pos = "x"
                            direction_num =  1 
                            direction_dim = "w"
                        elseif v == "vertical" then
                            direction_pos = "y"
                            direction_num =  2 
                            direction_dim = "h"
                        else
                            error("Expected 'horizontal' or 'vertical'. Received "..v,2)
                        end
                        direction = v 
                        resized = true
                    end
                end,
                progress = function(instance,_ENV)
                    return function(oldf) return progress     end,
                    function(oldf,self,v) 
                        print(v)
                        if type(v) ~= "number" then
                            error("Expected number. Received ".. type(v),2)
                        elseif v > 1 or v < 0 then 
                            error("Must be between [0,1]. Received ".. v,2)
                        end
                        grip[direction_pos] = 
                            v*(track[direction_dim]-grip[direction_dim]) + 
                            grip[direction_dim]/2
                        
                        print(direction_pos,grip.gid,grip[direction_pos])
                        
                        progress = v 
                    end
                end,
                widget_type = function(instance,_ENV)
                    return function(oldf) return "Slider" end
                end,
                attributes = function(instance,_ENV)
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
            drag_horizontal= function(instance,_ENV)
                return function(x,_)
                    p = p + ( x - prev_pos )*pixels_to_progress_ratio
                    
                    prev_pos = x
                    
                    instance.progress = p > 1 and 1 or p > 0 and p or 0
                end
            end,
            drag_vertical =  function(instance,_ENV)
                return function(_,y)
                    p = p + ( y - prev_pos )*pixels_to_progress_ratio
                    
                    prev_pos = y
                    
                    instance.progress = p > 1 and 1 or p > 0 and p or 0
                end
            end,
            update = function(instance,_ENV)
                return function()
                    --print("\n\nupdate\n\n")
                    if resized then
                        resized = false
                        --print("grip sz1",grip.w,grip.h)
                        grip.x = grip.x
                        --print("grip sz1.5",grip.w,grip.h)
                        grip.anchor_point = {
                            grip.w/2,
                            grip.h/2
                        }
                        --print("grip ap",grip.w,grip.h)
                        if direction == "horizontal" then
                            local w = grip.w/2
                            --print("settin x",w*2,grip.h)
                            grip.x = w
                            --print("set x",grip.w,grip.h)
                            grip.y = track.h/2
                        elseif direction == "vertical" then
                            grip.x = track.w/2
                            grip.y = grip.h/2
                        else
                            error("invalid direction",2)
                        end
                        
                        instance.w = grip.w > track.w and grip.w or track.w
                        instance.h = grip.h > track.h and grip.h or track.h
                    end
                end
            end,
        },
        
        
        declare = function(self,parameters)
            local instance, _ENV = Widget(parameters)
            
            grip  = NineSlice{
                name = "grip",
                reactive = true,
                on_button_down = function(self,...)
                    print("here",direction_dim)
                    pixels_to_progress_ratio = 1/(track[direction_dim]-grip[direction_dim])
                    
                    --position_grabbed_from = ({...})[direction_num]
                    prev_pos = ({...})[direction_num]
                    
                    --this function is called by screen_on_motion
                    g_dragging = _ENV["drag_"..direction]
                    grip:grab_pointer()
                    
                    return true
                end,
                on_motion = function(self,...)
                    return g_dragging and g_dragging(...)
                end,
                on_button_up = function(self,...)
                    grip:ungrab_pointer()
                    g_dragging = nil
                    p = instance.progress
                end,
            }
            track = NineSlice{
                name =  "track", 
                reactive = true,
                on_button_down = function(self,...)
                    
                    pixels_to_progress_ratio = 1/(track[direction_dim]-grip[direction_dim])
                    
                    prev_pos =
                        --the transformed position of the grip
                        grip.transformed_position[direction_num]*
                        --transformed position value has to be converted to the 1920x1080 scale
                        screen[direction_dim]/screen.transformed_size[direction_num]+
                        -- transformed position doesn't take anchor point into account
                        grip[direction_dim]/2 
                    
                    _ENV["drag_"..direction](...)
                end,
            }
            
            p = 0
            progress = 0
            
            direction = "horizontal"
            direction_pos = "x"
            direction_num =  1
            direction_dim = "w"
            pixels_to_progress_ratio = 1
            prev_pos = 0
            
            add( instance, track, grip )
            
            setup_object(self,instance,_ENV)
            
            return instance, _ENV
            
            
        end,
    }
)
external.Slider = Slider