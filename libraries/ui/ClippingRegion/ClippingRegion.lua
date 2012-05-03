CLIPPINGREGION = true

local default_parameters = {w = 400, h = 400,virtual_w=1000,virtual_h=1000,clip_to_size=true}

ClippingRegion = function(parameters)
    
	-- input is either nil or a table
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = is_table_or_nil("ClippingRegion",parameters)
	
	-- function is in __UTILITIES/TypeChecking_and_TableTraversal.lua
	parameters = recursive_overwrite(parameters,default_parameters) 
	----------------------------------------------------------------------------
	--The ClippingRegion Object inherits from Widget
	
	local instance = Widget( parameters )
    local bg       = Rectangle{ name="Background"}
    local border   = Rectangle{ name="Border",color = "00000000"}
    local contents = Group{ name="Contents"}--,w=instance.virtual_w,h=instance.virtual_h}
	
    instance:add(bg,contents,border)
    
    ----------------------------------------------------------------------------
    
    local x_offset = 0
    local y_offset = 0
    
	override_property(instance,"virtual_w",
		function(oldf) return contents.w   end,
		function(oldf,self,v) 
            
            contents.w = v < instance.w  and instance.w or v 
            
        end
	)
	override_property(instance,"virtual_h",
		function(oldf) return contents.h     end,
		function(oldf,self,v) 
            
            contents.h = v < instance.h  and instance.h or v 
            
        end
	)
	override_property(instance,"virtual_x",
		function(oldf) return -contents.x - x_offset     end,
		function(oldf,self,v)  
            
            contents.x = bound_to(-(contents.w - instance.w),x_offset - v,0)
            
        end    
	)
	override_property(instance,"virtual_y",
		function(oldf) return -contents.y - y_offset     end,
		function(oldf,self,v)  
            
            contents.y = bound_to(-(contents.h - instance.h),y_offset - v,0)
            
        end 
	)
	override_property(instance,"sets_x_to",
		function(oldf) return x_offset     end,
		function(oldf,self,v) x_offset = v end
	)
	override_property(instance,"sets_y_to",
		function(oldf) return y_offset     end,
		function(oldf,self,v) y_offset = v end
	)
	override_function(instance,"add",
		function(oldf,self,...) contents:add(...) end
	)
    
	----------------------------------------------------------------------------
	
	instance:subscribe_to(
		{"h","w","width","height","size"},
		function()
			
			bg.size     = instance.size
			border.size = instance.size
            
            instance.virtual_w = instance.virtual_w
            instance.virtual_h = instance.virtual_h
            instance.virtual_x = instance.virtual_x
            instance.virtual_y = instance.virtual_y
            
            
		end
	)
    
	----------------------------------------------------------------------------
	
    local set_border_width = function() border.border_width = instance.style.border.width          end
    local set_border_color = function() border.border_color = instance.style.border.colors.default end
    local set_bg_color     = function() bg.color            = instance.style.fill_colors.default   end
    
    
	local function instance_on_style_changed()
		
		instance.style.fill_colors:on_changed(    instance, set_bg_color     )
		instance.style.border:on_changed(         instance, set_border_width )
		instance.style.border.colors:on_changed(  instance, set_border_color )
		
		set_border_width()
		set_border_color()
		set_bg_color()
        
	end
	
	instance:subscribe_to( "style", instance_on_style_changed )
	
	instance_on_style_changed()
	
	----------------------------------------------------------------------------
	
	instance:set(parameters)
	
	return instance
	
end