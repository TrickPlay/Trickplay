SLIDER = true

local default_parameters = {
    direction = "horizontal",
    grip  = {w =  80, h = 40,color="666666",border_width=2, border_color="ffffff"},
    track = {w = 500, h = 40,color="000000",border_width=2, border_color="ffffff"},
}
Slider = function(parameters)
    
	--input is either nil or a table
	parameters = is_table_or_nil("Slider",parameters) -- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
    
	----------------------------------------------------------------------------
	--The Slider Object inherits from Widget
	
	local instance = Widget(parameters)
    
    local grip, track
    local direction, direction_pos, direction_dim, direction_num 
	----------------------------------------------------------------------------
    
    local pixels_to_progress_ratio
    local prev_pos
    local g_dragging
    
    local p = 0
    local drag = {
        horizontal= function(x,_)
            p = p + ( x - prev_pos )*pixels_to_progress_ratio
            
            prev_pos = x
            
            instance.progress = p > 1 and 1 or p > 0 and p or 0
        end,
        vertical = function(_,y)
            p = p + ( y - prev_pos )*pixels_to_progress_ratio
            
            prev_pos = y
            
            instance.progress = p > 1 and 1 or p > 0 and p or 0
        end,
    }
    
    grip   = NineSlice{
        reactive = true,
        on_button_down = function(self,...)
            
            pixels_to_progress_ratio = 1/(track[direction_dim]-grip[direction_dim])
            
            --position_grabbed_from = ({...})[direction_num]
            prev_pos = ({...})[direction_num]
            
            --this function is called by screen_on_motion
            g_dragging = drag[direction]
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
	override_property(instance,"grip",
		function(oldf) return   grip     end,
		function(oldf,self,v) 
            if type(v) ~= "table" then
                error("Expected table. Received "..type(v),2)
            end
            grip:set(v)
        end
    )
    local progress = 0
	override_property(instance,"progress",
		function(oldf) return   progress     end,
		function(oldf,self,v) 
            
            if type(v) ~= "number" then
                error("Expected number. Received ".. type(v),2)
            elseif v > 1 or v < 0 then 
                error("Must be between [0,1]. Received ".. v,2)
            end
            grip[direction_pos] = v*(track[direction_dim]-grip[direction_dim]) +track[direction_pos]
            
            progress = v 
        end
    )
	----------------------------------------------------------------------------
    track  = NineSlice{
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
            
            drag[direction](...)
        end,
    }
	override_property(instance,"track",
		function(oldf) return   track     end,
		function(oldf,self,v) 
            if type(v) ~= "table" then
                error("Expected table. Received "..type(v),2)
            end
            track:set(v)
        end
    )
	instance:subscribe_to( "enabled",
		function()
            grip.enabled  = instance.enabled
            track.enabled = instance.enabled
        end
	)
    ----------------------------------------------------------------------------
	override_property(instance,"direction",
		function(oldf) return   direction     end,
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
        end
    )
    
    instance:subscribe_to(
        {"direction","track","grip"},
        function()
            grip.position = track.position
        end
    )
    
	----------------------------------------------------------------------------
	
	override_property(instance,"attributes",
        function(oldf,self)
            local t = oldf(self)
            
            t.direction = self.direction
            t.progress  = self.progress
            t.grip  = {w = grip.w, h = grip.h, }
            t.track = {w = track.w,h = track.h,}
            
            t.type = "Slider"
            
            return t
        end
    )
    
    
	----------------------------------------------------------------------------
    instance:add(track,grip)
    instance:set(parameters)
    
    return instance
end